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
    "/admin/courses",
    "/admin/courses/delete",
    "/admin/courses/warn",
    "/admin/courses/approve-appeal",
    "/admin/courses/reject-appeal"
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

        // Lấy tất cả khóa học cho Admin quản lý
        List<Course> courses = courseService.getAllCourses();
        request.setAttribute("courses", courses);

        request.getRequestDispatcher("/WEB-INF/views/admin/course-manage.jsp")
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

            if ("/admin/courses/delete".equals(path)) {
                new com.lms.dao.CourseDAO().delete(courseId); // Xóa cứng khóa học
                session.setAttribute("flashSuccess", "Đã xóa khóa học thành công!");
            } else if ("/admin/courses/warn".equals(path)) {
                String reason = request.getParameter("reason");
                courseService.warnCourse(courseId, reason);
                session.setAttribute("flashSuccess", "Đã cảnh cáo khóa học!");
            } else if ("/admin/courses/approve-appeal".equals(path)) {
                courseService.approveAppeal(courseId);
                session.setAttribute("flashSuccess", "Đã chấp nhận kháng cáo! Khóa học đã được phục hồi.");
            } else if ("/admin/courses/reject-appeal".equals(path)) {
                courseService.rejectAppeal(courseId);
                session.setAttribute("flashSuccess", "Đã từ chối kháng cáo. Khóa học vẫn ở trạng thái cảnh cáo.");
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

        response.sendRedirect(request.getContextPath() + "/admin");
    }
}