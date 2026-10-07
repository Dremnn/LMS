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

@WebServlet(urlPatterns = {"/enrollments/new", "/enrollments/cancel", "/enrollments/refund", "/student/my-courses", "/student/courses"})
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

        request.setAttribute("enrollments", enrollmentService.getMyEnrollments(currentUser.getId()));
        request.getRequestDispatcher("/WEB-INF/views/student/my-courses.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        String path = request.getServletPath();

        try {
            int courseId = Integer.parseInt(request.getParameter("courseId"));
            HttpSession session = request.getSession();

            if ("/enrollments/cancel".equals(path)) {
                enrollmentService.unenroll(currentUser.getId(), courseId);
                session.setAttribute("flashSuccess", "Đã hủy đăng ký khóa học thành công!");
                response.sendRedirect(request.getContextPath() + "/courses/detail?id=" + courseId);
            } else if ("/enrollments/refund".equals(path)) {
                enrollmentService.refundEnrollment(currentUser.getId(), courseId);
                // Cập nhật lại thông tin user trong session (số dư mới sau khi hoàn tiền)
                com.lms.dao.UserDAO userDAO = new com.lms.dao.UserDAO();
                session.setAttribute("currentUser", userDAO.findById(currentUser.getId()));
                session.setAttribute("flashSuccess", "Đã hủy đăng ký và hoàn lại tiền vào ví thành công!");
                response.sendRedirect(request.getContextPath() + "/courses/detail?id=" + courseId);
            } else {
                enrollmentService.enroll(currentUser.getId(), courseId);
                // Cập nhật lại thông tin user trong session (số dư mới sau khi thanh toán)
                com.lms.dao.UserDAO userDAO = new com.lms.dao.UserDAO();
                session.setAttribute("currentUser", userDAO.findById(currentUser.getId()));
                session.setAttribute("flashSuccess", "Đăng ký khóa học thành công! Bạn có thể bắt đầu học ngay.");
                // Đăng ký thành công -> vẫn ở trang course/detail
                response.sendRedirect(request.getContextPath() + "/courses/detail?id=" + courseId);
            }

        } catch (IllegalArgumentException | IllegalStateException e) {
            // Lỗi nghiệp vụ (đã đăng ký rồi, số dư không đủ, khóa học chưa published...)
            // Dùng flash message qua session vì đang redirect, không forward
            HttpSession session = request.getSession();
            session.setAttribute("flashError", e.getMessage());

            String courseId = request.getParameter("courseId");
            if (courseId != null && !courseId.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/courses/detail?id=" + courseId);
            } else {
                response.sendRedirect(request.getContextPath() + "/courses");
            }

        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("flashError", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại!");
            String courseId = request.getParameter("courseId");
            if (courseId != null && !courseId.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/courses/detail?id=" + courseId);
            } else {
                response.sendRedirect(request.getContextPath() + "/courses");
            }
        }
    }
}