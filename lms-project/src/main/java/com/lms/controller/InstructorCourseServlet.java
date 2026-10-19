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

/**
 * ============================================================================
 * CONTROLLER: InstructorCourseServlet
 * ============================================================================
 * VAI TRÒ (INSTRUCTOR):
 * - Quản lý vòng đời khóa học thuộc sở hữu của Giảng viên:
 *   + GET  /instructor/courses        : Xem danh sách khóa học của giảng viên (trạng thái, số học viên, nút thao tác).
 *   + GET  /instructor/courses/new    : Hiển thị form tạo khóa học mới.
 *   + POST /instructor/courses/new    : Nhận dữ liệu form tạo khóa học mới (trạng thái khởi tạo: 'draft').
 *   + GET  /instructor/courses/edit   : Hiển thị form cập nhật thông tin chung của khóa học (kiểm tra quyền sở hữu).
 *   + POST /instructor/courses/edit   : Lưu thông tin chỉnh sửa (tiêu đề, mô tả, giá, thumbnail).
 *   + POST /instructor/courses/submit : Đăng khóa học ('draft' -> 'published'), yêu cầu tối thiểu 1 chương & 1 bài học.
 *   + POST /instructor/courses/delete : Xóa khóa học (chỉ cho phép xóa khi còn là 'draft').
 *   + POST /instructor/courses/appeal : Gửi đơn kháng cáo lên Admin khi khóa học bị cảnh cáo ('warning' -> 'appealed').
 * 
 * VIEW TƯƠNG ỨNG:
 *   + /WEB-INF/views/instructor/course-list.jsp (Bảng danh sách khóa học của giảng viên)
 *   + /WEB-INF/views/instructor/course-form.jsp (Form tạo mới hoặc chỉnh sửa khóa học)
 * ============================================================================
 */
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

    /**
     * Khởi tạo các Service và DAO
     */
    @Override
    public void init() throws ServletException {
        this.courseService = new CourseService();
        this.categoryDAO = new CategoryDAO();
    }

    /**
     * Hàm phụ trợ lấy thông tin User hiện tại từ Session
     * (Filter AuthFilter đã đảm bảo role 'instructor' trước khi vào Servlet này)
     */
    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (User) session.getAttribute("currentUser");
    }

    /**
     * ------------------------------------------------------------------------
     * HÀM XỬ LÝ: doGet (Hiển thị danh sách hoặc form khóa học)
     * ------------------------------------------------------------------------
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        switch (path) {
            case "/instructor/courses":
                // 1. Đọc và dọn dẹp các thông báo Flash Message
                HttpSession sess = request.getSession(false);
                if (sess != null && sess.getAttribute("flashError") != null) {
                    request.setAttribute("error", sess.getAttribute("flashError"));
                    sess.removeAttribute("flashError");
                }
                if (sess != null && sess.getAttribute("flashSuccess") != null) {
                    request.setAttribute("successMessage", sess.getAttribute("flashSuccess"));
                    sess.removeAttribute("flashSuccess");
                }

                // 2. Tải danh sách khóa học do chính Giảng viên này tạo
                List<Course> courses = courseService.getMyCoursesAsInstructor(currentUser.getId());
                request.setAttribute("courses", courses);
                
                // 3. Render bảng danh sách khóa học
                request.getRequestDispatcher("/WEB-INF/views/instructor/course-list.jsp")
                        .forward(request, response);
                break;

            case "/instructor/courses/new":
                // Hiển thị form tạo khóa học mới -> nạp sẵn danh mục Category cho dropdown
                request.setAttribute("categories", categoryDAO.findAll());
                request.getRequestDispatcher("/WEB-INF/views/instructor/course-form.jsp")
                        .forward(request, response);
                break;

            case "/instructor/courses/edit":
                // Hiển thị form sửa thông tin khóa học đã có
                int courseId = Integer.parseInt(request.getParameter("id"));
                Course course = courseService.getCourseDetail(courseId);

                // KIỂM TRA BẢO MẬT: Giảng viên chỉ được sửa khóa học do chính mình tạo ra!
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

    /**
     * ------------------------------------------------------------------------
     * HÀM XỬ LÝ: doPost (Tiếp nhận các hành động: Tạo, Sửa, Đăng, Xóa, Kháng cáo)
     * ------------------------------------------------------------------------
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        try {
            switch (path) {
                case "/instructor/courses/new":
                    // Xử lý tạo mới khóa học
                    handleCreate(request, currentUser);
                    break;

                case "/instructor/courses/edit":
                    // Xử lý cập nhật thông tin khóa học
                    handleUpdate(request, currentUser);
                    break;

                case "/instructor/courses/submit":
                    // Xử lý đăng khóa học công khai (Publish)
                    handleSubmit(request, currentUser);
                    break;

                case "/instructor/courses/delete":
                    // Xử lý xóa khóa học nháp (Draft)
                    handleDelete(request, currentUser);
                    break;

                case "/instructor/courses/appeal":
                    // Xử lý gửi kháng cáo khóa học bị cảnh cáo
                    handleAppeal(request, currentUser);
                    break;

                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
            }

            // Xử lý thành công -> chuyển hướng về trang danh sách khóa học
            response.sendRedirect(request.getContextPath() + "/instructor/courses");

        } catch (IllegalArgumentException | IllegalStateException e) {
            // Xử lý lỗi nghiệp vụ logic (chưa đủ chương/bài để đăng, khóa học không ở draft...)
            if ("/instructor/courses/appeal".equals(path) 
                || "/instructor/courses/submit".equals(path)
                || "/instructor/courses/delete".equals(path)) {
                HttpSession session = request.getSession();
                session.setAttribute("flashError", e.getMessage());
                response.sendRedirect(request.getContextPath() + "/instructor/courses");
            } else {
                // Lỗi khi submit form create/edit -> giữ lại form kèm thông báo lỗi
                request.setAttribute("error", e.getMessage());
                request.setAttribute("categories", categoryDAO.findAll());
                request.getRequestDispatcher("/WEB-INF/views/instructor/course-form.jsp")
                        .forward(request, response);
            }

        } catch (SecurityException e) {
            // Lỗi xâm phạm quyền sở hữu khóa học
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

    /**
     * Thu thập tham số từ form và tạo khóa học mới
     */
    private void handleCreate(HttpServletRequest request, User currentUser) {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String categoryIdStr = request.getParameter("categoryId");
        String priceStr = request.getParameter("price");
        String thumbnailUrl = request.getParameter("thumbnailUrl");

        Integer categoryId = (categoryIdStr != null && !categoryIdStr.isEmpty())
                ? Integer.parseInt(categoryIdStr) : null;
        BigDecimal price = (priceStr != null && !priceStr.isEmpty())
                ? new BigDecimal(priceStr) : BigDecimal.ZERO;

        courseService.createCourse(currentUser.getId(), title, description, categoryId, price, thumbnailUrl);
    }

    /**
     * Cập nhật thông tin tiêu đề, mô tả, giá, thumbnail của khóa học
     */
    private void handleUpdate(HttpServletRequest request, User currentUser) {
        int courseId = Integer.parseInt(request.getParameter("id"));
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String categoryIdStr = request.getParameter("categoryId");
        String priceStr = request.getParameter("price");
        String thumbnailUrl = request.getParameter("thumbnailUrl");

        Integer categoryId = (categoryIdStr != null && !categoryIdStr.isEmpty())
                ? Integer.parseInt(categoryIdStr) : null;
        BigDecimal price = (priceStr != null && !priceStr.isEmpty())
                ? new BigDecimal(priceStr) : BigDecimal.ZERO;

        courseService.updateCourse(courseId, currentUser.getId(), title, description, categoryId, price, thumbnailUrl);
    }

    /**
     * Đăng khóa học (Publish): Chuyển trạng thái từ draft -> published
     * (Tầng Service sẽ kiểm tra điều kiện bắt buộc: phải có tối thiểu 1 chương và 1 bài học)
     */
    private void handleSubmit(HttpServletRequest request, User currentUser) {
        int courseId = Integer.parseInt(request.getParameter("id"));
        courseService.publishCourse(courseId, currentUser.getId());
    }

    /**
     * Xóa khóa học: Chỉ cho phép xóa khi khóa học còn ở trạng thái nháp (draft)
     */
    private void handleDelete(HttpServletRequest request, User currentUser) {
        int courseId = Integer.parseInt(request.getParameter("id"));
        courseService.deleteCourse(courseId, currentUser.getId());
    }

    /**
     * Kháng cáo khóa học: Gửi lý do giải trình khi khóa học bị Admin cảnh cáo (warning -> appealed)
     */
    private void handleAppeal(HttpServletRequest request, User currentUser) {
        int courseId = Integer.parseInt(request.getParameter("id"));
        String appealMessage = request.getParameter("appealMessage");
        courseService.appealCourse(courseId, currentUser.getId(), appealMessage);
    }
}