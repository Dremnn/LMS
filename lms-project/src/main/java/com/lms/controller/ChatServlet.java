package com.lms.controller;

import com.lms.dao.UserDAO;
import com.lms.model.FileData;
import com.lms.model.Message;
import com.lms.model.User;
import com.lms.service.MessageService;
import com.lms.util.FileDownloadUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(urlPatterns = {"/chat", "/chat/download"})
@MultipartConfig(
    maxFileSize = 25L * 1024 * 1024,        // 25 MB max per file
    maxRequestSize = 30L * 1024 * 1024,     // 30 MB max request
    fileSizeThreshold = 512 * 1024          // 512 KB threshold
)
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

        String path = request.getServletPath();

        // Xử lý tải / xem file đính kèm trong tin nhắn
        if ("/chat/download".equals(path) || "download".equals(request.getParameter("action"))) {
            String msgIdStr = request.getParameter("id");
            if (msgIdStr == null || msgIdStr.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID tin nhắn");
                return;
            }

            try {
                int msgId = Integer.parseInt(msgIdStr);
                Message msg = messageService.getMessageFile(msgId);
                if (msg == null || msg.getFileData() == null || msg.getFileData().length == 0) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy file hoặc tin nhắn không có file");
                    return;
                }

                // Bảo mật: Chỉ người gửi hoặc người nhận mới được phép xem/tải file
                if (msg.getSenderId() != currentUser.getId() && msg.getReceiverId() != currentUser.getId() 
                        && !"admin".equals(currentUser.getRole())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập file này");
                    return;
                }

                String inline = request.getParameter("inline");
                if ("true".equalsIgnoreCase(inline) && msg.getFileType() != null 
                        && (msg.getFileType().startsWith("image/") || "application/pdf".equals(msg.getFileType()))) {
                    response.setContentType(msg.getFileType());
                    response.setContentLength(msg.getFileData().length);
                    response.setHeader("Content-Disposition", "inline; filename=\"" + msg.getFileName() + "\"");
                    response.getOutputStream().write(msg.getFileData());
                    return;
                }

                FileData fileData = new FileData(msg.getFileName(), msg.getFileType(), msg.getFileData());
                FileDownloadUtil.send(response, fileData);
                return;

            } catch (NumberFormatException | SQLException e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi xử lý file");
                return;
            }
        }

        try {
            int currentUserId = currentUser.getId();

            // Load contact list (single SQL JOIN - no N+1 query problem)
            List<User> contacts = messageService.getAcceptedContactUsers(currentUserId);
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

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        try {
            if ("send".equals(action)) {
                int targetId = Integer.parseInt(request.getParameter("targetId"));
                String content = request.getParameter("content");
                String isAjax = request.getHeader("X-Requested-With");

                // Anti-spam protection at the backend level (500ms)
                Long lastChatTime = (Long) request.getSession().getAttribute("lastChatTime");
                long now = System.currentTimeMillis();
                if (lastChatTime != null && (now - lastChatTime) < 500) {
                    if ("XMLHttpRequest".equalsIgnoreCase(isAjax)) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        response.setContentType("application/json;charset=UTF-8");
                        response.getWriter().write("{\"status\":\"error\",\"message\":\"Vui lòng không gửi tin nhắn quá nhanh\"}");
                        return;
                    }
                    response.sendRedirect(request.getContextPath() + "/chat?targetId=" + targetId);
                    return;
                }
                request.getSession().setAttribute("lastChatTime", now);

                // Kiểm tra file đính kèm
                Part filePart = null;
                String contentType = request.getContentType();
                if (contentType != null && contentType.toLowerCase().startsWith("multipart/form-data")) {
                    try {
                        filePart = request.getPart("file");
                    } catch (Exception ignored) {}
                }

                String fileName = null;
                String fileType = null;
                Integer fileSize = null;
                byte[] fileData = null;

                if (filePart != null && filePart.getSize() > 0) {
                    fileName = filePart.getSubmittedFileName();
                    // Loại bỏ đường dẫn thư mục nếu có từ một số trình duyệt cũ
                    if (fileName != null && fileName.contains("\\")) {
                        fileName = fileName.substring(fileName.lastIndexOf('\\') + 1);
                    } else if (fileName != null && fileName.contains("/")) {
                        fileName = fileName.substring(fileName.lastIndexOf('/') + 1);
                    }
                    fileType = filePart.getContentType();
                    fileSize = (int) filePart.getSize();
                    fileData = filePart.getInputStream().readAllBytes();
                }

                boolean hasContent = content != null && !content.trim().isEmpty();
                boolean hasFile = fileName != null && fileData != null;

                if (hasContent || hasFile) {
                    String finalContent = hasContent ? content.trim() : (fileName != null ? fileName : "");
                    messageService.sendMessage(currentUser.getId(), targetId, finalContent, fileName, fileType, fileSize, fileData);
                }
                
                if ("XMLHttpRequest".equalsIgnoreCase(isAjax)) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"status\":\"success\"}");
                    return;
                }

                // Redirect back to conversation (for non-AJAX fallback)
                response.sendRedirect(request.getContextPath() + "/chat?targetId=" + targetId);
                return;
            } else if ("addContact".equals(action)) {
                String targetEmail = request.getParameter("email");
                User target = userDAO.findByEmail(targetEmail);
                if (target != null && target.getId() != currentUser.getId()) {
                    messageService.sendContactRequest(currentUser.getId(), target.getId());
                    messageService.acceptContactRequest(target.getId(), currentUser.getId());
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
