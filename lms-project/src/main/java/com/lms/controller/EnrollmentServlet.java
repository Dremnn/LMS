package com.lms.controller;

import com.lms.model.Course;
import com.lms.model.Enrollment;
import com.lms.model.User;
import com.lms.service.EnrollmentService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * ============================================================================
 * CONTROLLER: EnrollmentServlet
 * ============================================================================
 * VAI TRÒ (STUDENT):
 * - Quản lý chức năng "Khóa học của tôi" và các nghiệp vụ ghi danh khóa học:
 *   + GET  /student/my-courses : Tải danh sách các khóa học học viên đã tham gia kèm tiến độ (% progress).
 *   + POST /enrollments/new    : Đăng ký (mua) khóa học mới (trừ tiền ví nếu khóa học có phí).
 *   + POST /enrollments/refund : Hủy đăng ký và hoàn lại tiền vào ví (nếu đăng ký chưa quá 30 phút).
 *   + POST /enrollments/cancel : Hủy đăng ký (không hoàn tiền, dùng cho khóa học miễn phí hoặc quá 30 phút).
 * 
 * VIEW TƯƠNG ỨNG:
 *   + /WEB-INF/views/student/my-courses.jsp (Giao diện hiển thị danh sách khóa học của học viên)
 * ============================================================================
 */
