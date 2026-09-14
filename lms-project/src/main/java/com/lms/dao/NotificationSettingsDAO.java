package com.lms.dao;

import com.lms.model.NotificationSettings;
import com.lms.util.DBConnection;

import java.sql.*;

public class NotificationSettingsDAO {

    public NotificationSettings findByUserId(int userId) {
        String sql = "SELECT user_id, quiz_deadline_enabled, enrollment_enabled, event_reminder_enabled " +
                     "FROM notification_settings WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    NotificationSettings s = new NotificationSettings();
                    s.setUserId(rs.getInt("user_id"));
                    s.setQuizDeadlineEnabled(rs.getBoolean("quiz_deadline_enabled"));
                    s.setEnrollmentEnabled(rs.getBoolean("enrollment_enabled"));
                    s.setEventReminderEnabled(rs.getBoolean("event_reminder_enabled"));
                    return s;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null; // chưa có bản ghi -> Service sẽ coi như mặc định TẤT CẢ đang bật
    }

    // Dùng UPSERT (INSERT ... ON CONFLICT) của PostgreSQL - tạo mới nếu chưa có, cập nhật nếu đã có
    public boolean save(NotificationSettings s) {
        String sql = "INSERT INTO notification_settings (user_id, quiz_deadline_enabled, enrollment_enabled, event_reminder_enabled) " +
                     "VALUES (?, ?, ?, ?) " +
                     "ON CONFLICT (user_id) DO UPDATE SET " +
                     "quiz_deadline_enabled = EXCLUDED.quiz_deadline_enabled, " +
                     "enrollment_enabled = EXCLUDED.enrollment_enabled, " +
                     "event_reminder_enabled = EXCLUDED.event_reminder_enabled";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, s.getUserId());
            stmt.setBoolean(2, s.isQuizDeadlineEnabled());
            stmt.setBoolean(3, s.isEnrollmentEnabled());
            stmt.setBoolean(4, s.isEventReminderEnabled());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
