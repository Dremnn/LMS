package com.lms.controller;

import com.lms.dao.CourseDAO;
import com.lms.dao.EnrollmentDAO;
import com.lms.dao.NotificationDAO;
import com.lms.model.Course;
import com.lms.model.Enrollment;
import com.lms.model.Notification;
import com.lms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

@WebServlet(urlPatterns = {
    "/instructor/courses/students",
    "/instructor/students/warn",
    "/instructor/students/remove-warning"
})
public class InstructorStudentServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null || (!"instructor".equals(currentUser.getRole()) && !"admin".equals(currentUser.getRole()))) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String courseIdStr = req.getParameter("courseId");
        if (courseIdStr == null || courseIdStr.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số courseId");
            return;
        }

        try {
            int courseId = Integer.parseInt(courseIdStr.trim());
            Course course = courseDAO.findById(courseId);

            if (course == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy khóa học");
                return;
            }

            if (course.getInstructorId() != currentUser.getId() && !"admin".equals(currentUser.getRole())) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền quản lý học viên khóa học này.");
                return;
            }

            List<Enrollment> enrollments = enrollmentDAO.findEnrollmentsByCourse(courseId);

            int totalStudents = enrollments.size();
            int completedCount = 0;
            int warnedCount = 0;
            BigDecimal sumProgress = BigDecimal.ZERO;

            for (Enrollment e : enrollments) {
                if ("completed".equalsIgnoreCase(e.getStatus()) || 
                    (e.getProgressPercent() != null && e.getProgressPercent().compareTo(BigDecimal.valueOf(100)) >= 0)) {
                    completedCount++;
                }
                if ("warning".equals(e.getWarningStatus()) || "appealed".equals(e.getWarningStatus())) {
                    warnedCount++;
                }
                if (e.getProgressPercent() != null) {
                    sumProgress = sumProgress.add(e.getProgressPercent());
                }
            }

            BigDecimal avgProgress = totalStudents > 0 
                ? sumProgress.divide(BigDecimal.valueOf(totalStudents), 1, RoundingMode.HALF_UP) 
                : BigDecimal.ZERO;

            req.setAttribute("course", course);
            req.setAttribute("enrollments", enrollments);
            req.setAttribute("totalStudents", totalStudents);
            req.setAttribute("completedCount", completedCount);
            req.setAttribute("warnedCount", warnedCount);
            req.setAttribute("avgProgress", avgProgress);

            req.getRequestDispatcher("/WEB-INF/views/instructor/student-list.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "CourseId không hợp lệ");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null || (!"instructor".equals(currentUser.getRole()) && !"admin".equals(currentUser.getRole()))) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String actionPath = uri.substring(contextPath.length());

        String courseIdStr = req.getParameter("courseId");
        String enrollmentIdStr = req.getParameter("enrollmentId");

        if (courseIdStr == null || enrollmentIdStr == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số yêu cầu");
            return;
        }

        try {
            int courseId = Integer.parseInt(courseIdStr);
            int enrollmentId = Integer.parseInt(enrollmentIdStr);

            Course course = courseDAO.findById(courseId);
            if (course == null || (course.getInstructorId() != currentUser.getId() && !"admin".equals(currentUser.getRole()))) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thao tác trên khóa học này");
                return;
            }

            Enrollment enrollment = enrollmentDAO.findById(enrollmentId);
            if (enrollment == null || enrollment.getCourseId() != courseId) {
                session.setAttribute("flashError", "Bản ghi ghi danh không hợp lệ.");
                resp.sendRedirect(contextPath + "/instructor/courses/students?courseId=" + courseId);
                return;
            }

            if ("/instructor/students/warn".equals(actionPath)) {
                String reason = req.getParameter("reason");
                if (reason == null || reason.trim().isEmpty()) {
                    session.setAttribute("flashError", "Vui lòng nhập lý do cảnh cáo học viên.");
                } else {
                    if (enrollmentDAO.warnStudent(enrollmentId, reason.trim())) {
                        session.setAttribute("flashSuccess", "Đã gửi cảnh cáo đến học viên thành công!");
                        
                        // Gửi thông báo đến học viên
                        try {
                            Notification notif = new Notification(
                                enrollment.getStudentId(),
                                "course_warning",
                                "⚠️ Cảnh cáo tiến độ từ giảng viên",
                                "Giảng viên " + currentUser.getFullName() + " đã gửi cảnh cáo trong khóa học '" + course.getTitle() + "': " + reason.trim(),
                                "/student/my-courses"
                            );
                            notificationDAO.save(notif);
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    } else {
                        session.setAttribute("flashError", "Lỗi khi lưu thông tin cảnh cáo vào hệ thống.");
                    }
                }
            } else if ("/instructor/students/remove-warning".equals(actionPath)) {
                if (enrollmentDAO.removeWarning(enrollmentId)) {
                    session.setAttribute("flashSuccess", "Đã gỡ bỏ cảnh cáo cho học viên!");

                    // Gửi thông báo thông báo gỡ bỏ cảnh cáo
                    try {
                        Notification notif = new Notification(
                            enrollment.getStudentId(),
                            "course_warning_cleared",
                            "✅ Cảnh cáo đã được gỡ bỏ",
                            "Giảng viên " + currentUser.getFullName() + " đã gỡ bỏ cảnh cáo trong khóa học '" + course.getTitle() + "'. Hãy tiếp tục cố gắng!",
                            "/student/my-courses"
                        );
                        notificationDAO.save(notif);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                } else {
                    session.setAttribute("flashError", "Lỗi khi gỡ bỏ cảnh cáo.");
                }
            }

            resp.sendRedirect(contextPath + "/instructor/courses/students?courseId=" + courseId);

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Dữ liệu ID không hợp lệ");
        }
    }
}
