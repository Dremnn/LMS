package com.lms.filter;

import com.lms.model.User;

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

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Khởi tạo filter (nếu cần cấu hình ban đầu)
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
        // 1. CHO PHÉP TRUY CẬP CÁC TÀI NGUYÊN CÔNG KHAI (Public Resources)
        // =====================================================================
        boolean isPublicResource = path.startsWith("/assets/") || 
                                   path.endsWith(".css") || 
                                   path.endsWith(".js") || 
                                   path.endsWith(".png") || 
                                   path.endsWith(".jpg") || 
                                   path.endsWith(".jpeg");

        boolean isPublicPage = path.equals("/") || 
                               path.equals("/index.jsp") || 
                               path.equals("/login") || 
                               path.equals("/register") || 
                               path.equals("/logout") || 
                               path.equals("/test-db") ||
                               path.equals("/courses") ||           
                               path.equals("/courses/detail"); 

        if (isPublicResource || isPublicPage) {
            // Cho phép đi tiếp không cần kiểm tra đăng nhập
            chain.doFilter(request, response);
            return;
        }

        // =====================================================================
        // 2. KIỂM TRA TRẠNG THÁI ĐĂNG NHẬP
        // =====================================================================
        HttpSession session = httpRequest.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // Nếu chưa đăng nhập mà cố tình vào các trang yêu cầu bảo vệ
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

        // 3.3. Phân quyền khu vực HỌC VIÊN (/student/*)
        if (path.startsWith("/student/")) {
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