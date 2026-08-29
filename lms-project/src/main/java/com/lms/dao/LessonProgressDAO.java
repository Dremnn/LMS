package com.lms.dao;

import com.lms.model.LessonProgress;
import com.lms.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class LessonProgressDAO {

    // 1. Tìm bản ghi tiến độ của 1 bài học cụ thể trong 1 enrollment
    // (Dùng để biết bài này đã có bản ghi progress chưa - quyết định INSERT hay UPDATE)
    public LessonProgress findByEnrollmentAndLesson(int enrollmentId, int lessonId) {
        String sql = "SELECT id, enrollment_id, lesson_id, is_completed, completed_at " +
                     "FROM lesson_progress WHERE enrollment_id = ? AND lesson_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, enrollmentId);
            stmt.setInt(2, lessonId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToLessonProgress(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 2. Lấy toàn bộ tiến độ của 1 enrollment (dùng để hiển thị bài nào đã tick/chưa tick
    // trên trang xem nội dung khóa học)
    public List<LessonProgress> findByEnrollment(int enrollmentId) {
        List<LessonProgress> list = new ArrayList<>();
        String sql = "SELECT id, enrollment_id, lesson_id, is_completed, completed_at " +
                     "FROM lesson_progress WHERE enrollment_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, enrollmentId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToLessonProgress(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Tạo bản ghi tiến độ MỚI (lần đầu tick bài học này)
    // INSERT vào đây sẽ tự động kích hoạt Trigger trg_lesson_progress_update trong SQL Server
    public boolean insert(LessonProgress progress) {
        String sql = "INSERT INTO lesson_progress (enrollment_id, lesson_id, is_completed, completed_at) " +
                     "VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, progress.getEnrollmentId());
            stmt.setInt(2, progress.getLessonId());
            stmt.setBoolean(3, progress.isCompleted());

            if (progress.isCompleted()) {
                LocalDateTime now = LocalDateTime.now();
                stmt.setTimestamp(4, Timestamp.valueOf(now));
                progress.setCompletedAt(now);
            } else {
                stmt.setNull(4, Types.TIMESTAMP);
            }

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        progress.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 4. Cập nhật bản ghi tiến độ ĐÃ CÓ (đổi trạng thái tick/bỏ tick)
    // UPDATE vào đây cũng sẽ tự động kích hoạt Trigger trg_lesson_progress_update
    public boolean update(LessonProgress progress) {
        String sql = "UPDATE lesson_progress SET is_completed = ?, completed_at = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setBoolean(1, progress.isCompleted());

            if (progress.isCompleted()) {
                LocalDateTime now = LocalDateTime.now();
                stmt.setTimestamp(2, Timestamp.valueOf(now));
                progress.setCompletedAt(now);
            } else {
                stmt.setNull(2, Types.TIMESTAMP);
                progress.setCompletedAt(null);
            }

            stmt.setInt(3, progress.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private LessonProgress mapResultSetToLessonProgress(ResultSet rs) throws SQLException {
        LessonProgress p = new LessonProgress();
        p.setId(rs.getInt("id"));
        p.setEnrollmentId(rs.getInt("enrollment_id"));
        p.setLessonId(rs.getInt("lesson_id"));
        p.setCompleted(rs.getBoolean("is_completed"));

        Timestamp completedAt = rs.getTimestamp("completed_at");
        p.setCompletedAt(completedAt != null ? completedAt.toLocalDateTime() : null);

        return p;
    }
}