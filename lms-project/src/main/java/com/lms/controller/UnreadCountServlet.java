package com.lms.controller;

import com.lms.model.User;
import com.lms.service.MessageService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/api/chat/unread")
public class UnreadCountServlet extends HttpServlet {
    private final MessageService messageService = new MessageService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        try {
            int unreadCount = messageService.getUnreadMessageCount(currentUser.getId());
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"unread\": " + unreadCount + "}");
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
