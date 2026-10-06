package com.lms.service;

import com.lms.dao.AssignmentDAO;
import com.lms.dao.AssignmentSubmissionDAO;
import com.lms.dao.CourseDAO;
import com.lms.dao.EnrollmentDAO;
import com.lms.model.Assignment;
import com.lms.model.AssignmentSubmission;
import com.lms.model.Course;
import com.lms.model.FileData;
import com.lms.model.User;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

/**
 * Nghiệp vụ Bài tập:
 *  - Giảng viên (chủ khóa học) / admin: tạo, sửa, xóa bài tập, xem danh sách học viên đã nộp, tải bài nộp.
 *  - Học viên (đã đăng ký khóa học): xem bài tập, tải đề, nộp / nộp lại file trước hạn.
 */
public class AssignmentService {

    /** Dung lượng tối đa mỗi file: 10 MB (file được lưu trong DB nên cần giới hạn). */
    public static final long MAX_FILE_BYTES = 10L * 1024 * 1024;

    public static final Set<String> ALLOWED_EXTENSIONS = new HashSet<>(Arrays.asList(
            "pdf", "doc", "docx", "txt", "rtf", "odt",
            "xls", "xlsx", "csv", "ppt", "pptx",
            "zip", "rar", "7z", "png", "jpg", "jpeg"));

    private final AssignmentDAO assignmentDAO = new AssignmentDAO();
    private final AssignmentSubmissionDAO submissionDAO = new AssignmentSubmissionDAO();
    private final CourseDAO courseDAO = new CourseDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();

    // =========================================================================
    // PHÂN QUYỀN
    // =========================================================================

    /** Giảng viên chỉ được thao tác trên khóa của mình; admin được xem/quản lý tất cả. */
    private Course requireCourseOwner(int courseId, User user) {
        Course course = courseDAO.findById(courseId);
        if (course == null) {
            throw new IllegalArgumentException("Khóa học không tồn tại!");
        }
        boolean isAdmin = "admin".equals(user.getRole());
        if (!isAdmin && course.getInstructorId() != user.getId()) {
            throw new SecurityException("Bạn không có quyền quản lý bài tập của khóa học này!");
        }
        return course;
    }

    private Assignment requireAssignmentOwner(int assignmentId, User user) {
        Assignment a = assignmentDAO.findById(assignmentId);
        if (a == null) {
            throw new IllegalArgumentException("Bài tập không tồn tại!");
        }
        requireCourseOwner(a.getCourseId(), user);
        return a;
    }

    private Assignment requireAssignmentForStudent(int assignmentId, int studentId) {
        Assignment a = assignmentDAO.findById(assignmentId);
        if (a == null) {
            throw new IllegalArgumentException("Bài tập không tồn tại!");
        }
        if (!enrollmentDAO.isEnrolled(studentId, a.getCourseId())) {
            throw new SecurityException("Bạn cần đăng ký khóa học này để xem bài tập!");
        }
        return a;
    }

    // =========================================================================
    // GIẢNG VIÊN
    // =========================================================================

    public Course getCourseForManage(int courseId, User user) {
        return requireCourseOwner(courseId, user);
    }

    public List<Assignment> listForInstructor(int courseId, User user) {
        requireCourseOwner(courseId, user);
        return assignmentDAO.findByCourseForInstructor(courseId);
    }

    public Assignment getForInstructor(int assignmentId, User user) {
        return requireAssignmentOwner(assignmentId, user);
    }

    /**
     * Tạo bài tập. description và file đính kèm đều TÙY CHỌN (có thể để trống hoàn toàn).
     * fileBytes == null (hoặc rỗng) nghĩa là không đính kèm file.
     */
    public int create(int courseId, Integer sectionId, User user, String title, String description, LocalDateTime dueAt,
                      String fileName, byte[] fileBytes) {
        requireCourseOwner(courseId, user);

        Assignment a = new Assignment();
        a.setCourseId(courseId);
        a.setSectionId(sectionId);
        a.setTitle(validateTitle(title));
        a.setDescription(cleanDescription(description));
        if (dueAt != null && !dueAt.isAfter(LocalDateTime.now())) {
            throw new IllegalArgumentException("Hạn nộp phải sau thời điểm hiện tại!");
        }
        a.setDueAt(dueAt);

        byte[] data = null;
        if (fileBytes != null && fileBytes.length > 0) {
            String safeName = validateFile(fileName, fileBytes.length);
            a.setAttachName(safeName);
            a.setAttachType(mimeOf(safeName));
            data = fileBytes;
        }

        int id = assignmentDAO.insert(a, data);
        if (id < 0) {
            throw new RuntimeException("Có lỗi xảy ra khi tạo bài tập. Vui lòng thử lại!");
        }
        return id;
    }

