package com.lms.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Event implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private Integer courseId;      // nullable - sự kiện có thể không gắn với khóa học nào
    private String title;
    private LocalDateTime eventDate;
    private String description;
    private LocalDateTime createdAt;

    // Trường bổ sung từ JOIN - không map trực tiếp cột DB
    private String courseTitle;

    public Event() {}

    public Event(int userId, Integer courseId, String title, LocalDateTime eventDate, String description) {
        this.userId = userId;
        this.courseId = courseId;
        this.title = title;
        this.eventDate = eventDate;
        this.description = description;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Integer getCourseId() { return courseId; }
    public void setCourseId(Integer courseId) { this.courseId = courseId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public LocalDateTime getEventDate() { return eventDate; }
    public void setEventDate(LocalDateTime eventDate) { this.eventDate = eventDate; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }
}
