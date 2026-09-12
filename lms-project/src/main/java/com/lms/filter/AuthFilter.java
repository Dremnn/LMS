package com.lms.filter;

import com.lms.dao.UserDAO;
import com.lms.model.User;
import com.lms.util.CookieUtil;
import com.lms.util.RememberTokenUtil;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

// Filter này sẽ lắng nghe tất cả các đường dẫn trong ứng dụng
@WebFilter("/*")
public class AuthFilter implements Filter {

    private UserDAO userDAO;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        this.userDAO = new UserDAO();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Lấy đường dẫn mà người dùng đang truy cập (ví dụ: /admin/users, /login, /assets/css/style.css)
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());

        // =====================================================================
        // 1. CHO PHÉP TRUY CẬP CÁC TÀI NGUYÊN CÔNG KHAI (Static Resources)
        // =====================================================================
        boolean isPublicResource = path.startsWith("/assets/") || 
                                   path.endsWith(".css") || 
                                   path.endsWith(".js") || 
                                   path.endsWith(".png") || 
                                   path.endsWith(".jpg") || 
                                   path.endsWith(".jpeg");

        if (isPublicResource) {
            chain.doFilter(request, response);
            return;
        }

        // =====================================================================
        // 2. KIỂM TRA PHIÊN & TỰ ĐỘNG ĐĂNG NHẬP TỪ COOKIE (Remember Me)
        // =====================================================================
        HttpSession session = httpRequest.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // Nếu session chưa có currentUser, kiểm tra Cookie "remember_token" để tự động phục hồi đăng nhập
        if (currentUser == null) {
            String rememberToken = CookieUtil.getCookieValue(httpRequest, "remember_token");
            if (rememberToken != null && !rememberToken.trim().isEmpty()) {
                int userId = RememberTokenUtil.getUserIdFromToken(rememberToken);
                if (userId > 0) {
                    User dbUser = userDAO.findById(userId);
                    if (dbUser != null && RememberTokenUtil.validateToken(rememberToken, dbUser)) {
                        currentUser = dbUser;
                        if (session == null) {
                            session = httpRequest.getSession(true);
                        }
                        session.setAttribute("currentUser", currentUser);
                        session.setMaxInactiveInterval(60 * 60);
                    } else {
                        // Token sai hoặc hết hạn -> xóa cookie
                        CookieUtil.deleteCookie(httpResponse, "remember_token");
                    }
                }
            }
        }

        boolean isPublicPage = path.equals("/") || 
                               path.equals("/index.jsp") || 
                               path.equals("/login") || 
                               path.equals("/register") || 
                               path.equals("/logout") || 
                               path.equals("/test-db") ||
                               path.equals("/courses") ||           
                               path.equals("/courses/detail"); 

        if (isPublicPage) {
            // Cho phép đi tiếp không cần kiểm tra phân quyền
            chain.doFilter(request, response);
            return;
        }

        // =====================================================================
        // 3. KIỂM TRA TRẠNG THÁI ĐĂNG NHẬP CHO CÁC TRANG BẢO VỆ
        // =====================================================================
        if (currentUser == null) {
            // Lưu lại đường dẫn họ muốn vào để sau khi đăng nhập xong chuyển họ quay lại đây
            if (session == null) {
                session = httpRequest.getSession(true);
            }
            session.setAttribute("redirectAfterLogin", httpRequest.getRequestURI());

            // Chuyển hướng về trang login
            httpResponse.sendRedirect(contextPath + "/login");
            return;
        }

        // =====================================================================
        // 3. PHÂN QUYỀN THEO ROLE (Vai trò)
        // =====================================================================
        String role = currentUser.getRole();

        // 3.1. Phân quyền khu vực ADMIN (/admin/*)
        if (path.startsWith("/admin/")) {
            if (!"admin".equalsIgnoreCase(role)) {
                // Không phải admin mà cố tình vào -> Báo lỗi 403 (Forbidden - Cấm truy cập)
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khu vực Quản trị viên!");
                return;
            }
        }

        // 3.2. Phân quyền khu vực GIẢNG VIÊN (/instructor/* hoặc /courses/manage)
        if (path.startsWith("/instructor/") || path.equals("/courses/manage")) {
            if (!"instructor".equalsIgnoreCase(role) && !"admin".equalsIgnoreCase(role)) {
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Khu vực này chỉ dành cho Giảng viên!");
                return;
            }
        }

        // 3.3. Phân quyền khu vực HỌC VIÊN (/student/* hoặc /courses/reviews*)
        if (path.startsWith("/student/") || path.startsWith("/courses/reviews")) {
            if (!"student".equalsIgnoreCase(role)) {
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Khu vực này chỉ dành cho Học viên!");
                return;
            }
        }

        // Nếu hợp lệ về cả đăng nhập và quyền hạn -> Cho phép đi tiếp vào Servlet/JSP
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Dọn dẹp tài nguyên khi filter bị hủy
    }
}