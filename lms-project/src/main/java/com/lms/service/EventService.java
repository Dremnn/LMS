package com.lms.service;

import com.lms.dao.EventDAO;
import com.lms.model.Event;

import java.time.LocalDateTime;
import java.util.List;

public class EventService {

    private final EventDAO eventDAO;

    public EventService() {
        this.eventDAO = new EventDAO();
    }

    public List<Event> getEventsByMonth(int userId, int year, int month) {
        if (month < 1 || month > 12) {
            throw new IllegalArgumentException("Tháng không hợp lệ!");
        }
        return eventDAO.findByUserAndMonth(userId, year, month);
    }

    public Event createEvent(int userId, Integer courseId, String title, LocalDateTime eventDate, String description) {
        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("Tiêu đề sự kiện không được để trống!");
        }
        if (eventDate == null) {
            throw new IllegalArgumentException("Vui lòng chọn ngày giờ cho sự kiện!");
        }

        Event event = new Event(userId, courseId, title.trim(), eventDate,
                description != null ? description.trim() : null);

        boolean saved = eventDAO.save(event);
        if (!saved) {
            throw new RuntimeException("Có lỗi xảy ra khi tạo sự kiện!");
        }
        return event;
    }

    public void deleteEvent(int eventId, int currentUserId) {
        Event event = eventDAO.findById(eventId);
        if (event == null) {
            throw new IllegalArgumentException("Sự kiện không tồn tại!");
        }
        if (event.getUserId() != currentUserId) {
            throw new SecurityException("Bạn không có quyền xóa sự kiện này!");
        }
        eventDAO.delete(eventId);
    }
}
