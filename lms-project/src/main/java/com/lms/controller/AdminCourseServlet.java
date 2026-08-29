package com.lms.controller;

import com.lms.model.Course;
import com.lms.service.CourseService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {
    "/admin",
    "/admin/courses/approval",
    "/admin/courses/pending",
    "/admin/courses/approve",
    "/admin/courses/reject"
})
public class AdminCourseServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CourseService courseService;

    @Override
    public void init() throws ServletException {
        this.courseService = new CourseService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Đọc flash message nếu có
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("flashError") != null) {
            request.setAttribute("error", session.getAttribute("flashError"));
            session.removeAttribute("flashError");
        }
        if (session != null && session.getAttribute("flashSuccess") != null) {
            request.setAttribute("successMessage", session.getAttribute("flashSuccess"));
            session.removeAttribute("flashSuccess");
        }

        // Chỉ có 1 route GET: danh sách khóa học đang chờ duyệt
        List<Course> pendingCourses = courseService.getPendingCourses();
        request.setAttribute("pendingCourses", pendingCourses);

        request.getRequestDispatcher("/WEB-INF/views/admin/course-approval.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        HttpSession session = request.getSession();

        try {
            int courseId = Integer.parseInt(request.getParameter("courseId"));

            if ("/admin/courses/approve".equals(path)) {
                courseService.approveCourse(courseId);
                session.setAttribute("flashSuccess", "Đã duyệt khóa học thành công!");

            } else if ("/admin/courses/reject".equals(path)) {
                String reason = request.getParameter("reason");
                courseService.rejectCourse(courseId, reason);
                session.setAttribute("flashSuccess", "Đã từ chối khóa học!");

            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("flashError", "Đã xảy ra lỗi hệ thống!");
        }

        response.sendRedirect(request.getContextPath() + "/admin/courses/pending");
    }
}