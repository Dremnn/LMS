package com.lms.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Event implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private Integer courseId;
    private String title;
    private LocalDateTime eventDate;
    private String description;
    private String address;
    private String durationType;       // "none" | "until" | "minutes"
    private LocalDateTime durationEnd;  // dùng khi durationType = "until"
    private Integer durationMinutes;    // dùng khi durationType = "minutes"
    private LocalDateTime createdAt;

    private String courseTitle; // từ JOIN, không map cột DB

    public Event() {}

    public Event(int userId, Integer courseId, String title, LocalDateTime eventDate,
                 String description, String address, String durationType,
                 LocalDateTime durationEnd, Integer durationMinutes) {
        this.userId = userId;
        this.courseId = courseId;
        this.title = title;
        this.eventDate = eventDate;
        this.description = description;
        this.address = address;
        this.durationType = durationType;
        this.durationEnd = durationEnd;
        this.durationMinutes = durationMinutes;
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

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getDurationType() { return durationType; }
    public void setDurationType(String durationType) { this.durationType = durationType; }

    public LocalDateTime getDurationEnd() { return durationEnd; }
    public void setDurationEnd(LocalDateTime durationEnd) { this.durationEnd = durationEnd; }

    public Integer getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(Integer durationMinutes) { this.durationMinutes = durationMinutes; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }
}
