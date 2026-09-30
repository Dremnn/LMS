package com.lms.controller;

import com.lms.dao.EnrollmentDAO;
import com.lms.dao.NotificationDAO;
import com.lms.dao.UserDAO;
import com.lms.model.Notification;
import com.lms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/instructor/notifications/send")
public class InstructorNotificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private EnrollmentDAO enrollmentDAO;
    private UserDAO userDAO;
    private NotificationDAO notificationDAO;

    @Override
    public void init() throws ServletException {
        this.enrollmentDAO = new EnrollmentDAO();
        this.userDAO = new UserDAO();
        this.notificationDAO = new NotificationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/instructor/send-notification.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || (!"instructor".equals(currentUser.getRole()) && !"admin".equals(currentUser.getRole()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String target = request.getParameter("target"); // "my_students" or "all_students"
        String title = request.getParameter("title");
        String message = request.getParameter("message");

        if (title == null || title.trim().isEmpty() || message == null || message.trim().isEmpty()) {
            request.setAttribute("error", "Tiêu đề và nội dung không được để trống!");
            request.getRequestDispatcher("/WEB-INF/views/instructor/send-notification.jsp").forward(request, response);
            return;
        }

        List<Integer> studentIds;
        if ("all_students".equals(target)) {
            studentIds = userDAO.getAllStudentIds();
        } else {
            studentIds = enrollmentDAO.findStudentIdsByInstructor(currentUser.getId());
        }

        int count = 0;
        for (Integer sId : studentIds) {
            Notification n = new Notification(sId, "instructor_announcement", title, message, null);
            if (notificationDAO.save(n)) {
                count++;
            }
        }

        request.setAttribute("success", "Đã gửi thông báo thành công tới " + count + " học viên!");
        request.getRequestDispatcher("/WEB-INF/views/instructor/send-notification.jsp").forward(request, response);
    }
}
