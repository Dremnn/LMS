package com.lms.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Column(name = "email", nullable = false, unique = true)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(name = "role", nullable = false)
    private String role;        // "student", "instructor", "admin"

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(name = "phone")
    private String phone;

    @Column(name = "balance")
    private BigDecimal balance; // Số dư ví - chỉ có ý nghĩa sử dụng với role "student"

    @Column(name = "status", nullable = false)
    private String status;      // "active", "locked", "pending"

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    // 1. Constructor mặc định (Bắt buộc phải có để tuân thủ chuẩn JavaBean)
    public User() {
    }

    // 2. Constructor dùng khi ĐĂNG KÝ MỚI (chưa có id và createdAt do database tự sinh)
    public User(String fullName, String email, String passwordHash, String role, String status) {
        this.fullName = fullName;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
        this.status = status;
    }

    // 3. Constructor đầy đủ tất cả các trường (dùng khi đọc từ Database lên)
    public User(int id, String fullName, String email, String passwordHash, String role,
                String avatarUrl, String status, LocalDateTime createdAt) {
        this(id, fullName, email, passwordHash, role, avatarUrl, null, BigDecimal.ZERO, status, createdAt);
    }

    // 4. Constructor đầy đủ + phone + balance (dùng khi đọc từ Database lên, có ví tiền)
    public User(int id, String fullName, String email, String passwordHash, String role,
                String avatarUrl, String phone, BigDecimal balance, String status, LocalDateTime createdAt) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
        this.avatarUrl = avatarUrl;
        this.phone = phone;
        this.balance = balance != null ? balance : BigDecimal.ZERO;
        this.status = status;
        this.createdAt = createdAt;
    }

    // ==================== GETTER & SETTER ====================

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public BigDecimal getBalance() {
        return balance != null ? balance : BigDecimal.ZERO;
    }

    public void setBalance(BigDecimal balance) {
        this.balance = balance;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    // ==================== TO STRING ====================
    // Dùng để in log kiểm tra khi debug (ẩn passwordHash để đảm bảo bảo mật)
    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", fullName='" + fullName + '\'' +
                ", email='" + email + '\'' +
                ", role='" + role + '\'' +
                ", avatarUrl='" + avatarUrl + '\'' +
                ", phone='" + phone + '\'' +
                ", balance=" + balance +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}