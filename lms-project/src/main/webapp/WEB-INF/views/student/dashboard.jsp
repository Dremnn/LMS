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

    // Hàm phụ trợ escape JS string ngay trong scriptlet, tránh lỗi cú pháp khi title có dấu nháy
    java.util.function.Function<String, String> esc = s ->
        s == null ? "" : s.replace("\\", "\\\\").replace("'", "\\'").replace("\n", " ");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảng Điều Khiển - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <style>
        body { font-family: 'Segoe UI', Roboto, Arial, sans-serif; margin: 0; padding: 0; background: #f5f6fa; }
        .dashboard-container { max-width: 1200px; margin: 24px auto 40px; padding: 0 24px; }
        .panel { background: #fff; border-radius: 10px; padding: 20px; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); }
        .panel h2 { margin-top: 0; }

        .filter-row { display: flex; gap: 12px; margin-bottom: 16px; }
        .filter-row select, .filter-row input {
            padding: 8px 12px; border: 1px solid #ccc; border-radius: 6px; font-size: 14px;
        }

        .upcoming-item { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 1px solid #eee; }
        .upcoming-item:last-child { border-bottom: none; }
        .upcoming-item a { text-decoration: none; color: #1f2937; font-weight: 500; }
        .upcoming-item .meta { font-size: 12px; color: #888; }
        .no-items { color: #999; text-align: center; padding: 20px; }

        .timeline-date-header {
            font-size: 15px;
            font-weight: 600;
            color: #1f2937;
            margin: 20px 0 10px 0;
            padding-top: 16px;
            border-top: 1px solid #e5e7eb;
        }
        .timeline-date-header:first-of-type { border-top: none; padding-top: 0; }
        .timeline-row {
            display: flex;
            align-items: flex-start;
            gap: 16px;
            padding: 8px 0;
        }
        .tl-time {
            font-size: 13px;
            color: #6b7280;
            min-width: 40px;
            padding-top: 2px;
        }
        .tl-icon {
            color: #374151;
            padding-top: 0;
        }
        .tl-content {
            flex: 1;
        }
        .tl-title {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 2px;
        }
        .tl-title a {
            color: #2563eb;
            font-size: 14px;
            font-weight: 500;
            text-decoration: none;
        }
        .tl-title a:hover { text-decoration: underline; }
        .tl-meta {
            font-size: 12px;
            color: #6b7280;
        }
        .badge.overdue { background: #dc2626; padding: 2px 8px; border-radius: 12px; font-weight: normal; font-size: 11px; }

        .calendar-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .calendar-header a { text-decoration: none; color: #2563eb; font-weight: bold; }
        .calendar-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 6px; }
        .dow-label { font-weight: bold; text-align: center; color: #666; padding-bottom: 4px; }
        .cell { min-height: 90px; border: 1px solid #e0e0e0; border-radius: 8px; padding: 6px; cursor: pointer; transition: background 0.15s; }
        .cell:hover { background: #f9fafb; }
        .cell.empty { border: none; cursor: default; }
        .cell.empty:hover { background: none; }
        .cell.today { border: 2px solid #2563eb; background: #eff6ff; }
        .day-number { font-weight: bold; font-size: 13px; color: #333; }

        .badge { display: block; margin-top: 4px; padding: 3px 6px; border-radius: 5px; font-size: 11px;
                 text-decoration: none; color: #fff; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; cursor: pointer; }
        .badge.expired  { background: #9ca3af; }
        .badge.urgent   { background: #dc2626; }
        .badge.upcoming { background: #f59e0b; }
        .badge.none     { background: #6b7280; }
        .badge.event    { background: #7c3aed; }

        .btn { padding: 10px 18px; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 500; }
        .btn-primary { background: #2563eb; color: #fff; }
        .btn-secondary { background: #e5e7eb; color: #333; }
        .btn-danger-outline { background: #fff; border: 1px solid #ccc; color: #333; }

        .modal-overlay { display: none; position: fixed; top:0; left:0; width:100%; height:100%;
            background: rgba(0,0,0,0.4); align-items: center; justify-content: center; z-index: 1000; }
        .modal-overlay.show { display: flex; }

        .modal-box {
            background: #fff; 
            border-radius: 10px; 
            padding: 24px;
            width: 800px; /* rộng hơn hẳn, giống ảnh mẫu */
            max-height: 90vh; 
            overflow-y: auto;
        }
        .modal-box h3 { margin-top: 0; margin-bottom: 20px; }

        .modal-box .form-row {
            display: flex;
            align-items: flex-start;
            gap: 20px;
            margin: 20px 0;
        }
        .modal-box .form-row > label {
            width: 220px;
            flex-shrink: 0;
            text-align: left;
            padding-top: 8px;
            font-size: 14px;
            color: #555;
            margin: 0;
            display: flex;
            align-items: center;
        }
        .modal-box .form-row .field { flex: 1; }
        .modal-box .form-row input:not([type="radio"]):not([type="hidden"]):not([type="checkbox"]), 
        .modal-box .form-row select, 
        .modal-box .form-row textarea {
            width: 100%; 
            padding: 8px; 
            border: 1px solid #ccc; 
            border-radius: 6px; 
            box-sizing: border-box;
        }

        .custom-datetime-picker {
            display: flex; gap: 8px; align-items: center; flex-wrap: wrap;
        }
        .custom-datetime-picker input, .custom-datetime-picker select {
            padding: 6px 8px !important;
            border: 1px solid #ccc !important;
            border-radius: 4px !important;
            font-size: 14px !important;
            background: #fff;
            color: #333;
            width: auto !important;
        }
        .custom-datetime-picker input.dt-day { width: 60px !important; }
        .custom-datetime-picker select.dt-month { width: 110px !important; }
        .custom-datetime-picker input.dt-year { width: 80px !important; }
        .custom-datetime-picker input.dt-hour { width: 60px !important; }
        .custom-datetime-picker input.dt-minute { width: 60px !important; }

        
        .modal-actions { margin-top: 16px; display: flex; justify-content: flex-end; gap: 8px; }
        .show-more-link { color: #2563eb; cursor: pointer; font-size: 13px; text-decoration: underline; display: inline-block; margin-top: 4px; }
        .extra-fields { display: none; }
        .extra-fields.show { display: block; }
        .duration-option { margin: 6px 0; font-size: 13px; }
        .duration-sub { margin-left: 22px; margin-top: 4px; }

        /* Popup xem chi tiết sự kiện - style giống ảnh mẫu, header màu */
        .view-modal-box { background: #fff; border-radius: 10px; width: 340px; overflow: hidden; }
        .view-modal-header { background: #14b8a6; color: #fff; padding: 14px 16px; display: flex; justify-content: space-between; align-items: center; }
        .view-modal-header .close-x { cursor: pointer; font-size: 18px; }
        .view-modal-body { padding: 16px; }
        .view-modal-row { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; font-size: 14px; color: #444; }
        .view-modal-row a { color: #2563eb; text-decoration: none; }
        .view-modal-actions { padding: 0 16px 16px; display: flex; justify-content: flex-end; gap: 8px; }

        /* Khối ngăn kéo (Drawer) bên phải */
        .drawer-toggle-btn {
            position: fixed;
            top: 20%;
            right: 0;
            background: #212121;
            color: #fff;
            border: none;
            border-radius: 20px 0 0 20px;
            width: 40px;
            height: 48px;
            cursor: pointer;
            box-shadow: -2px 0 5px rgba(0,0,0,0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 999;
            transition: right 0.3s ease;
        }
        .drawer-toggle-btn:hover { background: #333; }
        .drawer-toggle-btn svg { width: 20px; height: 20px; fill: currentColor; }
        
        .right-drawer {
            position: fixed;
            top: 0;
            right: -320px;
            width: 320px;
            height: 100vh;
            background: #fff;
            box-shadow: -4px 0 15px rgba(0,0,0,0.1);
            z-index: 1000;
            transition: right 0.3s ease;
            overflow-y: auto;
            border-left: 1px solid #e5e7eb;
        }
        .right-drawer.open { right: 0; }
        
        .drawer-header {
            display: flex;
            justify-content: flex-end;
            padding: 12px;
        }
        .drawer-close-btn {
            background: none;
            border: none;
            font-size: 24px;
            cursor: pointer;
            color: #4b5563;
        }
        .drawer-close-btn:hover { color: #111; }
        
        .drawer-content { padding: 0 20px 20px; }
        .drawer-title {
            font-size: 18px;
            color: #1f2937;
            border-bottom: 1px solid #e5e7eb;
            padding-bottom: 12px;
            margin-top: 0;
            font-weight: 500;
        }
        .recent-item {
            display: flex;
            align-items: flex-start;
            padding: 12px 10px;
            text-decoration: none;
            color: inherit;
            border-radius: 8px;
            margin-bottom: 8px;
            transition: background 0.2s;
        }
        .recent-item:hover { background: #f3f4f6; }
        .recent-icon {
            margin-right: 12px;
            color: #4b5563;
            display: flex;
            align-items: center;
        }
        .recent-icon svg { width: 28px; height: 28px; }
        .recent-info { flex: 1; overflow: hidden; }
        .recent-name {
            font-size: 15px;
            color: #1f2937;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .recent-course {
            font-size: 13px;
            color: #2563eb;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            margin-top: 2px;
        }
        .show-more-btn {
            width: 150px;
            padding: 8px;
            background: #fff;
            border: 1px solid #4b5563;
            border-radius: 4px;
            color: #374151;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
        }
        .show-more-btn:hover { background: #f9fafb; }
    </style>
    <!-- TinyMCE CDN (Phiên bản Open Source không cần API key) -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/tinymce/6.8.3/tinymce.min.js" referrerpolicy="origin"></script>
</head>
<body class="mesh-bg">
    <!-- NAVBAR -->
    <nav class="lms-navbar">
        <div class="nav-left">
        <a href="<%=request.getContextPath()%>/" class="lms-logo">
            <img src="<%=request.getContextPath()%>/assets/images/utedu-logo.png" alt="UTEdu" class="lms-logo-img" style="height: 36px !important; width: auto; max-height: 36px;">
            <span class="logo-tag">LMS</span>
        </a>
        <% if (currentUser != null) { %>
        <div class="quick-actions">
            <a href="javascript:void(0)" onclick="toggleDrawer()" class="quick-action-btn" title="Gần đây">
                <i class="fa-solid fa-clock-rotate-left"></i><span class="quick-action-text">Gần đây</span>
            </a>
            <a href="<%=request.getContextPath()%>/student/notifications" class="quick-action-btn" title="Thông báo">
                <i class="fa-solid fa-bell"></i><span class="quick-action-text">Thông báo</span>
            </a>
        </div>
        <% } %>
    </div>
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
            String currentGroupDate = "";
            java.time.format.DateTimeFormatter timeFormatter = java.time.format.DateTimeFormatter.ofPattern("HH:mm");
            
            for (Quiz q : upcomingQuizzes) { 
                java.time.LocalDateTime dt = q.getCloseAt();
                String dateStr = "N/A";
                String timeStr = "00:00";
                if (dt != null) {
                    String dow = "";
                    switch (dt.getDayOfWeek().getValue()) {
                        case 1: dow = "Thứ Hai"; break;
                        case 2: dow = "Thứ Ba"; break;
                        case 3: dow = "Thứ Tư"; break;
                        case 4: dow = "Thứ Năm"; break;
                        case 5: dow = "Thứ Sáu"; break;
                        case 6: dow = "Thứ Bảy"; break;
                        case 7: dow = "Chủ Nhật"; break;
                    }
                    dateStr = dow + ", " + dt.getDayOfMonth() + " tháng " + dt.getMonthValue() + " " + dt.getYear();
                    timeStr = dt.format(timeFormatter);
                }
                
                if (!dateStr.equals(currentGroupDate)) {
                    currentGroupDate = dateStr;
                    %>
                    <h4 class="timeline-date-header"><%= currentGroupDate %></h4>
                    <%
                }
                
                String courseName = "Khoá học ID " + q.getCourseId();
                if (myCourses != null) {
                    for (Course c : myCourses) {
                        if (c.getId() == q.getCourseId()) {
                            courseName = c.getTitle();
                            break;
                        }
                    }
                }
            %>
                <div class="timeline-row">
                    <div class="tl-time"><%= timeStr %></div>
                    <div class="tl-icon">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="12" y1="18" x2="12" y2="12"></line><polyline points="9 15 12 12 15 15"></polyline></svg>
                    </div>
                    <div class="tl-content">
                        <div class="tl-title">
                            <a href="<%= request.getContextPath() %>/student/quizzes/intro?id=<%= q.getId() %>"><%= q.getTitle() %></a>
                            <% String urgency = urgencyByQuizId.get(q.getId()); 
                               if ("overdue".equals(urgency)) { %>
                                <span class="badge overdue">Overdue</span>
                            <% } %>
                        </div>
                        <div class="tl-meta">Bài tập tới hạn &middot; <%= courseName %></div>
                    </div>
                </div>
        <% } } %>
    </div>

    <!-- ================= PANEL 2: TIMETABLE ================= -->
    <div class="panel">
        <div class="filter-row" style="justify-content: space-between;">
            <form method="get" action="${pageContext.request.contextPath}/student/dashboard">
                <input type="hidden" name="year" value="<%= year %>">
                <input type="hidden" name="month" value="<%= month %>">
                <select name="courseId" onchange="this.form.submit()">
                    <option value="">Tất cả các khoá học</option>
                    <% if (myCourses != null) { for (Course c : myCourses) { %>
                        <option value="<%= c.getId() %>"><%= c.getTitle() %></option>
                    <% } } %>
                </select>
            </form>
            <button class="btn btn-primary" onclick="openCreateModal(null)">+ Sự kiện mới</button>
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
                <div class="<%= cellClass %>" onclick="openCreateModal('<%= cellDate %>')">
                    <div class="day-number"><%= day %></div>
                    <% if (dq != null) { for (Quiz q : dq) {
                        String urgency = urgencyByQuizId.get(q.getId()); %>
                        <a class="badge <%= urgency %>" title="<%= q.getTitle() %>"
                           href="<%= request.getContextPath() %>/student/quizzes/intro?id=<%= q.getId() %>"
                           onclick="event.stopPropagation();"><%= q.getTitle() %></a>
                    <% } }
                    if (de != null) { for (Event ev : de) {
                        String evDateStr = ev.getEventDate().toString(); // yyyy-MM-ddTHH:mm
                        String evEndStr = ev.getDurationEnd() != null ? ev.getDurationEnd().toString() : "";
                    %>
                        <span class="badge event"
                            title="<%= esc.apply(ev.getTitle()) %>"
                            data-id="<%= ev.getId() %>"
                            data-title="<%= esc.apply(ev.getTitle()) %>"
                            data-date="<%= evDateStr %>"
                            data-description="<%= esc.apply(ev.getDescription()) %>"
                            data-address="<%= esc.apply(ev.getAddress()) %>"
                            data-duration-type="<%= ev.getDurationType() %>"
                            data-end="<%= evEndStr %>"
                            data-duration-minutes="<%= ev.getDurationMinutes() != null ? ev.getDurationMinutes() : "" %>"
                            data-course-id="<%= ev.getCourseId() != null ? ev.getCourseId() : "" %>"
                            onclick="event.stopPropagation(); handleEventClick(this);">
                            <%= ev.getTitle() %>
                        </span>
                    <% } } %>
                </div>
            <% } %>
        </div>
    </div>
    </div> <!-- /dashboard-container -->

    <!-- ================= MODAL: TẠO / SỬA SỰ KIỆN ================= -->
    <div class="modal-overlay" id="eventFormModal">
        <div class="modal-box">
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #ddd; padding-bottom: 16px; margin-bottom: 24px;">
                <h3 id="eventFormTitle" style="margin: 0; font-size: 18px; color: #333;">Sự kiện mới</h3>
                <button type="button" class="close-x" onclick="closeCreateModal()" style="background: none; border: none; font-size: 24px; color: #666; cursor: pointer; padding: 0;">&times;</button>
            </div>
            
            <form method="post" id="eventForm" action="${pageContext.request.contextPath}/student/dashboard/events/new">
                <input type="hidden" name="eventId" id="fEventId">

                <div class="form-row">
                    <label>Tiêu đề sự kiện <span style="color: white; background: #dc2626; border-radius: 50%; width: 16px; height: 16px; display: inline-flex; justify-content: center; align-items: center; font-size: 11px; margin-left: 8px; font-weight: bold;">!</span></label>
                    <div class="field">
                        <input type="text" name="title" id="fTitle" required>
                    </div>
                </div>

                <div class="form-row">
                    <label>Ngày</label>
                    <div class="field">
                        <input type="hidden" name="eventDate" id="fEventDate">
                        <div class="custom-datetime-picker" id="picker_eventDate">
                            <input type="number" class="dt-day" min="1" max="31" placeholder="dd" onchange="syncPickerToHidden('picker_eventDate', 'fEventDate')">
                            <select class="dt-month" onchange="syncPickerToHidden('picker_eventDate', 'fEventDate')">
                                <option value="1">tháng 1</option><option value="2">tháng 2</option>
                                <option value="3">tháng 3</option><option value="4">tháng 4</option>
                                <option value="5">tháng 5</option><option value="6">tháng 6</option>
                                <option value="7">tháng 7</option><option value="8">tháng 8</option>
                                <option value="9">tháng 9</option><option value="10">tháng 10</option>
                                <option value="11">tháng 11</option><option value="12">tháng 12</option>
                            </select>
                            <input type="number" class="dt-year" min="2020" max="2100" placeholder="yyyy" onchange="syncPickerToHidden('picker_eventDate', 'fEventDate')">
                            <input type="number" class="dt-hour" min="0" max="23" placeholder="hh" onchange="syncPickerToHidden('picker_eventDate', 'fEventDate')">
                            <input type="number" class="dt-minute" min="0" max="59" placeholder="mm" onchange="syncPickerToHidden('picker_eventDate', 'fEventDate')">
                            <span style="color: #2563eb; font-size: 16px;">📅</span>
                        </div>
                    </div>
                </div>

                <div class="form-row" style="margin-bottom: 0;">
                    <label style="align-items: flex-start; padding-top: 0;">
                        <span class="show-more-link" id="toggleMoreLink" onclick="toggleMore()" style="border: 1px solid #93c5fd; padding: 2px 6px; background: #eff6ff; border-radius: 4px; color: #1d4ed8; text-decoration: none;">Show less...</span>
                    </label>
                    <div class="field"></div>
                </div>

                <div class="extra-fields show" id="extraFields">
                    <div class="form-row">
                        <label>Mô tả</label>
                        <div class="field">
                            <textarea name="description" id="fDescription" rows="4"></textarea>
                        </div>
                    </div>

                    <div class="form-row">
                        <label>Địa chỉ</label>
                        <div class="field">
                            <input type="text" name="address" id="fAddress">
                        </div>
                    </div>

                    <div class="form-row" style="display:none;">
                        <label>Khoá học (tùy chọn)</label>
                        <div class="field">
                            <select name="courseId" id="fCourseId">
                                <option value="">-- Khoá học (tùy chọn) --</option>
                                <% if (myCourses != null) { for (Course c : myCourses) { %>
                                    <option value="<%= c.getId() %>"><%= c.getTitle() %></option>
                                <% } } %>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <label>Thời lượng</label>
                        <div class="field">
                            <div class="duration-option">
                                <label style="display:inline; color:#555; width:auto; margin:0;"><input type="radio" name="durationType" value="none" checked onchange="onDurationChange()"> Không xác định thời lượng</label>
                            </div>
                            <div class="duration-option">
                                <label style="display:inline; color:#555; width:auto; margin:0;"><input type="radio" name="durationType" value="until" onchange="onDurationChange()"> Tới</label>
                                <div class="duration-sub">
                                    <input type="hidden" name="durationEnd" id="fDurationEnd">
                                    <div class="custom-datetime-picker" id="picker_durationEnd">
                                        <input type="number" class="dt-day" min="1" max="31" placeholder="dd" onchange="syncPickerToHidden('picker_durationEnd', 'fDurationEnd')">
                                        <select class="dt-month" onchange="syncPickerToHidden('picker_durationEnd', 'fDurationEnd')">
                                            <option value="1">tháng 1</option><option value="2">tháng 2</option>
                                            <option value="3">tháng 3</option><option value="4">tháng 4</option>
                                            <option value="5">tháng 5</option><option value="6">tháng 6</option>
                                            <option value="7">tháng 7</option><option value="8">tháng 8</option>
                                            <option value="9">tháng 9</option><option value="10">tháng 10</option>
                                            <option value="11">tháng 11</option><option value="12">tháng 12</option>
                                        </select>
                                        <input type="number" class="dt-year" min="2020" max="2100" placeholder="yyyy" onchange="syncPickerToHidden('picker_durationEnd', 'fDurationEnd')">
                                        <input type="number" class="dt-hour" min="0" max="23" placeholder="hh" onchange="syncPickerToHidden('picker_durationEnd', 'fDurationEnd')">
                                        <input type="number" class="dt-minute" min="0" max="59" placeholder="mm" onchange="syncPickerToHidden('picker_durationEnd', 'fDurationEnd')">
                                        <span style="color: #2563eb; font-size: 16px;">📅</span>
                                    </div>
                                </div>
                            </div>
                            <div class="duration-option">
                                <label style="display:inline; color:#555; width:auto; margin:0;"><input type="radio" name="durationType" value="minutes" onchange="onDurationChange()"> Thời lượng tính bằng phút</label>
                                <div class="duration-sub">
                                    <input type="number" name="durationMinutes" id="fDurationMinutes" min="1" disabled style="background:#f3f4f6; border-color:#d1d5db; max-width: 300px;">
                                </div>
                            </div>
                            
                            <div style="margin-top: 24px;">
                                <label style="display:inline-flex; align-items:center; gap:8px; color:#555; font-size:14px; margin:0; width:auto;">
                                    <input type="checkbox" name="repeatEvent" id="fRepeatEvent" onchange="onRepeatChange()"> Lặp lại sự kiện này
                                </label>
                            </div>
                        </div>
                    </div>

                    <div class="form-row">
                        <label>Lặp lại hàng tuần, tạo ra tất cả</label>
                        <div class="field">
                            <input type="number" name="repeatWeeks" id="fRepeatWeeks" value="1" min="1" disabled style="width: 100px; background:#f3f4f6; border-color:#d1d5db;">
                        </div>
                    </div>
                </div>

                <div class="form-row" style="margin-top: 24px;">
                    <div style="font-size: 13px; color: #555;">Có các mục bắt buộc trong biểu mẫu này được đánh dấu <span style="color: white; background: #dc2626; border-radius: 50%; width: 14px; height: 14px; display: inline-flex; justify-content: center; align-items: center; font-size: 10px; margin: 0 4px; font-weight: bold;">!</span> .</div>
                </div>

                <div class="modal-actions" style="margin-top:24px; padding-top:16px; border-top:1px solid #ddd; justify-content: flex-end;">
                    <button type="submit" class="btn btn-primary" style="padding: 8px 24px;">Lưu</button>
                </div>
            </form>
        </div>
    </div>

    <!-- ================= POPUP: XEM CHI TIẾT SỰ KIỆN ================= -->
    <div class="modal-overlay" id="viewModal">
        <div class="view-modal-box">
            <div class="view-modal-header">
                <span id="vTitle">Sự kiện</span>
                <span class="close-x" onclick="closeViewModal()">&times;</span>
            </div>
            <div class="view-modal-body">
                <div class="view-modal-row">🕒 <span id="vDate"></span></div>
                <div class="view-modal-row">📅 Sự kiện thành viên</div>
                <div class="view-modal-row" id="vAddressRow" style="display:none;">📍 <span id="vAddress"></span></div>
                <div class="view-modal-row" id="vDescRow" style="display:none;"><span id="vDescription"></span></div>
            </div>
            <div class="view-modal-actions">
                <button class="btn btn-danger-outline" onclick="openDeleteConfirm()">Xoá</button>
                <button class="btn btn-primary" onclick="openEditFromView()">Chỉnh sửa</button>
            </div>
        </div>
    </div>

    <!-- ================= MODAL: XÁC NHẬN XÓA ================= -->
    <div class="modal-overlay" id="deleteModal">
        <div class="modal-box" style="width:360px;">
            <h3>Xóa sự kiện</h3>
            <p>Bạn có chắc chắn muốn xoá sự kiện này?</p>
            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" onclick="closeDeleteConfirm()">Huỷ bỏ</button>
                <form method="post" id="deleteForm" action="${pageContext.request.contextPath}/student/dashboard/events/delete" style="display:inline;">
                    <input type="hidden" name="eventId" id="dEventId">
                    <input type="hidden" name="year" value="<%= year %>">
                    <input type="hidden" name="month" value="<%= month %>">
                    <button type="submit" class="btn btn-primary">Xóa sự kiện</button>
                </form>
            </div>
        </div>
    </div>

    

    <script>
        // Khởi tạo TinyMCE
        tinymce.init({
            selector: '#fDescription',
            height: 250,
            menubar: false,
            plugins: 'advlist autolink lists link image charmap preview anchor searchreplace visualblocks code fullscreen insertdatetime media table help wordcount',
            toolbar: 'undo redo | blocks | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | removeformat | help',
            base_zindex: 2000, /* modal-overlay có z-index 1000 nên để TinyMCE cao hơn */
            setup: function (editor) {
                editor.on('change', function () {
                    editor.save(); // Đồng bộ dữ liệu về textarea gốc
                });
            }
        });

        var currentViewEvent = null;

        // ---------- Date Picker Sync ----------
        function syncPickerToHidden(pickerId, hiddenId) {
            var container = document.getElementById(pickerId);
            if(!container) return;
            var day = container.querySelector('.dt-day').value.padStart(2, '0');
            var month = container.querySelector('.dt-month').value.padStart(2, '0');
            var year = container.querySelector('.dt-year').value;
            var hour = container.querySelector('.dt-hour').value.padStart(2, '0');
            var minute = container.querySelector('.dt-minute').value.padStart(2, '0');
            
            if (day !== '00' && month !== '00' && year && hour !== '00' && minute !== '00') {
                document.getElementById(hiddenId).value = year + '-' + month + '-' + day + 'T' + hour + ':' + minute;
            } else {
                document.getElementById(hiddenId).value = '';
            }
        }

        function syncHiddenToPicker(hiddenId, pickerId) {
            var hiddenVal = document.getElementById(hiddenId).value;
            var container = document.getElementById(pickerId);
            if(!container) return;
            
            if (!hiddenVal) {
                container.querySelector('.dt-day').value = '';
                container.querySelector('.dt-month').value = '1';
                container.querySelector('.dt-year').value = '';
                container.querySelector('.dt-hour').value = '';
                container.querySelector('.dt-minute').value = '';
                return;
            }
            
            var parts = hiddenVal.split('T');
            if(parts.length === 2) {
                var dateParts = parts[0].split('-');
                var timeParts = parts[1].split(':');
                if(dateParts.length === 3 && timeParts.length >= 2) {
                    container.querySelector('.dt-year').value = dateParts[0];
                    container.querySelector('.dt-month').value = parseInt(dateParts[1], 10);
                    container.querySelector('.dt-day').value = parseInt(dateParts[2], 10);
                    container.querySelector('.dt-hour').value = parseInt(timeParts[0], 10);
                    container.querySelector('.dt-minute').value = parseInt(timeParts[1], 10);
                }
            }
        }

        function disablePicker(pickerId, disabled) {
            var container = document.getElementById(pickerId);
            if(!container) return;
            var inputs = container.querySelectorAll('input, select');
            for(var i=0; i<inputs.length; i++) {
                inputs[i].disabled = disabled;
                if(disabled) {
                    inputs[i].style.background = '#f3f4f6';
                } else {
                    inputs[i].style.background = '#fff';
                }
            }
        }

        // ---------- Modal Tạo/Sửa ----------
        function openCreateModal(dateStr) {
            document.getElementById('eventForm').action = '${pageContext.request.contextPath}/student/dashboard/events/new';
            document.getElementById('eventFormTitle').innerText = 'Sự kiện mới';
            document.getElementById('fEventId').value = '';
            document.getElementById('fTitle').value = '';
            
            // Nếu dateStr là ngày trong calendar (YYYY-MM-DDTHH:mm), thiết lập picker
            document.getElementById('fEventDate').value = dateStr ? dateStr : '';
            syncHiddenToPicker('fEventDate', 'picker_eventDate');

            document.getElementById('fDescription').value = '';
            document.getElementById('fAddress').value = '';
            document.getElementById('fCourseId').value = '';
            
            var radios = document.getElementsByName('durationType');
            radios[0].checked = true;
            onDurationChange();

            document.getElementById('fRepeatEvent').checked = false;
            onRepeatChange();
            
            if (tinymce.get('fDescription')) {
                tinymce.get('fDescription').setContent('');
            }
            document.getElementById('eventFormModal').classList.add('show');
        }

        function handleEventClick(el) {
            const id = el.dataset.id;
            const title = el.dataset.title;
            const date = el.dataset.date;
            const description = el.dataset.description;
            const address = el.dataset.address;
            const durationType = el.dataset.durationType;
            const end = el.dataset.end;
            const durationMinutes = el.dataset.durationMinutes || null;
            const courseId = el.dataset.courseId || null;

            openViewModal(id, title, date, description, address, durationType, end, durationMinutes, courseId);
    }

    function openViewModal(id, title, date, description, address, durationType, end, durationMinutes, courseId) {
        // logic mở modal của bạn ở đây
        console.log({ id, title, date, description, address, durationType, end, durationMinutes, courseId });
    }

        function closeCreateModal() {
            document.getElementById('eventFormModal').classList.remove('show');
        }

        function toggleMore() {
            var extra = document.getElementById('extraFields');
            var link = document.getElementById('toggleMoreLink');
            if (extra.classList.contains('show')) {
                collapseExtra();
            } else {
                extra.classList.add('show');
                link.innerText = 'Show less...';
            }
        }
        function collapseExtra() {
            document.getElementById('extraFields').classList.remove('show');
            document.getElementById('toggleMoreLink').innerText = 'Show more...';
        }

        function onDurationChange() {
            var type = document.querySelector('input[name="durationType"]:checked').value;
            disablePicker('picker_durationEnd', type !== 'until');
            document.getElementById('fDurationMinutes').disabled = (type !== 'minutes');
            if(type === 'minutes') {
                document.getElementById('fDurationMinutes').style.background = '#fff';
            } else {
                document.getElementById('fDurationMinutes').style.background = '#f3f4f6';
            }
        }

        function onRepeatChange() {
            var chk = document.getElementById('fRepeatEvent');
            var weeksInput = document.getElementById('fRepeatWeeks');
            weeksInput.disabled = !chk.checked;
            if(chk.checked) {
                weeksInput.style.background = '#fff';
            } else {
                weeksInput.style.background = '#f3f4f6';
            }
        }

        // ---------- Popup Xem chi tiết ----------
        function openViewModal(id, title, eventDate, description, address, durationType, durationEnd, durationMinutes, courseId) {
            currentViewEvent = { id: id, title: title, eventDate: eventDate, description: description,
                address: address, durationType: durationType, durationEnd: durationEnd,
                durationMinutes: durationMinutes, courseId: courseId };

            document.getElementById('vTitle').innerText = title;
            document.getElementById('vDate').innerText = eventDate.replace('T', ' ');

            var addrRow = document.getElementById('vAddressRow');
            if (address) { addrRow.style.display = 'flex'; document.getElementById('vAddress').innerText = address; }
            else { addrRow.style.display = 'none'; }

            var descRow = document.getElementById('vDescRow');
            if (description) { descRow.style.display = 'flex'; document.getElementById('vDescription').innerHTML = description; }
            else { descRow.style.display = 'none'; }

            document.getElementById('viewModal').classList.add('show');
        }
        function closeViewModal() {
            document.getElementById('viewModal').classList.remove('show');
        }

        // ---------- Chuyển từ Xem sang Sửa ----------
        function openEditFromView() {
            var ev = currentViewEvent;
            closeViewModal();

            document.getElementById('eventForm').action = '${pageContext.request.contextPath}/student/dashboard/events/edit';
            document.getElementById('eventFormTitle').innerText = 'Chỉnh sửa sự kiện';
            document.getElementById('fEventId').value = ev.id;
            document.getElementById('fTitle').value = ev.title;
            
            document.getElementById('fEventDate').value = ev.eventDate;
            syncHiddenToPicker('fEventDate', 'picker_eventDate');
            
            document.getElementById('fDescription').value = ev.description || '';
            if (tinymce.get('fDescription')) {
                tinymce.get('fDescription').setContent(ev.description || '');
            }
            document.getElementById('fAddress').value = ev.address || '';
            document.getElementById('fCourseId').value = ev.courseId || '';

            document.querySelector('input[name="durationType"][value="' + (ev.durationType || 'none') + '"]').checked = true;
            
            document.getElementById('fDurationEnd').value = ev.durationEnd || '';
            syncHiddenToPicker('fDurationEnd', 'picker_durationEnd');
            
            document.getElementById('fDurationMinutes').value = ev.durationMinutes || '';
            onDurationChange();


            document.getElementById('eventFormModal').classList.add('show');
        }

        // ---------- Xác nhận xóa ----------
        function openDeleteConfirm() {
            document.getElementById('dEventId').value = currentViewEvent.id;
            closeViewModal();
            document.getElementById('deleteModal').classList.add('show');
        }
        function closeDeleteConfirm() {
            document.getElementById('deleteModal').classList.remove('show');
        }

        
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=30"></script>


    <jsp:include page="/WEB-INF/views/components/drawer.jsp" />
</body>
</html>
