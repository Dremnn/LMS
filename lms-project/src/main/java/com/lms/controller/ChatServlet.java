package com.lms.controller;

import com.lms.dao.UserDAO;
import com.lms.model.Message;
import com.lms.model.User;
import com.lms.service.MessageService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {
    private final MessageService messageService = new MessageService();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int currentUserId = currentUser.getId();

            // Load contact list
            List<Integer> contactIds = messageService.getMyContacts(currentUserId);
            List<User> contacts = new ArrayList<>();
            for (Integer cid : contactIds) {
                User contact = userDAO.findById(cid);
                if (contact != null) {
                    contacts.add(contact);
                }
            }
            request.setAttribute("contacts", contacts);

            java.util.Map<Integer, Integer> unreadCounts = messageService.getUnreadCountsPerContact(currentUserId);
            request.setAttribute("unreadCounts", unreadCounts);

            // Check if specific conversation is opened
            String targetIdParam = request.getParameter("targetId");
            if (targetIdParam != null && !targetIdParam.isEmpty()) {
                int targetId = Integer.parseInt(targetIdParam);
                User targetUser = userDAO.findById(targetId);
                request.setAttribute("targetUser", targetUser);

                // Mark messages as read
                messageService.markMessagesAsRead(targetId, currentUserId);

                // Get conversation history (last 50 messages)
                List<Message> conversation = messageService.getConversation(currentUserId, targetId, 50, 0);
                request.setAttribute("conversation", conversation);
            }

            request.getRequestDispatcher("/WEB-INF/views/student/chat.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi tải dữ liệu chat");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        try {
            if ("send".equals(action)) {
                int targetId = Integer.parseInt(request.getParameter("targetId"));
                String content = request.getParameter("content");

                // Anti-spam protection at the backend level (1 request per second)
                Long lastChatTime = (Long) request.getSession().getAttribute("lastChatTime");
                long now = System.currentTimeMillis();
                if (lastChatTime != null && (now - lastChatTime) < 1000) {
                    response.sendRedirect(request.getContextPath() + "/chat?targetId=" + targetId);
                    return;
                }
                request.getSession().setAttribute("lastChatTime", now);

                if (content != null && !content.trim().isEmpty()) {
                    messageService.sendMessage(currentUser.getId(), targetId, content.trim());
                }
                
                // Redirect back to conversation
                response.sendRedirect(request.getContextPath() + "/chat?targetId=" + targetId);
                return;
            } else if ("addContact".equals(action)) {
                String targetEmail = request.getParameter("email");
                User target = userDAO.findByEmail(targetEmail);
                if (target != null && target.getId() != currentUser.getId()) {
                    messageService.sendContactRequest(currentUser.getId(), target.getId());
                    messageService.acceptContactRequest(currentUser.getId(), target.getId());
                    request.getSession().setAttribute("chatSuccess", "Đã thêm " + target.getFullName() + " vào danh bạ!");
                    response.sendRedirect(request.getContextPath() + "/chat?targetId=" + target.getId());
                } else {
                    request.getSession().setAttribute("chatError", "Không tìm thấy người dùng với email này!");
                    response.sendRedirect(request.getContextPath() + "/chat");
                }
                return;
            } else if ("deleteMessage".equals(action)) {
                int messageId = Integer.parseInt(request.getParameter("messageId"));
                int targetId = Integer.parseInt(request.getParameter("targetId"));
                messageService.deleteMessage(messageId, currentUser.getId());
                response.sendRedirect(request.getContextPath() + "/chat?targetId=" + targetId);
                return;
            } else if ("deleteConversation".equals(action)) {
                int targetId = Integer.parseInt(request.getParameter("targetId"));
                messageService.deleteConversation(currentUser.getId(), targetId);
                response.sendRedirect(request.getContextPath() + "/chat");
                return;
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi thực hiện thao tác");
        }
    }
}

