package com.lms.service;

import com.lms.dao.CourseDAO;
import com.lms.dao.EnrollmentDAO;
import com.lms.dao.LessonProgressDAO;
import com.lms.model.Course;
import com.lms.model.Enrollment;
import com.lms.model.LessonProgress;

import java.util.List;

public class EnrollmentService {

    private final EnrollmentDAO enrollmentDAO;
    private final LessonProgressDAO lessonProgressDAO;
    private final CourseDAO courseDAO;

    public EnrollmentService() {
        this.enrollmentDAO = new EnrollmentDAO();
        this.lessonProgressDAO = new LessonProgressDAO();
        this.courseDAO = new CourseDAO();
    }

    // =========================================================================
    // 1. STUDENT: ĐĂNG KÝ (GHI DANH) 1 KHÓA HỌC
    // =========================================================================
    public Enrollment enroll(int studentId, int courseId) {

        Course course = courseDAO.findById(courseId);
        if (course == null) {
            throw new IllegalArgumentException("Khóa học không tồn tại!");
        }
        if (!"published".equals(course.getStatus())) {
            throw new IllegalStateException("Khóa học này chưa được công khai, không thể đăng ký!");
        }

        if (enrollmentDAO.isEnrolled(studentId, courseId)) {
            throw new IllegalStateException("Bạn đã đăng ký khóa học này rồi!");
        }

        Enrollment enrollment = new Enrollment(studentId, courseId);
        boolean saved = enrollmentDAO.save(enrollment);
        if (!saved) {
            throw new RuntimeException("Có lỗi xảy ra khi đăng ký khóa học. Vui lòng thử lại!");
        }

        // Lưu ý: total_students của course được Trigger trg_enrollment_update_total_students
        // tự động cập nhật trong SQL Server ngay khi INSERT enrollment - không cần code thêm ở đây

        return enrollment;
    }

    // =========================================================================
    // 2. STUDENT: LẤY DANH SÁCH KHÓA HỌC ĐÃ THAM GIA (trang "Khóa học của tôi")
    // =========================================================================
    public List<Enrollment> getMyEnrollments(int studentId) {
        return enrollmentDAO.findByStudent(studentId);
    }

    // =========================================================================
    // 3. KIỂM TRA QUYỀN XEM BÀI HỌC: Student phải đã enroll khóa học chứa bài học đó
    // Trả về Enrollment nếu hợp lệ, ném lỗi nếu chưa đăng ký
    // =========================================================================
    public Enrollment getEnrollmentOrThrow(int studentId, int courseId) {
        Enrollment enrollment = enrollmentDAO.findByStudentAndCourse(studentId, courseId);
        if (enrollment == null) {
            throw new IllegalStateException("Bạn cần đăng ký khóa học này trước khi xem nội dung!");
        }
        return enrollment;
    }

    // =========================================================================
    // 4. LẤY TOÀN BỘ TIẾN ĐỘ BÀI HỌC CỦA 1 ENROLLMENT
    // Dùng để hiển thị bài nào đã tick "hoàn thành" trên giao diện
    // =========================================================================
    public List<LessonProgress> getLessonProgressList(int enrollmentId) {
        return lessonProgressDAO.findByEnrollment(enrollmentId);
    }

    // =========================================================================
    // 5. ĐÁNH DẤU HOÀN THÀNH / BỎ ĐÁNH DẤU 1 BÀI HỌC
    // Đây là hàm quan trọng nhất module này:
    // - Nếu bài học CHƯA có bản ghi progress -> INSERT mới
    // - Nếu ĐÃ có bản ghi -> UPDATE lại trạng thái
    // - Sau khi INSERT/UPDATE, Trigger trg_lesson_progress_update trong SQL Server
    //   sẽ tự động tính lại enrollments.progress_percent - ta chỉ cần đọc lại giá trị mới
    // =========================================================================
    public Enrollment toggleLessonCompletion(int studentId, int courseId, int lessonId, boolean completed) {

        // Bước 1: Xác nhận Student có quyền (đã enroll khóa học chứa bài học này)
        Enrollment enrollment = getEnrollmentOrThrow(studentId, courseId);

        // Bước 2: Tìm xem đã có bản ghi lesson_progress cho bài học này chưa
        LessonProgress existing = lessonProgressDAO.findByEnrollmentAndLesson(enrollment.getId(), lessonId);

        if (existing == null) {
            // Chưa có -> tạo mới
            LessonProgress newProgress = new LessonProgress(enrollment.getId(), lessonId, completed);
            boolean inserted = lessonProgressDAO.insert(newProgress);
            if (!inserted) {
                throw new RuntimeException("Có lỗi xảy ra khi cập nhật tiến độ học!");
            }
        } else {
            // Đã có -> cập nhật lại trạng thái
            existing.setCompleted(completed);
            boolean updated = lessonProgressDAO.update(existing);
            if (!updated) {
                throw new RuntimeException("Có lỗi xảy ra khi cập nhật tiến độ học!");
            }
        }

        // Bước 3: Đọc lại Enrollment từ DB - lúc này progress_percent đã được
        // Trigger trong SQL Server tự động tính lại, ta lấy giá trị MỚI NHẤT
        // (không dùng object "enrollment" cũ trong bộ nhớ vì nó đã lỗi thời)
        return enrollmentDAO.findById(enrollment.getId());
    }

    // Kiểm tra Student đã enroll khóa học chưa - trả về null nếu chưa (không throw exception)
    // Dùng cho các trang hiển thị có/không có tùy trạng thái đăng ký (VD: course-detail.jsp)
    public Enrollment getEnrollmentIfExists(int studentId, int courseId) {
        return enrollmentDAO.findByStudentAndCourse(studentId, courseId);
    }

    // =========================================================================
    // 6. Hủy đăng ký khóa học (Unenroll)
    // =========================================================================
    public void unenroll(int studentId, int courseId) {
        if (!enrollmentDAO.isEnrolled(studentId, courseId)) {
            throw new IllegalStateException("Bạn chưa đăng ký khóa học này!");
        }

        boolean deleted = enrollmentDAO.delete(studentId, courseId);
        if (!deleted) {
            throw new RuntimeException("Có lỗi xảy ra khi hủy khóa học. Vui lòng thử lại!");
        }
    }
}