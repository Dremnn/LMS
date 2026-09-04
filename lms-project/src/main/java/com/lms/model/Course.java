package com.lms.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class Course implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int instructorId;
    private Integer categoryId;   // nullable
    private String title;
    private String description;
    private String thumbnailUrl;
    private BigDecimal price;
    private BigDecimal passScore;
    private String status;        // draft, published, warning, appealed
    private String rejectReason;  // Lý do cảnh cáo của Admin
    private String appealMessage; // Nội dung kháng cáo của Instructor
    private BigDecimal avgRating;
    private int totalStudents;
    private int totalLessons;
    private LocalDateTime createdAt;

    // Các trường bổ sung từ JOIN (không map trực tiếp với cột DB)
    private String instructorName;
    private String categoryName;
    private List<Section> sectionsCache; // Không map với DB - chỉ dùng tạm khi hiển thị chi tiết

    public Course() {}

    // Constructor dùng khi Instructor tạo khóa học mới
    public Course(int instructorId, Integer categoryId, String title, String description, BigDecimal price) {
        this.instructorId = instructorId;
        this.categoryId = categoryId;
        this.title = title;
        this.description = description;
        this.price = price;
        this.status = "draft";
    }

    // ==================== GETTER & SETTER ====================

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getInstructorId() { return instructorId; }
    public void setInstructorId(int instructorId) { this.instructorId = instructorId; }

    public Integer getCategoryId() { return categoryId; }
    public void setCategoryId(Integer categoryId) { this.categoryId = categoryId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public BigDecimal getPassScore() { return passScore; }
    public void setPassScore(BigDecimal passScore) { this.passScore = passScore; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getRejectReason() { return rejectReason; }
    public void setRejectReason(String rejectReason) { this.rejectReason = rejectReason; }

    public String getAppealMessage() { return appealMessage; }
    public void setAppealMessage(String appealMessage) { this.appealMessage = appealMessage; }

    public BigDecimal getAvgRating() { return avgRating; }
    public void setAvgRating(BigDecimal avgRating) { this.avgRating = avgRating; }

    public int getTotalStudents() { return totalStudents; }
    public void setTotalStudents(int totalStudents) { this.totalStudents = totalStudents; }

    public int getTotalLessons() { return totalLessons; }
    public void setTotalLessons(int totalLessons) { this.totalLessons = totalLessons; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getInstructorName() { return instructorName; }
    public void setInstructorName(String instructorName) { this.instructorName = instructorName; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public List<Section> getSectionsCache() { return sectionsCache; }
    public void setSectionsCache(List<Section> sectionsCache) { this.sectionsCache = sectionsCache; }
}