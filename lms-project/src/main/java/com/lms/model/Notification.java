package com.lms.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import jakarta.persistence.*;

@Entity
@Table(name = "notifications")
public class Notification implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "user_id", nullable = false)
    private int userId;

    @Column(name = "type", nullable = false)
    private String type;        // "quiz_deadline" | "enrollment" | "event_reminder"

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "message", columnDefinition = "TEXT")
    private String message;

    @Column(name = "related_url")
    private String relatedUrl;

    @Column(name = "is_read", nullable = false)
    private boolean read;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    // Quan hệ ORM
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;

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

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
}
