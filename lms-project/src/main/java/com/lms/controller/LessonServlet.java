package com.lms.controller;

import com.lms.dao.LessonDAO;
import com.lms.dao.SectionDAO;  
import com.lms.model.Course;
import com.lms.model.Enrollment;
import com.lms.model.Lesson;
import com.lms.model.LessonProgress;
import com.lms.model.Section;
import com.lms.model.User;
import com.lms.service.CourseService;
import com.lms.service.EnrollmentService;
import com.lms.util.VideoUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet(urlPatterns = {"/student/lessons/view", "/student/lessons/complete"})
public class LessonServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private EnrollmentService enrollmentService;
    private CourseService courseService;
    private LessonDAO lessonDAO;
    private SectionDAO sectionDAO;

    @Override
    public void init() throws ServletException {
        this.enrollmentService = new EnrollmentService();
        this.courseService = new CourseService();
        this.lessonDAO = new LessonDAO();
        this.sectionDAO = new SectionDAO();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (User) session.getAttribute("currentUser");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        // Đọc flash message (nếu vừa redirect từ doPost với lỗi)
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("flashError") != null) {
            request.setAttribute("error", session.getAttribute("flashError"));
            session.removeAttribute("flashError");
        }

        try {
            int lessonId = Integer.parseInt(request.getParameter("lessonId"));

            // 1. Tìm bài học -> tìm chương chứa nó -> tìm khóa học chứa chương đó
            Lesson lesson = lessonDAO.findById(lessonId);
            if (lesson == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Bài học không tồn tại!");
                return;
            }

            Section section = sectionDAO.findById(lesson.getSectionId());
            if (section == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Chương học không tồn tại!");
                return;
            }

            int courseId = section.getCourseId();

            // 3. Lấy toàn bộ nội dung khóa học (để hiển thị sidebar danh sách chương/bài)
            Course course = courseService.getCourseDetail(courseId);

            // 2. Kiểm tra quyền truy cập (Admin/Instructor chủ khóa học được xem trước, Student phải đăng ký)
            boolean isPreview = false;
            if (currentUser != null && "admin".equals(currentUser.getRole())) {
                isPreview = true;
            } else if (currentUser != null && "instructor".equals(currentUser.getRole())) {
                if (course != null && course.getInstructorId() == currentUser.getId()) {
                    isPreview = true;
                } else {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem khóa học của giảng viên khác!");
                    return;
                }
            }

            Enrollment enrollment = null;
            if (!isPreview) {
                enrollment = enrollmentService.getEnrollmentOrThrow(currentUser.getId(), courseId);
            }

            // Lấy thêm danh sách Quiz để hiển thị ở sidebar
            List<com.lms.model.Quiz> quizzes = new com.lms.service.QuizService().getAllQuizzesForCourse(course);

            // 4. Lấy danh sách tiến độ đã hoàn thành
            Set<Integer> completedLessonIds = new HashSet<>();
            if (enrollment != null) {
                List<LessonProgress> progressList = enrollmentService.getLessonProgressList(enrollment.getId());
                for (LessonProgress p : progressList) {
                    if (p.isCompleted()) {
                        completedLessonIds.add(p.getLessonId());
                    }
                }
            }

            // Danh sách bài tập của khóa học
            List<com.lms.model.Assignment> assignments;
            if (isPreview) {
                assignments = new com.lms.dao.AssignmentDAO().findByCourseForInstructor(courseId);
            } else {
                assignments = new com.lms.dao.AssignmentDAO().findByCourseForStudent(courseId, currentUser.getId());
            }

            String youtubeEmbedUrl = VideoUtil.getYouTubeEmbedUrl(lesson.getVideoUrl());

            request.setAttribute("course", course);
            request.setAttribute("currentLesson", lesson);
            request.setAttribute("enrollment", enrollment);
            request.setAttribute("isPreview", isPreview);
            request.setAttribute("completedLessonIds", completedLessonIds);
            request.setAttribute("youtubeEmbedUrl", youtubeEmbedUrl); // null nếu không phải YouTube
            request.setAttribute("quizzes", quizzes); // Truyền xuống JSP
            request.setAttribute("assignments", assignments);

            request.getRequestDispatcher("/WEB-INF/views/student/lesson-view.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã bài học không hợp lệ!");
        } catch (IllegalStateException e) {
            // Chưa đăng ký khóa học này
            response.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        int lessonId = -1;

        try {
            lessonId = Integer.parseInt(request.getParameter("lessonId"));
            int courseId = Integer.parseInt(request.getParameter("courseId"));

            // Giảng viên và Quản trị viên không được đánh dấu tiến độ bài học
            if (currentUser != null && ("instructor".equals(currentUser.getRole()) || "admin".equals(currentUser.getRole()))) {
                HttpSession session = request.getSession();
                session.setAttribute("flashError", "Giảng viên và Quản trị viên không thể đánh dấu tiến độ hoàn thành bài học!");
                response.sendRedirect(request.getContextPath() + "/student/lessons/view?lessonId=" + lessonId);
                return;
            }

            // Checkbox HTML: nếu được tick, giá trị param sẽ tồn tại (VD "on" hoặc "true");
            // nếu KHÔNG tick, checkbox sẽ hoàn toàn KHÔNG được gửi lên request
            String completedParam = request.getParameter("completed");
            boolean completed = (completedParam != null);

            enrollmentService.toggleLessonCompletion(currentUser.getId(), courseId, lessonId, completed);

            // Quay lại đúng trang xem bài học đó, đã cập nhật tiến độ mới
            response.sendRedirect(request.getContextPath() + "/student/lessons/view?lessonId=" + lessonId);

        } catch (IllegalStateException | IllegalArgumentException e) {
            HttpSession session = request.getSession();
            session.setAttribute("flashError", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/student/lessons/view?lessonId=" + lessonId);

        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("flashError", "Đã xảy ra lỗi hệ thống!");
            response.sendRedirect(request.getContextPath() + "/student/lessons/view?lessonId=" + lessonId);
        }
    }
}