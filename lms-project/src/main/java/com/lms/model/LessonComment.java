package com.lms.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class LessonComment {
    private int id;
    private int lessonId;
    private int userId;
    private Integer parentId; // null nếu là bình luận gốc
    private String content;
    private LocalDateTime createdAt;

    // Các trường join từ User để hiển thị
    private String userName;
    private String userAvatar;
    private String userRole; // student / instructor / admin

    // Danh sách câu trả lời con (Replies)
    private List<LessonComment> replies = new ArrayList<>();

    public LessonComment() {
    }

    public LessonComment(int lessonId, int userId, Integer parentId, String content) {
        this.lessonId = lessonId;
        this.userId = userId;
        this.parentId = parentId;
        this.content = content;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getLessonId() {
        return lessonId;
    }

    public void setLessonId(int lessonId) {
        this.lessonId = lessonId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public Integer getParentId() {
        return parentId;
    }

    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserAvatar() {
        return userAvatar;
    }

    public void setUserAvatar(String userAvatar) {
        this.userAvatar = userAvatar;
    }

    public String getUserRole() {
        return userRole;
    }

    public void setUserRole(String userRole) {
        this.userRole = userRole;
    }

    public List<LessonComment> getReplies() {
        return replies;
    }

    public void setReplies(List<LessonComment> replies) {
        this.replies = replies;
    }

    public String getCreatedAtFormatted() {
        if (createdAt == null) return "";
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");
        return createdAt.format(formatter);
    }
}
