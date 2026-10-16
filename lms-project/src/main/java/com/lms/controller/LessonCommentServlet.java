package com.lms.controller;

import com.lms.dao.LessonCommentDAO;
import com.lms.model.LessonComment;
import com.lms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(urlPatterns = {"/lesson-comments", "/lesson-comments/delete"})
public class LessonCommentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private LessonCommentDAO commentDAO;

    @Override
    public void init() throws ServletException {
        this.commentDAO = new LessonCommentDAO();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        String lessonIdStr = request.getParameter("lessonId");
        if (lessonIdStr == null || lessonIdStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("[]");
            return;
        }

        try {
            int lessonId = Integer.parseInt(lessonIdStr);
            List<LessonComment> comments = commentDAO.findCommentsByLesson(lessonId);

            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < comments.size(); i++) {
                json.append(commentToJson(comments.get(i)));
                if (i < comments.size() - 1) json.append(",");
            }
            json.append("]");

            PrintWriter out = response.getWriter();
            out.print(json.toString());
            out.flush();

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("[]");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập để bình luận!\"}");
            return;
        }

        String path = request.getServletPath();

        if ("/lesson-comments/delete".equals(path)) {
            handleDelete(request, response, currentUser);
        } else {
            handleCreate(request, response, currentUser);
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        try {
            int lessonId = Integer.parseInt(request.getParameter("lessonId"));
            String content = request.getParameter("content");
            String parentIdStr = request.getParameter("parentId");

            if (content == null || content.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\":false,\"message\":\"Nội dung bình luận không được để trống!\"}");
                return;
            }

            Integer parentId = (parentIdStr != null && !parentIdStr.isEmpty()) ? Integer.parseInt(parentIdStr) : null;

            LessonComment comment = new LessonComment(lessonId, currentUser.getId(), parentId, content.trim());
            boolean success = commentDAO.save(comment);

            if (success) {
                response.getWriter().write("{\"success\":true,\"message\":\"Đã đăng bình luận thành công!\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"success\":false,\"message\":\"Lỗi khi lưu bình luận!\"}");
            }

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"message\":\"Dữ liệu không hợp lệ!\"}");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        try {
            int commentId = Integer.parseInt(request.getParameter("commentId"));
            boolean isAdminOrInstructor = "admin".equalsIgnoreCase(currentUser.getRole()) || "instructor".equalsIgnoreCase(currentUser.getRole());

            boolean deleted = commentDAO.delete(commentId, currentUser.getId(), isAdminOrInstructor);

            if (deleted) {
                response.getWriter().write("{\"success\":true,\"message\":\"Đã xóa bình luận!\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("{\"success\":false,\"message\":\"Không thể xóa bình luận này!\"}");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"message\":\"Yêu cầu không hợp lệ!\"}");
        }
    }

    private String commentToJson(LessonComment c) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"id\":").append(c.getId()).append(",");
        sb.append("\"lessonId\":").append(c.getLessonId()).append(",");
        sb.append("\"userId\":").append(c.getUserId()).append(",");
        sb.append("\"parentId\":").append(c.getParentId() != null ? c.getParentId() : "null").append(",");
        sb.append("\"content\":").append(escapeJson(c.getContent())).append(",");
        sb.append("\"createdAtFormatted\":\"").append(c.getCreatedAtFormatted()).append("\",");
        sb.append("\"userName\":").append(escapeJson(c.getUserName() != null ? c.getUserName() : "Người dùng")).append(",");
        sb.append("\"userAvatar\":").append(escapeJson(c.getUserAvatar() != null ? c.getUserAvatar() : "")).append(",");
        sb.append("\"userRole\":\"").append(c.getUserRole() != null ? c.getUserRole() : "student").append("\",");

        sb.append("\"replies\":[");
        List<LessonComment> replies = c.getReplies();
        for (int i = 0; i < replies.size(); i++) {
            sb.append(commentToJson(replies.get(i)));
            if (i < replies.size() - 1) sb.append(",");
        }
        sb.append("]");
        sb.append("}");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "\"\"";
        StringBuilder sb = new StringBuilder("\"");
        for (char c : s.toCharArray()) {
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (c < ' ') {
                        sb.append(String.format("\\u%04x", (int) c));
                    } else {
                        sb.append(c);
                    }
            }
        }
        sb.append("\"");
        return sb.toString();
    }
}
