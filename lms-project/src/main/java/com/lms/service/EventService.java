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

    public Event getEventAndVerifyOwnership(int eventId, int currentUserId) {
        Event event = eventDAO.findById(eventId);
        if (event == null) {
            throw new IllegalArgumentException("Sự kiện không tồn tại!");
        }
        if (event.getUserId() != currentUserId) {
            throw new SecurityException("Bạn không có quyền thao tác trên sự kiện này!");
        }
        return event;
    }

    private void validateEventFields(String title, LocalDateTime eventDate, String durationType,
                                      LocalDateTime durationEnd, Integer durationMinutes) {
        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("Tiêu đề sự kiện không được để trống!");
        }
        if (eventDate == null) {
            throw new IllegalArgumentException("Vui lòng chọn ngày giờ cho sự kiện!");
        }
        if ("until".equals(durationType)) {
            if (durationEnd == null) {
                throw new IllegalArgumentException("Vui lòng chọn thời điểm kết thúc!");
            }
            if (!durationEnd.isAfter(eventDate)) {
                throw new IllegalArgumentException("Thời điểm kết thúc phải sau thời điểm bắt đầu!");
            }
        } else if ("minutes".equals(durationType)) {
            if (durationMinutes == null || durationMinutes <= 0) {
                throw new IllegalArgumentException("Thời lượng phải lớn hơn 0 phút!");
            }
        }
    }

    public Event createEvent(int userId, Integer courseId, String title, LocalDateTime eventDate,
                              String description, String address, String durationType,
                              LocalDateTime durationEnd, Integer durationMinutes) {

        validateEventFields(title, eventDate, durationType, durationEnd, durationMinutes);

        Event event = new Event(userId, courseId, title.trim(), eventDate,
                description != null ? description.trim() : null,
                address != null ? address.trim() : null,
                durationType != null ? durationType : "none",
                durationEnd, durationMinutes);

        boolean saved = eventDAO.save(event);
        if (!saved) {
            throw new RuntimeException("Có lỗi xảy ra khi tạo sự kiện!");
        }
        return event;
    }

    public void updateEvent(int eventId, int currentUserId, Integer courseId, String title,
                             LocalDateTime eventDate, String description, String address,
                             String durationType, LocalDateTime durationEnd, Integer durationMinutes) {

        Event event = getEventAndVerifyOwnership(eventId, currentUserId);
        validateEventFields(title, eventDate, durationType, durationEnd, durationMinutes);

        event.setCourseId(courseId);
        event.setTitle(title.trim());
        event.setEventDate(eventDate);
        event.setDescription(description != null ? description.trim() : null);
        event.setAddress(address != null ? address.trim() : null);
        event.setDurationType(durationType != null ? durationType : "none");
        event.setDurationEnd(durationEnd);
        event.setDurationMinutes(durationMinutes);

        boolean updated = eventDAO.update(event);
        if (!updated) {
            throw new RuntimeException("Có lỗi xảy ra khi cập nhật sự kiện!");
        }
    }

    public void deleteEvent(int eventId, int currentUserId) {
        getEventAndVerifyOwnership(eventId, currentUserId); // ném lỗi nếu không có quyền
        eventDAO.delete(eventId);
    }
}
