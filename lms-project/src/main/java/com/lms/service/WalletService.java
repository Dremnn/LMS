package com.lms.service;

import com.lms.dao.UserDAO;
import com.lms.dao.WalletTransactionDAO;
import com.lms.model.WalletTransaction;
import com.lms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

/**
 * Xử lý nghiệp vụ ví tiền: nạp tiền và thanh toán khóa học.
 * Mỗi thao tác chạy trong 1 transaction DB duy nhất (cộng/trừ số dư + ghi log)
 * để đảm bảo không bao giờ lệch số dư nếu có lỗi giữa chừng.
 */
public class WalletService {

    private final UserDAO userDAO;
    private final WalletTransactionDAO walletTransactionDAO;

    public WalletService() {
        this.userDAO = new UserDAO();
        this.walletTransactionDAO = new WalletTransactionDAO();
    }

    // =========================================================================
    // 1. NẠP TIỀN VÀO VÍ (chỉ dành cho Student)
    // amount: số tiền nạp; referenceCode: mã giao dịch chuyển khoản do user nhập
    // Trả về số dư MỚI sau khi nạp
    // =========================================================================
    public BigDecimal topUp(int userId, BigDecimal amount, String referenceCode) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Số tiền nạp phải lớn hơn 0!");
        }
        if (amount.compareTo(new BigDecimal("10000")) < 0) {
            throw new IllegalArgumentException("Số tiền nạp tối thiểu là 10,000đ!");
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            BigDecimal newBalance = userDAO.addBalance(conn, userId, amount);
            if (newBalance == null) {
                throw new IllegalStateException("Không tìm thấy tài khoản để nạp tiền!");
            }

            WalletTransaction tx = new WalletTransaction(userId, "topup", amount, referenceCode, null);
            tx.setBalanceAfter(newBalance);
            walletTransactionDAO.insert(conn, tx);

            conn.commit();
            return newBalance;

        } catch (SQLException e) {
            rollbackQuietly(conn);
            e.printStackTrace();
            throw new RuntimeException("Có lỗi hệ thống khi nạp tiền. Vui lòng thử lại!");
        } finally {
            closeQuietly(conn);
        }
    }

    // =========================================================================
    // 2. THANH TOÁN KHÓA HỌC BẰNG SỐ DƯ VÍ
    // Ném IllegalStateException("Số dư không đủ...") nếu không đủ tiền
    // Trả về số dư MỚI sau khi trừ
    // =========================================================================
    public BigDecimal payForCourse(int userId, int courseId, BigDecimal price) {
        if (price == null || price.compareTo(BigDecimal.ZERO) <= 0) {
            // Khóa học miễn phí - không cần trừ tiền
            return null;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            BigDecimal newBalance = userDAO.deductBalance(conn, userId, price);
            if (newBalance == null) {
                conn.rollback();
                throw new IllegalStateException(
                        "Số dư trong ví không đủ để đăng ký khóa học này. Vui lòng nạp thêm tiền!");
            }

            WalletTransaction tx = new WalletTransaction(userId, "payment", price, null, courseId);
            tx.setBalanceAfter(newBalance);
            walletTransactionDAO.insert(conn, tx);

            conn.commit();
            return newBalance;

        } catch (IllegalStateException e) {
            throw e; // Lỗi nghiệp vụ (không đủ tiền) - đã rollback ở trên, ném lại cho tầng trên xử lý
        } catch (SQLException e) {
            rollbackQuietly(conn);
            e.printStackTrace();
            throw new RuntimeException("Có lỗi hệ thống khi thanh toán. Vui lòng thử lại!");
        } finally {
            closeQuietly(conn);
        }
    }

    // =========================================================================
    // 3. LẤY LỊCH SỬ GIAO DỊCH VÍ (hiển thị ở trang Hồ sơ)
    // =========================================================================
    public List<WalletTransaction> getHistory(int userId) {
        return walletTransactionDAO.findByUser(userId, 20);
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ignored) {
            }
        }
    }

    private void closeQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException ignored) {
            }
        }
    }
}
