package com.lms.controller;

import com.lms.model.Notification;
import com.lms.model.NotificationSettings;
import com.lms.model.User;
import com.lms.service.NotificationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {
    "/student/notifications",
    "/student/notifications/mark-all-read",
    "/student/notifications/settings"
})
public class NotificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private NotificationService notificationService;

    @Override
    public void init() throws ServletException {
        this.notificationService = new NotificationService();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        if ("/student/notifications".equals(path)) {
            List<Notification> notifications = notificationService.getRecentNotifications(currentUser.getId(), 50);

            Notification selected = null;
            String idStr = request.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                int id = Integer.parseInt(idStr);
                selected = notificationService.getNotificationAndVerifyOwnership(id, currentUser.getId());
                notificationService.markRead(id, currentUser.getId());
            } else if (!notifications.isEmpty()) {
                selected = notifications.get(0); // mặc định chọn cái mới nhất, giống ảnh mẫu
                notificationService.markRead(selected.getId(), currentUser.getId());
            }

            request.setAttribute("notifications", notifications);
            request.setAttribute("selected", selected);
            request.getRequestDispatcher("/WEB-INF/views/student/notifications.jsp").forward(request, response);

        } else if ("/student/notifications/settings".equals(path)) {
            NotificationSettings settings = notificationService.getSettings(currentUser.getId());
            request.setAttribute("settings", settings);
            request.getRequestDispatcher("/WEB-INF/views/student/notification-settings.jsp").forward(request, response);

        }else if ("/student/notifications/mark-all-read".equals(path)) {
            notificationService.markAllRead(currentUser.getId());
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":true}");
            
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        if ("/student/notifications/mark-all-read".equals(path)) {
            notificationService.markAllRead(currentUser.getId());
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":true}");

        } else if ("/student/notifications/settings".equals(path)) {
            boolean quizDeadline = "on".equals(request.getParameter("quizDeadlineEnabled"));
            boolean enrollment = "on".equals(request.getParameter("enrollmentEnabled"));
            boolean eventReminder = "on".equals(request.getParameter("eventReminderEnabled"));

            notificationService.saveSettings(currentUser.getId(), quizDeadline, enrollment, eventReminder);
            response.sendRedirect(request.getContextPath() + "/student/notifications/settings");

        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}
