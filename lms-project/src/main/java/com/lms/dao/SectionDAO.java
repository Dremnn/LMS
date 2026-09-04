package com.lms.dao;

import com.lms.model.Section;
import com.lms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SectionDAO {

    // 1. Lấy toàn bộ chương của 1 khóa học, sắp theo order_index
    public List<Section> findByCourseId(int courseId) {
        List<Section> list = new ArrayList<>();
        String sql = "SELECT id, course_id, title, order_index FROM sections " +
                     "WHERE course_id = ? ORDER BY order_index ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, courseId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToSection(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Tìm 1 section theo ID (dùng khi kiểm tra quyền sở hữu trước khi thêm Lesson)
    public Section findById(int id) {
        String sql = "SELECT id, course_id, title, order_index FROM sections WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToSection(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 3. Tự động tính order_index tiếp theo (số chương hiện có + 1)
    // Giúp Instructor không cần tự nhập thứ tự, hệ thống tự xếp cuối danh sách
    public int getNextOrderIndex(int courseId) {
        String sql = "SELECT COALESCE(MAX(order_index), 0) + 1 AS next_order " +
                     "FROM sections WHERE course_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, courseId);

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

    // 4. Thêm chương mới
    public boolean save(Section section) {
        String sql = "INSERT INTO sections (course_id, title, order_index) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, section.getCourseId());
            stmt.setString(2, section.getTitle());
            stmt.setInt(3, section.getOrderIndex());

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        section.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 5. Sửa tên chương
    public boolean update(Section section) {
        String sql = "UPDATE sections SET title = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, section.getTitle());
            stmt.setInt(2, section.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 6. Xóa chương (sẽ tự động xóa luôn các Lesson bên trong nhờ ON DELETE CASCADE đã khai báo trong DB)
    public boolean delete(int sectionId) {
        String sql = "DELETE FROM sections WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, sectionId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Section mapResultSetToSection(ResultSet rs) throws SQLException {
        Section section = new Section();
        section.setId(rs.getInt("id"));
        section.setCourseId(rs.getInt("course_id"));
        section.setTitle(rs.getString("title"));
        section.setOrderIndex(rs.getInt("order_index"));
        return section;
    }
}