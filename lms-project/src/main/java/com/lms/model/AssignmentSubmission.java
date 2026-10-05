package com.lms.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/** Bài nộp của 1 học viên cho 1 bài tập (mỗi học viên 1 bài - nộp lại sẽ ghi đè). */
public class AssignmentSubmission implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int assignmentId;
    private int studentId;
    private String fileName;
    private String fileType;
    private int fileSize;
    private String note;
    private LocalDateTime submittedAt;

    // Từ JOIN
    private String studentName;
    private String studentEmail;
    private LocalDateTime assignmentDueAt;

    public AssignmentSubmission() {}

    /** Nộp trễ so với hạn (chỉ có ý nghĩa nếu giảng viên đổi hạn sau khi học viên đã nộp). */
    public boolean isLate() {
        return assignmentDueAt != null && submittedAt != null && submittedAt.isAfter(assignmentDueAt);
    }

    private static final java.time.format.DateTimeFormatter DISPLAY_FMT =
            java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");

    public String getSubmittedAtDisplay() { return submittedAt != null ? submittedAt.format(DISPLAY_FMT) : ""; }
    public String getFileSizeDisplay() { return FileSizeUtil.format(fileSize); }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getAssignmentId() { return assignmentId; }
    public void setAssignmentId(int assignmentId) { this.assignmentId = assignmentId; }
    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }
    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }
    public String getFileType() { return fileType; }
    public void setFileType(String fileType) { this.fileType = fileType; }
    public int getFileSize() { return fileSize; }
    public void setFileSize(int fileSize) { this.fileSize = fileSize; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public LocalDateTime getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(LocalDateTime submittedAt) { this.submittedAt = submittedAt; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }
    public LocalDateTime getAssignmentDueAt() { return assignmentDueAt; }
    public void setAssignmentDueAt(LocalDateTime assignmentDueAt) { this.assignmentDueAt = assignmentDueAt; }
}
