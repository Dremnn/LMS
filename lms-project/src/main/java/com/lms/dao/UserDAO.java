package com.lms.dao;

import com.lms.model.User;
import com.lms.util.DBConnection;
import com.lms.util.DBUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.NoResultException;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;

public class UserDAO {

    private static final String SELECT_COLUMNS =
            "id, full_name, email, password_hash, role, avatar_url, phone, balance, status, created_at ";

    // 1. Tìm User theo Email (Dùng khi Đăng nhập) - Ưu tiên JPA Chapter 13, tự động Fallback JDBC nếu cần
    public User findByEmail(String email) {
        if (DBUtil.getEmFactory() != null) {
            EntityManager em = null;
            try {
                em = DBUtil.getEmFactory().createEntityManager();
                return em.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class)
                         .setParameter("email", email)
                         .getSingleResult();
            } catch (NoResultException e) {
                return null;
            } catch (Exception e) {
                // Nếu JPA gặp sự cố mapping thì dùng fallback JDBC
            } finally {
                if (em != null && em.isOpen()) em.close();
            }
        }
        return findByEmailJdbc(email);
    }

    private User findByEmailJdbc(String email) {
        String sql = "SELECT " + SELECT_COLUMNS + "FROM users WHERE email = ?";
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
        return null;
    }

    // 2. Kiểm tra Email đã tồn tại trong Database chưa (Dùng khi Đăng ký)
    public boolean existsByEmail(String email) {
        return findByEmail(email) != null;
    }

    // 3. Thêm User mới vào Database (Dùng khi Đăng ký) - Chuẩn JPA Chapter 13
    public boolean save(User user) {
        if (user.getCreatedAt() == null) {
            user.setCreatedAt(LocalDateTime.now());
        }
        if (user.getRole() == null) {
            user.setRole("student");
        }
        if (user.getStatus() == null) {
            user.setStatus("active");
        }
        if (DBUtil.getEmFactory() != null) {
            EntityManager em = null;
            EntityTransaction trans = null;
            try {
                em = DBUtil.getEmFactory().createEntityManager();
                trans = em.getTransaction();
                trans.begin();
                em.persist(user);
                trans.commit();
                return true;
            } catch (Exception e) {
                if (trans != null && trans.isActive()) trans.rollback();
            } finally {
                if (em != null && em.isOpen()) em.close();
            }
        }
        return saveJdbc(user);
    }

    private boolean saveJdbc(User user) {
        String sql = "INSERT INTO users (full_name, email, password_hash, role, status, created_at) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPasswordHash());
            stmt.setString(4, user.getRole() != null ? user.getRole() : "student");
            stmt.setString(5, user.getStatus() != null ? user.getStatus() : "active");
            LocalDateTime now = user.getCreatedAt() != null ? user.getCreatedAt() : LocalDateTime.now();
            stmt.setTimestamp(6, Timestamp.valueOf(now));
            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        user.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 4. Tìm User theo ID - Ưu tiên JPA Chapter 13, tự động Fallback JDBC nếu cần
    public User findById(int id) {
        if (DBUtil.getEmFactory() != null) {
            EntityManager em = null;
            try {
                em = DBUtil.getEmFactory().createEntityManager();
                return em.find(User.class, id);
            } catch (Exception e) {
                // Fallback JDBC
            } finally {
                if (em != null && em.isOpen()) em.close();
            }
        }
        return findByIdJdbc(id);
    }

    private User findByIdJdbc(int id) {
        String sql = "SELECT " + SELECT_COLUMNS + "FROM users WHERE id = ?";
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
                rs.getString("phone"),
                rs.getBigDecimal("balance"),
                rs.getString("status"),
                createdAt
        );
    }

    // =========================================================================
    // 6. Cập nhật thông tin cá nhân (trang Hồ sơ): avatar + số điện thoại
    // Họ tên và email KHÔNG cho sửa ở đây (email gắn với đăng ký/đăng nhập)
    // =========================================================================
    public boolean updateProfile(int userId,String fullName, String avatarUrl, String phone) {
        String sql = "UPDATE users SET full_name = ?, avatar_url = ?, phone = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, fullName);
            stmt.setString(2, avatarUrl);
            stmt.setString(3, phone);
            stmt.setInt(4, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // =========================================================================
    // 7. Cộng tiền vào ví (Nạp tiền) - trả về số dư MỚI sau khi cộng, null nếu lỗi
    // Nhận vào 1 Connection có sẵn để có thể gộp chung transaction với việc
    // ghi log vào bảng wallet_transactions (WalletTransactionDAO)
    // =========================================================================
    public BigDecimal addBalance(Connection conn, int userId, BigDecimal amount) throws SQLException {
        String sql = "UPDATE users SET balance = balance + ? WHERE id = ? RETURNING balance";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBigDecimal(1, amount);
            stmt.setInt(2, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("balance");
                }
            }
        }
        return null;
    }

    // =========================================================================
    // 8. Trừ tiền trong ví (Thanh toán khóa học) - CHỈ trừ được nếu đủ số dư
    // Điều kiện "balance >= ?" được kiểm tra ngay trong câu UPDATE để tránh
    // race-condition (2 request trừ tiền cùng lúc). Trả về số dư MỚI, hoặc
    // null nếu KHÔNG đủ tiền (không có dòng nào bị update).
    // =========================================================================
    public BigDecimal deductBalance(Connection conn, int userId, BigDecimal amount) throws SQLException {
        String sql = "UPDATE users SET balance = balance - ? WHERE id = ? AND balance >= ? RETURNING balance";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBigDecimal(1, amount);
            stmt.setInt(2, userId);
            stmt.setBigDecimal(3, amount);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("balance");
                }
            }
        }
        return null; // Không đủ số dư
    }
}