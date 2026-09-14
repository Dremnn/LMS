package com.lms.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class QuizAttempt implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int studentId;
    private int quizId;
    private BigDecimal score;
    private Boolean passed;
    private LocalDateTime submittedAt;

    public QuizAttempt() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getQuizId() { return quizId; }
    public void setQuizId(int quizId) { this.quizId = quizId; }

    public BigDecimal getScore() { return score; }
    public void setScore(BigDecimal score) { this.score = score; }

    public Boolean getPassed() { return passed; }
    public void setPassed(Boolean passed) { this.passed = passed; }

    public LocalDateTime getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(LocalDateTime submittedAt) { this.submittedAt = submittedAt; }
    private static final java.time.format.DateTimeFormatter DISPLAY_FMT =
        java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");
    public String getSubmittedAtFormatted() {
        return submittedAt != null ? submittedAt.format(DISPLAY_FMT) : "";
    }

}