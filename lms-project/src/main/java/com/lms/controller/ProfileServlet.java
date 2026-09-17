package com.lms.controller;

import com.lms.dao.UserDAO;
import com.lms.model.User;
import com.lms.model.WalletTransaction;
import com.lms.service.WalletService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

/**
 * Trang "Hồ sơ cá nhân" - dùng chung cho cả 3 role (student / instructor / admin).
 * Hiển thị: họ tên, tên đăng nhập (email), avatar, email, số điện thoại.
 * Riêng student còn hiển thị thêm: số dư ví + lịch sử giao dịch.
 */
@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;
    private WalletService walletService;

    @Override
    public void init() throws ServletException {
        this.userDAO = new UserDAO();
        this.walletService = new WalletService();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User sessionUser = getCurrentUser(request);
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Đọc lại User mới nhất từ DB (để số dư/avatar/phone luôn chính xác,
        // không dùng dữ liệu cũ đã lưu trong session từ lúc đăng nhập)
        User freshUser = userDAO.findById(sessionUser.getId());
        if (freshUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        request.getSession().setAttribute("currentUser", freshUser);

        HttpSession session = request.getSession(false);
        if (session != null) {
            if (session.getAttribute("flashError") != null) {
                request.setAttribute("error", session.getAttribute("flashError"));
                session.removeAttribute("flashError");
            }
            if (session.getAttribute("flashSuccess") != null) {
                request.setAttribute("success", session.getAttribute("flashSuccess"));
                session.removeAttribute("flashSuccess");
            }
        }

        List<WalletTransaction> history = ("student".equals(freshUser.getRole()) || "instructor".equals(freshUser.getRole()))
                ? walletService.getHistory(freshUser.getId())
                : Collections.emptyList();

        request.setAttribute("profileUser", freshUser);
        request.setAttribute("walletHistory", history);
        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String fullName = request.getParameter("fullName");
        String avatarUrl = request.getParameter("avatarUrl");
        String phone = request.getParameter("phone");
        HttpSession session = request.getSession();
        try {
            if (fullName == null || fullName.trim().isEmpty()) {
                throw new IllegalArgumentException("Họ và tên không được để trống!");
            }
            if (phone != null && !phone.isEmpty() && !phone.matches("^[0-9+()\\-\\s]{8,20}$")) {
                throw new IllegalArgumentException("Số điện thoại không hợp lệ!");
            }
            boolean updated = userDAO.updateProfile(currentUser.getId(),
                    fullName.trim(),
                    (avatarUrl != null && !avatarUrl.isEmpty()) ? avatarUrl.trim() : null,
                    (phone != null && !phone.isEmpty()) ? phone.trim() : null);
            if (!updated) {
                throw new RuntimeException("Có lỗi xảy ra khi cập nhật hồ sơ. Vui lòng thử lại!");
            }
            currentUser.setFullName(fullName.trim());
            session.setAttribute("flashSuccess", "Cập nhật hồ sơ thành công!");

        } catch (IllegalArgumentException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("flashError", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại!");
        }

        response.sendRedirect(request.getContextPath() + "/profile");
    }
}
