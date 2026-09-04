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

    // 6. Xóa quiz (CASCADE sẽ tự xóa questions/answer_options nhờ ON DELETE CASCADE đã khai báo trong DB)
    public boolean delete(int quizId) {
        String sql = "DELETE FROM quizzes WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
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