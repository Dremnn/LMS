package com.lms.service;

import com.lms.dao.*;
import com.lms.model.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;

public class QuizService {

    private final QuizDAO quizDAO;
    private final QuestionDAO questionDAO;
    private final QuizAttemptDAO quizAttemptDAO;
    private final CourseDAO courseDAO;
    private final SectionDAO sectionDAO;
    private final EnrollmentService enrollmentService;

    public QuizService() {
        this.quizDAO = new QuizDAO();
        this.questionDAO = new QuestionDAO();
        this.quizAttemptDAO = new QuizAttemptDAO();
        this.courseDAO = new CourseDAO();
        this.sectionDAO = new SectionDAO();
        this.enrollmentService = new EnrollmentService();
    }

    // =========================================================================
    // Hàm phụ trợ: Xác định quiz này thuộc courseId nào (dù gắn Section hay Course trực tiếp)
    // Dùng để kiểm tra quyền sở hữu (Instructor) và kiểm tra đã enroll (Student)
    // =========================================================================
    private int resolveCourseId(Quiz quiz) {
        if (quiz.getCourseId() != null) {
            return quiz.getCourseId();
        }
        Section section = sectionDAO.findById(quiz.getSectionId());
        if (section == null) {
            throw new IllegalStateException("Dữ liệu quiz không hợp lệ: không xác định được khóa học!");
        }
        return section.getCourseId();
    }

    // =========================================================================
    // Hàm phụ trợ: Kiểm tra Instructor hiện tại có sở hữu khóa học chứa quiz này không
    // =========================================================================
    private Quiz getQuizAndVerifyOwnership(int quizId, int currentInstructorId) {
        Quiz quiz = quizDAO.findById(quizId);
        if (quiz == null) {
            throw new IllegalArgumentException("Quiz không tồn tại!");
        }
        int courseId = resolveCourseId(quiz);
        Course course = courseDAO.findById(courseId);
        if (course == null || course.getInstructorId() != currentInstructorId) {
            throw new SecurityException("Bạn không có quyền thao tác trên quiz này!");
        }
        return quiz;
    }

    // =========================================================================
    // 1. INSTRUCTOR: TẠO QUIZ MỚI (gắn vào Section HOẶC Course, theo lựa chọn)
    // =========================================================================
    public Quiz createQuiz(int currentInstructorId, Integer sectionId, Integer courseId,
                            String title, BigDecimal passScore, Integer maxAttempts,
                            Integer timeLimitMinutes, java.time.LocalDateTime openAt, java.time.LocalDateTime closeAt) {

        if ((sectionId == null) == (courseId == null)) {
            // Cả 2 cùng null HOẶC cả 2 cùng có giá trị đều là sai - phải chọn ĐÚNG 1 trong 2
            throw new IllegalArgumentException("Quiz phải gắn vào đúng 1 Chương hoặc 1 Khóa học, không được cả hai hoặc không cái nào!");
        }

        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên quiz không được để trống!");
        }

        // Xác định courseId thật để kiểm tra quyền sở hữu
        int realCourseId;
        if (courseId != null) {
            realCourseId = courseId;
        } else {
            Section section = sectionDAO.findById(sectionId);
            if (section == null) {
                throw new IllegalArgumentException("Chương học không tồn tại!");
            }
            realCourseId = section.getCourseId();
        }

        Course course = courseDAO.findById(realCourseId);
        if (course == null || course.getInstructorId() != currentInstructorId) {
            throw new SecurityException("Bạn không có quyền tạo quiz cho khóa học này!");
        }

        if (passScore == null || passScore.compareTo(BigDecimal.ZERO) < 0 || passScore.compareTo(new BigDecimal(100)) > 0) {
            throw new IllegalArgumentException("Điểm đạt phải nằm trong khoảng 0-100!");
        }

        if (maxAttempts != null && maxAttempts <= 0) {
            throw new IllegalArgumentException("Số lần làm bài tối đa phải lớn hơn 0 (để trống nếu không giới hạn)!");
        }

        if (timeLimitMinutes != null && timeLimitMinutes <= 0) {
            throw new IllegalArgumentException("Thời gian làm bài phải lớn hơn 0 phút (để trống nếu không giới hạn)!");
        }

        if (openAt != null && closeAt != null && !closeAt.isAfter(openAt)) {
            throw new IllegalArgumentException("Thời điểm đóng quiz phải sau thời điểm mở!");
        }

