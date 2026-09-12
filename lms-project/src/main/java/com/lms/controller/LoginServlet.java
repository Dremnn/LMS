package com.lms.controller;

import com.lms.model.User;
import com.lms.service.AuthService;
import com.lms.util.CookieUtil;
import com.lms.util.RememberTokenUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AuthService authService;

    @Override
    public void init() throws ServletException {
        this.authService = new AuthService();
    }

    // =========================================================================
    // 1. GET /login : Hiển thị trang giao diện Đăng nhập
    // =========================================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Nếu đã đăng nhập rồi thì chuyển hướng về trang chủ, không bắt đăng nhập lại
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        // Kiểm tra xem có thông báo đăng ký thành công gửi qua URL không (/login?registerSuccess=true)
        String registerSuccess = request.getParameter("registerSuccess");
        if ("true".equals(registerSuccess)) {
            request.setAttribute("successMessage", "Đăng ký tài khoản thành công! Vui lòng đăng nhập.");
        }

        // Đọc Cookie remember_email (nếu có) để điền sẵn vào Form
        String rememberEmail = CookieUtil.getCookieValue(request, "remember_email");
        if (rememberEmail != null && !rememberEmail.trim().isEmpty()) {
            request.setAttribute("rememberEmail", rememberEmail);
            request.setAttribute("rememberMeChecked", true);
        }

        // Chuyển tiếp tới giao diện login.jsp
        request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
    }

    // =========================================================================
    // 2. POST /login : Xử lý dữ liệu submit từ Form đăng nhập
    // =========================================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");

        try {
            // 1. Gọi Service để xác thực email & mật khẩu
            User user = authService.login(email, password);

            // 2. TẠO SESSION VÀ LƯU THÔNG TIN USER (Chống tấn công Session Fixation)
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate(); // Hủy session cũ nếu có
            }

            HttpSession session = request.getSession(true); // Tạo session mới tinh
            session.setAttribute("currentUser", user);
            session.setMaxInactiveInterval(60 * 60); // Session hết hạn sau 60 phút không hoạt động

            // 3. XỬ LÝ COOKIE "GHI NHỚ ĐĂNG NHẬP" (Remember Me)
            if ("true".equalsIgnoreCase(rememberMe) || "on".equalsIgnoreCase(rememberMe)) {
                // Lưu email trong 30 ngày (để lần sau tự điền form)
                CookieUtil.addCookie(response, "remember_email", user.getEmail(), 30 * 24 * 60 * 60, false);
                // Tạo token đăng nhập tự động trong 14 ngày (HttpOnly chống XSS)
                String rememberToken = RememberTokenUtil.generateToken(user);
                CookieUtil.addCookie(response, "remember_token", rememberToken, RememberTokenUtil.TOKEN_COOKIE_MAX_AGE, true);
            } else {
                // Người dùng không chọn ghi nhớ -> Dọn sạch các cookie cũ nếu có
                CookieUtil.deleteCookie(response, "remember_email");
                CookieUtil.deleteCookie(response, "remember_token");
            }

            // 4. ĐIỀU HƯỚNG THEO ROLE (Vai trò)
            // Nếu có lưu URL mà user muốn vào trước đó (ví dụ đang xem dở bài học bị bắt login)
            String redirectUrl = (String) session.getAttribute("redirectAfterLogin");
            if (redirectUrl != null) {
                session.removeAttribute("redirectAfterLogin");
                response.sendRedirect(redirectUrl);
                return;
            }

            // Điều hướng mặc định về trang chủ
            response.sendRedirect(request.getContextPath() + "/index.jsp");

        } catch (IllegalArgumentException | IllegalStateException e) {
            // 4. ĐĂNG NHẬP THẤT BẠI:
            request.setAttribute("error", e.getMessage());
            request.setAttribute("email", email); // Giữ lại email đã nhập
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau!");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
        }
    }
}