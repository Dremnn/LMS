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

/**
 * ============================================================================
 * CONTROLLER: CourseContentServlet
 * ============================================================================
 * VAI TRÒ (INSTRUCTOR - QUẢN LÝ CHƯƠNG TRÌNH HỌC):
 * - Quản lý cấu trúc Chương (Section) và Bài học (Lesson) của khóa học:
 *   + GET  /instructor/courses/manage          : Hiển thị giao diện quản lý cấu trúc khóa học (danh sách chương, bài học).
 *   + POST /instructor/courses/sections/add    : Thêm chương học mới vào khóa học.
 *   + POST /instructor/courses/sections/edit   : Đổi tên chương học.
 *   + POST /instructor/courses/sections/delete : Xóa chương học (xóa luôn các bài học bên trong).
 *   + POST /instructor/courses/sections/reorder: Thay đổi số thứ tự hiển thị của chương.
 *   + POST /instructor/courses/lessons/add     : Thêm bài học mới vào chương (tiêu đề, video, tài liệu, mô tả,
 *                                                thiết lập ĐIỀU KIỆN TEST (Quiz/Code/Assignment) để học viên mở khóa bài tiếp theo).
 *   + POST /instructor/courses/lessons/edit    : Chỉnh sửa bài học và cập nhật lại bài kiểm tra điều kiện.
 *   + POST /instructor/courses/lessons/delete  : Xóa bài học khỏi chương.
 * 
 * VIEW TƯƠNG ỨNG:
 *   + /WEB-INF/views/instructor/course-manage.jsp (Giao diện quản lý nội dung khóa học)
 * ============================================================================
 */
