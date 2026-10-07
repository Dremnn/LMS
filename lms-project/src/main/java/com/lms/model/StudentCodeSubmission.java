package com.lms.model;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "student_code_submissions")
public class StudentCodeSubmission {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private User student;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exercise_id", nullable = false)
    private CodingExercise exercise;

    @Column(name = "submitted_code", columnDefinition = "TEXT", nullable = false)
    private String submittedCode;

    @Column(nullable = false)
    private String status;

    @Column(name = "output_message", columnDefinition = "TEXT")
    private String outputMessage;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "submitted_at")
    private Date submittedAt = new Date();

    public StudentCodeSubmission() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public User getStudent() { return student; }
    public void setStudent(User student) { this.student = student; }
    public CodingExercise getExercise() { return exercise; }
    public void setExercise(CodingExercise exercise) { this.exercise = exercise; }
    public String getSubmittedCode() { return submittedCode; }
    public void setSubmittedCode(String submittedCode) { this.submittedCode = submittedCode; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getOutputMessage() { return outputMessage; }
    public void setOutputMessage(String outputMessage) { this.outputMessage = outputMessage; }
    public Date getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Date submittedAt) { this.submittedAt = submittedAt; }
}
