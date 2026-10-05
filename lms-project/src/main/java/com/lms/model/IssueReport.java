package com.lms.model;

import java.sql.Timestamp;

public class IssueReport {
    private int id;
    private String referenceCode;
    private String email;
    private String role;           // "student" | "instructor"
    private String issueType;      // "notification", "quiz", "lesson", "payment", "account", "course", "ui", "other"
    private String description;
    private String pageUrl;
    private String screenshots;    // JSON array or base64 data URLs
    private String status;         // "pending", "resolved", "rejected"
    private String adminNote;
    private Integer resolvedBy;
    private String resolvedByName;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public IssueReport() {
        this.status = "pending";
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getReferenceCode() {
        return referenceCode;
    }

    public void setReferenceCode(String referenceCode) {
        this.referenceCode = referenceCode;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getIssueType() {
        return issueType;
    }

    public void setIssueType(String issueType) {
        this.issueType = issueType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getPageUrl() {
        return pageUrl;
    }

    public void setPageUrl(String pageUrl) {
        this.pageUrl = pageUrl;
    }

    public String getScreenshots() {
        return screenshots;
    }

    public void setScreenshots(String screenshots) {
        this.screenshots = screenshots;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getAdminNote() {
        return adminNote;
    }

    public void setAdminNote(String adminNote) {
        this.adminNote = adminNote;
    }

    public Integer getResolvedBy() {
        return resolvedBy;
    }

    public void setResolvedBy(Integer resolvedBy) {
        this.resolvedBy = resolvedBy;
    }

    public String getResolvedByName() {
        return resolvedByName;
    }

    public void setResolvedByName(String resolvedByName) {
        this.resolvedByName = resolvedByName;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    // Helper display methods
    public String getRoleDisplay() {
        if ("instructor".equalsIgnoreCase(role)) {
            return "Giảng viên";
        } else if ("student".equalsIgnoreCase(role)) {
            return "Sinh viên";
        }
        return role != null ? role : "Người dùng";
    }

    public String getRoleIcon() {
        if ("instructor".equalsIgnoreCase(role)) {
            return "fa-chalkboard-user";
        }
        return "fa-user-graduate";
    }

    public String getIssueTypeDisplay() {
        if (issueType == null) return "Khác";
        switch (issueType.toLowerCase()) {
            case "notification": return "Thông báo";
            case "quiz": return "Bài kiểm tra / Quiz";
            case "lesson": return "Bài học / Video";
            case "payment": return "Thanh toán / Ví";
            case "account": return "Tài khoản";
            case "course": return "Khóa học";
            case "ui": return "Giao diện / Hiển thị";
            default: return "Khác";
        }
    }

    public String getStatusDisplay() {
        if (status == null) return "Chờ xử lý";
        switch (status.toLowerCase()) {
            case "resolved": return "Đã xử lý";
            case "rejected": return "Từ chối";
            default: return "Chờ xử lý";
        }
    }

    public String getStatusBadgeClass() {
        if ("resolved".equalsIgnoreCase(status)) {
            return "badge-resolved";
        } else if ("rejected".equalsIgnoreCase(status)) {
            return "badge-rejected";
        }
        return "badge-pending";
    }
}
