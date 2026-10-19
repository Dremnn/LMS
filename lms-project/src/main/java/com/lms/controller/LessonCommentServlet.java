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

/**
 * ============================================================================
 * CONTROLLER: LessonCommentServlet
 * ============================================================================
 * VAI TRÒ (STUDENT & INSTRUCTOR):
 * - Quản lý hệ thống Hỏi đáp & Bình luận bài học (Comments & Replies):
 *   + GET  /lesson-comments        : Trả về danh sách bình luận dạng CÂY LỒNG NHAU (JSON) của 1 bài học.
 *   + POST /lesson-comments        : Đăng câu hỏi mới hoặc gửi câu trả lời (Reply) cho câu hỏi đã có.
 *   + POST /lesson-comments/delete : Xóa bình luận (chủ nhân bình luận hoặc Giảng viên/Admin).
 * 
 * KIẾN TRÚC GIAO TIẾP:
 * - Hoạt động như một RESTful API Endpoint trả về JSON cho mã JavaScript (fetch API)
 *   tại `lesson-view.jsp` để nạp và gửi bình luận realtime mà KHÔNG CẦN tải lại cả trang web.
 * ============================================================================
 */
@WebServlet(urlPatterns = {"/lesson-comments", "/lesson-comments/delete"})
public class LessonCommentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // DAO thực hiện các truy vấn bảng `lesson_comments`
    private LessonCommentDAO commentDAO;

    /**
     * Khởi tạo DAO
     */
    @Override
    public void init() throws ServletException {
        this.commentDAO = new LessonCommentDAO();
    }

    /**
     * Lấy thông tin tài khoản hiện tại từ Session
     */
    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }

    /**
     * ------------------------------------------------------------------------
     * HÀM XỬ LÝ: doGet (API Tải danh sách bình luận của bài học)
     * ------------------------------------------------------------------------
     * Mục đích:
     * - Nhận `lessonId` qua tham số query string.
     * - Gọi LessonCommentDAO.findCommentsByLesson(lessonId) để lấy các câu hỏi gốc
     *   kèm danh sách các câu trả lời con (replies) lồng bên trong.
     * - Chuyển đổi cây bình luận sang định dạng JSON và ghi ra response stream.
     */
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
            // Lấy danh sách cây bình luận từ CSDL
            List<LessonComment> comments = commentDAO.findCommentsByLesson(lessonId);

            // Chuyển đổi danh sách đối tượng Java sang chuỗi mảng JSON: [{...}, {...}]
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

    /**
     * ------------------------------------------------------------------------
     * HÀM XỬ LÝ: doPost (API Đăng mới hoặc Xóa bình luận)
     * ------------------------------------------------------------------------
     * Mục đích:
     * - Kiểm tra người dùng đã đăng nhập chưa (bắt buộc phải đăng nhập).
     * - Phân luồng:
     *   + /lesson-comments/delete : Xử lý xóa bình luận
     *   + /lesson-comments        : Xử lý đăng câu hỏi mới hoặc gửi câu trả lời
     */
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

    /**
     * ------------------------------------------------------------------------
     * HÀM XỬ LÝ: handleCreate (Đăng câu hỏi hoặc Trả lời)
     * ------------------------------------------------------------------------
     * Mục đích:
     * - Đọc: `lessonId`, `content`, `parentId` (nếu parentId != null thì đây là reply của câu hỏi cha).
     * - Validate nội dung không rỗng.
     * - Gọi DAO để INSERT bản ghi vào bảng `lesson_comments`.
     * - Trả về kết quả JSON {"success": true, ...}.
     */
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

    /**
     * ------------------------------------------------------------------------
     * HÀM XỬ LÝ: handleDelete (Xóa bình luận)
     * ------------------------------------------------------------------------
     * Mục đích:
     * - Nhận `commentId`.
     * - Kiểm tra phân quyền:
     *   + Nếu là Giảng viên (Instructor) hoặc Admin: Được quyền xóa bất kỳ bình luận nào (kiểm duyệt).
     *   + Nếu là Học viên (Student): Chỉ được xóa bình luận do chính mình viết (`user_id = currentUser.getId()`).
     */
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

    /**
     * ------------------------------------------------------------------------
     * HÀM PHỤ TRỢ: commentToJson (Chuyển đổi đệ quy Comment sang chuỗi JSON)
     * ------------------------------------------------------------------------
     * Mục đích:
     * - Tự động serialize các thuộc tính của đối tượng Comment: id, content, userName, avatar, role, v.v.
     * - Đệ quy duyệt qua mảng `replies` bên trong đối tượng để xây dựng đúng cấu trúc cây con.
     */
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

        // Đệ quy chuyển đổi danh sách các câu trả lời con (replies)
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

    /**
     * Thoát ký tự đặc biệt (dấu ngoặc kép, dấu gạch chéo, xuống dòng) để đảm bảo chuỗi JSON hợp lệ.
     */
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
