package com.lms.controller;

import com.lms.model.User;
import com.lms.service.ReviewService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(urlPatterns = {"/courses/reviews", "/courses/reviews/delete"})
public class ReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ReviewService reviewService;

    @Override
    public void init() throws ServletException {
        this.reviewService = new ReviewService();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        HttpSession session = request.getSession();
        String path = request.getServletPath();
        String courseIdParam = request.getParameter("courseId");

        if (courseIdParam == null || courseIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/courses");
            return;
        }

        int courseId;
        try {
            courseId = Integer.parseInt(courseIdParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/courses");
            return;
        }

        try {
            if ("/courses/reviews/delete".equals(path)) {
                reviewService.deleteReview(currentUser.getId(), courseId);
                session.setAttribute("flashSuccess", "Đã xóa đánh giá của bạn thành công.");
            } else {
                String ratingParam = request.getParameter("rating");
                String comment = request.getParameter("comment");

                if (ratingParam == null || ratingParam.trim().isEmpty()) {
                    session.setAttribute("flashError", "Vui lòng chọn số sao đánh giá (1 - 5 sao)!");
                    response.sendRedirect(request.getContextPath() + "/courses/detail?id=" + courseId);
                    return;
                }

                int rating = Integer.parseInt(ratingParam.trim());
                reviewService.addOrUpdateReview(currentUser.getId(), courseId, rating, comment);
                session.setAttribute("flashSuccess", "Cảm ơn bạn đã gửi đánh giá khóa học!");
            }
        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("flashError", "Có lỗi xảy ra khi xử lý đánh giá. Vui lòng thử lại!");
        }

        response.sendRedirect(request.getContextPath() + "/courses/detail?id=" + courseId + "#reviews-section");
    }
}
