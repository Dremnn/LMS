package com.lms.service;

import com.lms.dao.IssueReportDAO;
import com.lms.dao.NotificationDAO;
import com.lms.dao.UserDAO;
import com.lms.model.IssueReport;
import com.lms.model.Notification;
import com.lms.model.User;

import java.security.SecureRandom;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class IssueReportService {

    private final IssueReportDAO issueReportDAO;
    private final UserDAO userDAO;
    private final NotificationDAO notificationDAO;
    private static final String CHARACTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final SecureRandom RANDOM = new SecureRandom();

    public IssueReportService() {
        this.issueReportDAO = new IssueReportDAO();
        this.userDAO = new UserDAO();
        this.notificationDAO = new NotificationDAO();
    }

    public IssueReport submitReport(String email, String role, String issueType,
                                    String description, String pageUrl, String screenshots) {
        if (email == null || !email.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
            throw new IllegalArgumentException("Địa chỉ email không hợp lệ!");
        }

        if (role == null || (!role.equalsIgnoreCase("student") && !role.equalsIgnoreCase("instructor"))) {
            throw new IllegalArgumentException("Vai trò phải là 'Sinh viên' hoặc 'Giảng viên'!");
        }

        if (issueType == null || issueType.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn loại sự cố!");
        }

        if (description == null || description.trim().length() < 10) {
            throw new IllegalArgumentException("Mô tả sự cố phải có ít nhất 10 ký tự!");
        }

        String refCode = generateReferenceCode();
        while (issueReportDAO.findByReferenceCode(refCode) != null) {
            refCode = generateReferenceCode();
        }

        IssueReport report = new IssueReport();
        report.setReferenceCode(refCode);
        report.setEmail(email.trim().toLowerCase());
        report.setRole(role.trim().toLowerCase());
        report.setIssueType(issueType.trim().toLowerCase());
        report.setDescription(description.trim());
        report.setPageUrl(pageUrl != null ? pageUrl.trim() : null);
        report.setScreenshots(screenshots);
        report.setStatus("pending");

        boolean inserted = issueReportDAO.insert(report);
        if (!inserted) {
            throw new IllegalStateException("Không thể lưu báo cáo sự cố vào hệ thống!");
        }

        return report;
    }

    public List<IssueReport> getReports(String status, String role, String keyword) {
        return issueReportDAO.findAll(status, role, keyword);
    }

    public IssueReport getReportById(int id) {
        return issueReportDAO.findById(id);
    }

    public IssueReport getReportByReferenceCode(String refCode) {
        return issueReportDAO.findByReferenceCode(refCode);
    }

    public boolean resolveIssue(int id, String adminNote, Integer adminUserId) {
        IssueReport report = issueReportDAO.findById(id);
        if (report == null) {
            throw new IllegalArgumentException("Không tìm thấy sự cố!");
        }

        boolean updated = issueReportDAO.updateStatus(id, "resolved", adminNote, adminUserId);
        if (updated) {
            sendNotificationToReporterIfUserExists(report, "resolved", adminNote);
        }
        return updated;
    }

    public boolean rejectIssue(int id, String adminNote, Integer adminUserId) {
        IssueReport report = issueReportDAO.findById(id);
        if (report == null) {
            throw new IllegalArgumentException("Không tìm thấy sự cố!");
        }

        boolean updated = issueReportDAO.updateStatus(id, "rejected", adminNote, adminUserId);
        if (updated) {
            sendNotificationToReporterIfUserExists(report, "rejected", adminNote);
        }
        return updated;
    }

    public boolean setPendingIssue(int id, String adminNote, Integer adminUserId) {
        IssueReport report = issueReportDAO.findById(id);
        if (report == null) {
            throw new IllegalArgumentException("Không tìm thấy sự cố!");
        }

        return issueReportDAO.updateStatus(id, "pending", adminNote, adminUserId);
    }

    public Map<String, Integer> getStats() {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("total", issueReportDAO.countAll());
        stats.put("pending", issueReportDAO.countByStatus("pending"));
        stats.put("resolved", issueReportDAO.countByStatus("resolved"));
        stats.put("rejected", issueReportDAO.countByStatus("rejected"));
        return stats;
    }

    private void sendNotificationToReporterIfUserExists(IssueReport report, String status, String note) {
        try {
            User user = userDAO.findByEmail(report.getEmail());
            if (user != null) {
                Notification notification = new Notification();
                notification.setUserId(user.getId());
                notification.setType("issue_report_update");
                if ("resolved".equalsIgnoreCase(status)) {
                    notification.setTitle("Sự cố #" + report.getReferenceCode() + " đã được xử lý");
                    String msg = "Báo cáo sự cố của bạn đã được Admin xử lý thành công.";
                    if (note != null && !note.trim().isEmpty()) {
                        msg += " Ghi chú từ Admin: " + note.trim();
                    }
                    notification.setMessage(msg);
                } else if ("rejected".equalsIgnoreCase(status)) {
                    notification.setTitle("Sự cố #" + report.getReferenceCode() + " đã bị từ chối");
                    String msg = "Báo cáo sự cố của bạn đã bị từ chối.";
                    if (note != null && !note.trim().isEmpty()) {
                        msg += " Lý do: " + note.trim();
                    }
                    notification.setMessage(msg);
                }
                notification.setRelatedUrl("/notifications");
                notificationDAO.save(notification);
            }
        } catch (Exception e) {
            // Notification is best-effort, does not block issue status update
            e.printStackTrace();
        }
    }

    private String generateReferenceCode() {
        StringBuilder sb = new StringBuilder("RPT-");
        for (int i = 0; i < 6; i++) {
            sb.append(CHARACTERS.charAt(RANDOM.nextInt(CHARACTERS.length())));
        }
        return sb.toString();
    }
}
