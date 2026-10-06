package com.lms.dao;

import com.lms.model.Assignment;
import com.lms.model.FileData;
import com.lms.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class AssignmentDAO {

    static {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate("ALTER TABLE assignments ADD COLUMN IF NOT EXISTS section_id INT REFERENCES sections(id) ON DELETE SET NULL");
        } catch (Exception e) {
            System.err.println("AssignmentDAO auto migration: " + e.getMessage());
        }
    }

    // Các cột metadata - CỐ Ý không SELECT attach_data để danh sách không phải kéo file nặng
    private static final String META_COLUMNS =
            "a.id, a.course_id, a.section_id, a.title, a.description, a.due_at, a.attach_name, a.attach_type, " +
            "a.attach_size, a.notified_deadline, a.created_at";

    // 1. Tạo bài tập mới - trả về id, hoặc -1 nếu lỗi
    public int insert(Assignment a, byte[] attachData) {
        String sql = "INSERT INTO assignments " +
                "(course_id, section_id, title, description, due_at, attach_name, attach_type, attach_size, attach_data) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, a.getCourseId());
            if (a.getSectionId() != null) {
                stmt.setInt(2, a.getSectionId());
            } else {
                stmt.setNull(2, Types.INTEGER);
            }
            stmt.setString(3, a.getTitle());
            stmt.setString(4, a.getDescription());
            setTimestamp(stmt, 5, a.getDueAt());
            if (attachData != null) {
                stmt.setString(6, a.getAttachName());
                stmt.setString(7, a.getAttachType());
                stmt.setInt(8, attachData.length);
                stmt.setBytes(9, attachData);
            } else {
                stmt.setNull(6, Types.VARCHAR);
                stmt.setNull(7, Types.VARCHAR);
                stmt.setNull(8, Types.INTEGER);
                stmt.setNull(9, Types.BINARY);
            }

            if (stmt.executeUpdate() > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) return keys.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    // 2. Sửa bài tập.
    //    attachMode: "keep" (giữ file cũ) | "remove" (xóa file) | "replace" (thay bằng newData)
    //    Nếu hạn nộp thay đổi -> reset notified_deadline để hệ thống nhắc lại theo hạn mới.
    public boolean update(Assignment a, String attachMode, byte[] newData) {
        StringBuilder sql = new StringBuilder(
                "UPDATE assignments SET section_id = ?, title = ?, description = ?, " +
                "notified_deadline = CASE WHEN due_at IS DISTINCT FROM ? THEN FALSE ELSE notified_deadline END, " +
                "due_at = ?");
        if ("remove".equals(attachMode)) {
            sql.append(", attach_name = NULL, attach_type = NULL, attach_size = NULL, attach_data = NULL");
        } else if ("replace".equals(attachMode)) {
            sql.append(", attach_name = ?, attach_type = ?, attach_size = ?, attach_data = ?");
        }
        sql.append(" WHERE id = ?");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            int i = 1;
            if (a.getSectionId() != null) {
                stmt.setInt(i++, a.getSectionId());
            } else {
                stmt.setNull(i++, Types.INTEGER);
            }
            stmt.setString(i++, a.getTitle());
            stmt.setString(i++, a.getDescription());
            setTimestamp(stmt, i++, a.getDueAt());
            setTimestamp(stmt, i++, a.getDueAt());
            if ("replace".equals(attachMode)) {
                stmt.setString(i++, a.getAttachName());
                stmt.setString(i++, a.getAttachType());
                stmt.setInt(i++, newData.length);
                stmt.setBytes(i++, newData);
            }
            stmt.setInt(i, a.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 3. Xóa bài tập (bài nộp bị xóa theo nhờ ON DELETE CASCADE)
    public boolean delete(int id) {
        String sql = "DELETE FROM assignments WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 4. Lấy 1 bài tập (kèm tên khóa học và tên chương nếu có) - không kèm nội dung file
    public Assignment findById(int id) {
        String sql = "SELECT " + META_COLUMNS + ", c.title AS course_title, sec.title AS section_title " +
                "FROM assignments a " +
                "INNER JOIN courses c ON c.id = a.course_id " +
                "LEFT JOIN sections sec ON sec.id = a.section_id " +
                "WHERE a.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Assignment a = map(rs);
                    a.setCourseTitle(rs.getString("course_title"));
                    a.setSectionTitle(rs.getString("section_title"));
                    return a;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 5. Giảng viên: danh sách bài tập của khóa + số bài đã nộp / tổng học viên
    public List<Assignment> findByCourseForInstructor(int courseId) {
        String sql = "SELECT " + META_COLUMNS + ", sec.title AS section_title, " +
                "(SELECT COUNT(*) FROM assignment_submissions s WHERE s.assignment_id = a.id) AS submission_count, " +
                "(SELECT COUNT(*) FROM enrollments e WHERE e.course_id = a.course_id) AS enrolled_count " +
                "FROM assignments a " +
                "LEFT JOIN sections sec ON sec.id = a.section_id " +
                "WHERE a.course_id = ? " +
                "ORDER BY a.due_at ASC NULLS LAST, a.created_at DESC";
        List<Assignment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, courseId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Assignment a = map(rs);
                    a.setSectionTitle(rs.getString("section_title"));
                    a.setSubmissionCount(rs.getInt("submission_count"));
                    a.setEnrolledCount(rs.getInt("enrolled_count"));
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 6. Học viên: danh sách bài tập của khóa + trạng thái đã nộp của chính học viên đó
    public List<Assignment> findByCourseForStudent(int courseId, int studentId) {
        String sql = "SELECT " + META_COLUMNS + ", sec.title AS section_title, s.id AS my_submission_id, s.submitted_at AS my_submitted_at " +
                "FROM assignments a " +
                "LEFT JOIN sections sec ON sec.id = a.section_id " +
                "LEFT JOIN assignment_submissions s ON s.assignment_id = a.id AND s.student_id = ? " +
                "WHERE a.course_id = ? " +
                "ORDER BY a.due_at ASC NULLS LAST, a.created_at DESC";
        List<Assignment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentId);
            stmt.setInt(2, courseId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Assignment a = map(rs);
                    a.setSectionTitle(rs.getString("section_title"));
                    int subId = rs.getInt("my_submission_id");
                    if (!rs.wasNull()) {
                        a.setMySubmissionId(subId);
                        Timestamp ts = rs.getTimestamp("my_submitted_at");
                        a.setMySubmittedAt(ts != null ? ts.toLocalDateTime() : null);
                    }
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Assignment> findBySectionId(int sectionId) {
        String sql = "SELECT " + META_COLUMNS + " FROM assignments a WHERE a.section_id = ? ORDER BY a.due_at ASC NULLS LAST, a.created_at DESC";
        List<Assignment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, sectionId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 7. File đề bài đính kèm (để download)
    public FileData getAttachment(int id) {
        String sql = "SELECT attach_name, attach_type, attach_data FROM assignments WHERE id = ? AND attach_data IS NOT NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new FileData(rs.getString("attach_name"), rs.getString("attach_type"), rs.getBytes("attach_data"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 8. Scheduler: bài tập có hạn nộp trong (now, threshold] và chưa gửi nhắc
    public List<Assignment> findDueSoonNotNotified(LocalDateTime now, LocalDateTime threshold) {
        String sql = "SELECT " + META_COLUMNS + " FROM assignments a " +
                "WHERE a.due_at IS NOT NULL AND a.notified_deadline = FALSE " +
                "AND a.due_at > ? AND a.due_at <= ?";
        List<Assignment> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setTimestamp(1, Timestamp.valueOf(now));
            stmt.setTimestamp(2, Timestamp.valueOf(threshold));
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void markDeadlineNotified(int id) {
        String sql = "UPDATE assignments SET notified_deadline = TRUE WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void setTimestamp(PreparedStatement stmt, int index, LocalDateTime value) throws SQLException {
        if (value != null) {
            stmt.setTimestamp(index, Timestamp.valueOf(value));
        } else {
            stmt.setNull(index, Types.TIMESTAMP);
        }
    }

    private Assignment map(ResultSet rs) throws SQLException {
        Assignment a = new Assignment();
        a.setId(rs.getInt("id"));
        a.setCourseId(rs.getInt("course_id"));
        int secId = rs.getInt("section_id");
        a.setSectionId(rs.wasNull() ? null : secId);
        a.setTitle(rs.getString("title"));
        a.setDescription(rs.getString("description"));
        Timestamp due = rs.getTimestamp("due_at");
        a.setDueAt(due != null ? due.toLocalDateTime() : null);
        a.setAttachName(rs.getString("attach_name"));
        a.setAttachType(rs.getString("attach_type"));
        int size = rs.getInt("attach_size");
        a.setAttachSize(rs.wasNull() ? null : size);
        a.setNotifiedDeadline(rs.getBoolean("notified_deadline"));
        Timestamp created = rs.getTimestamp("created_at");
        a.setCreatedAt(created != null ? created.toLocalDateTime() : null);
        return a;
    }
}
