package com.lms.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class LessonProgress implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int enrollmentId;
    private int lessonId;
    private boolean completed;
    private LocalDateTime completedAt;

    public LessonProgress() {}

    public LessonProgress(int enrollmentId, int lessonId, boolean completed) {
        this.enrollmentId = enrollmentId;
        this.lessonId = lessonId;
        this.completed = completed;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getEnrollmentId() { return enrollmentId; }
    public void setEnrollmentId(int enrollmentId) { this.enrollmentId = enrollmentId; }

    public int getLessonId() { return lessonId; }
    public void setLessonId(int lessonId) { this.lessonId = lessonId; }

    public boolean isCompleted() { return completed; }
    public void setCompleted(boolean completed) { this.completed = completed; }

    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }
}