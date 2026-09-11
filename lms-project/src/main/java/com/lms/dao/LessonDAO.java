package com.lms.dao;

import com.lms.model.Lesson;
import com.lms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LessonDAO {

    // 1. Lấy toàn bộ bài học của 1 chương, sắp theo order_index
    public List<Lesson> findBySectionId(int sectionId) {
        List<Lesson> list = new ArrayList<>();
        String sql = "SELECT id, section_id, title, video_url, document_url, " +
                     "duration_minutes, order_index FROM lessons " +
                     "WHERE section_id = ? ORDER BY order_index ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sectionId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToLesson(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Lấy toàn bộ bài học của 1 khóa học (JOIN qua sections) - dùng để tính tổng số bài
    // hoặc hiển thị toàn bộ nội dung khóa học trên 1 trang duy nhất
    public List<Lesson> findByCourseId(int courseId) {
        List<Lesson> list = new ArrayList<>();
        String sql = "SELECT l.id, l.section_id, l.title, l.video_url, l.document_url, " +
                     "l.duration_minutes, l.order_index " +
                     "FROM lessons l INNER JOIN sections s ON l.section_id = s.id " +
                     "WHERE s.course_id = ? ORDER BY s.order_index ASC, l.order_index ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, courseId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToLesson(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Tìm 1 bài học theo ID
    public Lesson findById(int id) {
        String sql = "SELECT id, section_id, title, video_url, document_url, " +
                     "duration_minutes, order_index FROM lessons WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToLesson(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 4. Tự động tính order_index tiếp theo trong 1 section
    public int getNextOrderIndex(int sectionId) {
        String sql = "SELECT COALESCE(MAX(order_index), 0) + 1 AS next_order " +
                     "FROM lessons WHERE section_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sectionId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("next_order");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 1;
    }

    // 5. Thêm bài học mới
    // Lưu ý: KHÔNG cần tự cập nhật courses.total_lessons ở đây
    // vì đã có Trigger trg_lesson_update_total_lessons tự động xử lý (đã viết ở phần DB)
    public boolean save(Lesson lesson) {
        String sql = "INSERT INTO lessons (section_id, title, video_url, document_url, " +
                     "duration_minutes, order_index) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, lesson.getSectionId());
            stmt.setString(2, lesson.getTitle());
            stmt.setString(3, lesson.getVideoUrl());
            stmt.setString(4, lesson.getDocumentUrl());

            if (lesson.getDurationMinutes() != null) {
                stmt.setInt(5, lesson.getDurationMinutes());
            } else {
                stmt.setNull(5, Types.INTEGER);
            }

            stmt.setInt(6, lesson.getOrderIndex());

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        lesson.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 6. Sửa bài học
    public boolean update(Lesson lesson) {
        String sql = "UPDATE lessons SET title = ?, video_url = ?, document_url = ?, " +
                     "duration_minutes = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, lesson.getTitle());
            stmt.setString(2, lesson.getVideoUrl());
            stmt.setString(3, lesson.getDocumentUrl());

            if (lesson.getDurationMinutes() != null) {
                stmt.setInt(4, lesson.getDurationMinutes());
            } else {
                stmt.setNull(4, Types.INTEGER);
            }

            stmt.setInt(5, lesson.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 7. Xóa bài học (Trigger sẽ tự cập nhật lại total_lessons)
    public boolean delete(int lessonId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Xóa lesson_progress liên quan trước để tránh lỗi foreign key
            String delProgressSql = "DELETE FROM lesson_progress WHERE lesson_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(delProgressSql)) {
                stmt.setInt(1, lessonId);
                stmt.executeUpdate();
            }

            String sql = "DELETE FROM lessons WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, lessonId);
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

    private Lesson mapResultSetToLesson(ResultSet rs) throws SQLException {
        Lesson lesson = new Lesson();
        lesson.setId(rs.getInt("id"));
        lesson.setSectionId(rs.getInt("section_id"));
        lesson.setTitle(rs.getString("title"));
        lesson.setVideoUrl(rs.getString("video_url"));
        lesson.setDocumentUrl(rs.getString("document_url"));

        int duration = rs.getInt("duration_minutes");
        lesson.setDurationMinutes(rs.wasNull() ? null : duration);

        lesson.setOrderIndex(rs.getInt("order_index"));
        return lesson;
    }
}