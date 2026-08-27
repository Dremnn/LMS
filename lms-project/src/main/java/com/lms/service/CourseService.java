package com.lms.service;

import com.lms.dao.CourseDAO;
import com.lms.dao.LessonDAO;
import com.lms.dao.SectionDAO;
import com.lms.model.Course;
import com.lms.model.Lesson;
import com.lms.model.Section;

import java.math.BigDecimal;
import java.util.List;

public class CourseService {

    private final CourseDAO courseDAO;
    private final SectionDAO sectionDAO;
    private final LessonDAO lessonDAO;

    public CourseService() {
        this.courseDAO = new CourseDAO();
        this.sectionDAO = new SectionDAO();
        this.lessonDAO = new LessonDAO();
    }

    // =========================================================================
    // 1. TÌM KIẾM KHÓA HỌC (cho Student - chỉ khóa học đã published)
    // =========================================================================
    public List<Course> searchCourses(String keyword, Integer categoryId, String sortBy) {
        return courseDAO.search(keyword, categoryId, sortBy);
    }

    // =========================================================================
    // 2. XEM CHI TIẾT KHÓA HỌC (kèm danh sách Section + Lesson lồng nhau)
    // =========================================================================
    public Course getCourseDetail(int courseId) {
        Course course = courseDAO.findById(courseId);
        if (course == null) {
            throw new IllegalArgumentException("Khóa học không tồn tại!");
        }

        List<Section> sections = sectionDAO.findByCourseId(courseId);
        for (Section section : sections) {
            List<Lesson> lessons = lessonDAO.findBySectionId(section.getId());
            section.setLessons(lessons);
        }

        // Gán tạm vào course thông qua 1 danh sách section đã có lesson
        // (Course model hiện không có field "sections" - xem lưu ý bên dưới)
        course.setSectionsCache(sections);

        return course;
    }

    // =========================================================================
    // 3. INSTRUCTOR: LẤY DANH SÁCH KHÓA HỌC CỦA CHÍNH MÌNH
    // =========================================================================
    public List<Course> getMyCoursesAsInstructor(int instructorId) {
        return courseDAO.findByInstructor(instructorId);
    }

    // =========================================================================
    // 4. INSTRUCTOR: TẠO KHÓA HỌC MỚI
    // =========================================================================
    public Course createCourse(int instructorId, String title, String description,
                                Integer categoryId, BigDecimal price) {

        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên khóa học không được để trống!");
        }
        if (title.trim().length() < 5) {
            throw new IllegalArgumentException("Tên khóa học phải có ít nhất 5 ký tự!");
        }
        if (price != null && price.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Giá khóa học không được là số âm!");
        }

        Course course = new Course(instructorId, categoryId, title.trim(),
                description != null ? description.trim() : null,
                price != null ? price : BigDecimal.ZERO);

