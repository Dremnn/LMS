package com.lms.controller;

import com.lms.model.AnswerOption;
import com.lms.model.Question;
import com.lms.model.Quiz;
import com.lms.model.User;
import com.lms.model.Course;
import com.lms.service.QuizService;
import com.lms.service.CourseService;
import com.lms.dao.QuestionDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = {
    "/instructor/quizzes/new",
    "/instructor/quizzes/manage",
    "/instructor/quizzes/questions/add",
    "/instructor/quizzes/questions/delete"
})
public class QuizManageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private QuizService quizService;
    private CourseService courseService;
    private QuestionDAO questionDAO;

    @Override
    public void init() throws ServletException {
        this.quizService = new QuizService();
        this.courseService = new CourseService();
        this.questionDAO = new QuestionDAO();
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

        // Đọc flash message nếu có
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("flashError") != null) {
            request.setAttribute("error", session.getAttribute("flashError"));
            session.removeAttribute("flashError");
        }

        try {
            if ("/instructor/quizzes/new".equals(path)) {
                // Hiển thị form tạo quiz mới - cần biết đang gắn vào Course nào (bắt buộc)
                // và tùy chọn Section nào (nếu Instructor muốn gắn vào 1 chương cụ thể)
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                Course course = courseService.getCourseDetail(courseId);
                request.setAttribute("course", course);
                request.setAttribute("courseId", courseId);
                request.getRequestDispatcher("/WEB-INF/views/instructor/quiz-form.jsp")
                        .forward(request, response);

            } else if ("/instructor/quizzes/manage".equals(path)) {
                int quizId = Integer.parseInt(request.getParameter("id"));

                Quiz quiz = quizService.getQuizForManage(quizId, currentUser.getId());
                List<Question> questions = quizService.getQuestionsForManage(quizId, currentUser.getId());

                request.setAttribute("quiz", quiz);
                request.setAttribute("questions", questions);
                request.getRequestDispatcher("/WEB-INF/views/instructor/quiz-manage.jsp")
                        .forward(request, response);

            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tham số không hợp lệ!");
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        } catch (SecurityException e) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        try {
            if ("/instructor/quizzes/new".equals(path)) {
                handleCreateQuiz(request, response, currentUser);

            } else if ("/instructor/quizzes/questions/add".equals(path)) {
                handleAddQuestion(request, response, currentUser);

            } else if ("/instructor/quizzes/questions/delete".equals(path)) {
                handleDeleteQuestion(request, response, currentUser);

            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }

        } catch (IllegalArgumentException | IllegalStateException e) {
            HttpSession session = request.getSession();
            session.setAttribute("flashError", e.getMessage());
            // Quay lại trang phù hợp tùy ngữ cảnh - đơn giản hóa bằng cách quay về courseId nếu có
            String courseId = request.getParameter("courseId");
            if (courseId != null) {
                response.sendRedirect(request.getContextPath() + "/instructor/courses/manage?id=" + courseId);
            } else {
                response.sendRedirect(request.getContextPath() + "/instructor/courses");
            }

        } catch (SecurityException e) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        }
    }

    // Tạo quiz mới, gắn vào Section hoặc Course tùy lựa chọn từ form
    private void handleCreateQuiz(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {

        int courseId = Integer.parseInt(request.getParameter("courseId"));
        String attachType = request.getParameter("attachType"); // "section" hoặc "course"
        String title = request.getParameter("title");
        BigDecimal passScore = new BigDecimal(request.getParameter("passScore"));

        String maxAttemptsStr = request.getParameter("maxAttempts");
        Integer maxAttempts = (maxAttemptsStr != null && !maxAttemptsStr.trim().isEmpty())
                ? Integer.parseInt(maxAttemptsStr) : null;

        Integer sectionId = null;
        Integer courseIdForQuiz = null;

        if ("section".equals(attachType)) {
            String secIdStr = request.getParameter("sectionId");
            if (secIdStr == null || secIdStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Vui lòng chọn một chương để gắn Quiz!");
            }
            sectionId = Integer.parseInt(secIdStr);
        } else {
            courseIdForQuiz = courseId;
        }

        Quiz quiz = quizService.createQuiz(currentUser.getId(), sectionId, courseIdForQuiz,
                title, passScore, maxAttempts);

        // Tạo xong -> chuyển sang trang quản lý quiz đó để thêm câu hỏi
        response.sendRedirect(request.getContextPath() + "/instructor/quizzes/manage?id=" + quiz.getId());
    }

    // Thêm 1 câu hỏi (kèm nhiều đáp án) vào quiz đã có
    private void handleAddQuestion(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {

        int quizId = Integer.parseInt(request.getParameter("quizId"));
        String content = request.getParameter("content");
        String questionType = request.getParameter("questionType"); // "single_choice" | "multi_choice"

        // Đọc mảng nội dung đáp án - form JSP gửi nhiều input cùng tên "optionContent"
        String[] optionContents = request.getParameterValues("optionContent");

        // Đọc mảng chỉ số đáp án ĐÚNG - checkbox chỉ gửi lên nếu được tick,
        // value của mỗi checkbox chính là chỉ số (index) của đáp án đó trong mảng optionContents
        String[] correctIndicesStr = request.getParameterValues("correctOption");

        List<AnswerOption> options = new ArrayList<>();

        if (optionContents != null) {
            // Gom các chỉ số đúng vào 1 Set để tra cứu nhanh
            java.util.Set<Integer> correctIndices = new java.util.HashSet<>();
            if (correctIndicesStr != null) {
                for (String s : correctIndicesStr) {
                    correctIndices.add(Integer.parseInt(s));
                }
            }

            for (int i = 0; i < optionContents.length; i++) {
                boolean isCorrect = correctIndices.contains(i);
                options.add(new AnswerOption(0, optionContents[i], isCorrect)); // questionId sẽ gán sau ở DAO
            }
        }

        Question question = quizService.addQuestion(currentUser.getId(), quizId, content, questionType, options);

        response.sendRedirect(request.getContextPath() + "/instructor/quizzes/manage?id=" + quizId);
    }

    private void handleDeleteQuestion(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {

        int questionId = Integer.parseInt(request.getParameter("questionId"));
        int quizId = Integer.parseInt(request.getParameter("quizId"));

        // Kiểm tra quyền sở hữu thông qua quiz chứa câu hỏi này trước khi xóa
        quizService.getQuizForManage(quizId, currentUser.getId()); // ném lỗi nếu không có quyền
        questionDAO.delete(questionId);

        response.sendRedirect(request.getContextPath() + "/instructor/quizzes/manage?id=" + quizId);
    }
}