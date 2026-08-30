package com.lms.dao;

import com.lms.model.AnswerOption;
import com.lms.model.Question;
import com.lms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class QuestionDAO {

    // 1. Lấy toàn bộ câu hỏi của 1 quiz, KÈM SẴN danh sách đáp án cho mỗi câu
    // (dùng chung cho cả trang Instructor quản lý và trang Student làm bài -
    //  việc ẨN đáp án đúng khi Student làm bài sẽ xử lý ở tầng Service, không xử lý ở đây)
    public List<Question> findByQuizId(int quizId) {
        List<Question> questions = new ArrayList<>();
        String sql = "SELECT id, quiz_id, content, question_type FROM questions WHERE quiz_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, quizId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(mapResultSetToQuestion(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Với mỗi câu hỏi, load thêm danh sách đáp án tương ứng
        for (Question q : questions) {
            q.setOptions(findOptionsByQuestionId(q.getId()));
        }

        return questions;
    }

    // 2. Lấy danh sách đáp án của 1 câu hỏi
    public List<AnswerOption> findOptionsByQuestionId(int questionId) {
        List<AnswerOption> options = new ArrayList<>();
        String sql = "SELECT id, question_id, content, is_correct FROM answer_options WHERE question_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, questionId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    AnswerOption opt = new AnswerOption();
                    opt.setId(rs.getInt("id"));
                    opt.setQuestionId(rs.getInt("question_id"));
                    opt.setContent(rs.getString("content"));
                    opt.setCorrect(rs.getBoolean("is_correct"));
                    options.add(opt);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return options;
    }

    // 3. Tìm 1 câu hỏi theo ID (kèm đáp án)
    public Question findById(int id) {
        String sql = "SELECT id, quiz_id, content, question_type FROM questions WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Question q = mapResultSetToQuestion(rs);
                    q.setOptions(findOptionsByQuestionId(q.getId()));
                    return q;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 4. Thêm câu hỏi MỚI, KÈM LUÔN danh sách đáp án của nó trong 1 lần gọi
    // Dùng Transaction: nếu 1 trong các bước insert bị lỗi, rollback toàn bộ
    // (tránh trường hợp câu hỏi được tạo nhưng thiếu đáp án do lỗi giữa chừng)
    public boolean saveWithOptions(Question question) {
        String questionSql = "INSERT INTO questions (quiz_id, content, question_type) VALUES (?, ?, ?)";
        String optionSql = "INSERT INTO answer_options (question_id, content, is_correct) VALUES (?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Bắt đầu transaction thủ công

            try (PreparedStatement qStmt = conn.prepareStatement(questionSql, Statement.RETURN_GENERATED_KEYS)) {
                qStmt.setInt(1, question.getQuizId());
                qStmt.setString(2, question.getContent());
                qStmt.setString(3, question.getQuestionType());
                qStmt.executeUpdate();

                try (ResultSet keys = qStmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        question.setId(keys.getInt(1));
                    }
                }
            }

            try (PreparedStatement oStmt = conn.prepareStatement(optionSql)) {
                for (AnswerOption opt : question.getOptions()) {
                    oStmt.setInt(1, question.getId());
                    oStmt.setString(2, opt.getContent());
                    oStmt.setBoolean(3, opt.isCorrect());
                    oStmt.addBatch(); // Gom nhiều lệnh insert lại, thực thi 1 lần cho nhanh
                }
                oStmt.executeBatch();
            }

            conn.commit(); // Mọi thứ thành công -> lưu thật
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback(); // Có lỗi -> hủy toàn bộ thay đổi trong transaction này
                } catch (SQLException rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Trả lại chế độ mặc định trước khi đóng connection
                    conn.close();
                } catch (SQLException closeEx) {
                    closeEx.printStackTrace();
                }
            }
        }
    }

    // 5. Xóa câu hỏi (CASCADE tự xóa answer_options liên quan)
    public boolean delete(int questionId) {
        String sql = "DELETE FROM questions WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, questionId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Question mapResultSetToQuestion(ResultSet rs) throws SQLException {
        Question q = new Question();
        q.setId(rs.getInt("id"));
        q.setQuizId(rs.getInt("quiz_id"));
        q.setContent(rs.getString("content"));
        q.setQuestionType(rs.getString("question_type"));
        return q;
    }
}