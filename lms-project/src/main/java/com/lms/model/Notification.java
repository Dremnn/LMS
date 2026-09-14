package com.lms.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Notification implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private String type;        // "quiz_deadline" | "enrollment" | "event_reminder"
    private String title;
    private String message;
    private String relatedUrl;
    private boolean read;
    private LocalDateTime createdAt;

    public Notification() {}

    public Notification(int userId, String type, String title, String message, String relatedUrl) {
        this.userId = userId;
        this.type = type;
        this.title = title;
        this.message = message;
        this.relatedUrl = relatedUrl;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getRelatedUrl() { return relatedUrl; }
    public void setRelatedUrl(String relatedUrl) { this.relatedUrl = relatedUrl; }

    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
