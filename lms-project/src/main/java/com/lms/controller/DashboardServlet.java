package com.lms.controller;

import com.lms.model.*;
import com.lms.service.EventService;
import com.lms.service.QuizService;
import com.lms.service.CourseService;

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

@WebServlet(urlPatterns = {"/student/dashboard", "/student/dashboard/events/new"})
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private QuizService quizService;
    private EventService eventService;
    private CourseService courseService;

    @Override
    public void init() throws ServletException {
        this.quizService = new QuizService();
        this.eventService = new EventService();
        this.courseService = new CourseService();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        // Đọc flash message nếu có (sau khi tạo sự kiện xong redirect về đây)
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

        // Tham số cho bảng "Mốc thời gian"
        String dueFilter = request.getParameter("dueFilter");
        if (dueFilter == null || dueFilter.isEmpty()) dueFilter = "7";
        String sortBy = request.getParameter("sortBy");
        if (sortBy == null || sortBy.isEmpty()) sortBy = "dates";
        String courseIdStr = request.getParameter("courseId");
        Integer courseIdFilter = (courseIdStr != null && !courseIdStr.isEmpty())
                ? Integer.parseInt(courseIdStr) : null;

        try {
            // 1. Danh sách "Mốc thời gian" (upcoming panel)
            List<Quiz> upcomingQuizzes = quizService.getUpcomingQuizzesForStudent(
                    currentUser.getId(), dueFilter, sortBy, courseIdFilter);

            // 2. Dữ liệu Timetable tháng hiện tại - gộp cả Quiz deadline + Event tự tạo
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

            List<Course> myCourses = new ArrayList<>();
            List<Enrollment> myEnrollments = new com.lms.dao.EnrollmentDAO().findByStudent(currentUser.getId());
            com.lms.dao.CourseDAO courseDAOTemp = new com.lms.dao.CourseDAO();
            for (Enrollment e : myEnrollments) {
                Course c = courseDAOTemp.findById(e.getCourseId());
                if (c != null) {
                    myCourses.add(c);
                }
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
        User currentUser = getCurrentUser(request);

        try {
            String title = request.getParameter("title");
            String dateStr = request.getParameter("eventDate"); // format "yyyy-MM-ddTHH:mm"
            String description = request.getParameter("description");
            String courseIdStr = request.getParameter("courseId");

            LocalDateTime eventDate = LocalDateTime.parse(dateStr);
            Integer courseId = (courseIdStr != null && !courseIdStr.isEmpty())
                    ? Integer.parseInt(courseIdStr) : null;

            eventService.createEvent(currentUser.getId(), courseId, title, eventDate, description);

            response.sendRedirect(request.getContextPath() + "/student/dashboard?year="
                    + eventDate.getYear() + "&month=" + eventDate.getMonthValue());

        } catch (IllegalArgumentException e) {
            HttpSession session = request.getSession();
            session.setAttribute("flashError", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/student/dashboard");

        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("flashError", "Đã xảy ra lỗi hệ thống!");
            response.sendRedirect(request.getContextPath() + "/student/dashboard");
        }
    }

    private int parseOrDefault(String value, int defaultValue) {
        try { return Integer.parseInt(value); } catch (Exception e) { return defaultValue; }
    }
}
