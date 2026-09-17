package com.lms.controller;

import com.lms.model.*;
import com.lms.service.EventService;
import com.lms.service.QuizService;
import com.lms.dao.CourseDAO;
import com.lms.dao.EnrollmentDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@WebServlet(urlPatterns = {
    "/dashboard",
    "/dashboard/events/new",
    "/dashboard/events/edit",
    "/dashboard/events/delete"
})
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private QuizService quizService;
    private EventService eventService;
    private CourseDAO courseDAO;
    private EnrollmentDAO enrollmentDAO;

    @Override
    public void init() throws ServletException {
        this.quizService = new QuizService();
        this.eventService = new EventService();
        this.courseDAO = new CourseDAO();
        this.enrollmentDAO = new EnrollmentDAO();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("flashError") != null) {
            request.setAttribute("error", session.getAttribute("flashError"));
            session.removeAttribute("flashError");
        }

        LocalDate now = LocalDate.now();
        int year = parseOrDefault(request.getParameter("year"), now.getYear());
        int month = parseOrDefault(request.getParameter("month"), now.getMonthValue());
        if (month < 1) { month = 12; year--; }
        else if (month > 12) { month = 1; year++; }

        String dueFilter = request.getParameter("dueFilter");
        if (dueFilter == null || dueFilter.isEmpty()) dueFilter = "7";
        String sortBy = request.getParameter("sortBy");
        if (sortBy == null || sortBy.isEmpty()) sortBy = "dates";
        String courseIdStr = request.getParameter("courseId");
        Integer courseIdFilter = (courseIdStr != null && !courseIdStr.isEmpty())
                ? Integer.parseInt(courseIdStr) : null;

        try {
            List<Quiz> upcomingQuizzes = quizService.getUpcomingQuizzesForStudent(
                    currentUser.getId(), dueFilter, sortBy, courseIdFilter);

            List<Quiz> monthQuizzes = quizService.getQuizzesByCloseAtMonth(year, month);
            List<Event> monthEvents = eventService.getEventsByMonth(currentUser.getId(), year, month);

            Map<Integer, List<Quiz>> quizzesByDay = new HashMap<>();
            Map<Integer, String> urgencyByQuizId = new HashMap<>();
            for (Quiz q : monthQuizzes) {
                int day = q.getCloseAt().getDayOfMonth();
                quizzesByDay.computeIfAbsent(day, k -> new ArrayList<>()).add(q);
                urgencyByQuizId.put(q.getId(), quizService.getDeadlineUrgency(q));
            }

            Map<Integer, List<Event>> eventsByDay = new HashMap<>();
            for (Event e : monthEvents) {
                int day = e.getEventDate().getDayOfMonth();
                eventsByDay.computeIfAbsent(day, k -> new ArrayList<>()).add(e);
            }

            // Danh sách khóa học Student đã enroll - dùng cho listbox lọc + dropdown gắn sự kiện
            List<Course> myCourses = new ArrayList<>();
            List<Enrollment> myEnrollments = enrollmentDAO.findByStudent(currentUser.getId());
            for (Enrollment en : myEnrollments) {
                Course c = courseDAO.findById(en.getCourseId());
                if (c != null) myCourses.add(c);
            }

            request.setAttribute("year", year);
            request.setAttribute("month", month);
            request.setAttribute("quizzesByDay", quizzesByDay);
            request.setAttribute("urgencyByQuizId", urgencyByQuizId);
            request.setAttribute("eventsByDay", eventsByDay);
            request.setAttribute("today", LocalDate.now());
            request.setAttribute("upcomingQuizzes", upcomingQuizzes);
            request.setAttribute("dueFilter", dueFilter);
            request.setAttribute("sortBy", sortBy);
            request.setAttribute("courseIdFilter", courseIdFilter);
            request.setAttribute("myCourses", myCourses);

            request.getRequestDispatcher("/WEB-INF/views/student/dashboard.jsp")
                    .forward(request, response);

        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        try {
            if ("/dashboard/events/new".equals(path)) {
                handleCreateEvent(request, response, currentUser);

            } else if ("/dashboard/events/edit".equals(path)) {
                handleEditEvent(request, response, currentUser);

            } else if ("/dashboard/events/delete".equals(path)) {
                handleDeleteEvent(request, response, currentUser);

            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }

        } catch (IllegalArgumentException e) {
            HttpSession session = request.getSession();
            session.setAttribute("flashError", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/dashboard");

        } catch (SecurityException e) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());

        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("flashError", "Đã xảy ra lỗi hệ thống!");
            response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }

    private void handleCreateEvent(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        EventFormData data = readEventForm(request);
        eventService.createEvent(currentUser.getId(), data.courseId, data.title, data.eventDate,
                data.description, data.address, data.durationType, data.durationEnd, data.durationMinutes);

        response.sendRedirect(request.getContextPath() + "/dashboard?year="
                + data.eventDate.getYear() + "&month=" + data.eventDate.getMonthValue());
    }

    private void handleEditEvent(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        int eventId = Integer.parseInt(request.getParameter("eventId"));
        EventFormData data = readEventForm(request);

        eventService.updateEvent(eventId, currentUser.getId(), data.courseId, data.title, data.eventDate,
                data.description, data.address, data.durationType, data.durationEnd, data.durationMinutes);

        response.sendRedirect(request.getContextPath() + "/dashboard?year="
                + data.eventDate.getYear() + "&month=" + data.eventDate.getMonthValue());
    }

    private void handleDeleteEvent(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        int eventId = Integer.parseInt(request.getParameter("eventId"));
        String year = request.getParameter("year");
        String month = request.getParameter("month");

        eventService.deleteEvent(eventId, currentUser.getId());

        response.sendRedirect(request.getContextPath() + "/dashboard?year=" + year + "&month=" + month);
    }

    // Gom việc đọc form vào 1 chỗ, dùng chung cho create/edit
    private EventFormData readEventForm(HttpServletRequest request) {
        EventFormData data = new EventFormData();
        data.title = request.getParameter("title");
        data.eventDate = LocalDateTime.parse(request.getParameter("eventDate"));
        data.description = request.getParameter("description");
        data.address = request.getParameter("address");

        String courseIdStr = request.getParameter("courseId");
        data.courseId = (courseIdStr != null && !courseIdStr.isEmpty()) ? Integer.parseInt(courseIdStr) : null;

        data.durationType = request.getParameter("durationType");
        if (data.durationType == null) data.durationType = "none";

        String durationEndStr = request.getParameter("durationEnd");
        data.durationEnd = (durationEndStr != null && !durationEndStr.isEmpty())
                ? LocalDateTime.parse(durationEndStr) : null;

        String durationMinutesStr = request.getParameter("durationMinutes");
        data.durationMinutes = (durationMinutesStr != null && !durationMinutesStr.isEmpty())
                ? Integer.parseInt(durationMinutesStr) : null;

        return data;
    }

    private static class EventFormData {
        String title;
        LocalDateTime eventDate;
        String description;
        String address;
        Integer courseId;
        String durationType;
        LocalDateTime durationEnd;
        Integer durationMinutes;
    }

    private int parseOrDefault(String value, int defaultValue) {
        try { return Integer.parseInt(value); } catch (Exception e) { return defaultValue; }
    }
}
