package com.lms.controller;

import com.lms.model.Course;
import com.lms.model.User;
import com.lms.service.CourseService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(urlPatterns = {
    "/instructor/courses/manage",
    "/instructor/courses/sections/add",
    "/instructor/courses/lessons/add"
})
public class CourseContentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CourseService courseService;

    @Override
    public void init() throws ServletException {
        this.courseService = new CourseService();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (User) session.getAttribute("currentUser");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        // Đọc flash message (nếu có từ lần redirect trước) rồi xóa ngay
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("flashError") != null) {
            request.setAttribute("error", session.getAttribute("flashError"));
            session.removeAttribute("flashError");
        }

        try {
            int courseId = Integer.parseInt(request.getParameter("id"));
            Course course = courseService.getCourseDetail(courseId);

            // Instructor chỉ được xem khóa học của mình.
            // Admin được xem tất cả (để kiểm tra nội dung trước khi duyệt).
            boolean isAdmin = "admin".equals(currentUser.getRole());
            if (!isAdmin && course.getInstructorId() != currentUser.getId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền quản lý khóa học này!");
                return;
            }

            request.setAttribute("course", course);
            request.getRequestDispatcher("/WEB-INF/views/instructor/course-manage.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã khóa học không hợp lệ!");
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        int courseId = -1;

        try {
            if ("/instructor/courses/sections/add".equals(path)) {
                courseId = Integer.parseInt(request.getParameter("courseId"));
                String title = request.getParameter("title");

                courseService.addSection(courseId, currentUser.getId(), title);

            } else if ("/instructor/courses/lessons/add".equals(path)) {
                int sectionId = Integer.parseInt(request.getParameter("sectionId"));
                courseId = Integer.parseInt(request.getParameter("courseId"));

                String title = request.getParameter("title");
                String videoUrl = request.getParameter("videoUrl");
                String documentUrl = request.getParameter("documentUrl");
                String durationStr = request.getParameter("durationMinutes");

                Integer duration = (durationStr != null && !durationStr.isEmpty())
                        ? Integer.parseInt(durationStr) : null;

                courseService.addLesson(sectionId, currentUser.getId(), title, videoUrl, documentUrl, duration);

            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            response.sendRedirect(request.getContextPath() + "/instructor/courses/manage?id=" + courseId);

        } catch (IllegalArgumentException | IllegalStateException e) {
            HttpSession session = request.getSession();
            session.setAttribute("flashError", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/instructor/courses/manage?id=" + courseId);

        } catch (SecurityException e) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());

        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("flashError", "Đã xảy ra lỗi hệ thống!");
            response.sendRedirect(request.getContextPath() + "/instructor/courses/manage?id=" + courseId);
        }
    }
}