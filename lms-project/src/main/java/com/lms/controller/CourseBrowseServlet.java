package com.lms.controller;

import com.lms.model.Course;
import com.lms.model.Enrollment;
import com.lms.model.Review;
import com.lms.model.User;
import com.lms.service.CourseService;
import com.lms.service.EnrollmentService;
import com.lms.service.ReviewService;
import com.lms.dao.CategoryDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@WebServlet(urlPatterns = {"/courses", "/courses/detail"})
public class CourseBrowseServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CourseService courseService;
    private CategoryDAO categoryDAO;
    private EnrollmentService enrollmentService;
    private ReviewService reviewService;

    @Override
    public void init() throws ServletException {
        this.courseService = new CourseService();
        this.categoryDAO = new CategoryDAO();
        this.enrollmentService = new EnrollmentService();
        this.reviewService = new ReviewService();
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

    private void showCourseBrowse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");

        String categoryIdStr = request.getParameter("categoryId");
        Integer categoryId = (categoryIdStr != null && !categoryIdStr.isEmpty())
                ? Integer.parseInt(categoryIdStr) : null;

        String sortBy = request.getParameter("sortBy");
        if (sortBy == null || sortBy.isEmpty()) {
            sortBy = "newest";
        }

        List<Course> courses = courseService.searchCourses(keyword, categoryId, sortBy);

        request.setAttribute("courses", courses);
        request.setAttribute("categories", categoryDAO.findAll());
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedCategoryId", categoryId);
        request.setAttribute("sortBy", sortBy);

        request.getRequestDispatcher("/WEB-INF/views/student/course-browse.jsp")
                .forward(request, response);
    }

    private void showCourseDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Đọc flash message (nếu vừa redirect từ EnrollmentServlet/ReviewServlet với lỗi/thành công)
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

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu mã khóa học!");
            return;
        }

        try {
            int courseId = Integer.parseInt(idParam);
            Course course = courseService.getCourseDetail(courseId);

        List<String> allowedStatuses = Arrays.asList("published", "appealed", "warning");

        if (!allowedStatuses.contains(course.getStatus())) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Khóa học không tồn tại hoặc không thể truy cập!");
            return;
        }

            request.setAttribute("course", course);

            // Kiểm tra: nếu đang đăng nhập VÀ là student, xem đã enroll khóa học này chưa
            // Kết quả dùng để JSP quyết định: hiện nút "Đăng ký học" hay cho phép click vào bài học, đánh giá
            User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
            Enrollment enrollment = null;
            Review myReview = null;
            if (currentUser != null && "student".equalsIgnoreCase(currentUser.getRole())) {
                enrollment = enrollmentService.getEnrollmentIfExists(currentUser.getId(), courseId);
                myReview = reviewService.getStudentReview(currentUser.getId(), courseId);
            }
            request.setAttribute("enrollment", enrollment); // null nếu chưa đăng ký (hoặc không phải student)
            request.setAttribute("myReview", myReview);

            // Lấy toàn bộ đánh giá của khóa học
            List<Review> reviews = reviewService.getCourseReviews(courseId);
            request.setAttribute("reviews", reviews);

            request.getRequestDispatcher("/WEB-INF/views/student/course-detail.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã khóa học không hợp lệ!");
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        }
    }
}