@WebServlet(urlPatterns = {
    "/instructor/courses/manage",
    "/courses/manage",
    "/instructor/courses/sections/add",
    "/instructor/courses/sections/edit",
    "/instructor/courses/sections/delete",
    "/instructor/courses/sections/reorder",
    "/instructor/courses/lessons/add",
    "/instructor/courses/lessons/edit",
    "/instructor/courses/lessons/delete"
})
public class CourseContentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CourseService courseService;

    /**
     * Khởi tạo tầng nghiệp vụ CourseService
     */
    @Override
    public void init() throws ServletException {
        this.courseService = new CourseService();
    }

    /**
     * Lấy thông tin tài khoản hiện tại từ Session
     */
    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (User) session.getAttribute("currentUser");
    }

    /**
     * ------------------------------------------------------------------------
     * HÀM XỬ LÝ: doGet (Giao diện Quản lý Chương & Bài học của khóa học)
     * ------------------------------------------------------------------------
     * Mục đích:
     * - Nhận `id` khóa học.
     * - Tải toàn bộ cấu trúc khóa học (các Section kèm danh sách Lesson lồng nhau).
     * - Kiểm tra quyền sở hữu (Giảng viên chỉ quản lý khóa học của mình, Admin quản lý tất cả).
     * - Tải danh sách Quiz và Assignment của khóa học (để Giảng viên chọn làm bài kiểm tra điều kiện mở khóa bài).
     * - Tìm ID bài học đầu tiên (`firstLessonId`) để cung cấp nút "Xem bài học ở giao diện học viên".
     * - Forward sang /WEB-INF/views/instructor/course-manage.jsp.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        // 1. Đọc và dọn dẹp flash message (nếu có lỗi từ lần redirect trước)
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("flashError") != null) {
            request.setAttribute("error", session.getAttribute("flashError"));
            session.removeAttribute("flashError");
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/instructor/courses");
            return;
        }

        try {
            int courseId = Integer.parseInt(idParam);
            // Lấy thông tin khóa học kèm toàn bộ danh sách Chương và Bài học lồng nhau
            Course course = courseService.getCourseDetail(courseId);
            if (course == null) {
                response.sendRedirect(request.getContextPath() + "/instructor/courses");
                return;
            }

            // 2. KIỂM TRA PHÂN QUYỀN:
            // Giảng viên chỉ được quản lý khóa học do chính mình tạo
            // Quản trị viên (Admin) được xem tất cả (để duyệt hoặc kiểm tra nội dung)
            boolean isAdmin = "admin".equals(currentUser.getRole());
            if (!isAdmin && course.getInstructorId() != currentUser.getId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền quản lý khóa học này!");
                return;
            }

            // 3. Tải danh sách Quiz và Bài tập Assignment để Giảng viên chọn gắn làm điều kiện mở khóa bài
            java.util.List<com.lms.model.Quiz> quizzes = new com.lms.service.QuizService().getAllQuizzesForCourse(course);
            java.util.List<com.lms.model.Assignment> assignments =
                    new com.lms.service.AssignmentService().listForInstructor(course.getId(), currentUser);

            // 4. Tìm ID của bài học đầu tiên (dùng cho nút xem trước bài học ở góc trên giao diện)
            Integer firstLessonId = null;
            if (course.getSectionsCache() != null) {
                for (com.lms.model.Section s : course.getSectionsCache()) {
                    if (s.getLessons() != null && !s.getLessons().isEmpty()) {
                        firstLessonId = s.getLessons().get(0).getId();
                        break;
                    }
                }
            }

            // 5. Đẩy dữ liệu sang JSP
            request.setAttribute("course", course);
            request.setAttribute("quizzes", quizzes);
            request.setAttribute("assignments", assignments);
            request.setAttribute("firstLessonId", firstLessonId);
            request.getRequestDispatcher("/WEB-INF/views/instructor/course-manage.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã khóa học không hợp lệ!");
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        }
    }

    /**
     * ------------------------------------------------------------------------
     * HÀM XỬ LÝ: doPost (Tiếp nhận Thêm/Sửa/Xóa Chương và Bài học)
     * ------------------------------------------------------------------------
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        int courseId = -1;

        try {
            // =================================================================
            // 1. CÁC HÀNH ĐỘNG VỚI CHƯƠNG HỌC (SECTION)
            // =================================================================
            if ("/instructor/courses/sections/add".equals(path)) {
                // Thêm một chương mới vào cuối khóa học
                courseId = Integer.parseInt(request.getParameter("courseId"));
                String title = request.getParameter("title");
                courseService.addSection(courseId, currentUser.getId(), title);

            } else if ("/instructor/courses/sections/edit".equals(path)) {
                // Đổi tên chương học
                courseId = Integer.parseInt(request.getParameter("courseId"));
                int sectionId = Integer.parseInt(request.getParameter("sectionId"));
                String title = request.getParameter("title");
                courseService.updateSection(sectionId, currentUser.getId(), title);

            } else if ("/instructor/courses/sections/delete".equals(path)) {
                // Xóa chương học (tất cả bài học bên trong sẽ bị xóa theo và tự dồn số thứ tự)
                courseId = Integer.parseInt(request.getParameter("courseId"));
                int sectionId = Integer.parseInt(request.getParameter("sectionId"));
                courseService.deleteSection(sectionId, currentUser.getId());

            } else if ("/instructor/courses/sections/reorder".equals(path)) {
                // Đổi vị trí thứ tự của chương
                courseId = Integer.parseInt(request.getParameter("courseId"));
                int sectionId = Integer.parseInt(request.getParameter("sectionId"));
                int targetOrder = Integer.parseInt(request.getParameter("targetOrder"));
                courseService.reorderSection(sectionId, currentUser.getId(), targetOrder);

            // =================================================================
            // 2. CÁC HÀNH ĐỘNG VỚI BÀI HỌC (LESSON)
            // =================================================================
            } else if ("/instructor/courses/lessons/add".equals(path)) {
                // THÊM BÀI HỌC MỚI VÀO CHƯƠNG
                int sectionId = Integer.parseInt(request.getParameter("sectionId"));
                courseId = Integer.parseInt(request.getParameter("courseId"));

                String title = request.getParameter("title");
                String videoUrl = request.getParameter("videoUrl");
                String documentUrl = request.getParameter("documentUrl");
                String durationStr = request.getParameter("durationMinutes");
                String description = request.getParameter("description");
                if (description != null) {
                    description = description.trim();
                    if (description.isEmpty()) description = null;
                }

                Integer duration = (durationStr != null && !durationStr.isEmpty())
                        ? Integer.parseInt(durationStr) : null;

                // Các điểm dừng video checkpoint (nếu có)
                String cpSecStr = request.getParameter("videoCheckpointSeconds");
                Integer videoCheckpointSeconds = (cpSecStr != null && !cpSecStr.trim().isEmpty()) ? Integer.parseInt(cpSecStr.trim()) : null;
                String checkpointType = request.getParameter("checkpointType");
                if (checkpointType != null && checkpointType.trim().isEmpty()) checkpointType = null;
                String cpRefStr = request.getParameter("checkpointRefId");
                Integer checkpointRefId = (cpRefStr != null && !cpRefStr.trim().isEmpty()) ? Integer.parseInt(cpRefStr.trim()) : null;

                // THIẾT LẬP ĐIỀU KIỆN TEST ĐỂ MỞ KHÓA BÀI KẾ TIẾP:
                // assessmentType: "none" (tự tick), "quiz" (đạt pass quiz), "code" (100% test case), "assignment" (nộp bài)
                String assessmentType = request.getParameter("assessmentType");
                String assessRefStr = request.getParameter("assessmentRefId");
                Integer assessmentRefId = (assessRefStr != null && !assessRefStr.trim().isEmpty()) ? Integer.parseInt(assessRefStr.trim()) : null;

                // 2.1. Thêm bản ghi bài học mới vào bảng lessons
                com.lms.model.Lesson createdLesson = courseService.addLesson(sectionId, currentUser.getId(), title, videoUrl, documentUrl, duration, description);
                if (createdLesson != null) {
                    // 2.2. Gắn điểm dừng video (nếu có)
                    if (videoCheckpointSeconds != null || checkpointType != null) {
                        new com.lms.dao.LessonDAO().updateCheckpoint(createdLesson.getId(), videoCheckpointSeconds, checkpointType, checkpointRefId);
                    }
                    // 2.3. Lưu cấu hình bài kiểm tra điều kiện vào cột assessment_type và assessment_ref_id
                    if (assessmentType != null && !assessmentType.trim().isEmpty()) {
                        new com.lms.dao.LessonDAO().updateAssessment(createdLesson.getId(), assessmentType, assessmentRefId);
                    }
                }

            } else if ("/instructor/courses/lessons/edit".equals(path)) {
                // CẬP NHẬT THÔNG TIN BÀI HỌC VÀ ĐIỀU KIỆN MỞ KHÓA
                courseId = Integer.parseInt(request.getParameter("courseId"));
                int lessonId = Integer.parseInt(request.getParameter("lessonId"));

                String title = request.getParameter("title");
                String videoUrl = request.getParameter("videoUrl");
                String documentUrl = request.getParameter("documentUrl");
                String durationStr = request.getParameter("durationMinutes");
                String description = request.getParameter("description");
                if (description != null) {
                    description = description.trim();
                    if (description.isEmpty()) description = null;
                }

                Integer duration = (durationStr != null && !durationStr.isEmpty())
                        ? Integer.parseInt(durationStr) : null;

                String cpSecStr = request.getParameter("videoCheckpointSeconds");
                Integer videoCheckpointSeconds = (cpSecStr != null && !cpSecStr.trim().isEmpty()) ? Integer.parseInt(cpSecStr.trim()) : null;
                String checkpointType = request.getParameter("checkpointType");
                if (checkpointType != null && checkpointType.trim().isEmpty()) checkpointType = null;
                String cpRefStr = request.getParameter("checkpointRefId");
                Integer checkpointRefId = (cpRefStr != null && !cpRefStr.trim().isEmpty()) ? Integer.parseInt(cpRefStr.trim()) : null;

                String assessmentType = request.getParameter("assessmentType");
                String assessRefStr = request.getParameter("assessmentRefId");
                Integer assessmentRefId = (assessRefStr != null && !assessRefStr.trim().isEmpty()) ? Integer.parseInt(assessRefStr.trim()) : null;

                // Cập nhật thông tin nội dung bài học
                courseService.updateLesson(lessonId, currentUser.getId(), title, videoUrl, documentUrl, duration, description);
                new com.lms.dao.LessonDAO().updateCheckpoint(lessonId, videoCheckpointSeconds, checkpointType, checkpointRefId);
                // Cập nhật lại điều kiện bài test mở khóa
                new com.lms.dao.LessonDAO().updateAssessment(lessonId, assessmentType, assessmentRefId);

            } else if ("/instructor/courses/lessons/delete".equals(path)) {
                // XÓA BÀI HỌC
                courseId = Integer.parseInt(request.getParameter("courseId"));
                int lessonId = Integer.parseInt(request.getParameter("lessonId"));
                courseService.deleteLesson(lessonId, currentUser.getId());

            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            // Chuyển hướng quay lại đúng trang quản lý nội dung của khóa học đó
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