package com.lms.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import jakarta.persistence.*;

@Entity
@Table(name = "group_submissions")
public class GroupSubmission implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    // Tạm giả định bạn đã có hoặc sẽ có class Assignment (Bài tập)
    // Nếu chưa có, bạn có thể thay bằng int assignmentId tạm thời, 
    // hoặc tạo Entity Assignment sau.
    @Column(name = "assignment_id", nullable = false)
    private int assignmentId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "group_id", nullable = false)
    private StudyGroup studyGroup;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "submitter_id", nullable = false)
    private User submitter;

    @Column(name = "file_url", nullable = false)
    private String fileUrl;

    @Column(name = "score")
    private Double score;

    @Column(name = "feedback")
    private String feedback;

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt;

    @PrePersist
    protected void onCreate() {
        submittedAt = LocalDateTime.now();
    }

    public GroupSubmission() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getAssignmentId() { return assignmentId; }
    public void setAssignmentId(int assignmentId) { this.assignmentId = assignmentId; }

    public StudyGroup getStudyGroup() { return studyGroup; }
    public void setStudyGroup(StudyGroup studyGroup) { this.studyGroup = studyGroup; }

    public User getSubmitter() { return submitter; }
    public void setSubmitter(User submitter) { this.submitter = submitter; }

    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }

    public Double getScore() { return score; }
    public void setScore(Double score) { this.score = score; }

    public String getFeedback() { return feedback; }
    public void setFeedback(String feedback) { this.feedback = feedback; }

    public LocalDateTime getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(LocalDateTime submittedAt) { this.submittedAt = submittedAt; }
}
