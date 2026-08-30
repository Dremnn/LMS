package com.lms.model;

import java.io.Serializable;
import java.math.BigDecimal;

public class Quiz implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private Integer sectionId;   // nullable - quiz gắn vào Section
    private Integer courseId;    // nullable - quiz gắn vào toàn bộ Course
    private String title;
    private BigDecimal passScore;
    private Integer maxAttempts; // null = không giới hạn số lần làm

    // Bổ sung từ JOIN - không map trực tiếp cột DB
    private String sectionTitle;
    private String courseTitle;
    private int totalQuestions;

    public Quiz() {}

    public Quiz(Integer sectionId, Integer courseId, String title,
                BigDecimal passScore, Integer maxAttempts) {
        this.sectionId = sectionId;
        this.courseId = courseId;
        this.title = title;
        this.passScore = passScore;
        this.maxAttempts = maxAttempts;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getSectionId() { return sectionId; }
    public void setSectionId(Integer sectionId) { this.sectionId = sectionId; }

    public Integer getCourseId() { return courseId; }
    public void setCourseId(Integer courseId) { this.courseId = courseId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public BigDecimal getPassScore() { return passScore; }
    public void setPassScore(BigDecimal passScore) { this.passScore = passScore; }

    public Integer getMaxAttempts() { return maxAttempts; }
    public void setMaxAttempts(Integer maxAttempts) { this.maxAttempts = maxAttempts; }

    public String getSectionTitle() { return sectionTitle; }
    public void setSectionTitle(String sectionTitle) { this.sectionTitle = sectionTitle; }

    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

    public int getTotalQuestions() { return totalQuestions; }
    public void setTotalQuestions(int totalQuestions) { this.totalQuestions = totalQuestions; }
}