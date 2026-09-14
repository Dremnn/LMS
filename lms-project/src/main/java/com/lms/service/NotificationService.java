package com.lms.service;

import com.lms.dao.*;
import com.lms.model.*;
import com.lms.model.Section;

import java.time.LocalDateTime;
import java.util.List;

public class NotificationService {

    private final NotificationDAO notificationDAO;
    private final NotificationSettingsDAO settingsDAO;

    public NotificationService() {
        this.notificationDAO = new NotificationDAO();
        this.settingsDAO = new NotificationSettingsDAO();
    }

    public List<Notification> getRecentNotifications(int userId, int limit) {
        return notificationDAO.findByUser(userId, limit);
    }

    public int countUnread(int userId) {
        return notificationDAO.countUnread(userId);
    }

    public Notification getNotificationAndVerifyOwnership(int notificationId, int currentUserId) {
        Notification n = notificationDAO.findById(notificationId);
        if (n == null) {
            throw new IllegalArgumentException("Thông báo không tồn tại!");
        }
        if (n.getUserId() != currentUserId) {
            throw new SecurityException("Bạn không có quyền xem thông báo này!");
        }
        return n;
    }

    public void markAllRead(int userId) {
        notificationDAO.markAllRead(userId);
    }

    public void markRead(int notificationId, int userId) {
        notificationDAO.markRead(notificationId, userId);
    }

    public NotificationSettings getSettings(int userId) {
        NotificationSettings s = settingsDAO.findByUserId(userId);
        if (s == null) {
            // Chưa có bản ghi -> trả về mặc định tất cả đang bật (chưa lưu xuống DB)
            s = new NotificationSettings();
            s.setUserId(userId);
        }
        return s;
    }

    public void saveSettings(int userId, boolean quizDeadline, boolean enrollment, boolean eventReminder) {
        NotificationSettings s = new NotificationSettings();
        s.setUserId(userId);
        s.setQuizDeadlineEnabled(quizDeadline);
        s.setEnrollmentEnabled(enrollment);
        s.setEventReminderEnabled(eventReminder);
        settingsDAO.save(s);
    }

    // =========================================================================
    // Tạo thông báo khi Student ghi danh khóa học thành công
    // Gọi hàm này tại nơi xử lý enroll thành công (EnrollmentService của bạn)
    // =========================================================================
    public void notifyEnrollment(int studentId, String courseTitle, String courseUrl) {
        if (!getSettings(studentId).isEnrollmentEnabled()) return;

        Notification n = new Notification(studentId, "enrollment",
                "Đăng ký khóa học thành công",
                "Bạn đã ghi danh thành công vào khóa học '" + courseTitle + "'.",
                courseUrl);
        notificationDAO.save(n);
    }

    // =========================================================================
    // Tạo thông báo nhắc quiz sắp hết hạn - dùng cho Scheduler chạy định kỳ
    // Chỉ tạo 1 lần cho mỗi quiz (đánh dấu quizzes.notified_deadline = true sau khi tạo)
    // =========================================================================
    public void checkAndNotifyQuizDeadlines() {
        QuizDAO quizDAO = new QuizDAO();
        EnrollmentDAO enrollmentDAO = new EnrollmentDAO();

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime threshold = now.plusHours(24);

        List<Quiz> upcomingQuizzes = quizDAO.findQuizzesClosingSoonNotNotified(now, threshold);

        for (Quiz quiz : upcomingQuizzes) {

            SectionDAO sectionDao = new SectionDAO();

            int courseId = quiz.getCourseId() != null ? quiz.getCourseId() : sectionDao.findById(quiz.getSectionId()).getCourseId();

            List<Integer> enrolledStudentIds = enrollmentDAO.findStudentIdsByCourseOrSection(courseId);

            for (Integer studentId : enrolledStudentIds) {
                if (!getSettings(studentId).isQuizDeadlineEnabled()) continue;

                Notification n = new Notification(studentId, "quiz_deadline",
                        "Quiz sắp hết hạn: " + quiz.getTitle(),
                        "Quiz '" + quiz.getTitle() + "' sẽ đóng lúc " + quiz.getCloseAt() + ". Hãy hoàn thành sớm!",
                        "/student/quizzes/intro?id=" + quiz.getId());
                notificationDAO.save(n);
            }

            quizDAO.markDeadlineNotified(quiz.getId());
        }
    }

    // =========================================================================
    // Tạo thông báo nhắc sự kiện tự tạo (gọi khi tạo Event nếu muốn nhắc ngay)
    // =========================================================================
    public void notifyEventReminder(int userId, String eventTitle, String eventUrl) {
        if (!getSettings(userId).isEventReminderEnabled()) return;

        Notification n = new Notification(userId, "event_reminder",
                "Sự kiện sắp diễn ra: " + eventTitle,
                "Bạn có sự kiện '" + eventTitle + "' sắp diễn ra.",
                eventUrl);
        notificationDAO.save(n);
    }
}
