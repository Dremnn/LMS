package com.lms.controller;

import com.lms.dao.NotificationDAO;
import com.lms.model.Notification;
import com.lms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/notifications/recent")
public class RecentNotificationsServlet extends HttpServlet {
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        List<Notification> recent = notificationDAO.findByUser(currentUser.getId(), 5);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < recent.size(); i++) {
            Notification n = recent.get(i);
            String title = n.getTitle() != null ? n.getTitle().replace("\"", "\\\"").replace("\n", " ") : "";
            String message = n.getMessage() != null ? n.getMessage().replace("\"", "\\\"").replace("\n", " ") : "";
            String url = n.getRelatedUrl() != null ? n.getRelatedUrl().replace("\"", "\\\"") : "";
            String time = n.getCreatedAt() != null ? (n.getCreatedAt().toString() + "Z") : "";
            
            json.append("{")
                .append("\"id\":").append(n.getId()).append(",")
                .append("\"type\":\"").append(n.getType() != null ? n.getType() : "").append("\",")
                .append("\"title\":\"").append(title).append("\",")
                .append("\"message\":\"").append(message).append("\",")
                .append("\"relatedUrl\":\"").append(url).append("\",")
                .append("\"isRead\":").append(n.isRead()).append(",")
                .append("\"createdAt\":\"").append(time).append("\"")
                .append("}");
                
            if (i < recent.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        
        out.write(json.toString());
    }
}

