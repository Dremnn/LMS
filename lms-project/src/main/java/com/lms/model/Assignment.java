package com.lms.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Bài tập do giảng viên tạo trong 1 khóa học.
 * Mô tả và file đính kèm đều tùy chọn (có thể để trống).
 * Nội dung file (attach_data) KHÔNG được nạp vào object này khi liệt kê - chỉ tải khi download.
 */
public class Assignment implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int courseId;
    private String title;
    private String description;
    private LocalDateTime dueAt;          // null = không có hạn nộp
    private String attachName;
    private String attachType;
    private Integer attachSize;
    private boolean notifiedDeadline;
    private LocalDateTime createdAt;

    // Trường bổ sung từ JOIN (không map trực tiếp 1-1 với cột)
    private String courseTitle;
    private int submissionCount;          // dành cho giảng viên: số bài đã nộp
    private int enrolledCount;            // dành cho giảng viên: tổng số học viên trong khóa
    private Integer mySubmissionId;       // dành cho học viên: id bài nộp của mình (null = chưa nộp)
    private LocalDateTime mySubmittedAt;

    public Assignment() {}

    public boolean isOverdue() {
        return dueAt != null && LocalDateTime.now().isAfter(dueAt);
    }

    public boolean isHasAttachment() {
        return attachName != null && !attachName.isEmpty();
    }

    public boolean isSubmittedByMe() {
        return mySubmissionId != null;
    }

    /** Còn trong vòng 24h tới hạn (và chưa quá hạn) - dùng để tô nhãn "Sắp đến hạn". */
    public boolean isDueSoon() {
        return dueAt != null && !isOverdue() && LocalDateTime.now().plusHours(24).isAfter(dueAt);
    }

    private static final java.time.format.DateTimeFormatter DISPLAY_FMT =
            java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");

    // Các getter định dạng sẵn cho JSP (JSTL fmt:formatDate không hỗ trợ java.time)
    public String getDueAtDisplay() { return dueAt != null ? dueAt.format(DISPLAY_FMT) : ""; }
    public String getCreatedAtDisplay() { return createdAt != null ? createdAt.format(DISPLAY_FMT) : ""; }
    public String getMySubmittedAtDisplay() { return mySubmittedAt != null ? mySubmittedAt.format(DISPLAY_FMT) : ""; }
    public String getAttachSizeDisplay() { return attachSize != null ? FileSizeUtil.format(attachSize) : ""; }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public LocalDateTime getDueAt() { return dueAt; }
    public void setDueAt(LocalDateTime dueAt) { this.dueAt = dueAt; }
    public String getAttachName() { return attachName; }
    public void setAttachName(String attachName) { this.attachName = attachName; }
    public String getAttachType() { return attachType; }
    public void setAttachType(String attachType) { this.attachType = attachType; }
    public Integer getAttachSize() { return attachSize; }
    public void setAttachSize(Integer attachSize) { this.attachSize = attachSize; }
    public boolean isNotifiedDeadline() { return notifiedDeadline; }
    public void setNotifiedDeadline(boolean notifiedDeadline) { this.notifiedDeadline = notifiedDeadline; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }
    public int getSubmissionCount() { return submissionCount; }
    public void setSubmissionCount(int submissionCount) { this.submissionCount = submissionCount; }
    public int getEnrolledCount() { return enrolledCount; }
    public void setEnrolledCount(int enrolledCount) { this.enrolledCount = enrolledCount; }
    public Integer getMySubmissionId() { return mySubmissionId; }
    public void setMySubmissionId(Integer mySubmissionId) { this.mySubmissionId = mySubmissionId; }
    public LocalDateTime getMySubmittedAt() { return mySubmittedAt; }
    public void setMySubmittedAt(LocalDateTime mySubmittedAt) { this.mySubmittedAt = mySubmittedAt; }
}
