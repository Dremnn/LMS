package com.lms.model;

import java.time.LocalDateTime;

public class Contact {
    private int userId;
    private int contactId;
    private String status; // e.g. "pending", "accepted"
    private LocalDateTime createdAt;

    public Contact() {}

    public Contact(int userId, int contactId, String status, LocalDateTime createdAt) {
        this.userId = userId;
        this.contactId = contactId;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getContactId() { return contactId; }
    public void setContactId(int contactId) { this.contactId = contactId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