        boolean saved = courseDAO.save(course);
        if (!saved) {
            throw new RuntimeException("Có lỗi xảy ra khi tạo khóa học. Vui lòng thử lại!");
        }
        return course;
    }

    // =========================================================================
    // 5. INSTRUCTOR: CẬP NHẬT THÔNG TIN KHÓA HỌC
    // =========================================================================
    public void updateCourse(int courseId, int currentInstructorId, String title,
                              String description, Integer categoryId, BigDecimal price) {

        Course course = getCourseAndVerifyOwnership(courseId, currentInstructorId);

        // Chỉ cho phép sửa khi khóa học đang ở trạng thái draft hoặc bị từ chối
        // (không cho sửa khi đang pending chờ duyệt hoặc đã published - tránh Admin duyệt nhầm nội dung đã đổi)
        if (!"draft".equals(course.getStatus()) && !"rejected".equals(course.getStatus())) {
            throw new IllegalStateException(
                "Không thể chỉnh sửa khóa học đang ở trạng thái '" + course.getStatus() + "'!");
        }

        if (title == null || title.trim().isEmpty() || title.trim().length() < 5) {
            throw new IllegalArgumentException("Tên khóa học phải có ít nhất 5 ký tự!");
        }
        if (price != null && price.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Giá khóa học không được là số âm!");
        }

        course.setTitle(title.trim());
        course.setDescription(description != null ? description.trim() : null);
        course.setCategoryId(categoryId);
        course.setPrice(price != null ? price : BigDecimal.ZERO);

        boolean updated = courseDAO.update(course);
        if (!updated) {
            throw new RuntimeException("Có lỗi xảy ra khi cập nhật khóa học!");
        }
    }

    // =========================================================================
    // 6. INSTRUCTOR: GỬI KHÓA HỌC CHO ADMIN DUYỆT (draft -> pending)
    // =========================================================================
    public void submitForApproval(int courseId, int currentInstructorId) {
        Course course = getCourseAndVerifyOwnership(courseId, currentInstructorId);

        if (!"draft".equals(course.getStatus()) && !"rejected".equals(course.getStatus())) {
            throw new IllegalStateException("Chỉ có thể gửi duyệt khóa học đang ở trạng thái nháp!");
        }

        // Điều kiện bắt buộc: khóa học phải có ít nhất 1 chương và 1 bài học mới được gửi duyệt
        List<Section> sections = sectionDAO.findByCourseId(courseId);
        if (sections.isEmpty()) {
            throw new IllegalStateException("Khóa học cần có ít nhất 1 chương trước khi gửi duyệt!");
        }

        boolean hasAtLeastOneLesson = false;
        for (Section section : sections) {
            if (!lessonDAO.findBySectionId(section.getId()).isEmpty()) {
                hasAtLeastOneLesson = true;
                break;
            }
        }
        if (!hasAtLeastOneLesson) {
            throw new IllegalStateException("Khóa học cần có ít nhất 1 bài học trước khi gửi duyệt!");
        }

        boolean updated = courseDAO.updateStatus(courseId, "pending", null);
        if (!updated) {
            throw new RuntimeException("Có lỗi xảy ra khi gửi duyệt khóa học!");
        }
    }

    // =========================================================================
    // 7. INSTRUCTOR: XÓA KHÓA HỌC (chỉ khi còn draft)
    // =========================================================================
    public void deleteCourse(int courseId, int currentInstructorId) {
        Course course = getCourseAndVerifyOwnership(courseId, currentInstructorId);

        if (!"draft".equals(course.getStatus())) {
            throw new IllegalStateException("Chỉ có thể xóa khóa học đang ở trạng thái nháp!");
        }

        boolean deleted = courseDAO.delete(courseId);
        if (!deleted) {
            throw new RuntimeException("Có lỗi xảy ra khi xóa khóa học!");
        }
    }

    // =========================================================================
    // 8. ADMIN: DUYỆT KHÓA HỌC (pending -> published)
    // =========================================================================
    public void approveCourse(int courseId) {
        Course course = courseDAO.findById(courseId);
        if (course == null) {
            throw new IllegalArgumentException("Khóa học không tồn tại!");
        }
        if (!"pending".equals(course.getStatus())) {
            throw new IllegalStateException("Chỉ có thể duyệt khóa học đang chờ phê duyệt!");
        }

        boolean updated = courseDAO.updateStatus(courseId, "published", null);
        if (!updated) {
            throw new RuntimeException("Có lỗi xảy ra khi duyệt khóa học!");
        }
    }

    // =========================================================================
    // 9. ADMIN: TỪ CHỐI KHÓA HỌC (pending -> rejected, kèm lý do)
    // =========================================================================
    public void rejectCourse(int courseId, String reason) {
        Course course = courseDAO.findById(courseId);
        if (course == null) {
            throw new IllegalArgumentException("Khóa học không tồn tại!");
        }
        if (!"pending".equals(course.getStatus())) {
            throw new IllegalStateException("Chỉ có thể từ chối khóa học đang chờ phê duyệt!");
        }
        if (reason == null || reason.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập lý do từ chối!");
        }

        boolean updated = courseDAO.updateStatus(courseId, "rejected", reason.trim());
        if (!updated) {
            throw new RuntimeException("Có lỗi xảy ra khi từ chối khóa học!");
        }
    }

    // =========================================================================
    // 10. QUẢN LÝ CHƯƠNG (Section)
    // =========================================================================
    public Section addSection(int courseId, int currentInstructorId, String title) {
        getCourseAndVerifyOwnership(courseId, currentInstructorId);

        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên chương không được để trống!");
        }

        int nextOrder = sectionDAO.getNextOrderIndex(courseId);
        Section section = new Section(courseId, title.trim(), nextOrder);

        boolean saved = sectionDAO.save(section);
        if (!saved) {
            throw new RuntimeException("Có lỗi xảy ra khi thêm chương!");
        }
        return section;
    }

    // =========================================================================
    // 11. QUẢN LÝ BÀI HỌC (Lesson)
    // =========================================================================
    public Lesson addLesson(int sectionId, int currentInstructorId, String title,
                             String videoUrl, String documentUrl, Integer durationMinutes) {

        Section section = sectionDAO.findById(sectionId);
        if (section == null) {
            throw new IllegalArgumentException("Chương học không tồn tại!");
        }

        // Kiểm tra quyền sở hữu: section này thuộc course nào, course đó có phải của instructor này không
        getCourseAndVerifyOwnership(section.getCourseId(), currentInstructorId);

        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên bài học không được để trống!");
        }
        if ((videoUrl == null || videoUrl.trim().isEmpty()) &&
            (documentUrl == null || documentUrl.trim().isEmpty())) {
            throw new IllegalArgumentException("Bài học cần có ít nhất 1 video hoặc 1 tài liệu!");
        }

        int nextOrder = lessonDAO.getNextOrderIndex(sectionId);
        Lesson lesson = new Lesson(sectionId, title.trim(), videoUrl, documentUrl,
                durationMinutes, nextOrder);

        boolean saved = lessonDAO.save(lesson);
        if (!saved) {
            throw new RuntimeException("Có lỗi xảy ra khi thêm bài học!");
        }
        return lesson;
    }

    // =========================================================================
    // Hàm phụ trợ: Lấy khóa học và kiểm tra đúng là của instructor đang thao tác
    // Đây là "chốt chặn bảo mật" quan trọng - ngăn Instructor A sửa khóa học của Instructor B
    // =========================================================================
    private Course getCourseAndVerifyOwnership(int courseId, int currentInstructorId) {
        Course course = courseDAO.findById(courseId);
        if (course == null) {
            throw new IllegalArgumentException("Khóa học không tồn tại!");
        }
        if (course.getInstructorId() != currentInstructorId) {
            throw new SecurityException("Bạn không có quyền thao tác trên khóa học này!");
        }
        return course;
    }
}