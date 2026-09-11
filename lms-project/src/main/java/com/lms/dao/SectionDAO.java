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
    public boolean updateTitle(int sectionId, String title) {
        String sql = "UPDATE sections SET title = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, title);
            stmt.setInt(2, sectionId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean update(Section section) {
        return updateTitle(section.getId(), section.getTitle());
    }

    // 6. Xóa chương và tự động dồn số thứ tự các chương sau lên 1
    public boolean deleteAndShiftOrder(int sectionId, int courseId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int deletedOrder = -1;
            String getOrderSql = "SELECT order_index FROM sections WHERE id = ? AND course_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(getOrderSql)) {
                stmt.setInt(1, sectionId);
                stmt.setInt(2, courseId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        deletedOrder = rs.getInt("order_index");
                    }
                }
            }

            if (deletedOrder == -1) {
                conn.rollback();
                return false;
            }

            // Dọn dẹp lesson_progress của các bài học bên trong
            String delProgressSql = "DELETE FROM lesson_progress WHERE lesson_id IN " +
                                    "(SELECT id FROM lessons WHERE section_id = ?)";
            try (PreparedStatement stmt = conn.prepareStatement(delProgressSql)) {
                stmt.setInt(1, sectionId);
                stmt.executeUpdate();
            }

            // Gỡ liên kết quiz nếu gắn với section này
            String unbindQuizSql = "UPDATE quizzes SET section_id = NULL WHERE section_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(unbindQuizSql)) {
                stmt.setInt(1, sectionId);
                stmt.executeUpdate();
            }

            // Xóa section (lessons tự xóa theo CASCADE)
            String delSectionSql = "DELETE FROM sections WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(delSectionSql)) {
                stmt.setInt(1, sectionId);
                stmt.executeUpdate();
            }

            // Dồn thứ tự: giảm order_index đi 1 cho các section có order_index > deletedOrder
            String shiftSql = "UPDATE sections SET order_index = order_index - 1 " +
                              "WHERE course_id = ? AND order_index > ?";
            try (PreparedStatement stmt = conn.prepareStatement(shiftSql)) {
                stmt.setInt(1, courseId);
                stmt.setInt(2, deletedOrder);
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

    // 7. Đổi số thứ tự chương và tự động điều chỉnh các chương khác theo
    public boolean reorderSection(int sectionId, int courseId, int targetOrder) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int currentOrder = -1;
            String getOrderSql = "SELECT order_index FROM sections WHERE id = ? AND course_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(getOrderSql)) {
                stmt.setInt(1, sectionId);
                stmt.setInt(2, courseId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        currentOrder = rs.getInt("order_index");
                    }
                }
            }

            if (currentOrder == -1 || currentOrder == targetOrder) {
                conn.rollback();
                return currentOrder == targetOrder;
            }

            // Kiểm tra tổng số chương của khóa học
            int totalSections = 0;
            String countSql = "SELECT COUNT(*) FROM sections WHERE course_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(countSql)) {
                stmt.setInt(1, courseId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        totalSections = rs.getInt(1);
                    }
                }
            }

            if (targetOrder < 1 || targetOrder > totalSections) {
                conn.rollback();
                return false;
            }

            // Tạm thời đưa section đang chọn về -1
            String tempSql = "UPDATE sections SET order_index = -1 WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(tempSql)) {
                stmt.setInt(1, sectionId);
                stmt.executeUpdate();
            }

            // Nếu targetOrder < currentOrder: dịch các section [targetOrder, currentOrder - 1] tăng lên 1
            if (targetOrder < currentOrder) {
                String shiftUpSql = "UPDATE sections SET order_index = order_index + 1 " +
                                    "WHERE course_id = ? AND order_index >= ? AND order_index < ?";
                try (PreparedStatement stmt = conn.prepareStatement(shiftUpSql)) {
                    stmt.setInt(1, courseId);
                    stmt.setInt(2, targetOrder);
                    stmt.setInt(3, currentOrder);
                    stmt.executeUpdate();
                }
            } else {
                // targetOrder > currentOrder: dịch các section [currentOrder + 1, targetOrder] giảm đi 1
                String shiftDownSql = "UPDATE sections SET order_index = order_index - 1 " +
                                      "WHERE course_id = ? AND order_index > ? AND order_index <= ?";
                try (PreparedStatement stmt = conn.prepareStatement(shiftDownSql)) {
                    stmt.setInt(1, courseId);
                    stmt.setInt(2, currentOrder);
                    stmt.setInt(3, targetOrder);
                    stmt.executeUpdate();
                }
            }

            // Đặt section đang chọn về targetOrder
            String finalSql = "UPDATE sections SET order_index = ? WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(finalSql)) {
                stmt.setInt(1, targetOrder);
                stmt.setInt(2, sectionId);
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

    public boolean delete(int sectionId) {
        Section s = findById(sectionId);
        if (s != null) {
            return deleteAndShiftOrder(sectionId, s.getCourseId());
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