        Quiz quiz = new Quiz(sectionId, courseId, title.trim(), passScore, maxAttempts,
                timeLimitMinutes, openAt, closeAt);
        boolean saved = quizDAO.save(quiz);
        if (!saved) {
            throw new RuntimeException("Có lỗi xảy ra khi tạo quiz!");
        }
        return quiz;
    }

    // =========================================================================
    // 2. INSTRUCTOR: THÊM CÂU HỎI VÀO QUIZ (kèm các đáp án)
    // =========================================================================
    public Question addQuestion(int currentInstructorId, int quizId, String content,
                                 String questionType, List<AnswerOption> options) {

        getQuizAndVerifyOwnership(quizId, currentInstructorId);

        if (content == null || content.trim().isEmpty()) {
            throw new IllegalArgumentException("Nội dung câu hỏi không được để trống!");
        }
        if (!"single_choice".equals(questionType) && !"multi_choice".equals(questionType)) {
            throw new IllegalArgumentException("Loại câu hỏi không hợp lệ!");
        }
        if (options == null || options.size() < 2) {
            throw new IllegalArgumentException("Câu hỏi cần có ít nhất 2 đáp án!");
        }

        long correctCount = options.stream().filter(AnswerOption::isCorrect).count();
        if (correctCount == 0) {
            throw new IllegalArgumentException("Câu hỏi cần có ít nhất 1 đáp án đúng!");
        }
        if ("single_choice".equals(questionType) && correctCount > 1) {
            throw new IllegalArgumentException("Câu hỏi 1 đáp án đúng (single choice) chỉ được chọn đúng 1 đáp án đúng!");
        }

        for (AnswerOption opt : options) {
            if (opt.getContent() == null || opt.getContent().trim().isEmpty()) {
                throw new IllegalArgumentException("Nội dung đáp án không được để trống!");
            }
        }

        Question question = new Question(quizId, content.trim(), questionType);
        question.setOptions(options);

        boolean saved = questionDAO.saveWithOptions(question);
        if (!saved) {
            throw new RuntimeException("Có lỗi xảy ra khi thêm câu hỏi!");
        }
        return question;
    }

    // =========================================================================
    // 2b. Lấy toàn bộ danh sách quiz của 1 khóa học (dùng cho trang quản lý nội dung)
    // Trả về List các quiz thuộc về khóa học (courseId) và các chương (sectionId) của nó
    // =========================================================================
    public List<Quiz> getAllQuizzesForCourse(Course course) {
        List<Quiz> allQuizzes = new ArrayList<>();
        
        // 1. Lấy quiz tổng kết (gắn trực tiếp vào course)
        List<Quiz> courseQuizzes = quizDAO.findByCourseId(course.getId());
        for (Quiz q : courseQuizzes) {
            q.setTotalQuestions(quizDAO.countQuestions(q.getId()));
            allQuizzes.add(q);
        }
        
        // 2. Lấy quiz của từng chương
        if (course.getSectionsCache() != null) {
            for (Section section : course.getSectionsCache()) {
                List<Quiz> sectionQuizzes = quizDAO.findBySectionId(section.getId());
                for (Quiz q : sectionQuizzes) {
                    q.setTotalQuestions(quizDAO.countQuestions(q.getId()));
                    allQuizzes.add(q);
                }
            }
        }
        return allQuizzes;
    }

    // =========================================================================
    // 3. INSTRUCTOR: XEM QUIZ ĐẦY ĐỦ (kèm đáp án đúng - dùng cho trang quản lý)
    // =========================================================================
    public Quiz getQuizForManage(int quizId, int currentInstructorId) {
        Quiz quiz = getQuizAndVerifyOwnership(quizId, currentInstructorId);
        List<Question> questions = questionDAO.findByQuizId(quizId);
        // Không cần ẩn gì - Instructor được phép thấy đáp án đúng
        quiz.setTotalQuestions(questions.size());
        return quiz; // JSP sẽ gọi thêm hàm lấy questions riêng, xem hàm bên dưới
    }

    public List<Question> getQuestionsForManage(int quizId, int currentInstructorId) {
        getQuizAndVerifyOwnership(quizId, currentInstructorId);
        return questionDAO.findByQuizId(quizId);
    }

    // =========================================================================
    // 4. STUDENT: LẤY QUIZ ĐỂ LÀM BÀI — ẨN ĐÁP ÁN ĐÚNG (điểm bảo mật quan trọng)
    // =========================================================================
    public List<Question> getQuestionsForAttempt(int studentId, int quizId) {
        Quiz quiz = quizDAO.findById(quizId);
        if (quiz == null) {
            throw new IllegalArgumentException("Quiz không tồn tại!");
        }

        int courseId = resolveCourseId(quiz);

        // Bắt buộc phải đã đăng ký khóa học chứa quiz này mới được làm bài
        enrollmentService.getEnrollmentOrThrow(studentId, courseId);

        // Kiểm tra cửa sổ thời gian mở/đóng của quiz
        checkQuizWindow(quiz);

        // Kiểm tra giới hạn số lần làm bài (nếu Instructor có set max_attempts)
        if (quiz.getMaxAttempts() != null) {
            int attemptsUsed = quizAttemptDAO.countAttempts(studentId, quizId);
            if (attemptsUsed >= quiz.getMaxAttempts()) {
                throw new IllegalStateException(
                    "Bạn đã hết lượt làm bài (tối đa " + quiz.getMaxAttempts() + " lần)!");
            }
        }

        List<Question> questions = questionDAO.findByQuizId(quizId);

        // *** ĐIỂM BẢO MẬT QUAN TRỌNG NHẤT CỦA MODULE NÀY ***
        // Tạo bản sao "vô hiệu hóa" thông tin đáp án đúng trước khi trả về cho Student
        // Không được để lộ field "correct" ra JSP khi đang làm bài
        List<Question> sanitized = new ArrayList<>();
        for (Question q : questions) {
            Question copy = new Question(q.getQuizId(), q.getContent(), q.getQuestionType());
            copy.setId(q.getId());

            List<AnswerOption> sanitizedOptions = new ArrayList<>();
            for (AnswerOption opt : q.getOptions()) {
                AnswerOption optCopy = new AnswerOption(opt.getQuestionId(), opt.getContent(), false); // luôn set false
                optCopy.setId(opt.getId());
                sanitizedOptions.add(optCopy);
            }
            copy.setOptions(sanitizedOptions);
            sanitized.add(copy);
        }

        return sanitized;
    }

    // =========================================================================
    // Hàm phụ trợ: Kiểm tra quiz có đang trong khoảng thời gian mở/đóng cho phép không
    // =========================================================================
    private static final java.time.format.DateTimeFormatter DATETIME_FMT =
            java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");

    private void checkQuizWindow(Quiz quiz) {
        java.time.LocalDateTime now = java.time.LocalDateTime.now();
        if (quiz.getOpenAt() != null && now.isBefore(quiz.getOpenAt())) {
            throw new IllegalStateException(
                "Quiz chưa mở! Quiz sẽ mở lúc " + quiz.getOpenAt().format(DATETIME_FMT) + ".");
        }
        if (quiz.getCloseAt() != null && now.isAfter(quiz.getCloseAt())) {
            throw new IllegalStateException(
                "Quiz đã đóng lúc " + quiz.getCloseAt().format(DATETIME_FMT) + ", không thể làm bài nữa!");
        }
    }

    // Số phút cho phép trễ so với time_limit_minutes trước khi coi là quá hạn nghiêm trọng
    // (bù độ trễ mạng / độ lệch giữa đồng hồ client-server so với JS đếm ngược)
    private static final long TIME_LIMIT_GRACE_MINUTES = 2;

    // =========================================================================
    // 5. STUDENT: NỘP BÀI — CHẤM ĐIỂM TỰ ĐỘNG
    // selectedAnswers: Map<questionId, List<selectedOptionId>>
    // attemptStartedAt: thời điểm Student bắt đầu làm bài (lấy từ session) - null nếu không xác định được
    // =========================================================================
    public QuizAttempt submitAttempt(int studentId, int quizId, Map<Integer, List<Integer>> selectedAnswers,
                                      java.time.LocalDateTime attemptStartedAt) {

        Quiz quiz = quizDAO.findById(quizId);
        if (quiz == null) {
            throw new IllegalArgumentException("Quiz không tồn tại!");
        }

        int courseId = resolveCourseId(quiz);
        enrollmentService.getEnrollmentOrThrow(studentId, courseId);

        // Kiểm tra lại cửa sổ mở/đóng (phòng trường hợp Student mở tab từ trước, quiz đóng lúc đang làm)
        checkQuizWindow(quiz);

        // Kiểm tra lại giới hạn số lần làm bài (phòng trường hợp Student mở 2 tab cùng lúc)
        if (quiz.getMaxAttempts() != null) {
            int attemptsUsed = quizAttemptDAO.countAttempts(studentId, quizId);
            if (attemptsUsed >= quiz.getMaxAttempts()) {
                throw new IllegalStateException(
                    "Bạn đã hết lượt làm bài (tối đa " + quiz.getMaxAttempts() + " lần)!");
            }
        }

        // Kiểm tra thời gian làm bài (time_limit_minutes) - có cộng thêm ít phút "grace"
        // để bù độ trễ mạng/độ lệch giờ, tránh làm mất bài do sai số nhỏ
        if (quiz.getTimeLimitMinutes() != null && attemptStartedAt != null) {
            long elapsedMinutes = java.time.Duration.between(attemptStartedAt, java.time.LocalDateTime.now()).toMinutes();
            if (elapsedMinutes > quiz.getTimeLimitMinutes() + TIME_LIMIT_GRACE_MINUTES) {
                throw new IllegalStateException(
                    "Đã hết thời gian làm bài (giới hạn " + quiz.getTimeLimitMinutes() + " phút)! Bài làm không được ghi nhận.");
            }
        }

        // Lấy đáp án ĐÚNG thật từ DB để so sánh (không tin tưởng dữ liệu Client gửi lên)
        Map<Integer, List<Integer>> correctAnswersMap = quizAttemptDAO.getCorrectAnswersMap(quizId);

        int totalQuestions = correctAnswersMap.size();
        if (totalQuestions == 0) {
            throw new IllegalStateException("Quiz này chưa có câu hỏi nào!");
        }

        int correctCount = 0;

        for (Map.Entry<Integer, List<Integer>> entry : correctAnswersMap.entrySet()) {
            int questionId = entry.getKey();

            // Set các đáp án ĐÚNG thật (từ DB)
            Set<Integer> correctSet = new HashSet<>(entry.getValue());

            // Set các đáp án Student đã CHỌN (có thể rỗng nếu bỏ trống câu này)
            List<Integer> selectedList = selectedAnswers.getOrDefault(questionId, new ArrayList<>());
            Set<Integer> selectedSet = new HashSet<>(selectedList);

            // Coi là ĐÚNG chỉ khi tập hợp đáp án chọn TRÙNG KHỚP HOÀN TOÀN với tập hợp đáp án đúng
            // (áp dụng cho cả single_choice lẫn multi_choice - với single_choice, set chỉ có 1 phần tử)
            if (correctSet.equals(selectedSet)) {
                correctCount++;
            }
        }

        // Tính điểm theo thang 100
        BigDecimal score = new BigDecimal(correctCount)
                .divide(new BigDecimal(totalQuestions), 4, RoundingMode.HALF_UP)
                .multiply(new BigDecimal(100))
                .setScale(2, RoundingMode.HALF_UP);

        boolean passed = score.compareTo(quiz.getPassScore()) >= 0;

        QuizAttempt attempt = new QuizAttempt();
        attempt.setStudentId(studentId);
        attempt.setQuizId(quizId);
        attempt.setScore(score);
        attempt.setPassed(passed);

        boolean saved = quizAttemptDAO.saveAttemptWithAnswers(attempt, selectedAnswers);
        if (!saved) {
            throw new RuntimeException("Có lỗi xảy ra khi lưu kết quả bài làm!");
        }

        return attempt;
    }

    // =========================================================================
    // 6. Lấy 1 attempt theo ID (dùng cho trang xem kết quả sau khi nộp)
    // =========================================================================
    public QuizAttempt getAttemptById(int attemptId) {
        QuizAttempt attempt = quizAttemptDAO.findById(attemptId);
        if (attempt == null) {
            throw new IllegalArgumentException("Không tìm thấy kết quả bài làm!");
        }
        return attempt;
    }

    // =========================================================================
    // 7. Lấy quiz theo ID (dùng chung nhiều nơi - không kiểm tra quyền, JSP tự quyết định hiển thị gì)
    // =========================================================================
    public Quiz getQuizById(int quizId) {
        Quiz quiz = quizDAO.findById(quizId);
        if (quiz == null) {
            throw new IllegalArgumentException("Quiz không tồn tại!");
        }
        return quiz;
    }
}