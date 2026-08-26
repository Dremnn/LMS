package com.lms.controller;

import com.lms.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/test-db")
public class TestDBServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<!DOCTYPE html><html><head><title>Test DB</title></head><body>");
        out.println("<h1>Ket qua test ket noi Database</h1>");

        // Câu lệnh test: đọc dữ liệu từ bảng users
        String sql = "SELECT id, full_name, email, role FROM users";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            out.println("<p style='color:green;'>Ket noi DB thanh cong!</p>");
            out.println("<table border='1' cellpadding='8'>");
            out.println("<tr><th>ID</th><th>Full Name</th><th>Email</th><th>Role</th></tr>");

            boolean hasData = false;
            while (rs.next()) {
                hasData = true;
                out.println("<tr>");
                out.println("<td>" + rs.getInt("id") + "</td>");
                out.println("<td>" + rs.getString("full_name") + "</td>");
                out.println("<td>" + rs.getString("email") + "</td>");
                out.println("<td>" + rs.getString("role") + "</td>");
                out.println("</tr>");
            }

            if (!hasData) {
                out.println("<tr><td colspan='4'>Bang users dang trong (chua co data - binh thuong)</td></tr>");
            }

            out.println("</table>");

        } catch (SQLException e) {
            out.println("<p style='color:red;'>Loi ket noi DB: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }

        out.println("</body></html>");
    }
}