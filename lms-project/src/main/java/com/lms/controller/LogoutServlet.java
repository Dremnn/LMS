package com.lms.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Xử lý khi người dùng click vào thẻ <a href="logout">Đăng xuất</a> (phương thức GET)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processLogout(request, response);
    }

    // Xử lý khi người dùng submit nút Đăng xuất qua Form POST
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processLogout(request, response);
    }

    // Gom logic xử lý chung vào 1 hàm
    private void processLogout(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        // 1. Lấy session hiện tại (nếu có, không tạo session mới)
        HttpSession session = request.getSession(false);

        if (session != null) {
            // Xóa thuộc tính currentUser
            session.removeAttribute("currentUser");
            
            // Hủy toàn bộ session
            session.invalidate();
        }

        // 2. Chuyển hướng về trang đăng nhập
        response.sendRedirect(request.getContextPath() + "/login");
    }
}