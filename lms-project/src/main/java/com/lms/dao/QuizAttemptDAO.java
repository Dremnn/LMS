package com.lms.dao;

import com.lms.model.AnswerOption;
import com.lms.model.QuizAttempt;
import com.lms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class QuizAttemptDAO {

    // 1. Đếm số lần Student đã làm quiz này (dùng để kiểm tra giới hạn max_attempts)
    public int countAttempts(int studentId, int quizId) {
        String sql = "SELECT COUNT(*) AS total FROM quiz_attempts WHERE student_id = ? AND quiz_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, studentId);
            stmt.setInt(2, quizId);

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

    // 2. Lấy điểm cao nhất Student từng đạt được ở quiz này (dùng hiển thị lịch sử)
    public BigDecimal getHighestScore(int studentId, int quizId) {
        String sql = "SELECT MAX(score) AS highest FROM quiz_attempts WHERE student_id = ? AND quiz_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, studentId);
            stmt.setInt(2, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("highest");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 3. Lưu 1 lần làm bài (attempt) KÈM toàn bộ câu trả lời đã chọn - dùng Transaction
    // selectedAnswers: Map<questionId, List<selectedOptionId>>
    // (dùng List vì multi_choice có thể chọn nhiều đáp án cho 1 câu)
    public boolean saveAttemptWithAnswers(QuizAttempt attempt, Map<Integer, List<Integer>> selectedAnswers) {
        String attemptSql = "INSERT INTO quiz_attempts (student_id, quiz_id, score, is_passed, submitted_at) " +
                            "VALUES (?, ?, ?, ?, ?)";
        String answerSql = "INSERT INTO attempt_answers (attempt_id, question_id, selected_option_id) " +
                           "VALUES (?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement aStmt = conn.prepareStatement(attemptSql, Statement.RETURN_GENERATED_KEYS)) {
                aStmt.setInt(1, attempt.getStudentId());
                aStmt.setInt(2, attempt.getQuizId());
                aStmt.setBigDecimal(3, attempt.getScore());
                aStmt.setBoolean(4, attempt.getPassed());

                LocalDateTime now = LocalDateTime.now();
                aStmt.setTimestamp(5, Timestamp.valueOf(now));
                attempt.setSubmittedAt(now);

                aStmt.executeUpdate();

                try (ResultSet keys = aStmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        attempt.setId(keys.getInt(1));
                    }
                }
            }

            try (PreparedStatement ansStmt = conn.prepareStatement(answerSql)) {
                for (Map.Entry<Integer, List<Integer>> entry : selectedAnswers.entrySet()) {
                    int questionId = entry.getKey();
                    for (Integer optionId : entry.getValue()) {
                        ansStmt.setInt(1, attempt.getId());
                        ansStmt.setInt(2, questionId);
                        ansStmt.setInt(3, optionId);
                        ansStmt.addBatch();
                    }
                }
                ansStmt.executeBatch();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
    }

    // 4. Lấy danh sách đáp án ĐÚNG cho từng câu hỏi trong 1 quiz - dùng để CHẤM ĐIỂM
    // Trả về Map<questionId, List<correctOptionId>>
    public Map<Integer, List<Integer>> getCorrectAnswersMap(int quizId) {
        Map<Integer, List<Integer>> result = new java.util.HashMap<>();

        String sql = "SELECT q.id AS question_id, ao.id AS option_id " +
                     "FROM questions q " +
                     "INNER JOIN answer_options ao ON ao.question_id = q.id " +
                     "WHERE q.quiz_id = ? AND ao.is_correct = 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    int questionId = rs.getInt("question_id");
                    int optionId = rs.getInt("option_id");

                    result.computeIfAbsent(questionId, k -> new java.util.ArrayList<>()).add(optionId);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    // 5. Lấy 1 attempt theo ID (dùng hiển thị trang kết quả sau khi nộp bài)
    public QuizAttempt findById(int id) {
        String sql = "SELECT id, student_id, quiz_id, score, is_passed, submitted_at " +
                     "FROM quiz_attempts WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAttempt(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private QuizAttempt mapResultSetToAttempt(ResultSet rs) throws SQLException {
        QuizAttempt a = new QuizAttempt();
        a.setId(rs.getInt("id"));
        a.setStudentId(rs.getInt("student_id"));
        a.setQuizId(rs.getInt("quiz_id"));
        a.setScore(rs.getBigDecimal("score"));
        a.setPassed(rs.getBoolean("is_passed"));

        Timestamp ts = rs.getTimestamp("submitted_at");
        a.setSubmittedAt(ts != null ? ts.toLocalDateTime() : null);

        return a;
    }
}