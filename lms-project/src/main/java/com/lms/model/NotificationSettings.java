package com.lms.model;

import java.io.Serializable;

public class NotificationSettings implements Serializable {
    private static final long serialVersionUID = 1L;

    private int userId;
    private boolean quizDeadlineEnabled = true;
    private boolean enrollmentEnabled = true;
    private boolean eventReminderEnabled = true;

    public NotificationSettings() {}

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public boolean isQuizDeadlineEnabled() { return quizDeadlineEnabled; }
    public void setQuizDeadlineEnabled(boolean v) { this.quizDeadlineEnabled = v; }

    public boolean isEnrollmentEnabled() { return enrollmentEnabled; }
    public void setEnrollmentEnabled(boolean v) { this.enrollmentEnabled = v; }

    public boolean isEventReminderEnabled() { return eventReminderEnabled; }
    public void setEventReminderEnabled(boolean v) { this.eventReminderEnabled = v; }
}