    /**
     * Sửa bài tập. attachMode: "keep" | "remove" | "replace".
     * "replace" bắt buộc phải có file mới.
     */
    public void update(int assignmentId, Integer sectionId, User user, String title, String description, LocalDateTime dueAt,
                       String attachMode, String fileName, byte[] fileBytes) {
        Assignment existing = requireAssignmentOwner(assignmentId, user);

        existing.setSectionId(sectionId);
        existing.setTitle(validateTitle(title));
        existing.setDescription(cleanDescription(description));

        boolean dueChanged = dueAt != null && !dueAt.equals(existing.getDueAt());
        if (dueChanged && !dueAt.isAfter(LocalDateTime.now())) {
            throw new IllegalArgumentException("Hạn nộp mới phải sau thời điểm hiện tại!");
        }
        existing.setDueAt(dueAt);

        boolean hasNewFile = fileBytes != null && fileBytes.length > 0;
        String mode = "keep";
        byte[] data = null;
        if (hasNewFile) {
            String safeName = validateFile(fileName, fileBytes.length);
            existing.setAttachName(safeName);
            existing.setAttachType(mimeOf(safeName));
            data = fileBytes;
            mode = "replace";
        } else if ("remove".equals(attachMode)) {
            mode = "remove";
        }

        if (!assignmentDAO.update(existing, mode, data)) {
            throw new RuntimeException("Có lỗi xảy ra khi cập nhật bài tập. Vui lòng thử lại!");
        }
    }

    public void delete(int assignmentId, User user) {
        requireAssignmentOwner(assignmentId, user);
        if (!assignmentDAO.delete(assignmentId)) {
            throw new RuntimeException("Có lỗi xảy ra khi xóa bài tập. Vui lòng thử lại!");
        }
    }

    /** Danh sách học viên đã nộp bài của 1 bài tập. */
    public List<AssignmentSubmission> listSubmissions(int assignmentId, User user) {
        requireAssignmentOwner(assignmentId, user);
        return submissionDAO.findByAssignment(assignmentId);
    }

    public FileData getAttachmentForInstructor(int assignmentId, User user) {
        requireAssignmentOwner(assignmentId, user);
        return requireFile(assignmentDAO.getAttachment(assignmentId));
    }

    public Assignment getForPreview(int assignmentId) {
        Assignment a = assignmentDAO.findById(assignmentId);
        if (a == null) {
            throw new IllegalArgumentException("Bài tập không tồn tại!");
        }
        return a;
    }

    public FileData getAttachmentForPreview(int assignmentId) {
        return requireFile(assignmentDAO.getAttachment(assignmentId));
    }

    public FileData getSubmissionFileForInstructor(int submissionId, User user) {
        AssignmentSubmission s = submissionDAO.findById(submissionId);
        if (s == null) {
            throw new IllegalArgumentException("Bài nộp không tồn tại!");
        }
        requireAssignmentOwner(s.getAssignmentId(), user);
        return requireFile(submissionDAO.getFile(submissionId));
    }

    // =========================================================================
    // HỌC VIÊN
    // =========================================================================

    public Course getCourseForStudent(int courseId, int studentId) {
        Course course = courseDAO.findById(courseId);
        if (course == null) {
            throw new IllegalArgumentException("Khóa học không tồn tại!");
        }
        if (!enrollmentDAO.isEnrolled(studentId, courseId)) {
            throw new SecurityException("Bạn cần đăng ký khóa học này để xem bài tập!");
        }
        return course;
    }

    public List<Assignment> listForStudent(int courseId, int studentId) {
        getCourseForStudent(courseId, studentId);
        return assignmentDAO.findByCourseForStudent(courseId, studentId);
    }

    public Assignment getForStudent(int assignmentId, int studentId) {
        return requireAssignmentForStudent(assignmentId, studentId);
    }

    public AssignmentSubmission getMySubmission(int assignmentId, int studentId) {
        requireAssignmentForStudent(assignmentId, studentId);
        return submissionDAO.findByAssignmentAndStudent(assignmentId, studentId);
    }

