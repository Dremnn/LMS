package com.lms.dao;

import com.lms.model.Quiz;
import com.lms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class QuizDAO {

    // 1. Lấy tất cả quiz gắn vào 1 Section
    public List<Quiz> findBySectionId(int sectionId) {
        List<Quiz> list = new ArrayList<>();
        String sql = "SELECT id, section_id, course_id, title, pass_score, max_attempts, " +
                     "time_limit_minutes, open_at, close_at " +
                     "FROM quizzes WHERE section_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sectionId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToQuiz(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Lấy tất cả quiz gắn trực tiếp vào 1 Course (quiz tổng kết cuối khóa)
    public List<Quiz> findByCourseId(int courseId) {
        List<Quiz> list = new ArrayList<>();
        String sql = "SELECT id, section_id, course_id, title, pass_score, max_attempts, " +
                     "time_limit_minutes, open_at, close_at " +
                     "FROM quizzes WHERE course_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, courseId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToQuiz(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Tìm 1 quiz theo ID
    public Quiz findById(int id) {
        String sql = "SELECT id, section_id, course_id, title, pass_score, max_attempts, " +
                     "time_limit_minutes, open_at, close_at " +
                     "FROM quizzes WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToQuiz(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 4. Đếm số câu hỏi hiện có trong quiz (dùng để hiển thị, hoặc kiểm tra quiz có đủ câu hỏi chưa)
    public int countQuestions(int quizId) {
        String sql = "SELECT COUNT(*) AS total FROM questions WHERE quiz_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 5. Tạo quiz mới
    public boolean save(Quiz quiz) {
        String sql = "INSERT INTO quizzes (section_id, course_id, title, pass_score, max_attempts, " +
                     "time_limit_minutes, open_at, close_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            if (quiz.getSectionId() != null) {
                stmt.setInt(1, quiz.getSectionId());
            } else {
                stmt.setNull(1, Types.INTEGER);
            }

            if (quiz.getCourseId() != null) {
                stmt.setInt(2, quiz.getCourseId());
            } else {
                stmt.setNull(2, Types.INTEGER);
            }

            stmt.setString(3, quiz.getTitle());
            stmt.setBigDecimal(4, quiz.getPassScore());

            if (quiz.getMaxAttempts() != null) {
                stmt.setInt(5, quiz.getMaxAttempts());
            } else {
                stmt.setNull(5, Types.INTEGER);
            }

            if (quiz.getTimeLimitMinutes() != null) {
                stmt.setInt(6, quiz.getTimeLimitMinutes());
            } else {
                stmt.setNull(6, Types.INTEGER);
            }

            if (quiz.getOpenAt() != null) {
                stmt.setTimestamp(7, Timestamp.valueOf(quiz.getOpenAt()));
            } else {
                stmt.setNull(7, Types.TIMESTAMP);
            }

            if (quiz.getCloseAt() != null) {
                stmt.setTimestamp(8, Timestamp.valueOf(quiz.getCloseAt()));
            } else {
                stmt.setNull(8, Types.TIMESTAMP);
            }

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        quiz.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 6. Xóa quiz an toàn trong transaction (xóa cả attempts, attempt_answers, options, questions)
    public boolean delete(int quizId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Xóa câu trả lời chi tiết của các lượt làm bài
            String delAttemptAnswersSql = "DELETE FROM attempt_answers WHERE attempt_id IN " +
                                          "(SELECT id FROM quiz_attempts WHERE quiz_id = ?)";
            try (PreparedStatement stmt = conn.prepareStatement(delAttemptAnswersSql)) {
                stmt.setInt(1, quizId);
                stmt.executeUpdate();
            }

            // 2. Xóa các lượt làm bài
            String delAttemptsSql = "DELETE FROM quiz_attempts WHERE quiz_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(delAttemptsSql)) {
                stmt.setInt(1, quizId);
                stmt.executeUpdate();
            }

            // 3. Xóa các đáp án lựa chọn của các câu hỏi trong quiz
            String delOptionsSql = "DELETE FROM answer_options WHERE question_id IN " +
                                  "(SELECT id FROM questions WHERE quiz_id = ?)";
            try (PreparedStatement stmt = conn.prepareStatement(delOptionsSql)) {
                stmt.setInt(1, quizId);
                stmt.executeUpdate();
            }

            // 4. Xóa câu hỏi trong quiz
            String delQuestionsSql = "DELETE FROM questions WHERE quiz_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(delQuestionsSql)) {
                stmt.setInt(1, quizId);
                stmt.executeUpdate();
            }

            // 5. Xóa quiz
            String delQuizSql = "DELETE FROM quizzes WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(delQuizSql)) {
                stmt.setInt(1, quizId);
                stmt.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        return false;
    }

    public List<Quiz> findByCloseAtMonth(int year, int month) {
        List<Quiz> list = new ArrayList<>();
        String sql = "SELECT id, section_id, course_id, title, pass_score, max_attempts, " +
                    "time_limit_minutes, open_at, close_at " +
                    "FROM quizzes " +
                    "WHERE EXTRACT(YEAR FROM close_at) = ? AND EXTRACT(MONTH FROM close_at) = ?";

        try (Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, year);
            stmt.setInt(2, month);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToQuiz(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Quiz mapResultSetToQuiz(ResultSet rs) throws SQLException {
        Quiz quiz = new Quiz();
        quiz.setId(rs.getInt("id"));

        int sectionId = rs.getInt("section_id");
        quiz.setSectionId(rs.wasNull() ? null : sectionId);

        int courseId = rs.getInt("course_id");
        quiz.setCourseId(rs.wasNull() ? null : courseId);

        quiz.setTitle(rs.getString("title"));
        quiz.setPassScore(rs.getBigDecimal("pass_score"));

        int maxAttempts = rs.getInt("max_attempts");
        quiz.setMaxAttempts(rs.wasNull() ? null : maxAttempts);

        int timeLimit = rs.getInt("time_limit_minutes");
        quiz.setTimeLimitMinutes(rs.wasNull() ? null : timeLimit);

        Timestamp openAt = rs.getTimestamp("open_at");
        quiz.setOpenAt(openAt != null ? openAt.toLocalDateTime() : null);

        Timestamp closeAt = rs.getTimestamp("close_at");
        quiz.setCloseAt(closeAt != null ? closeAt.toLocalDateTime() : null);

        return quiz;
    }
}