package com.lms.service;

import com.lms.dao.UserDAO;
import com.lms.dao.WalletTransactionDAO;
import com.lms.model.WalletTransaction;
import com.lms.util.DBConnection;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

/**
 * Xử lý nghiệp vụ ví tiền: nạp tiền và thanh toán khóa học.
 * Mỗi thao tác chạy trong 1 transaction DB duy nhất (cộng/trừ số dư + ghi log)
 * để đảm bảo không bao giờ lệch số dư nếu có lỗi giữa chừng.
 */
public class WalletService {

    // Hoa hồng nền tảng: 3% giá khóa học được chuyển cho tài khoản admin,
    // giảng viên nhận phần còn lại (97%)
    public static final BigDecimal COMMISSION_RATE = new BigDecimal("0.03");

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
    // Trừ tiền của Student, cộng 97% cho Instructor và 3% hoa hồng cho Admin
    // trong CÙNG 1 transaction (hoặc thành công cả 3, hoặc rollback cả 3)
    // Ném IllegalStateException("Số dư không đủ...") nếu không đủ tiền
    // Trả về số dư MỚI của student sau khi trừ
    // =========================================================================
    public BigDecimal payForCourse(int studentId, int instructorId, int courseId, BigDecimal price) {
        if (price == null || price.compareTo(BigDecimal.ZERO) <= 0) {
            // Khóa học miễn phí - không cần thanh toán
            return null;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            BigDecimal studentNewBalance = userDAO.deductBalance(conn, studentId, price);
            if (studentNewBalance == null) {
                conn.rollback();
                throw new IllegalStateException(
                        "Số dư trong ví không đủ để đăng ký khóa học này. Vui lòng nạp thêm tiền!");
            }

            WalletTransaction paymentTx = new WalletTransaction(studentId, "payment", price, null, courseId);
            paymentTx.setBalanceAfter(studentNewBalance);
            walletTransactionDAO.insert(conn, paymentTx);

            // Tách hoa hồng: admin nhận 3%, giảng viên nhận phần còn lại
            Integer adminId = userDAO.findFirstAdminId();
            BigDecimal commission = calcCommission(price, instructorId, adminId);
            BigDecimal instructorShare = price.subtract(commission);

            // Cộng tiền cho giảng viên sở hữu khóa học
            BigDecimal instructorNewBalance = userDAO.addBalance(conn, instructorId, instructorShare);
            if (instructorNewBalance == null) {
                conn.rollback();
                throw new RuntimeException("Không tìm thấy tài khoản giảng viên để cộng tiền!");
            }

            WalletTransaction earningTx = new WalletTransaction(instructorId, "earning", instructorShare, null, courseId);
            earningTx.setBalanceAfter(instructorNewBalance);
            walletTransactionDAO.insert(conn, earningTx);

            // Cộng hoa hồng cho admin
            if (commission.signum() > 0) {
                BigDecimal adminNewBalance = userDAO.addBalance(conn, adminId, commission);
                if (adminNewBalance == null) {
                    conn.rollback();
                    throw new RuntimeException("Không tìm thấy tài khoản admin để cộng hoa hồng!");
                }

                WalletTransaction commissionTx = new WalletTransaction(adminId, "commission", commission, null, courseId);
                commissionTx.setBalanceAfter(adminNewBalance);
                walletTransactionDAO.insert(conn, commissionTx);
            }

            conn.commit();
            return studentNewBalance;

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
    // 2b. HOÀN TIỀN KHÓA HỌC (Refund) - dùng khi Student hủy đăng ký trong thời hạn cho phép
    // Hoàn lại 100% tiền cho Student, đồng thời trừ lại phần 97% của Instructor
    // và 3% hoa hồng của Admin, trong CÙNG 1 transaction (hoặc thành công hết, hoặc rollback hết)
    // =========================================================================
    public void refundCourse(int studentId, int instructorId, int courseId, BigDecimal price) {
        if (price == null || price.compareTo(BigDecimal.ZERO) <= 0) {
            return; // Khóa học miễn phí - không có gì để hoàn tiền
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Tính lại đúng phần hoa hồng đã chia lúc thanh toán
            Integer adminId = userDAO.findFirstAdminId();
            BigDecimal commission = calcCommission(price, instructorId, adminId);
            BigDecimal instructorShare = price.subtract(commission);

            // Trừ lại tiền của giảng viên trước - nếu giảng viên không còn đủ số dư này
            // (ví dụ đã rút/tiêu hết) thì hủy toàn bộ thao tác hoàn tiền
            BigDecimal instructorNewBalance = userDAO.deductBalance(conn, instructorId, instructorShare);
            if (instructorNewBalance == null) {
                conn.rollback();
                throw new IllegalStateException(
                        "Không thể hoàn tiền vì số dư của giảng viên không đủ. Vui lòng liên hệ quản trị viên!");
            }

            WalletTransaction deductionTx = new WalletTransaction(instructorId, "refund_deduction", instructorShare, null, courseId);
            deductionTx.setBalanceAfter(instructorNewBalance);
            walletTransactionDAO.insert(conn, deductionTx);

            // Thu hồi hoa hồng đã chuyển cho admin
            if (commission.signum() > 0) {
                BigDecimal adminNewBalance = userDAO.deductBalance(conn, adminId, commission);
                if (adminNewBalance == null) {
                    conn.rollback();
                    throw new IllegalStateException(
                            "Không thể hoàn tiền vì số dư của admin không đủ để thu hồi hoa hồng. Vui lòng liên hệ quản trị viên!");
                }

                WalletTransaction commissionRefundTx =
                        new WalletTransaction(adminId, "commission_refund", commission, null, courseId);
                commissionRefundTx.setBalanceAfter(adminNewBalance);
                walletTransactionDAO.insert(conn, commissionRefundTx);
            }

            // Hoàn tiền vào ví Student
            BigDecimal studentNewBalance = userDAO.addBalance(conn, studentId, price);
            if (studentNewBalance == null) {
                conn.rollback();
                throw new RuntimeException("Không tìm thấy tài khoản để hoàn tiền!");
            }

            WalletTransaction refundTx = new WalletTransaction(studentId, "refund", price, null, courseId);
            refundTx.setBalanceAfter(studentNewBalance);
            walletTransactionDAO.insert(conn, refundTx);

            conn.commit();

        } catch (IllegalStateException e) {
            throw e;
        } catch (SQLException e) {
            rollbackQuietly(conn);
            e.printStackTrace();
            throw new RuntimeException("Có lỗi hệ thống khi hoàn tiền. Vui lòng thử lại!");
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

    // =========================================================================
    // Tính hoa hồng admin = 3% giá khóa học (làm tròn 2 chữ số thập phân).
    // Trả về 0 (không thu hoa hồng) nếu: chưa có admin, hoặc chủ khóa học chính là admin.
    // Dùng chung cho cả thanh toán và hoàn tiền để 2 chiều luôn khớp nhau.
    // =========================================================================
    private BigDecimal calcCommission(BigDecimal price, int instructorId, Integer adminId) {
        if (adminId == null) {
            System.err.println("[WalletService] Chưa có tài khoản admin - bỏ qua hoa hồng, giảng viên nhận 100%.");
            return BigDecimal.ZERO;
        }
        if (adminId == instructorId) {
            return BigDecimal.ZERO; // admin tự bán khóa học: không cần chia
        }
        return price.multiply(COMMISSION_RATE).setScale(2, RoundingMode.HALF_UP);
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