@WebServlet(urlPatterns = {"/enrollments/new", "/enrollments/cancel", "/enrollments/refund", "/student/my-courses", "/student/courses", "/student/courses/appeal", "/enrollments/appeal"})
public class EnrollmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Service xử lý logic đăng ký, tính tiến độ và hoàn tiền
    private EnrollmentService enrollmentService;

    /**
     * Khởi tạo tầng Service xử lý Enrollment
     */
    @Override
    public void init() throws ServletException {
        this.enrollmentService = new EnrollmentService();
    }

    /**
     * Hàm phụ trợ lấy thông tin User hiện tại từ Session
     */
    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (User) session.getAttribute("currentUser");
    }

    /**
     * ------------------------------------------------------------------------
     * HÀM XỬ LÝ: doGet (Trang "Khóa học của tôi")
     * ------------------------------------------------------------------------
     * Mục đích:
     * - Tiếp nhận yêu cầu xem danh sách khóa học của học viên tại /student/my-courses.
     * - Đọc các thông báo Flash Message (nếu có từ lần redirect trước).
     * - Gọi EnrollmentService.getMyEnrollments(studentId) để lấy các bản ghi Enrollment
     *   (kèm % tiến độ, số bài học, thumbnail khóa học).
     * - Forward sang /WEB-INF/views/student/my-courses.jsp để render.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        // 1. Đọc và dọn dẹp flash message trong session (lỗi hoặc thành công sau redirect)
        HttpSession session = request.getSession(false);
        if (session != null) {
            if (session.getAttribute("flashError") != null) {
                request.setAttribute("error", session.getAttribute("flashError"));
                session.removeAttribute("flashError");
            }
            if (session.getAttribute("flashSuccess") != null) {
                request.setAttribute("success", session.getAttribute("flashSuccess"));
                session.removeAttribute("flashSuccess");
            }
        }

        // 2. Lấy danh sách khóa học học viên đã đăng ký từ tầng Service
        // Mỗi Enrollment chứa thông tin: courseTitle, courseThumbnailUrl, totalLessons, progressPercent, status ('inprogress' | 'completed')
        request.setAttribute("enrollments", enrollmentService.getMyEnrollments(currentUser.getId()));
        
        // 3. Chuyển tiếp đến giao diện My Courses
        request.getRequestDispatcher("/WEB-INF/views/student/my-courses.jsp")
                .forward(request, response);
    }

    /**
     * ------------------------------------------------------------------------
     * HÀM XỬ LÝ: doPost (Đăng ký / Hủy / Hoàn tiền khóa học)
     * ------------------------------------------------------------------------
     * Mục đích:
     * - Phân biệt URL path:
     *   + /enrollments/cancel : Hủy ghi danh (unenroll không hoàn tiền)
     *   + /enrollments/refund : Hủy ghi danh kèm hoàn tiền ví (trong vòng 30 phút)
     *   + Mặc định (/enrollments/new): Đăng ký khóa học mới (trừ tiền ví student + cộng ví instructor)
     * - Dùng Session Flash Messages để mang thông báo sang trang /courses/detail sau khi redirect.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        String path = request.getServletPath();

        try {
            HttpSession session = request.getSession();

            if ("/student/courses/appeal".equals(path) || "/enrollments/appeal".equals(path)) {
                int enrollmentId = Integer.parseInt(request.getParameter("enrollmentId"));
                String appealMessage = request.getParameter("appealMessage");
                if (appealMessage == null || appealMessage.trim().isEmpty()) {
                    session.setAttribute("flashError", "Vui lòng nhập nội dung kháng cáo / phản hồi.");
                } else {
                    com.lms.dao.EnrollmentDAO enrollmentDAO = new com.lms.dao.EnrollmentDAO();
                    Enrollment en = enrollmentDAO.findById(enrollmentId);
                    if (en != null && en.getStudentId() == currentUser.getId()) {
                        enrollmentDAO.appealWarning(enrollmentId, appealMessage.trim());
                        session.setAttribute("flashSuccess", "Đã gửi kháng cáo / phản hồi đến giảng viên thành công!");

                        try {
                            com.lms.dao.CourseDAO courseDAO = new com.lms.dao.CourseDAO();
                            Course c = courseDAO.findById(en.getCourseId());
                            if (c != null) {
                                com.lms.model.Notification notif = new com.lms.model.Notification(
                                    c.getInstructorId(),
                                    "warning_appeal",
                                    "📩 Học viên gửi kháng cáo: " + currentUser.getFullName(),
                                    "Học viên " + currentUser.getFullName() + " đã gửi phản hồi cảnh cáo trong khóa học '" + c.getTitle() + "': " + appealMessage.trim(),
                                    "/instructor/courses/students?courseId=" + c.getId()
                                );
                                new com.lms.dao.NotificationDAO().save(notif);
                            }
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    } else {
                        session.setAttribute("flashError", "Không tìm thấy thông tin ghi danh hợp lệ.");
                    }
                }
                response.sendRedirect(request.getContextPath() + "/student/my-courses");
                return;
            }

            int courseId = Integer.parseInt(request.getParameter("courseId"));

            if ("/enrollments/cancel".equals(path)) {
                // 1. Hủy đăng ký bình thường (không hoàn tiền)
                enrollmentService.unenroll(currentUser.getId(), courseId);
                session.setAttribute("flashSuccess", "Đã hủy đăng ký khóa học thành công!");
                response.sendRedirect(request.getContextPath() + "/courses/detail?id=" + courseId);

            } else if ("/enrollments/refund".equals(path)) {
                // 2. Hủy đăng ký VÀ HOÀN TIỀN vào ví (nếu chưa quá 30 phút từ lúc đăng ký)
                enrollmentService.refundEnrollment(currentUser.getId(), courseId);
                
                // Cập nhật lại số dư mới của user trong Session
                com.lms.dao.UserDAO userDAO = new com.lms.dao.UserDAO();
                session.setAttribute("currentUser", userDAO.findById(currentUser.getId()));
                session.setAttribute("flashSuccess", "Đã hủy đăng ký và hoàn lại tiền vào ví thành công!");
                response.sendRedirect(request.getContextPath() + "/courses/detail?id=" + courseId);

            } else {
                // 3. Đăng ký khóa học mới (kiểm tra số dư ví nếu khóa học có phí, trừ ví học viên, tạo enrollment)
                enrollmentService.enroll(currentUser.getId(), courseId);
                
                // Cập nhật lại thông tin user trong Session (số dư ví sau khi thanh toán)
                com.lms.dao.UserDAO userDAO = new com.lms.dao.UserDAO();
                session.setAttribute("currentUser", userDAO.findById(currentUser.getId()));
                session.setAttribute("flashSuccess", "Đăng ký khóa học thành công! Bạn có thể bắt đầu học ngay.");
                
                // Đăng ký thành công -> chuyển về trang chi tiết khóa học đó để bắt đầu học
                response.sendRedirect(request.getContextPath() + "/courses/detail?id=" + courseId);
            }

        } catch (IllegalArgumentException | IllegalStateException e) {
            // Bắt các lỗi nghiệp vụ (ví dụ: Số dư ví không đủ, đã đăng ký rồi, quá hạn 30 phút hoàn tiền...)
            HttpSession session = request.getSession();
            session.setAttribute("flashError", e.getMessage());

            String courseId = request.getParameter("courseId");
            if (courseId != null && !courseId.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/courses/detail?id=" + courseId);
            } else {
                response.sendRedirect(request.getContextPath() + "/courses");
            }

        } catch (Exception e) {
            // Lỗi hệ thống bất ngờ
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("flashError", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại!");
            String courseId = request.getParameter("courseId");
            if (courseId != null && !courseId.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/courses/detail?id=" + courseId);
            } else {
                response.sendRedirect(request.getContextPath() + "/courses");
            }
        }
    }
}