    /** Nộp bài lần đầu hoặc nộp lại (ghi đè bài cũ) - chỉ được nộp trước hạn. */
    public void submit(int assignmentId, int studentId, String fileName, byte[] fileBytes, String note) {
        Assignment a = requireAssignmentForStudent(assignmentId, studentId);

        if (a.isOverdue()) {
            throw new IllegalStateException("Đã quá hạn nộp bài tập này!");
        }
        if (fileBytes == null || fileBytes.length == 0) {
            throw new IllegalArgumentException("Vui lòng chọn file bài làm để nộp!");
        }
        String safeName = validateFile(fileName, fileBytes.length);

        AssignmentSubmission s = new AssignmentSubmission();
        s.setAssignmentId(assignmentId);
        s.setStudentId(studentId);
        s.setFileName(safeName);
        s.setFileType(mimeOf(safeName));
        s.setNote(note == null || note.trim().isEmpty() ? null : note.trim());

        if (!submissionDAO.upsert(s, fileBytes)) {
            throw new RuntimeException("Có lỗi xảy ra khi nộp bài. Vui lòng thử lại!");
        }
    }

    public FileData getAttachmentForStudent(int assignmentId, int studentId) {
        requireAssignmentForStudent(assignmentId, studentId);
        return requireFile(assignmentDAO.getAttachment(assignmentId));
    }

    /** Học viên chỉ tải được bài nộp của chính mình. */
    public FileData getMySubmissionFile(int submissionId, int studentId) {
        AssignmentSubmission s = submissionDAO.findById(submissionId);
        if (s == null || s.getStudentId() != studentId) {
            throw new SecurityException("Bạn không có quyền tải bài nộp này!");
        }
        return requireFile(submissionDAO.getFile(submissionId));
    }

    // =========================================================================
    // TIỆN ÍCH
    // =========================================================================

    private FileData requireFile(FileData f) {
        if (f == null || f.getBytes() == null) {
            throw new IllegalArgumentException("Không tìm thấy file!");
        }
        return f;
    }

    private String validateTitle(String title) {
        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("Tiêu đề bài tập không được để trống!");
        }
        String t = title.trim();
        if (t.length() > 200) {
            throw new IllegalArgumentException("Tiêu đề bài tập tối đa 200 ký tự!");
        }
        return t;
    }

    private String cleanDescription(String description) {
        return (description == null || description.trim().isEmpty()) ? null : description.trim();
    }

    /** Kiểm tra đuôi file + dung lượng, trả về tên file đã làm sạch (bỏ đường dẫn, ký tự lạ). */
    private String validateFile(String fileName, long size) {
        if (size > MAX_FILE_BYTES) {
            throw new IllegalArgumentException("File quá lớn! Dung lượng tối đa là 10 MB.");
        }
        String safe = sanitizeFileName(fileName);
        String ext = extensionOf(safe);
        if (!ALLOWED_EXTENSIONS.contains(ext)) {
            throw new IllegalArgumentException(
                    "Định dạng file không được hỗ trợ! Chỉ chấp nhận: " + String.join(", ", new java.util.TreeSet<>(ALLOWED_EXTENSIONS)) + ".");
        }
        return safe;
    }

    private String sanitizeFileName(String fileName) {
        String name = fileName == null ? "" : fileName;
        int slash = Math.max(name.lastIndexOf('/'), name.lastIndexOf('\\'));
        if (slash >= 0) name = name.substring(slash + 1);
        name = name.replaceAll("[\\p{Cntrl}\"<>|:*?]", "_").trim();
        if (name.isEmpty()) {
            throw new IllegalArgumentException("Tên file không hợp lệ!");
        }
        if (name.length() > 200) {
            String ext = extensionOf(name);
            name = name.substring(0, 190) + (ext.isEmpty() ? "" : "." + ext);
        }
        return name;
    }

    private String extensionOf(String fileName) {
        int dot = fileName.lastIndexOf('.');
        return dot < 0 ? "" : fileName.substring(dot + 1).toLowerCase(Locale.ROOT);
    }

    /** MIME suy ra từ đuôi file (không tin Content-Type do client gửi lên). */
    private String mimeOf(String fileName) {
        switch (extensionOf(fileName)) {
            case "pdf":  return "application/pdf";
            case "doc":  return "application/msword";
            case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            case "txt":  return "text/plain; charset=UTF-8";
            case "rtf":  return "application/rtf";
            case "odt":  return "application/vnd.oasis.opendocument.text";
            case "xls":  return "application/vnd.ms-excel";
            case "xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            case "csv":  return "text/csv; charset=UTF-8";
            case "ppt":  return "application/vnd.ms-powerpoint";
            case "pptx": return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
            case "zip":  return "application/zip";
            case "rar":  return "application/vnd.rar";
            case "7z":   return "application/x-7z-compressed";
            case "png":  return "image/png";
            case "jpg":
            case "jpeg": return "image/jpeg";
            default:     return "application/octet-stream";
        }
    }
}
