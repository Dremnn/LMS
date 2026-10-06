package com.lms.dao;

import com.lms.model.AssignmentSubmission;
import com.lms.model.FileData;
import com.lms.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class AssignmentSubmissionDAO {

    // 1. Nộp bài (UPSERT): chưa có -> tạo mới; đã có -> ghi đè bài cũ bằng file mới
    public boolean upsert(AssignmentSubmission s, byte[] data) {
        String sql = "INSERT INTO assignment_submissions " +
                "(assignment_id, student_id, file_name, file_type, file_size, file_data, note, submitted_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?) " +
                "ON CONFLICT (assignment_id, student_id) DO UPDATE SET " +
                "file_name = EXCLUDED.file_name, file_type = EXCLUDED.file_type, " +
                "file_size = EXCLUDED.file_size, file_data = EXCLUDED.file_data, " +
                "note = EXCLUDED.note, submitted_at = EXCLUDED.submitted_at";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, s.getAssignmentId());
            stmt.setInt(2, s.getStudentId());
            stmt.setString(3, s.getFileName());
            stmt.setString(4, s.getFileType());
            stmt.setInt(5, data.length);
            stmt.setBytes(6, data);
            stmt.setString(7, s.getNote());
            stmt.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 2. Giảng viên: danh sách học viên đã nộp (kèm tên/email) - không kèm nội dung file
    public List<AssignmentSubmission> findByAssignment(int assignmentId) {
        String sql = "SELECT s.id, s.assignment_id, s.student_id, s.file_name, s.file_type, s.file_size, " +
                "s.note, s.submitted_at, u.full_name, u.email, a.due_at " +
                "FROM assignment_submissions s " +
                "INNER JOIN users u ON u.id = s.student_id " +
                "INNER JOIN assignments a ON a.id = s.assignment_id " +
                "WHERE s.assignment_id = ? ORDER BY s.submitted_at DESC";
        List<AssignmentSubmission> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, assignmentId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Học viên: bài nộp hiện tại của chính mình cho 1 bài tập
    public AssignmentSubmission findByAssignmentAndStudent(int assignmentId, int studentId) {
        String sql = "SELECT s.id, s.assignment_id, s.student_id, s.file_name, s.file_type, s.file_size, " +
                "s.note, s.submitted_at, u.full_name, u.email, a.due_at " +
                "FROM assignment_submissions s " +
                "INNER JOIN users u ON u.id = s.student_id " +
                "INNER JOIN assignments a ON a.id = s.assignment_id " +
                "WHERE s.assignment_id = ? AND s.student_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, assignmentId);
            stmt.setInt(2, studentId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 4. Metadata 1 bài nộp theo id (để kiểm tra quyền trước khi cho tải file)
    public AssignmentSubmission findById(int id) {
        String sql = "SELECT s.id, s.assignment_id, s.student_id, s.file_name, s.file_type, s.file_size, " +
                "s.note, s.submitted_at, u.full_name, u.email, a.due_at " +
                "FROM assignment_submissions s " +
                "INNER JOIN users u ON u.id = s.student_id " +
                "INNER JOIN assignments a ON a.id = s.assignment_id " +
                "WHERE s.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 5. Nội dung file bài nộp (để download)
    public FileData getFile(int id) {
        String sql = "SELECT file_name, file_type, file_data FROM assignment_submissions WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new FileData(rs.getString("file_name"), rs.getString("file_type"), rs.getBytes("file_data"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private AssignmentSubmission map(ResultSet rs) throws SQLException {
        AssignmentSubmission s = new AssignmentSubmission();
        s.setId(rs.getInt("id"));
        s.setAssignmentId(rs.getInt("assignment_id"));
        s.setStudentId(rs.getInt("student_id"));
        s.setFileName(rs.getString("file_name"));
        s.setFileType(rs.getString("file_type"));
        s.setFileSize(rs.getInt("file_size"));
        s.setNote(rs.getString("note"));
        Timestamp ts = rs.getTimestamp("submitted_at");
        s.setSubmittedAt(ts != null ? ts.toLocalDateTime() : null);
        s.setStudentName(rs.getString("full_name"));
        s.setStudentEmail(rs.getString("email"));
        Timestamp due = rs.getTimestamp("due_at");
        s.setAssignmentDueAt(due != null ? due.toLocalDateTime() : null);
        return s;
    }
}
