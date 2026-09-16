package com.lms.service;

import com.lms.dao.CourseDAO;
import com.lms.dao.EnrollmentDAO;
import com.lms.dao.LessonProgressDAO;
import com.lms.dao.UserDAO;
import com.lms.model.Course;
import com.lms.model.Enrollment;
import com.lms.model.LessonProgress;
import com.lms.model.User;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

public class EnrollmentService {

    // Thời hạn tối đa (phút) kể từ lúc đăng ký để Student còn được phép hủy + hoàn tiền
    private static final long REFUND_WINDOW_MINUTES = 30;

    private final EnrollmentDAO enrollmentDAO;
    private final LessonProgressDAO lessonProgressDAO;
    private final CourseDAO courseDAO;
    private final UserDAO userDAO;
    private final WalletService walletService;

    public EnrollmentService() {
        this.enrollmentDAO = new EnrollmentDAO();
        this.lessonProgressDAO = new LessonProgressDAO();
        this.courseDAO = new CourseDAO();
        this.userDAO = new UserDAO();
        this.walletService = new WalletService();
    }

    // =========================================================================
    // 1. STUDENT: ĐĂNG KÝ (GHI DANH) 1 KHÓA HỌC
    // Nếu khóa học có phí (price > 0) -> kiểm tra & trừ tiền trong ví trước.
    // Nếu số dư không đủ -> ném IllegalStateException, KHÔNG tạo enrollment.
    // =========================================================================
    public Enrollment enroll(int studentId, int courseId) {

        User student = userDAO.findById(studentId);
        if (student == null) {
            throw new IllegalArgumentException("Tài khoản không tồn tại!");
        }
        // Chỉ role "student" mới được đăng ký khóa học - khóa chức năng này với instructor/admin
        if (!"student".equals(student.getRole())) {
            throw new IllegalStateException("Chỉ học viên (student) mới có thể đăng ký khóa học!");
        }

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

        BigDecimal price = course.getPrice();
        boolean isPaidCourse = price != null && price.compareTo(BigDecimal.ZERO) > 0;

        // Kiểm tra trước để báo lỗi rõ ràng, thân thiện (kèm số dư hiện tại/còn thiếu)
        if (isPaidCourse) {
            BigDecimal currentBalance = student.getBalance();
            if (currentBalance.compareTo(price) < 0) {
                BigDecimal missing = price.subtract(currentBalance);
                throw new IllegalStateException(String.format(
                        "Số dư trong ví không đủ để đăng ký khóa học này (cần %sđ, còn thiếu %sđ). " +
                        "Vui lòng nạp thêm tiền vào ví!",
                        price.toPlainString(), missing.toPlainString()));
            }
        }

        Enrollment enrollment = new Enrollment(studentId, courseId);
        boolean saved = enrollmentDAO.save(enrollment);
        if (!saved) {
            throw new RuntimeException("Có lỗi xảy ra khi đăng ký khóa học. Vui lòng thử lại!");
        }

        // Trừ tiền Student + cộng tiền Instructor SAU KHI enrollment đã được tạo thành công.
        // Nếu vì lý do nào đó (race-condition hiếm gặp) số dư không còn đủ nữa thì hoàn tác
        // (xóa enrollment vừa tạo).
        if (isPaidCourse) {
            try {
                walletService.payForCourse(studentId, course.getInstructorId(), courseId, price);
            } catch (IllegalStateException e) {
                enrollmentDAO.delete(studentId, courseId);
                throw e;
            }
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
    // 6. Hủy đăng ký khóa học (Unenroll) - KHÔNG hoàn tiền (dùng cho khóa học miễn phí,
    // hoặc khóa học có phí nhưng đã quá thời hạn hoàn tiền)
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

    // =========================================================================
    // 7. Kiểm tra 1 enrollment còn trong thời hạn được hoàn tiền hay không
    // Điều kiện: khóa học CÓ PHÍ và thời gian đăng ký chưa quá REFUND_WINDOW_MINUTES
    // =========================================================================
    public boolean isRefundEligible(Enrollment enrollment, Course course) {
        if (enrollment == null || enrollment.getEnrolledAt() == null || course == null) {
            return false;
        }
        BigDecimal price = course.getPrice();
        boolean isPaidCourse = price != null && price.compareTo(BigDecimal.ZERO) > 0;
        if (!isPaidCourse) {
            return false;
        }
        long minutesSinceEnroll = Duration.between(enrollment.getEnrolledAt(), LocalDateTime.now()).toMinutes();
        return minutesSinceEnroll < REFUND_WINDOW_MINUTES;
    }

    // =========================================================================
    // 8. HỦY ĐĂNG KÝ + HOÀN TIỀN (Refund)
    // Điều kiện: khóa học có phí VÀ đăng ký chưa quá 30 phút.
    // Hoàn tiền cho Student, đồng thời trừ lại đúng số tiền đó khỏi Instructor.
    // Nếu khóa học miễn phí -> chỉ hủy đăng ký bình thường (không có gì để hoàn).
    // =========================================================================
    public void refundEnrollment(int studentId, int courseId) {
        Enrollment enrollment = enrollmentDAO.findByStudentAndCourse(studentId, courseId);
        if (enrollment == null) {
            throw new IllegalStateException("Bạn chưa đăng ký khóa học này!");
        }

        Course course = courseDAO.findById(courseId);
        if (course == null) {
            throw new IllegalArgumentException("Khóa học không tồn tại!");
        }

        BigDecimal price = course.getPrice();
        boolean isPaidCourse = price != null && price.compareTo(BigDecimal.ZERO) > 0;

        if (!isPaidCourse) {
            // Khóa học miễn phí - không có tiền để hoàn, chỉ cần hủy đăng ký bình thường
            unenroll(studentId, courseId);
            return;
        }

        long minutesSinceEnroll = Duration.between(enrollment.getEnrolledAt(), LocalDateTime.now()).toMinutes();
        if (minutesSinceEnroll >= REFUND_WINDOW_MINUTES) {
            throw new IllegalStateException(
                    "Đã quá 30 phút kể từ lúc đăng ký nên khóa học có phí này không còn được hoàn tiền. " +
                    "Bạn vẫn có thể hủy đăng ký (không hoàn tiền) bằng nút \"Hsủy khóa học\".");
        }

        // Hoàn tiền cho Student + trừ lại tiền đã cộng cho Instructor (cùng 1 transaction)
        walletService.refundCourse(studentId, course.getInstructorId(), courseId, price);

        boolean deleted = enrollmentDAO.delete(studentId, courseId);
        if (!deleted) {
            throw new RuntimeException(
                    "Đã hoàn tiền thành công nhưng có lỗi khi xóa đăng ký. Vui lòng liên hệ quản trị viên!");
        }
    }
}