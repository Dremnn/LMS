package com.lms.controller;

import com.lms.model.Course;
import com.lms.model.User;
import com.lms.service.CourseService;
import com.lms.dao.CategoryDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

// urlPatterns: dùng 1 Servlet xử lý nhiều đường dẫn con khác nhau (thay vì mỗi hành động 1 Servlet riêng)
@WebServlet(urlPatterns = {
    "/instructor/courses",
    "/instructor/courses/new",
    "/instructor/courses/edit",
    "/instructor/courses/submit",
    "/instructor/courses/delete",
    "/instructor/courses/appeal"
})
public class InstructorCourseServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CourseService courseService;
    private CategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        this.courseService = new CourseService();
        this.categoryDAO = new CategoryDAO();
    }

    // Hàm phụ trợ: lấy User hiện tại đang đăng nhập từ session
    // (AuthFilter đã đảm bảo user không null khi vào tới đây)
    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (User) session.getAttribute("currentUser");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        switch (path) {
            case "/instructor/courses":
                // Đọc flash messages
                HttpSession sess = request.getSession(false);
                if (sess != null && sess.getAttribute("flashError") != null) {
                    request.setAttribute("error", sess.getAttribute("flashError"));
                    sess.removeAttribute("flashError");
                }
                if (sess != null && sess.getAttribute("flashSuccess") != null) {
                    request.setAttribute("successMessage", sess.getAttribute("flashSuccess"));
                    sess.removeAttribute("flashSuccess");
                }
                // Danh sách khóa học của Instructor hiện tại
                List<Course> courses = courseService.getMyCoursesAsInstructor(currentUser.getId());
                request.setAttribute("courses", courses);
                request.getRequestDispatcher("/WEB-INF/views/instructor/course-list.jsp")
                        .forward(request, response);
                break;

            case "/instructor/courses/new":
                // Hiển thị form tạo khóa học mới -> cần load sẵn danh sách category cho dropdown
                request.setAttribute("categories", categoryDAO.findAll());
                request.getRequestDispatcher("/WEB-INF/views/instructor/course-form.jsp")
                        .forward(request, response);
                break;

            case "/instructor/courses/edit":
                // Hiển thị form sửa khóa học đã có
                int courseId = Integer.parseInt(request.getParameter("id"));
                Course course = courseService.getCourseDetail(courseId);

                // Kiểm tra quyền sở hữu ngay tại Servlet trước khi hiển thị form
                if (course.getInstructorId() != currentUser.getId()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền sửa khóa học này!");
                    return;
                }

                request.setAttribute("course", course);
                request.setAttribute("categories", categoryDAO.findAll());
                request.getRequestDispatcher("/WEB-INF/views/instructor/course-form.jsp")
                        .forward(request, response);
                break;

            default:
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        try {
            switch (path) {
                case "/instructor/courses/new":
                    handleCreate(request, currentUser);
                    break;

                case "/instructor/courses/edit":
                    handleUpdate(request, currentUser);
                    break;

                case "/instructor/courses/submit":
                    handleSubmit(request, currentUser);
                    break;

                case "/instructor/courses/delete":
                    handleDelete(request, currentUser);
                    break;

                case "/instructor/courses/appeal":
                    handleAppeal(request, currentUser);
                    break;

                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
            }

            // Sau khi xử lý xong (thành công), quay lại danh sách khóa học
            response.sendRedirect(request.getContextPath() + "/instructor/courses");

        } catch (IllegalArgumentException | IllegalStateException e) {
            // Nếu lỗi từ appeal hoặc submit/delete -> redirect về danh sách kèm flash error
            if ("/instructor/courses/appeal".equals(path) 
                || "/instructor/courses/submit".equals(path)
                || "/instructor/courses/delete".equals(path)) {
                HttpSession session = request.getSession();
                session.setAttribute("flashError", e.getMessage());
                response.sendRedirect(request.getContextPath() + "/instructor/courses");
            } else {
                // Lỗi từ create/edit -> forward về form kèm thông báo lỗi
                request.setAttribute("error", e.getMessage());
                request.setAttribute("categories", categoryDAO.findAll());
                request.getRequestDispatcher("/WEB-INF/views/instructor/course-form.jsp")
                        .forward(request, response);
            }

        } catch (SecurityException e) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());

        } catch (Exception e) {
            e.printStackTrace();
            if ("/instructor/courses/appeal".equals(path)
                || "/instructor/courses/submit".equals(path)
                || "/instructor/courses/delete".equals(path)) {
                HttpSession session = request.getSession();
                session.setAttribute("flashError", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại!");
                response.sendRedirect(request.getContextPath() + "/instructor/courses");
            } else {
                request.setAttribute("error", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại!");
                request.getRequestDispatcher("/WEB-INF/views/instructor/course-form.jsp")
                        .forward(request, response);
            }
        }
    }

    private void handleCreate(HttpServletRequest request, User currentUser) {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String categoryIdStr = request.getParameter("categoryId");
        String priceStr = request.getParameter("price");

        Integer categoryId = (categoryIdStr != null && !categoryIdStr.isEmpty())
                ? Integer.parseInt(categoryIdStr) : null;
        BigDecimal price = (priceStr != null && !priceStr.isEmpty())
                ? new BigDecimal(priceStr) : BigDecimal.ZERO;

        courseService.createCourse(currentUser.getId(), title, description, categoryId, price);
    }

    private void handleUpdate(HttpServletRequest request, User currentUser) {
        int courseId = Integer.parseInt(request.getParameter("id"));
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String categoryIdStr = request.getParameter("categoryId");
        String priceStr = request.getParameter("price");

        Integer categoryId = (categoryIdStr != null && !categoryIdStr.isEmpty())
                ? Integer.parseInt(categoryIdStr) : null;
        BigDecimal price = (priceStr != null && !priceStr.isEmpty())
                ? new BigDecimal(priceStr) : BigDecimal.ZERO;

        courseService.updateCourse(courseId, currentUser.getId(), title, description, categoryId, price);
    }

    private void handleSubmit(HttpServletRequest request, User currentUser) {
        int courseId = Integer.parseInt(request.getParameter("id"));
        courseService.publishCourse(courseId, currentUser.getId());
    }

    private void handleDelete(HttpServletRequest request, User currentUser) {
        int courseId = Integer.parseInt(request.getParameter("id"));
        courseService.deleteCourse(courseId, currentUser.getId());
    }

    private void handleAppeal(HttpServletRequest request, User currentUser) {
        int courseId = Integer.parseInt(request.getParameter("id"));
        String appealMessage = request.getParameter("appealMessage");
        courseService.appealCourse(courseId, currentUser.getId(), appealMessage);
    }
}