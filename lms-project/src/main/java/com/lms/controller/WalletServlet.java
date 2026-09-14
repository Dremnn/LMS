package com.lms.controller;

import com.lms.model.User;
import com.lms.service.WalletService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;

/**
 * Nạp tiền vào ví - CHỈ dành cho role "student".
 * Luồng demo: user nhập số tiền + (tùy chọn) mã giao dịch chuyển khoản sau khi
 * quét QR, bấm "Tôi đã chuyển khoản" -> số dư được cộng ngay lập tức.
 * (Chưa tích hợp cổng thanh toán/webhook ngân hàng thật.)
 */
@WebServlet("/wallet/topup")
public class WalletServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private WalletService walletService;

    @Override
    public void init() throws ServletException {
        this.walletService = new WalletService();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }

    private boolean requireStudent(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        if (!"student".equals(currentUser.getRole())) {
            // Chỉ student mới có ví để nạp tiền mua khóa học
            response.sendRedirect(request.getContextPath() + "/profile");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (!requireStudent(request, response, currentUser)) {
            return;
        }

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("flashError") != null) {
            request.setAttribute("error", session.getAttribute("flashError"));
            session.removeAttribute("flashError");
        }

        request.getRequestDispatcher("/WEB-INF/views/student/wallet-topup.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);
        if (!requireStudent(request, response, currentUser)) {
            return;
        }

        HttpSession session = request.getSession();
        String amountStr = request.getParameter("amount");
        String referenceCode = request.getParameter("referenceCode");

        try {
            BigDecimal amount = new BigDecimal(amountStr.trim().replace(",", ""));

            walletService.topUp(currentUser.getId(), amount, referenceCode);

            // Cập nhật lại session để navbar/hồ sơ hiển thị số dư mới ngay, không cần đăng nhập lại
            currentUser.setBalance(currentUser.getBalance().add(amount));
            session.setAttribute("currentUser", currentUser);

            session.setAttribute("flashSuccess", "Nạp tiền thành công! Số dư của bạn đã được cập nhật.");
            response.sendRedirect(request.getContextPath() + "/profile");

        } catch (NumberFormatException e) {
            session.setAttribute("flashError", "Số tiền nạp không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/wallet/topup");

        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("flashError", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/wallet/topup");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("flashError", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại!");
            response.sendRedirect(request.getContextPath() + "/wallet/topup");
        }
    }
}
