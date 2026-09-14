package com.lms.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Lịch sử giao dịch ví: nạp tiền ("topup") hoặc thanh toán khóa học ("payment").
 */
public class WalletTransaction implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private String type;           // "topup", "payment"
    private BigDecimal amount;
    private String referenceCode;  // Mã giao dịch chuyển khoản (chỉ có ở "topup")
    private Integer courseId;      // Khóa học liên quan (chỉ có ở "payment")
    private BigDecimal balanceAfter;
    private LocalDateTime createdAt;

    // Các trường bổ sung từ JOIN (không map trực tiếp với cột DB)
    private String courseName;

    public WalletTransaction() {
    }

    public WalletTransaction(int userId, String type, BigDecimal amount, String referenceCode, Integer courseId) {
        this.userId = userId;
        this.type = type;
        this.amount = amount;
        this.referenceCode = referenceCode;
        this.courseId = courseId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getReferenceCode() {
        return referenceCode;
    }

    public void setReferenceCode(String referenceCode) {
        this.referenceCode = referenceCode;
    }

    public Integer getCourseId() {
        return courseId;
    }

    public void setCourseId(Integer courseId) {
        this.courseId = courseId;
    }

    public BigDecimal getBalanceAfter() {
        return balanceAfter;
    }

    public void setBalanceAfter(BigDecimal balanceAfter) {
        this.balanceAfter = balanceAfter;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }
}
