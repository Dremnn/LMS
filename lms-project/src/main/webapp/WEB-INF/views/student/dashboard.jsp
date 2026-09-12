<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.LocalDate, java.util.*, com.lms.model.Quiz, com.lms.model.Event, com.lms.model.Course, com.lms.model.User" %>
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
    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";

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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảng Điều Khiển - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=26">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=26">
    <style>
        body { margin: 0; padding: 0; min-height: 100vh; }
        .dashboard-container { max-width: 1200px; margin: 24px auto 40px; padding: 0 24px; }
        .panel { background: #fff; border-radius: 14px; padding: 24px; margin-bottom: 24px; box-shadow: 0 4px 16px rgba(9,60,98,.06); border: 1px solid #C6D8E3; }
        .panel h2 { margin-top: 0; color: #093C62; font-weight: 800; }

        .filter-row { display: flex; gap: 12px; margin-bottom: 16px; }
        .filter-row select, .filter-row input {
            padding: 8px 12px; border: 1.5px solid #C6D8E3; border-radius: 8px; font-size: 14px; color: #093C62; outline: none;
        }
        .filter-row select:focus, .filter-row input:focus { border-color: #076FA4; }

        .upcoming-item {
            display: flex; justify-content: space-between; align-items: center;
            padding: 12px 0; border-bottom: 1px solid #E2EEF5;
        }
        .upcoming-item:last-child { border-bottom: none; }
        .upcoming-item a { text-decoration: none; color: #093C62; font-weight: 600; }
        .upcoming-item a:hover { color: #076FA4; }
        .upcoming-item .meta { font-size: 12px; color: #5C7688; }
        .no-items { color: #5C7688; text-align: center; padding: 20px; }

        .calendar-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .calendar-header a { text-decoration: none; color: #076FA4; font-weight: bold; }
        .calendar-header h3 { color: #093C62; margin: 0; }
        .calendar-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 6px; }
        .dow-label { font-weight: bold; text-align: center; color: #5C7688; padding-bottom: 4px; }
        .cell {
            min-height: 90px; border: 1px solid #C6D8E3; border-radius: 8px; padding: 6px;
            cursor: pointer; transition: background 0.15s; background: #fff;
        }
        .cell:hover { background: #F0F6FA; }
        .cell.empty { border: none; cursor: default; background: transparent; }
        .cell.empty:hover { background: none; }
        .cell.today { border: 2px solid #076FA4; background: #E2EEF5; }
        .day-number { font-weight: bold; font-size: 13px; color: #093C62; }

        .badge { display: block; margin-top: 4px; padding: 3px 6px; border-radius: 5px; font-size: 11px;
                 text-decoration: none; color: #fff; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .badge.expired  { background: #9ca3af; }
        .badge.urgent   { background: #dc2626; }
        .badge.upcoming { background: #f59e0b; }
        .badge.none     { background: #6b7280; }
        .badge.event    { background: #076FA4; }

        .modal-overlay {
            display: none; position: fixed; top:0; left:0; width:100%; height:100%;
            background: rgba(15,23,42,0.6); backdrop-filter: blur(4px); align-items: center; justify-content: center; z-index: 1000;
        }
        .modal-overlay.show { display: flex; }
        .modal-box { background: #fff; border-radius: 14px; padding: 24px; width: 400px; border: 1px solid #C6D8E3; box-shadow: 0 20px 60px rgba(9,60,98,.2); }
        .modal-box h3 { margin-top: 0; color: #093C62; }
        .modal-box label { display: block; margin: 10px 0 4px; font-size: 13px; color: #093C62; font-weight: 600; }
        .modal-box input, .modal-box select, .modal-box textarea {
            width: 100%; padding: 8px 12px; border: 1.5px solid #C6D8E3; border-radius: 6px; box-sizing: border-box; color: #093C62; outline: none;
        }
        .modal-box input:focus, .modal-box select:focus, .modal-box textarea:focus { border-color: #076FA4; }
        .modal-actions { margin-top: 16px; display: flex; justify-content: flex-end; gap: 8px; }
        .btn-secondary { background: #E2EEF5; color: #093C62; }

        /* Dark Theme (Ô 1: #111312, Ô 2: #182535, Ô 3: #093C62) */
        body.dark-theme .panel { background: #182535; border-color: #093C62; box-shadow: 0 4px 16px rgba(0,0,0,.3); }
        body.dark-theme .panel h2 { color: #F4F8FA; }
        body.dark-theme .upcoming-item { border-bottom-color: #093C62; }
        body.dark-theme .upcoming-item a { color: #F4F8FA; }
        body.dark-theme .upcoming-item .meta { color: #9DB9CB; }
        body.dark-theme .filter-row select, body.dark-theme .filter-row input { background: #111312; border-color: #093C62; color: #F4F8FA; }
        body.dark-theme .calendar-header a { color: #076FA4; }
        body.dark-theme .calendar-header h3 { color: #F4F8FA; }
        body.dark-theme .dow-label { color: #9DB9CB; }
        body.dark-theme .cell { border-color: #093C62; background: #182535; }
        body.dark-theme .cell:hover { background: #111312; }
        body.dark-theme .cell.today { border-color: #076FA4; background: #093C62; }
        body.dark-theme .day-number { color: #F4F8FA; }
        body.dark-theme .modal-box { background: #182535; border: 1px solid #093C62; color: #F4F8FA; }
        body.dark-theme .modal-box h3 { color: #F4F8FA; }
        body.dark-theme .modal-box label { color: #9DB9CB; }
        body.dark-theme .modal-box input, body.dark-theme .modal-box select, body.dark-theme .modal-box textarea { background: #111312; border-color: #093C62; color: #F4F8FA; }
    </style>
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">
    <!-- NAVBAR -->
    <nav class="lms-navbar">
        <a href="<%=request.getContextPath()%>/" class="lms-logo">
            <img src="<%=request.getContextPath()%>/assets/images/utedu-logo.png" alt="UTEdu" class="lms-logo-img">
            <span class="logo-tag">LMS</span>
        </a>
        <div class="nav-links">
            <a href="<%=request.getContextPath()%>/courses" class="nav-link">Khóa học</a>
            <% if (currentUser != null) { %>
                <% if ("student".equals(role)) { %>
                    <a href="<%=request.getContextPath()%>/student/dashboard" class="nav-link active">Bảng điều khiển</a>
                <% } %>
                <div class="user-badge">
                    <div class="user-avatar"><%=currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName().substring(0,1).toUpperCase() : "U"%></div>
                    <span><%=currentUser.getFullName()%></span>
                    <span class="role-tag"><%=role%></span>
                </div>
                <% if ("instructor".equals(role)) { %>
                    <a href="<%=request.getContextPath()%>/instructor/courses" class="btn btn-outline">Quản lý</a>
                <% } else if ("admin".equals(role)) { %>
                    <a href="<%=request.getContextPath()%>/admin" class="btn btn-outline">Quản trị</a>
                <% } else { %>
                    <a href="<%=request.getContextPath()%>/student/my-courses" class="btn btn-outline">Của tôi</a>
                <% } %>
                <a href="<%=request.getContextPath()%>/logout" class="btn btn-danger">Đăng xuất</a>
            <% } else { %>
                <a href="<%=request.getContextPath()%>/login" class="btn btn-outline">Đăng nhập</a>
                <a href="<%=request.getContextPath()%>/register" class="btn btn-primary">Đăng ký</a>
            <% } %>
        </div>
    </nav>

    <div class="dashboard-container">
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
    </div> <!-- /dashboard-container -->

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
                    <button type="button" class="btn btn-danger" style="background:#ef4444;color:#fff;">Xoá</button>
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

    <!-- Dynamic Island Theme Toggle -->
    <div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
        <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
        <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
        <span class="toggle-text">Chế độ Tối</span>
    </div>

    <script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=26"></script>
</body>
</html>
