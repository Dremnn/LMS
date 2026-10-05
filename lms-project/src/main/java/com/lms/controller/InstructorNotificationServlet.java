package com.lms.controller;

import com.lms.dao.CourseDAO;
import com.lms.dao.EnrollmentDAO;
import com.lms.dao.NotificationDAO;
import com.lms.dao.UserDAO;
import com.lms.model.Course;
import com.lms.model.Notification;
import com.lms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/instructor/notifications/send")
public class InstructorNotificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private EnrollmentDAO enrollmentDAO;
    private UserDAO userDAO;
    private NotificationDAO notificationDAO;
    private CourseDAO courseDAO;

    @Override
    public void init() throws ServletException {
        this.enrollmentDAO = new EnrollmentDAO();
        this.userDAO = new UserDAO();
        this.notificationDAO = new NotificationDAO();
        this.courseDAO = new CourseDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || (!"instructor".equals(currentUser.getRole()) && !"admin".equals(currentUser.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Tải danh sách khóa học của giảng viên để cho phép chọn gửi thông báo theo từng khóa học
        List<Course> courses = courseDAO.findByInstructor(currentUser.getId());
        request.setAttribute("instructorCourses", courses);

        request.getRequestDispatcher("/WEB-INF/views/instructor/send-notification.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || (!"instructor".equals(currentUser.getRole()) && !"admin".equals(currentUser.getRole()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String target = request.getParameter("target");
        String title = request.getParameter("title");
        String message = request.getParameter("message");

        // Giữ lại danh sách khóa học khi load lại form
        List<Course> courses = courseDAO.findByInstructor(currentUser.getId());
        request.setAttribute("instructorCourses", courses);

        if (title == null || title.trim().isEmpty() || message == null || message.trim().isEmpty()) {
            request.setAttribute("error", "Tiêu đề và nội dung thông báo không được để trống!");
            request.setAttribute("title", title);
            request.setAttribute("message", message);
            request.getRequestDispatcher("/WEB-INF/views/instructor/send-notification.jsp").forward(request, response);
            return;
        }

        List<Integer> studentIds;
        if ("all_students".equals(target) && "admin".equals(currentUser.getRole())) {
            studentIds = userDAO.getAllStudentIds();
        } else if (target != null && target.startsWith("course_")) {
            try {
                int courseId = Integer.parseInt(target.substring("course_".length()));
                studentIds = enrollmentDAO.findStudentIdsByCourseOrSection(courseId);
            } catch (NumberFormatException e) {
                studentIds = enrollmentDAO.findStudentIdsByInstructor(currentUser.getId());
            }
        } else {
            studentIds = enrollmentDAO.findStudentIdsByInstructor(currentUser.getId());
        }

        if (studentIds == null || studentIds.isEmpty()) {
            request.setAttribute("error", "Không tìm thấy học viên nào trong đối tượng đã chọn để gửi thông báo!");
            request.setAttribute("title", title);
            request.setAttribute("message", message);
            request.getRequestDispatcher("/WEB-INF/views/instructor/send-notification.jsp").forward(request, response);
            return;
        }

        // Loại bỏ trùng lặp ID học viên nếu họ học nhiều khóa
        Set<Integer> uniqueStudentIds = new LinkedHashSet<>(studentIds);
        int count = 0;
        for (Integer sId : uniqueStudentIds) {
            Notification n = new Notification(sId, "instructor_announcement", title.trim(), message.trim(), null);
            if (notificationDAO.save(n)) {
                count++;
            }
        }

        request.setAttribute("success", "Đã gửi thông báo thành công tới " + count + " học viên!");
        request.getRequestDispatcher("/WEB-INF/views/instructor/send-notification.jsp").forward(request, response);
    }
}
