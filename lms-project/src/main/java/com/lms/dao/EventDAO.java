package com.lms.dao;

import com.lms.model.Event;
import com.lms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EventDAO {

    private static final String COLUMNS =
        "e.id, e.user_id, e.course_id, e.title, e.event_date, e.description, " +
        "e.address, e.duration_type, e.duration_end, e.duration_minutes, e.created_at";

    public List<Event> findByUserAndMonth(int userId, int year, int month) {
        List<Event> list = new ArrayList<>();
        String sql = "SELECT " + COLUMNS + ", c.title AS course_title " +
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
                while (rs.next()) list.add(mapResultSetToEvent(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Event findById(int id) {
        String sql = "SELECT " + COLUMNS + ", c.title AS course_title " +
                     "FROM events e LEFT JOIN courses c ON e.course_id = c.id WHERE e.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapResultSetToEvent(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean save(Event event) {
        String sql = "INSERT INTO events (user_id, course_id, title, event_date, description, " +
                     "address, duration_type, duration_end, duration_minutes) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            bindEventParams(stmt, event, 1);

            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) event.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(Event event) {
        String sql = "UPDATE events SET course_id = ?, title = ?, event_date = ?, description = ?, " +
                     "address = ?, duration_type = ?, duration_end = ?, duration_minutes = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            // UPDATE không có cột user_id (chủ sở hữu không đổi), gán thủ công đúng thứ tự cột ở câu SQL trên
            stmt.setObject(1, event.getCourseId(), Types.INTEGER);
            stmt.setString(2, event.getTitle());
            stmt.setTimestamp(3, Timestamp.valueOf(event.getEventDate()));
            stmt.setString(4, event.getDescription());
            stmt.setString(5, event.getAddress());
            stmt.setString(6, event.getDurationType());
            stmt.setTimestamp(7, event.getDurationEnd() != null ? Timestamp.valueOf(event.getDurationEnd()) : null);
            stmt.setObject(8, event.getDurationMinutes(), Types.INTEGER);
            stmt.setInt(9, event.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

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

    // Gán tham số theo thứ tự dùng cho INSERT: user_id, course_id, title, event_date, description,
    // address, duration_type, duration_end, duration_minutes
    private int bindEventParams(PreparedStatement stmt, Event event, int startIndex) throws SQLException {
        int i = startIndex;
        stmt.setInt(i++, event.getUserId());
        stmt.setObject(i++, event.getCourseId(), Types.INTEGER);
        stmt.setString(i++, event.getTitle());
        stmt.setTimestamp(i++, Timestamp.valueOf(event.getEventDate()));
        stmt.setString(i++, event.getDescription());
        stmt.setString(i++, event.getAddress());
        stmt.setString(i++, event.getDurationType());
        stmt.setTimestamp(i++, event.getDurationEnd() != null ? Timestamp.valueOf(event.getDurationEnd()) : null);
        stmt.setObject(i++, event.getDurationMinutes(), Types.INTEGER);
        return i;
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
        event.setAddress(rs.getString("address"));
        event.setDurationType(rs.getString("duration_type"));

        Timestamp durationEndTs = rs.getTimestamp("duration_end");
        event.setDurationEnd(durationEndTs != null ? durationEndTs.toLocalDateTime() : null);

        int durationMinutes = rs.getInt("duration_minutes");
        event.setDurationMinutes(rs.wasNull() ? null : durationMinutes);

        Timestamp createdAtTs = rs.getTimestamp("created_at");
        event.setCreatedAt(createdAtTs != null ? createdAtTs.toLocalDateTime() : null);

        event.setCourseTitle(rs.getString("course_title"));

        return event;
    }
}
