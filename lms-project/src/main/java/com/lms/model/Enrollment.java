package com.lms.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Enrollment implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int studentId;
    private int courseId;
    private BigDecimal progressPercent;
    private String status;          // "in_progress", "completed"
    private LocalDateTime enrolledAt;
    private LocalDateTime completedAt;

    // Các trường bổ sung từ JOIN (không map trực tiếp với cột DB)
    private String courseTitle;
    private String courseThumbnailUrl;
    private int totalLessons;

    public Enrollment() {}

    public Enrollment(int studentId, int courseId) {
        this.studentId = studentId;
        this.courseId = courseId;
        this.progressPercent = BigDecimal.ZERO;
        this.status = "in_progress";
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public BigDecimal getProgressPercent() { return progressPercent; }
    public void setProgressPercent(BigDecimal progressPercent) { this.progressPercent = progressPercent; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getEnrolledAt() { return enrolledAt; }
    public void setEnrolledAt(LocalDateTime enrolledAt) { this.enrolledAt = enrolledAt; }

    public String getFormattedEnrolledAt() {
        if (enrolledAt == null) return "";
        return enrolledAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }

    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

    public String getCourseThumbnailUrl() { return courseThumbnailUrl; }
    public void setCourseThumbnailUrl(String courseThumbnailUrl) { this.courseThumbnailUrl = courseThumbnailUrl; }

    public int getTotalLessons() { return totalLessons; }
    public void setTotalLessons(int totalLessons) { this.totalLessons = totalLessons; }
}