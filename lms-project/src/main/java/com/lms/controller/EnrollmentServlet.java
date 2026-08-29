package com.lms.controller;

import com.lms.model.User;
import com.lms.service.EnrollmentService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(urlPatterns = {"/enrollments/new", "/student/my-courses"})
public class EnrollmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private EnrollmentService enrollmentService;

    @Override
    public void init() throws ServletException {
        this.enrollmentService = new EnrollmentService();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (User) session.getAttribute("currentUser");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Chỉ có 1 route GET: trang "Khóa học của tôi"
        User currentUser = getCurrentUser(request);

        request.setAttribute("enrollments", enrollmentService.getMyEnrollments(currentUser.getId()));
        request.getRequestDispatcher("/WEB-INF/views/student/my-courses.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        try {
            int courseId = Integer.parseInt(request.getParameter("courseId"));
            enrollmentService.enroll(currentUser.getId(), courseId);

            // Đăng ký thành công -> chuyển tới trang "Khóa học của tôi"
            response.sendRedirect(request.getContextPath() + "/student/my-courses");

        } catch (IllegalArgumentException | IllegalStateException e) {
            // Lỗi nghiệp vụ (đã đăng ký rồi, khóa học chưa published...)
            // Dùng flash message qua session vì đang redirect, không forward
            HttpSession session = request.getSession();
            session.setAttribute("flashError", e.getMessage());

            String courseId = request.getParameter("courseId");
            response.sendRedirect(request.getContextPath() + "/courses/detail?id=" + courseId);

        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("flashError", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại!");
            response.sendRedirect(request.getContextPath() + "/courses");
        }
    }
}