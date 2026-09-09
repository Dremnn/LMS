package com.lms.dao;

import com.lms.model.Event;
import com.lms.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class EventDAO {

    // 1. Lấy tất cả sự kiện của 1 user trong 1 tháng cụ thể (dùng cho Dashboard/Timetable)
    public List<Event> findByUserAndMonth(int userId, int year, int month) {
        List<Event> list = new ArrayList<>();
        String sql = "SELECT e.id, e.user_id, e.course_id, e.title, e.event_date, e.description, e.created_at, " +
                     "c.title AS course_title " +
                     "FROM events e LEFT JOIN courses c ON e.course_id = c.id " +
                     "WHERE e.user_id = ? " +
                     "AND EXTRACT(YEAR FROM e.event_date) = ? " +
                     "AND EXTRACT(MONTH FROM e.event_date) = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            stmt.setInt(2, year);
            stmt.setInt(3, month);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToEvent(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Tạo sự kiện mới
    public boolean save(Event event) {
        String sql = "INSERT INTO events (user_id, course_id, title, event_date, description) " +
                     "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, event.getUserId());

            if (event.getCourseId() != null) {
                stmt.setInt(2, event.getCourseId());
            } else {
                stmt.setNull(2, Types.INTEGER);
            }

            stmt.setString(3, event.getTitle());
            stmt.setTimestamp(4, Timestamp.valueOf(event.getEventDate()));
            stmt.setString(5, event.getDescription());

            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        event.setId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 3. Xóa sự kiện (chỉ chủ sở hữu mới được xóa - kiểm tra ở Service)
    public boolean delete(int eventId) {
        String sql = "DELETE FROM events WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, eventId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Event findById(int id) {
        String sql = "SELECT e.id, e.user_id, e.course_id, e.title, e.event_date, e.description, e.created_at, " +
                     "c.title AS course_title " +
                     "FROM events e LEFT JOIN courses c ON e.course_id = c.id WHERE e.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToEvent(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private Event mapResultSetToEvent(ResultSet rs) throws SQLException {
        Event event = new Event();
        event.setId(rs.getInt("id"));
        event.setUserId(rs.getInt("user_id"));

        int courseId = rs.getInt("course_id");
        event.setCourseId(rs.wasNull() ? null : courseId);

        event.setTitle(rs.getString("title"));

        Timestamp eventDateTs = rs.getTimestamp("event_date");
        event.setEventDate(eventDateTs != null ? eventDateTs.toLocalDateTime() : null);

        event.setDescription(rs.getString("description"));

        Timestamp createdAtTs = rs.getTimestamp("created_at");
        event.setCreatedAt(createdAtTs != null ? createdAtTs.toLocalDateTime() : null);

        event.setCourseTitle(rs.getString("course_title"));

        return event;
    }
}
