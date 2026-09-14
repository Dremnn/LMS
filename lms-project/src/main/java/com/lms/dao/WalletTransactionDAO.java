package com.lms.dao;

import com.lms.model.WalletTransaction;
import com.lms.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class WalletTransactionDAO {

    // 1. Ghi 1 giao dịch ví (dùng chung Connection với UserDAO.addBalance/deductBalance
    //    để đảm bảo cùng 1 transaction - hoặc thành công cả 2, hoặc rollback cả 2)
    public boolean insert(Connection conn, WalletTransaction tx) throws SQLException {
        String sql = "INSERT INTO wallet_transactions " +
                "(user_id, type, amount, reference_code, course_id, balance_after, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, tx.getUserId());
            stmt.setString(2, tx.getType());
            stmt.setBigDecimal(3, tx.getAmount());
            stmt.setString(4, tx.getReferenceCode());
            if (tx.getCourseId() != null) {
                stmt.setInt(5, tx.getCourseId());
            } else {
                stmt.setNull(5, Types.INTEGER);
            }
            stmt.setBigDecimal(6, tx.getBalanceAfter());

            LocalDateTime now = LocalDateTime.now();
            stmt.setTimestamp(7, Timestamp.valueOf(now));

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        tx.setId(keys.getInt(1));
                        tx.setCreatedAt(now);
                    }
                }
                return true;
            }
        }
        return false;
    }

    // 2. Lấy lịch sử giao dịch của 1 user (mới nhất trước), dùng cho trang Hồ sơ
    public List<WalletTransaction> findByUser(int userId, int limit) {
        String sql = "SELECT wt.id, wt.user_id, wt.type, wt.amount, wt.reference_code, " +
                "wt.course_id, wt.balance_after, wt.created_at, c.title AS course_name " +
                "FROM wallet_transactions wt " +
                "LEFT JOIN courses c ON c.id = wt.course_id " +
                "WHERE wt.user_id = ? " +
                "ORDER BY wt.created_at DESC " +
                "LIMIT ?";

        List<WalletTransaction> list = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            stmt.setInt(2, limit);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    WalletTransaction tx = new WalletTransaction();
                    tx.setId(rs.getInt("id"));
                    tx.setUserId(rs.getInt("user_id"));
                    tx.setType(rs.getString("type"));
                    tx.setAmount(rs.getBigDecimal("amount"));
                    tx.setReferenceCode(rs.getString("reference_code"));
                    int courseId = rs.getInt("course_id");
                    tx.setCourseId(rs.wasNull() ? null : courseId);
                    tx.setBalanceAfter(rs.getBigDecimal("balance_after"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    tx.setCreatedAt(ts != null ? ts.toLocalDateTime() : null);
                    tx.setCourseName(rs.getString("course_name"));
                    list.add(tx);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
