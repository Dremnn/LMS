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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;


@WebServlet(urlPatterns = {"/student/lessons/view", "/student/lessons/complete"})
public class LessonServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private EnrollmentService enrollmentService;
    private CourseService courseService;
    private LessonDAO lessonDAO;
    private SectionDAO sectionDAO;

    /**
     * Khởi tạo các Service và DAO
     */
    @Override
    public void init() throws ServletException {
        this.enrollmentService = new EnrollmentService();
        this.courseService = new CourseService();
        this.lessonDAO = new LessonDAO();
        this.sectionDAO = new SectionDAO();
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
     * HÀM XỬ LÝ: doGet (Xem nội dung bài học & Thuật toán mở khóa bài học)
     * ------------------------------------------------------------------------
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        // Đọc flash message nếu vừa redirect với thông báo lỗi
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("flashError") != null) {
            request.setAttribute("error", session.getAttribute("flashError"));
            session.removeAttribute("flashError");
        }

        try {
            int lessonId = Integer.parseInt(request.getParameter("lessonId"));

            // 1. Tìm bài học -> tìm chương chứa bài -> tìm khóa học chứa chương đó
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

            // 2. Lấy toàn bộ cấu trúc khóa học (để hiển thị sidebar danh sách chương/bài)
            Course course = courseService.getCourseDetail(courseId);

            // 3. KIỂM TRA PHÂN QUYỀN TRUY CẬP:
            // - Admin hoặc Giảng viên sở hữu khóa học: được xem trước (Preview mode)
            // - Học viên bình thường: bắt buộc phải có Enrollment hợp lệ
            boolean isPreview = false;
            if (currentUser != null && "admin".equals(currentUser.getRole())) {
                isPreview = true;
            } else if (currentUser != null && "instructor".equals(currentUser.getRole())) {
                if (course != null && course.getInstructorId() == currentUser.getId()) {
                    isPreview = true; // Giảng viên chủ khóa học được quyền xem trước
                } else {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem khóa học của giảng viên khác!");
                    return;
                }
            }

            Enrollment enrollment = null;
            if (!isPreview) {
                // Nếu là học viên: kiểm tra đã ghi danh chưa (chưa sẽ ném IllegalStateException)
                enrollment = enrollmentService.getEnrollmentOrThrow(currentUser.getId(), courseId);
            }

            // Lấy danh sách Quiz để hiển thị ở sidebar
            List<com.lms.model.Quiz> quizzes = new com.lms.service.QuizService().getAllQuizzesForCourse(course);

            // 4. LẤY DANH SÁCH BÀI HỌC ĐÃ HOÀN THÀNH:
            Set<Integer> completedLessonIds = new HashSet<>();
            if (enrollment != null) {
                List<LessonProgress> progressList = enrollmentService.getLessonProgressList(enrollment.getId());
                for (LessonProgress p : progressList) {
                    if (p.isCompleted()) {
                        completedLessonIds.add(p.getLessonId());
                    }
                }
            }

            // Tập hợp toàn bộ bài học theo thứ tự tuần tự trong toàn bộ khóa học
            List<Lesson> allOrderedLessons = new ArrayList<>();
            if (course != null && course.getSectionsCache() != null) {
                for (Section sec : course.getSectionsCache()) {
                    if (sec.getLessons() != null) {
                        allOrderedLessons.addAll(sec.getLessons());
                    }
                }
            }

            // 5. THUẬT TOÁN TÍNH TOÁN TRẠNG THÁI KHÓA (LOCK STATUS) CHO TỪNG BÀI:
            Map<Integer, Boolean> lessonLockedMap = new HashMap<>();
            Integer firstIncompleteOrUnlockedId = null;

            if (isPreview) {
                // ĐỐI VỚI GIẢNG VIÊN VÀ ADMIN: MỞ KHÓA TẤT CẢ CÁC BÀI HỌC (false = không bị khóa)
                for (Lesson l : allOrderedLessons) {
                    lessonLockedMap.put(l.getId(), false);
                }
            } else {
                // ĐỐI VỚI HỌC VIÊN: MỞ KHÓA TUẦN TỰ (Bài K chỉ mở khi bài K-1 đã hoàn thành)
                boolean prevCompleted = true; // Bài học đầu tiên của khóa học luôn luôn được mở!
                for (Lesson l : allOrderedLessons) {
                    boolean isCompleted = completedLessonIds.contains(l.getId());
                    if (prevCompleted) {
                        lessonLockedMap.put(l.getId(), false); // Mở khóa bài này
                        if (!isCompleted && firstIncompleteOrUnlockedId == null) {
                            firstIncompleteOrUnlockedId = l.getId();
                        }
                    } else {
                        lessonLockedMap.put(l.getId(), true);  // Khóa bài này (học viên không được click)
                    }
                    prevCompleted = isCompleted; // Cập nhật cờ: bài tiếp theo chỉ mở nếu bài này đã hoàn thành
                }

                if (firstIncompleteOrUnlockedId == null && !allOrderedLessons.isEmpty()) {
                    firstIncompleteOrUnlockedId = allOrderedLessons.get(0).getId();
                }

                // Kiểm tra bảo mật: Nếu học viên cố tình nhập link URL trực tiếp vào bài đang bị khóa
                if (Boolean.TRUE.equals(lessonLockedMap.get(lesson.getId()))) {
                    HttpSession sess = request.getSession();
                    sess.setAttribute("flashError", "Bài học này đang bị khóa. Bạn cần hoàn thành bài học trước để mở khóa!");
                    response.sendRedirect(request.getContextPath() + "/student/lessons/view?lessonId=" + firstIncompleteOrUnlockedId);
                    return;
                }
            }

            // 6. KIỂM TRA ĐIỀU KIỆN LÀM TEST ĐỂ HOÀN THÀNH BÀI HỌC (Quiz / Code / Assignment):
            String aType = lesson.getAssessmentType(); // Kiểu bài kiểm tra: "none", "quiz", "code", "assignment"
            if (aType != null && !"none".equalsIgnoreCase(aType)) {
                
                // Trường hợp 1: Bài học yêu cầu vượt qua bài QUIZ trắc nghiệm
                if ("quiz".equalsIgnoreCase(aType) && lesson.getAssessmentRefId() != null) {
                    com.lms.model.Quiz assessQuiz = new com.lms.dao.QuizDAO().findById(lesson.getAssessmentRefId());
                    request.setAttribute("assessmentQuiz", assessQuiz);
                    if (currentUser != null) {
                        boolean hasPassedQuiz = new com.lms.dao.QuizAttemptDAO().hasStudentPassed(currentUser.getId(), lesson.getAssessmentRefId());
                        request.setAttribute("hasPassedAssessment", hasPassedQuiz);
                        // Nếu đã đạt điểm Pass mà bài học chưa đánh dấu hoàn thành -> Tự động kích hoạt hoàn thành bài học!
                        if (hasPassedQuiz && !completedLessonIds.contains(lesson.getId()) && enrollment != null) {
                            enrollmentService.toggleLessonCompletion(currentUser.getId(), courseId, lesson.getId(), true);
                            completedLessonIds.add(lesson.getId());
                        }
                    }
                
                // Trường hợp 2: Bài học yêu cầu vượt qua bài tập CODE thực hành
                } else if ("code".equalsIgnoreCase(aType)) {
                    com.lms.model.CodingExercise assessCode = new com.lms.dao.CodingExerciseDAO().findByLessonId(lesson.getId());
                    request.setAttribute("assessmentCode", assessCode);
                    if (currentUser != null && assessCode != null) {
                        boolean hasPassedCode = new com.lms.dao.CodingExerciseDAO().hasStudentPassed(assessCode.getId(), currentUser.getId());
                        request.setAttribute("hasPassedAssessment", hasPassedCode);
                        // Nếu đã pass 100% test cases -> Tự động hoàn thành bài học
                        if (hasPassedCode && !completedLessonIds.contains(lesson.getId()) && enrollment != null) {
                            enrollmentService.toggleLessonCompletion(currentUser.getId(), courseId, lesson.getId(), true);
                            completedLessonIds.add(lesson.getId());
                        }
                    }
                
                // Trường hợp 3: Bài học yêu cầu nộp file bài tập ASSIGNMENT
                } else if ("assignment".equalsIgnoreCase(aType) && lesson.getAssessmentRefId() != null) {
                    com.lms.model.Assignment assessAsg = new com.lms.dao.AssignmentDAO().findById(lesson.getAssessmentRefId());
                    request.setAttribute("assessmentAssignment", assessAsg);
                    if (currentUser != null) {
                        boolean hasSubmittedAsg = new com.lms.dao.AssignmentSubmissionDAO().findByAssignmentAndStudent(lesson.getAssessmentRefId(), currentUser.getId()) != null;
                        request.setAttribute("hasPassedAssessment", hasSubmittedAsg);
                        // Nếu đã nộp bài tập -> Tự động hoàn thành bài học
                        if (hasSubmittedAsg && !completedLessonIds.contains(lesson.getId()) && enrollment != null) {
                            enrollmentService.toggleLessonCompletion(currentUser.getId(), courseId, lesson.getId(), true);
                            completedLessonIds.add(lesson.getId());
                        }
                    }
                }
            }

            // Danh sách bài tập lớn của khóa học
            List<com.lms.model.Assignment> assignments;
            if (isPreview) {
                assignments = new com.lms.dao.AssignmentDAO().findByCourseForInstructor(courseId);
            } else {
                assignments = new com.lms.dao.AssignmentDAO().findByCourseForStudent(courseId, currentUser.getId());
            }

            // Chuyển đổi link YouTube sang định dạng Embed iframe
            String youtubeEmbedUrl = VideoUtil.getYouTubeEmbedUrl(lesson.getVideoUrl());

            // 7. Gửi các đối tượng ra JSP để hiển thị
            request.setAttribute("course", course);
            request.setAttribute("currentLesson", lesson);
            request.setAttribute("enrollment", enrollment);
            request.setAttribute("isPreview", isPreview);
            request.setAttribute("completedLessonIds", completedLessonIds); // Set chứa ID các bài đã xong
            request.setAttribute("lessonLockedMap", lessonLockedMap);       // Map xác định bài nào bị khóa
            request.setAttribute("youtubeEmbedUrl", youtubeEmbedUrl);
            request.setAttribute("quizzes", quizzes);
            request.setAttribute("assignments", assignments);

            request.getRequestDispatcher("/WEB-INF/views/student/lesson-view.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã bài học không hợp lệ!");
        } catch (IllegalStateException e) {
            // Học viên chưa đăng ký khóa học này
            response.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        }
    }

    /**
     * ------------------------------------------------------------------------
     * HÀM XỬ LÝ: doPost (Học viên tự đánh dấu hoàn thành bài học qua Checkbox)
     * ------------------------------------------------------------------------
     * Mục đích:
     * - Dùng cho các bài học KHÔNG có bài kiểm tra bắt buộc.
     * - Nhận lessonId, courseId và trạng thái checkbox 'completed'.
     * - Gọi EnrollmentService.toggleLessonCompletion(...) để ghi nhận bản ghi tiến độ vào DB.
     * - Trigger CSDL sẽ tự động tính lại % tiến độ của toàn khóa học.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        int lessonId = -1;

        try {
            lessonId = Integer.parseInt(request.getParameter("lessonId"));
            int courseId = Integer.parseInt(request.getParameter("courseId"));

            // Giảng viên và Quản trị viên ở chế độ xem trước không được đánh dấu tiến độ học viên
            if (currentUser != null && ("instructor".equals(currentUser.getRole()) || "admin".equals(currentUser.getRole()))) {
                HttpSession session = request.getSession();
                session.setAttribute("flashError", "Giảng viên và Quản trị viên không thể đánh dấu tiến độ hoàn thành bài học!");
                response.sendRedirect(request.getContextPath() + "/student/lessons/view?lessonId=" + lessonId);
                return;
            }

            // Đọc trạng thái checkbox từ form HTML gửi lên
            String completedParam = request.getParameter("completed");
            boolean completed = (completedParam != null);

            // Cập nhật trạng thái hoàn thành bài học vào database
            enrollmentService.toggleLessonCompletion(currentUser.getId(), courseId, lessonId, completed);

            // Tải lại đúng trang bài học đó với tiến độ mới nhất
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