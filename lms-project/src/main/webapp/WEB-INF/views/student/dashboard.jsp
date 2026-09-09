<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.LocalDate, java.util.*, com.lms.model.Quiz, com.lms.model.Event, com.lms.model.Course" %>
<%
    int year = (Integer) request.getAttribute("year");
    int month = (Integer) request.getAttribute("month");
    Map<Integer, List<Quiz>> quizzesByDay = (Map<Integer, List<Quiz>>) request.getAttribute("quizzesByDay");
    Map<Integer, String> urgencyByQuizId = (Map<Integer, String>) request.getAttribute("urgencyByQuizId");
    Map<Integer, List<Event>> eventsByDay = (Map<Integer, List<Event>>) request.getAttribute("eventsByDay");
    LocalDate today = (LocalDate) request.getAttribute("today");
    List<Quiz> upcomingQuizzes = (List<Quiz>) request.getAttribute("upcomingQuizzes");
    String dueFilter = (String) request.getAttribute("dueFilter");
    String sortBy = (String) request.getAttribute("sortBy");
    List<Course> myCourses = (List<Course>) request.getAttribute("myCourses");

    LocalDate firstDay = LocalDate.of(year, month, 1);
    int daysInMonth = firstDay.lengthOfMonth();
    int startOffset = firstDay.getDayOfWeek().getValue() - 1;

    int prevMonth = month - 1, prevYear = year;
    if (prevMonth < 1) { prevMonth = 12; prevYear--; }
    int nextMonth = month + 1, nextYear = year;
    if (nextMonth > 12) { nextMonth = 1; nextYear++; }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Bảng Điều Khiển - LMS</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f6fa; }
        .panel { background: #fff; border-radius: 10px; padding: 20px; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); }
        .panel h2 { margin-top: 0; }

        .filter-row { display: flex; gap: 12px; margin-bottom: 16px; }
        .filter-row select, .filter-row input {
            padding: 8px 12px; border: 1px solid #ccc; border-radius: 6px; font-size: 14px;
        }

        .upcoming-item {
            display: flex; justify-content: space-between; align-items: center;
            padding: 10px 0; border-bottom: 1px solid #eee;
        }
        .upcoming-item:last-child { border-bottom: none; }
        .upcoming-item a { text-decoration: none; color: #1f2937; font-weight: 500; }
        .upcoming-item .meta { font-size: 12px; color: #888; }
        .no-items { color: #999; text-align: center; padding: 20px; }

        .calendar-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .calendar-header a { text-decoration: none; color: #2563eb; font-weight: bold; }
        .calendar-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 6px; }
        .dow-label { font-weight: bold; text-align: center; color: #666; padding-bottom: 4px; }
        .cell {
            min-height: 90px; border: 1px solid #e0e0e0; border-radius: 8px; padding: 6px;
            cursor: pointer; transition: background 0.15s;
        }
        .cell:hover { background: #f9fafb; }
        .cell.empty { border: none; cursor: default; }
        .cell.empty:hover { background: none; }
        .cell.today { border: 2px solid #2563eb; background: #eff6ff; }
        .day-number { font-weight: bold; font-size: 13px; color: #333; }

        .badge { display: block; margin-top: 4px; padding: 3px 6px; border-radius: 5px; font-size: 11px;
                 text-decoration: none; color: #fff; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .badge.expired  { background: #9ca3af; }
        .badge.urgent   { background: #dc2626; }
        .badge.upcoming { background: #f59e0b; }
        .badge.none     { background: #6b7280; }
        .badge.event    { background: #7c3aed; }

        .btn { padding: 10px 18px; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 500; }
        .btn-primary { background: #2563eb; color: #fff; }

        .modal-overlay {
            display: none; position: fixed; top:0; left:0; width:100%; height:100%;
            background: rgba(0,0,0,0.4); align-items: center; justify-content: center; z-index: 1000;
        }
        .modal-overlay.show { display: flex; }
        .modal-box { background: #fff; border-radius: 10px; padding: 24px; width: 400px; }
        .modal-box h3 { margin-top: 0; }
        .modal-box label { display: block; margin: 10px 0 4px; font-size: 13px; color: #555; }
        .modal-box input, .modal-box select, .modal-box textarea {
            width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 6px; box-sizing: border-box;
        }
        .modal-actions { margin-top: 16px; display: flex; justify-content: flex-end; gap: 8px; }
        .btn-secondary { background: #e5e7eb; color: #333; }
    </style>
</head>
<body>

    <% if (request.getAttribute("error") != null) { %>
        <div class="panel" style="background:#fef2f2; color:#991b1b;"><%= request.getAttribute("error") %></div>
    <% } %>

    <!-- ================= PANEL 1: MỐC THỜI GIAN ================= -->
    <div class="panel">
        <h2>Mốc thời gian</h2>
        <form method="get" action="${pageContext.request.contextPath}/student/dashboard" class="filter-row">
            <input type="hidden" name="year" value="<%= year %>">
            <input type="hidden" name="month" value="<%= month %>">

            <select name="dueFilter" onchange="this.form.submit()">
                <option value="all" <%= "all".equals(dueFilter) ? "selected" : "" %>>Tất cả</option>
                <option value="overdue" <%= "overdue".equals(dueFilter) ? "selected" : "" %>>Overdue</option>
                <option value="7" <%= "7".equals(dueFilter) ? "selected" : "" %>>Next 7 days</option>
                <option value="30" <%= "30".equals(dueFilter) ? "selected" : "" %>>Next 30 days</option>
                <option value="90" <%= "90".equals(dueFilter) ? "selected" : "" %>>Next 3 months</option>
                <option value="180" <%= "180".equals(dueFilter) ? "selected" : "" %>>Next 6 months</option>
            </select>

            <select name="sortBy" onchange="this.form.submit()">
                <option value="dates" <%= "dates".equals(sortBy) ? "selected" : "" %>>Sort by dates</option>
                <option value="courses" <%= "courses".equals(sortBy) ? "selected" : "" %>>Sort by courses</option>
            </select>
        </form>

        <% if (upcomingQuizzes == null || upcomingQuizzes.isEmpty()) { %>
            <div class="no-items">Không có mốc thời gian nào phù hợp bộ lọc.</div>
        <% } else {
            for (Quiz q : upcomingQuizzes) { %>
            <div class="upcoming-item">
                <a href="<%= request.getContextPath() %>/student/quizzes/intro?id=<%= q.getId() %>">
                    <%= q.getTitle() %>
                </a>
                <span class="meta">Hạn: <%= q.getCloseAt() %></span>
            </div>
        <%  }
        } %>
    </div>

    <!-- ================= PANEL 2: TIMETABLE ================= -->
    <div class="panel">
        <div class="filter-row" style="justify-content: space-between;">
            <form method="get" action="${pageContext.request.contextPath}/student/dashboard">
                <input type="hidden" name="year" value="<%= year %>">
                <input type="hidden" name="month" value="<%= month %>">
                <select name="courseId" onchange="this.form.submit()">
                    <option value="">Tất cả các khoá học</option>
                    <% if (myCourses != null) {
                        for (Course c : myCourses) { %>
                        <option value="<%= c.getId() %>"><%= c.getTitle() %></option>
                    <%  }
                    } %>
                </select>
            </form>
            <button class="btn btn-primary" onclick="openEventModal(null)">+ Sự kiện mới</button>
        </div>

        <div class="calendar-header">
            <a href="${pageContext.request.contextPath}/student/dashboard?year=<%= prevYear %>&month=<%= prevMonth %>">&laquo; Tháng trước</a>
            <h2>Tháng <%= month %> / <%= year %></h2>
            <a href="${pageContext.request.contextPath}/student/dashboard?year=<%= nextYear %>&month=<%= nextMonth %>">Tháng sau &raquo;</a>
        </div>

        <div class="calendar-grid">
            <% String[] dowLabels = {"T2","T3","T4","T5","T6","T7","CN"};
               for (String l : dowLabels) { %>
                <div class="dow-label"><%= l %></div>
            <% }
            for (int i = 0; i < startOffset; i++) { %>
                <div class="cell empty"></div>
            <% }
            for (int day = 1; day <= daysInMonth; day++) {
                boolean isToday = today.getYear() == year && today.getMonthValue() == month && today.getDayOfMonth() == day;
                List<Quiz> dq = quizzesByDay.get(day);
                List<Event> de = eventsByDay.get(day);
                String cellClass = isToday ? "cell today" : "cell";
                String cellDate = String.format("%04d-%02d-%02dT08:00", year, month, day);
            %>
                <div class="<%= cellClass %>" onclick="openEventModal('<%= cellDate %>')">
                    <div class="day-number"><%= day %></div>
                    <% if (dq != null) { for (Quiz q : dq) {
                        String urgency = urgencyByQuizId.get(q.getId()); %>
                        <a class="badge <%= urgency %>" title="<%= q.getTitle() %>"
                           href="<%= request.getContextPath() %>/student/quizzes/intro?id=<%= q.getId() %>"
                           onclick="event.stopPropagation();"><%= q.getTitle() %></a>
                    <%  } }
                    if (de != null) { for (Event ev : de) { %>
                        <span class="badge event" title="<%= ev.getTitle() %>"><%= ev.getTitle() %></span>
                    <%  } } %>
                </div>
            <% } %>
        </div>
    </div>

    <!-- ================= MODAL: TẠO SỰ KIỆN MỚI ================= -->
    <div class="modal-overlay" id="eventModal">
        <div class="modal-box">
            <h3>Sự kiện mới</h3>
            <form method="post" action="${pageContext.request.contextPath}/student/dashboard/events/new">
                <label>Tiêu đề sự kiện *</label>
                <input type="text" name="title" required>

                <label>Ngày giờ *</label>
                <input type="datetime-local" name="eventDate" id="eventDateInput" required>

                <label>Khoá học (tùy chọn)</label>
                <select name="courseId">
                    <option value="">-- Không gắn khoá học --</option>
                    <% if (myCourses != null) {
                        for (Course c : myCourses) { %>
                        <option value="<%= c.getId() %>"><%= c.getTitle() %></option>
                    <%  }
                    } %>
                </select>

                <label>Ghi chú</label>
                <textarea name="description" rows="3"></textarea>

                <div class="modal-actions">
                    <button type="button" class="btn btn-secondary" onclick="closeEventModal()">Huỷ</button>
                    <button type="submit" class="btn btn-primary">Lưu</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openEventModal(prefillDate) {
            document.getElementById('eventModal').classList.add('show');
            if (prefillDate) {
                document.getElementById('eventDateInput').value = prefillDate;
            }
        }
        function closeEventModal() {
            document.getElementById('eventModal').classList.remove('show');
        }
    </script>

</body>
</html>
