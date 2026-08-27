package com.lms.controller;

import com.lms.model.User;
import com.lms.service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AuthService authService;

    // Khởi tạo AuthService khi Servlet được load
    @Override
    public void init() throws ServletException {
        this.authService = new AuthService();
    }

    // =========================================================================
    // 1. GET /register : Hiển thị trang giao diện Đăng ký
    // =========================================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra: Nếu người dùng đã đăng nhập rồi thì không cần vào trang Đăng ký nữa
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        // Chuyển tiếp (forward) tới trang JSP giao diện đăng ký
        request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
    }

    // =========================================================================
    // 2. POST /register : Nhận dữ liệu submit từ Form đăng ký
    // =========================================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Cấu hình UTF-8 để nhận tiếng Việt có dấu (ví dụ họ tên: Nguyễn Văn A)
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // 1. Đọc dữ liệu từ form
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");

        try {
            // 2. Gọi tầng Service để thực hiện nghiệp vụ đăng ký
            User newUser = authService.register(fullName, email, password, confirmPassword, role);

            // 3. ĐĂNG KÝ THÀNH CÔNG:
            // Sử dụng Post/Redirect/Get pattern để tránh bị gửi lại form khi người dùng F5
            response.sendRedirect(request.getContextPath() + "/login?registerSuccess=true");

        } catch (IllegalArgumentException | IllegalStateException e) {
            // 4. ĐĂNG KÝ THẤT BẠI DO LỖI NHẬP LIỆU:
            // Gửi thông báo lỗi và giữ lại dữ liệu cũ người dùng đã nhập để họ không phải gõ lại
            request.setAttribute("error", e.getMessage());
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.setAttribute("role", role);

            // Forward lại về trang JSP để hiện thông báo đỏ
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);

        } catch (Exception e) {
            // Lỗi hệ thống bất ngờ khác
            e.printStackTrace();
            request.setAttribute("error", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau!");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
        }
    }
}