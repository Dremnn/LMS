package com.lms.dao;

import com.lms.model.User;
import com.lms.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;

public class UserDAO {

    // 1. Tìm User theo Email (Dùng khi Đăng nhập)
    public User findByEmail(String email) {
        String sql = "SELECT id, full_name, email, password_hash, role, avatar_url, status, created_at " +
                     "FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null; // Không tìm thấy user
    }

    // 2. Kiểm tra Email đã tồn tại trong Database chưa (Dùng khi Đăng ký)
    public boolean existsByEmail(String email) {
        String sql = "SELECT 1 FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);

            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next(); // Trả về true nếu có kết quả, false nếu chưa có
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 3. Thêm User mới vào Database (Dùng khi Đăng ký)
    public boolean save(User user) {
        String sql = "INSERT INTO users (full_name, email, password_hash, role, status, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPasswordHash());
            stmt.setString(4, user.getRole() != null ? user.getRole() : "student");
            stmt.setString(5, user.getStatus() != null ? user.getStatus() : "active");
            
            // Xử lý thời gian hiện tại
            LocalDateTime now = LocalDateTime.now();
            stmt.setTimestamp(6, Timestamp.valueOf(now));

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                // Lấy ID tự tăng mà SQL Server vừa sinh ra gán ngược lại cho đối tượng user
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        user.setId(generatedKeys.getInt(1));
                        user.setCreatedAt(now);
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 4. Tìm User theo ID
    public User findById(int id) {
        String sql = "SELECT id, full_name, email, password_hash, role, avatar_url, status, created_at " +
                     "FROM users WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 5. Hàm phụ trợ (Private Helper): Đọc 1 dòng từ ResultSet và chuyển thành đối tượng User
    // Giúp tái sử dụng code, không phải viết lặp lại ở nhiều hàm
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        Timestamp timestamp = rs.getTimestamp("created_at");
        LocalDateTime createdAt = (timestamp != null) ? timestamp.toLocalDateTime() : null;

        return new User(
                rs.getInt("id"),
                rs.getString("full_name"),
                rs.getString("email"),
                rs.getString("password_hash"),
                rs.getString("role"),
                rs.getString("avatar_url"),
                rs.getString("status"),
                createdAt
        );
    }
}