package com.lms.controller;

import com.lms.model.Course;
import com.lms.service.CourseService;
import com.lms.dao.CategoryDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/courses", "/courses/detail"})
public class CourseBrowseServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CourseService courseService;
    private CategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        this.courseService = new CourseService();
        this.categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/courses/detail".equals(path)) {
            showCourseDetail(request, response);
        } else {
            showCourseBrowse(request, response);
        }
    }

    // Trang danh sách khóa học - có tìm kiếm + filter + sort
    private void showCourseBrowse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Đọc tham số từ URL (VD: /courses?keyword=java&categoryId=1&sortBy=popular)
        String keyword = request.getParameter("keyword");

        String categoryIdStr = request.getParameter("categoryId");
        Integer categoryId = (categoryIdStr != null && !categoryIdStr.isEmpty())
                ? Integer.parseInt(categoryIdStr) : null;

        String sortBy = request.getParameter("sortBy");
        if (sortBy == null || sortBy.isEmpty()) {
            sortBy = "newest"; // Mặc định sắp theo mới nhất
        }

        List<Course> courses = courseService.searchCourses(keyword, categoryId, sortBy);

        // Đưa lại các giá trị đã lọc vào request để JSP hiển thị đúng trạng thái đang chọn
        // (VD: giữ nguyên từ khóa đã gõ trong ô search, giữ dropdown category đang chọn)
        request.setAttribute("courses", courses);
        request.setAttribute("categories", categoryDAO.findAll());
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedCategoryId", categoryId);
        request.setAttribute("sortBy", sortBy);

        request.getRequestDispatcher("/WEB-INF/views/student/course-browse.jsp")
                .forward(request, response);
    }

    // Trang chi tiết 1 khóa học
    private void showCourseDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu mã khóa học!");
            return;
        }

        try {
            int courseId = Integer.parseInt(idParam);
            Course course = courseService.getCourseDetail(courseId);

            // Chỉ cho Student xem khóa học đã published (khóa học draft/pending không public)
            if (!"published".equals(course.getStatus())) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Khóa học không tồn tại hoặc chưa được công khai!");
                return;
            }

            request.setAttribute("course", course);
            request.getRequestDispatcher("/WEB-INF/views/student/course-detail.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã khóa học không hợp lệ!");
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        }
    }
}