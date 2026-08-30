package com.lms.controller;

import com.lms.model.Question;
import com.lms.model.Quiz;
import com.lms.model.QuizAttempt;
import com.lms.model.User;
import com.lms.service.QuizService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.*;

@WebServlet(urlPatterns = {
    "/student/quizzes/intro",
    "/student/quizzes/attempt",
    "/student/quizzes/submit",
    "/student/quizzes/result"
})
public class QuizAttemptServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private QuizService quizService;
    private com.lms.dao.QuizAttemptDAO quizAttemptDAO;

    @Override
    public void init() throws ServletException {
        this.quizService = new QuizService();
        this.quizAttemptDAO = new com.lms.dao.QuizAttemptDAO();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (User) session.getAttribute("currentUser");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("flashError") != null) {
            request.setAttribute("error", session.getAttribute("flashError"));
            session.removeAttribute("flashError");
        }

        try {
            if ("/student/quizzes/intro".equals(path)) {
                showIntro(request, response, currentUser);

            } else if ("/student/quizzes/attempt".equals(path)) {
                showAttemptForm(request, response, currentUser);

            } else if ("/student/quizzes/result".equals(path)) {
                showResult(request, response, currentUser);

            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tham số không hợp lệ!");
        } catch (IllegalStateException e) {
            HttpSession s = request.getSession();
            s.setAttribute("flashError", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/student/my-courses");
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        }
    }

    private void showIntro(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        int quizId = Integer.parseInt(request.getParameter("id"));
        Quiz quiz = quizService.getQuizById(quizId);
        
        // Ensure student is enrolled
        com.lms.model.Course course = null;
        if (quiz.getCourseId() != null) {
            course = new com.lms.service.CourseService().getCourseDetail(quiz.getCourseId());
            new com.lms.service.EnrollmentService().getEnrollmentOrThrow(currentUser.getId(), quiz.getCourseId());
        } else {
            com.lms.model.Section sec = new com.lms.dao.SectionDAO().findById(quiz.getSectionId());
            course = new com.lms.service.CourseService().getCourseDetail(sec.getCourseId());
            new com.lms.service.EnrollmentService().getEnrollmentOrThrow(currentUser.getId(), sec.getCourseId());
        }

        int attemptsUsed = quizAttemptDAO.countAttempts(currentUser.getId(), quizId);
        java.math.BigDecimal highestScore = quizAttemptDAO.getHighestScore(currentUser.getId(), quizId);

        request.setAttribute("quiz", quiz);
        request.setAttribute("course", course);
        request.setAttribute("attemptsUsed", attemptsUsed);
        request.setAttribute("highestScore", highestScore);
        
        request.getRequestDispatcher("/WEB-INF/views/student/quiz-intro.jsp")
                .forward(request, response);
    }

    private void showAttemptForm(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        int quizId = Integer.parseInt(request.getParameter("id"));

        Quiz quiz = quizService.getQuizById(quizId);
        // getQuestionsForAttempt() đã tự kiểm tra: đã enroll chưa, còn lượt làm bài không,
        // và ĐÃ ẨN SẴN đáp án đúng trước khi trả về (xử lý trong QuizService)
        List<Question> questions = quizService.getQuestionsForAttempt(currentUser.getId(), quizId);

        request.setAttribute("quiz", quiz);
        request.setAttribute("questions", questions);
        request.getRequestDispatcher("/WEB-INF/views/student/quiz-attempt.jsp")
                .forward(request, response);
    }

    private void showResult(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        int attemptId = Integer.parseInt(request.getParameter("attemptId"));
        QuizAttempt attempt = quizService.getAttemptById(attemptId);

        // Kiểm tra quyền: chỉ chính Student làm bài đó mới được xem kết quả
        if (attempt.getStudentId() != currentUser.getId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem kết quả này!");
            return;
        }

        Quiz quiz = quizService.getQuizById(attempt.getQuizId());

        request.setAttribute("attempt", attempt);
        request.setAttribute("quiz", quiz);
        request.getRequestDispatcher("/WEB-INF/views/student/quiz-result.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        User currentUser = getCurrentUser(request);

        int quizId = -1;

        try {
            quizId = Integer.parseInt(request.getParameter("quizId"));

            // Lấy danh sách câu hỏi thật (kèm ID) để biết cần đọc parameter nào từ form
            // (KHÔNG dùng bản đã ẩn đáp án - ở đây chỉ cần lấy ra danh sách questionId, không phải chấm điểm ở đây)
            List<Question> questions = quizService.getQuestionsForAttempt(currentUser.getId(), quizId);

            Map<Integer, List<Integer>> selectedAnswers = new HashMap<>();

            for (Question q : questions) {
                // Mỗi câu hỏi, form JSP gửi input tên "answer_{questionId}"
                // - single_choice: radio, chỉ 1 giá trị được chọn
                // - multi_choice: checkbox, có thể nhiều giá trị được chọn
                String[] selectedOptionIds = request.getParameterValues("answer_" + q.getId());

                List<Integer> selectedList = new ArrayList<>();
                if (selectedOptionIds != null) {
                    for (String s : selectedOptionIds) {
                        selectedList.add(Integer.parseInt(s));
                    }
                }
                selectedAnswers.put(q.getId(), selectedList);
            }

            QuizAttempt attempt = quizService.submitAttempt(currentUser.getId(), quizId, selectedAnswers);

            String redirectUrl = request.getContextPath() + "/student/quizzes/result?attemptId=" + attempt.getId();
            String lessonId = request.getParameter("lessonId");
            if (lessonId != null && !lessonId.trim().isEmpty()) {
                redirectUrl += "&lessonId=" + lessonId;
            }
            response.sendRedirect(redirectUrl);

        } catch (IllegalArgumentException | IllegalStateException e) {
            HttpSession session = request.getSession();
            session.setAttribute("flashError", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/student/quizzes/attempt?id=" + quizId);

        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("flashError", "Đã xảy ra lỗi hệ thống!");
            response.sendRedirect(request.getContextPath() + "/student/quizzes/attempt?id=" + quizId);
        }
    }
}