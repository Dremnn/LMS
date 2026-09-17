package com.lms.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import jakarta.persistence.*;

@Entity
@Table(name = "courses")
public class Course implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "instructor_id", nullable = false)
    private int instructorId;

    @Column(name = "category_id")
    private Integer categoryId;   // nullable

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "thumbnail_url")
    private String thumbnailUrl;

    @Column(name = "price", nullable = false)
    private BigDecimal price;

    @Column(name = "pass_score")
    private BigDecimal passScore;

    @Column(name = "status", nullable = false)
    private String status;        // draft, published, warning, appealed

    @Column(name = "reject_reason")
    private String rejectReason;  // Lý do cảnh cáo của Admin

    @Column(name = "appeal_message")
    private String appealMessage; // Nội dung kháng cáo của Instructor

    @Column(name = "avg_rating", nullable = false)
    private BigDecimal avgRating;

    @Column(name = "total_students", nullable = false)
    private int totalStudents;

    @Column(name = "total_lessons", nullable = false)
    private int totalLessons;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    // Quan hệ ORM
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "instructor_id", insertable = false, updatable = false)
    private User instructor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", insertable = false, updatable = false)
    private Category category;

    @OneToMany(mappedBy = "course")
    private List<Section> sections;

    // Các trường bổ sung từ JOIN (không map trực tiếp với cột DB)
    @Transient
    private String instructorName;

    @Transient
    private String categoryName;

    @Transient
    private List<Section> sectionsCache; // Không map với DB - chỉ dùng tạm khi hiển thị chi tiết

    public Course() {}

    // Constructor dùng khi Instructor tạo khóa học mới
    public Course(int instructorId, Integer categoryId, String title, String description, BigDecimal price) {
        this(instructorId, categoryId, title, description, price, null);
    }

    public Course(int instructorId, Integer categoryId, String title, String description, BigDecimal price, String thumbnailUrl) {
        this.instructorId = instructorId;
        this.categoryId = categoryId;
        this.title = title;
        this.description = description;
        this.price = price;
        this.thumbnailUrl = thumbnailUrl;
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

    private static final java.time.format.DateTimeFormatter DISPLAY_FMT =
        java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");

    public String getCreatedAtFormatted() {
        return createdAt != null ? createdAt.format(DISPLAY_FMT) : "";
    }

    public String getInstructorName() { return instructorName; }
    public void setInstructorName(String instructorName) { this.instructorName = instructorName; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public List<Section> getSectionsCache() { return sectionsCache; }
    public void setSectionsCache(List<Section> sectionsCache) { this.sectionsCache = sectionsCache; }

    public User getInstructor() { return instructor; }
    public void setInstructor(User instructor) { this.instructor = instructor; }

    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }

    public List<Section> getSections() { return sections; }
    public void setSections(List<Section> sections) { this.sections = sections; }
}