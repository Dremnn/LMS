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

/**
 * ============================================================================
 * CONTROLLER: CourseBrowseServlet
 * ============================================================================
 * VAI TRÒ (STUDENT / GUEST):
 * - Xử lý chức năng duyệt, tìm kiếm và xem chi tiết khóa học.
 * - URL Routing:
 *   + GET /courses        : Danh sách tất cả khóa học đã publish, hỗ trợ tìm kiếm, lọc danh mục, sắp xếp.
 *   + GET /courses/detail : Chi tiết 1 khóa học (mô tả, danh sách chương & bài học, đánh giá, kiểm tra đăng ký).
 * 
 * VIEW TƯƠNG ỨNG:
 *   + /WEB-INF/views/student/course-browse.jsp (Giao diện khám phá khóa học)
 *   + /WEB-INF/views/student/course-detail.jsp (Giao diện chi tiết khóa học & chương trình học)
 * ============================================================================
 */
@WebServlet(urlPatterns = {"/courses", "/courses/detail"})
public class CourseBrowseServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Các tầng Service và DAO hỗ trợ xử lý nghiệp vụ
    private CourseService courseService;
    private CategoryDAO categoryDAO;
    private EnrollmentService enrollmentService;
    private ReviewService reviewService;

    /**
     * Khởi tạo các Service và DAO khi Servlet được load lần đầu vào container.
     */
    @Override
    public void init() throws ServletException {
        this.courseService = new CourseService();
        this.categoryDAO = new CategoryDAO();
        this.enrollmentService = new EnrollmentService();
        this.reviewService = new ReviewService();
    }

    /**
     * Tiếp nhận tất cả các yêu cầu GET gửi đến /courses và /courses/detail.
     * Phân luồng xử lý tùy theo URL người dùng truy cập.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/courses/detail".equals(path)) {
            // Xem thông tin chi tiết một khóa học cụ thể
            showCourseDetail(request, response);
        } else {
            // Duyệt danh sách hoặc tìm kiếm khóa học
            showCourseBrowse(request, response);
        }
    }

    /**
     * ------------------------------------------------------------------------
     * HÀM XỬ LÝ: showCourseBrowse
     * ------------------------------------------------------------------------
     * Mục đích:
     * - Lấy các tham số lọc: từ khóa tìm kiếm (keyword), danh mục (categoryId), tiêu chí sắp xếp (sortBy).
     * - Gọi CourseService để lấy danh sách các khóa học đã được duyệt (status = 'published').
     * - Đẩy dữ liệu ra request attribute và forward sang trang course-browse.jsp.
     */
    private void showCourseBrowse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Đọc các tham số tìm kiếm & bộ lọc từ query string
        String keyword = request.getParameter("keyword"); // Từ khóa tìm kiếm theo tiêu đề/mô tả

        String categoryIdStr = request.getParameter("categoryId"); // Lọc theo danh mục
        Integer categoryId = (categoryIdStr != null && !categoryIdStr.isEmpty())
                ? Integer.parseInt(categoryIdStr) : null;

        String sortBy = request.getParameter("sortBy"); // Sắp xếp: "newest" (mới nhất), "popular" (phổ biến), "rating" (đánh giá sao)
        if (sortBy == null || sortBy.isEmpty()) {
            sortBy = "newest";
        }

        // 2. Gọi tầng Service để thực hiện tìm kiếm và sắp xếp
        List<Course> courses = courseService.searchCourses(keyword, categoryId, sortBy);

        // 3. Đưa dữ liệu vào request attributes để file JSP hiển thị
        request.setAttribute("courses", courses);                         // Danh sách khóa học tìm thấy
        request.setAttribute("categories", categoryDAO.findAll());         // Danh mục để hiển thị trên dropdown
        request.setAttribute("keyword", keyword);                         // Giữ lại từ khóa vừa tìm trên ô search
        request.setAttribute("selectedCategoryId", categoryId);           // Giữ lại danh mục đang chọn
        request.setAttribute("sortBy", sortBy);                           // Giữ lại tiêu chí sắp xếp đang chọn

        // 4. Chuyển tiếp (forward) sang giao diện danh sách khóa học
        request.getRequestDispatcher("/WEB-INF/views/student/course-browse.jsp")
                .forward(request, response);
    }

    /**
     * ------------------------------------------------------------------------
     * HÀM XỬ LÝ: showCourseDetail
     * ------------------------------------------------------------------------
     * Mục đích:
     * - Nhận ID khóa học (param: id).
     * - Gọi CourseService.getCourseDetail(courseId) để nạp thông tin khóa học kèm toàn bộ Sections và Lessons lồng nhau.
     * - Kiểm tra nếu học viên hiện tại đã đăng ký khóa học này chưa (để JSP quyết định hiện nút "Đăng ký" hay "Tiếp tục học").
     * - Tải danh sách đánh giá/bình chọn (Reviews) của khóa học.
     * - Forward sang trang course-detail.jsp.
     */
    private void showCourseDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Đọc flash message (nếu vừa redirect từ EnrollmentServlet sau khi đăng ký hoặc hoàn tiền)
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

        // 2. Validate tham số ID khóa học
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu mã khóa học!");
            return;
        }

        try {
            int courseId = Integer.parseInt(idParam);
            // Lấy chi tiết khóa học (bao gồm cả danh sách chương Section và bài học Lesson lồng nhau bên trong)
            Course course = courseService.getCourseDetail(courseId);

            // 3. Kiểm tra trạng thái khóa học: Chỉ cho phép xem nếu khóa học đã published hoặc đang cảnh cáo/kháng cáo
            List<String> allowedStatuses = Arrays.asList("published", "appealed", "warning");
            if (!allowedStatuses.contains(course.getStatus())) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Khóa học không tồn tại hoặc không thể truy cập!");
                return;
            }

            request.setAttribute("course", course);

            // 4. Kiểm tra quyền của người dùng hiện tại (nếu là student, xem đã enroll khóa học này chưa)
            // Kết quả (enrollment != null) sẽ được JSP dùng để:
            // - Hiện nút "Đăng ký học" (nếu null)
            // - Hiện thanh % tiến độ, nút "Tiếp tục học" và mở link bấm vào từng bài học (nếu đã enroll)
            User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
            Enrollment enrollment = null;
            Review myReview = null;
            if (currentUser != null && "student".equalsIgnoreCase(currentUser.getRole())) {
                enrollment = enrollmentService.getEnrollmentIfExists(currentUser.getId(), courseId);
                myReview = reviewService.getStudentReview(currentUser.getId(), courseId);
            }
            request.setAttribute("enrollment", enrollment); // null nếu chưa đăng ký (hoặc không phải student)
            request.setAttribute("myReview", myReview);

            // 5. Lấy toàn bộ đánh giá của học viên về khóa học này
            List<Review> reviews = reviewService.getCourseReviews(courseId);
            request.setAttribute("reviews", reviews);

            // 6. Forward sang giao diện chi tiết khóa học
            request.getRequestDispatcher("/WEB-INF/views/student/course-detail.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã khóa học không hợp lệ!");
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        }
    }
}