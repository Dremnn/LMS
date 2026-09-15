<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.LocalDate, java.time.LocalDateTime, java.util.*, com.lms.model.Quiz, com.lms.model.Event, com.lms.model.Course, com.lms.model.User" %>
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

    // Hàm phụ trợ escape JS string
    java.util.function.Function<String, String> esc = s ->
        s == null ? "" : s.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "&quot;").replace("\n", " ").replace("\r", "");
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

        .filter-row { display: flex; gap: 12px; margin-bottom: 16px; align-items: center; }
        .filter-row select, .filter-row input {
            padding: 8px 12px; border: 1.5px solid #C6D8E3; border-radius: 8px; font-size: 14px; color: #093C62; outline: none; background: #fff;
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
        .calendar-header h2 { color: #093C62; margin: 0; font-size: 20px; font-weight: 800; }
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
                 text-decoration: none; color: #fff; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; cursor: pointer; }
        .badge.expired  { background: #9ca3af; }
        .badge.urgent   { background: #dc2626; }
        .badge.upcoming { background: #f59e0b; }
        .badge.none     { background: #6b7280; }
        .badge.event    { background: #076FA4; }

        .btn { padding: 8px 16px; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 500; transition: background 0.2s; }
        .btn-primary { background: #076FA4; color: #fff; }
        .btn-primary:hover { background: #093C62; }
        .btn-secondary { background: #E2EEF5; color: #093C62; }
        .btn-secondary:hover { background: #C6D8E3; }
        .btn-danger { background: #ef4444; color: #fff; }
        .btn-danger:hover { background: #dc2626; }

        .modal-overlay {
            display: none; position: fixed; top:0; left:0; width:100%; height:100%;
            background: rgba(15,23,42,0.6); backdrop-filter: blur(4px); align-items: center; justify-content: center; z-index: 1000;
        }
        .modal-overlay.show { display: flex; }
        .modal-box { background: #fff; border-radius: 14px; padding: 24px; width: 440px; border: 1px solid #C6D8E3; box-shadow: 0 20px 60px rgba(9,60,98,.2); max-height: 90vh; overflow-y: auto; }
        .modal-box h3 { margin-top: 0; color: #093C62; font-size: 18px; }
        .modal-box label { display: block; margin: 10px 0 4px; font-size: 13px; color: #093C62; font-weight: 600; }
        .modal-box input:not([type="radio"]):not([type="checkbox"]), .modal-box select, .modal-box textarea {
            width: 100%; padding: 8px 12px; border: 1.5px solid #C6D8E3; border-radius: 6px; box-sizing: border-box; color: #093C62; outline: none; font-size: 14px; font-family: inherit;
        }
        .modal-box input:focus, .modal-box select:focus, .modal-box textarea:focus { border-color: #076FA4; }
        .modal-actions { margin-top: 16px; display: flex; justify-content: flex-end; gap: 8px; }
        .show-more-link { color: #076FA4; cursor: pointer; font-size: 13px; text-decoration: underline; display: inline-block; }

        /* Dark Theme (Ô 1: #111312, Ô 2: #182535, Ô 3: #093C62) */
        body.dark-theme .panel { background: #182535; border-color: #093C62; box-shadow: 0 4px 16px rgba(0,0,0,.3); }
        body.dark-theme .panel h2 { color: #F4F8FA; }
        body.dark-theme .upcoming-item { border-bottom-color: #093C62; }
        body.dark-theme .upcoming-item a { color: #F4F8FA; }
        body.dark-theme .upcoming-item .meta { color: #9DB9CB; }
        body.dark-theme .filter-row select, body.dark-theme .filter-row input { background: #111312; border-color: #093C62; color: #F4F8FA; }
        body.dark-theme .calendar-header a { color: #076FA4; }
        body.dark-theme .calendar-header h2 { color: #F4F8FA; }
        body.dark-theme .dow-label { color: #9DB9CB; }
        body.dark-theme .cell { border-color: #093C62; background: #182535; }
        body.dark-theme .cell:hover { background: #111312; }
        body.dark-theme .cell.today { border-color: #076FA4; background: #093C62; }
        body.dark-theme .day-number { color: #F4F8FA; }
        body.dark-theme .modal-box { background: #182535; border: 1px solid #093C62; color: #F4F8FA; }
        body.dark-theme .modal-box h3 { color: #F4F8FA; }
        body.dark-theme .modal-box label { color: #9DB9CB; }
        body.dark-theme .modal-box input:not([type="radio"]):not([type="checkbox"]), body.dark-theme .modal-box select, body.dark-theme .modal-box textarea { background: #111312; border-color: #093C62; color: #F4F8FA; }
        body.dark-theme .btn-secondary { background: #093C62; color: #F4F8FA; }
        body.dark-theme .show-more-link { color: #38bdf8; }
        body.dark-theme .view-modal-header { background: #076FA4; }
        body.dark-theme .view-modal-row { color: #F4F8FA; }
        body.dark-theme .view-modal-row i { color: #38bdf8 !important; }
        body.dark-theme #vDescRow { border-top-color: #093C62 !important; }
    </style>
    <!-- TinyMCE CDN -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/tinymce/6.8.3/tinymce.min.js" referrerpolicy="origin"></script>
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">
    <!-- NAVBAR -->
    <nav class="lms-navbar">
        <a href="<%=request.getContextPath()%>/" class="lms-logo">
            <img src="<%=request.getContextPath()%>/assets/images/utedu-logo.png" alt="UTEdu" class="lms-logo-img">
            <span class="logo-tag">LMS</span>
        </a>
        <% if (currentUser != null) { %>
        <div class="quick-actions">
            <a href="<%=request.getContextPath()%>/chat" class="quick-action-btn" title="Tin nhắn">
                <i class="fa-solid fa-comment-dots"></i><span class="quick-action-text">Tin nhắn</span>
            </a>
            <a href="<%=request.getContextPath()%>/student/notifications" class="quick-action-btn" title="Thông báo">
                <i class="fa-solid fa-bell"></i><span class="quick-action-text">Thông báo</span>
            </a>
        </div>
        <% } %>
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
                    <%  } }
                    if (de != null) { for (Event ev : de) {
                        String evDateStr = ev.getEventDate() != null ? ev.getEventDate().toString() : "";
                        String evEndStr = ev.getDurationEnd() != null ? ev.getDurationEnd().toString() : "";
                    %>
                        <span class="badge event"
                              title="<%= esc.apply(ev.getTitle()) %>"
                              data-id="<%= ev.getId() %>"
                              data-title="<%= esc.apply(ev.getTitle()) %>"
                              data-date="<%= evDateStr %>"
                              data-description="<%= esc.apply(ev.getDescription()) %>"
                              data-address="<%= esc.apply(ev.getAddress()) %>"
                              data-duration-type="<%= ev.getDurationType() != null ? ev.getDurationType() : "none" %>"
                              data-end="<%= evEndStr %>"
                              data-duration-minutes="<%= ev.getDurationMinutes() != null ? ev.getDurationMinutes() : "" %>"
                              data-course-id="<%= ev.getCourseId() != null ? ev.getCourseId() : "" %>"
                              onclick="event.stopPropagation(); handleEventClick(this);">
                            <%= ev.getTitle() %>
                        </span>
                    <%  } } %>
                </div>
            <% } %>
        </div>
    </div>
    </div> <!-- /dashboard-container -->

    <!-- ================= MODAL: TẠO / SỬA SỰ KIỆN ================= -->
    <div class="modal-overlay" id="eventModal">
        <div class="modal-box" style="width: 480px;">
            <h3 id="eventFormTitle">Sự kiện mới</h3>
            <form method="post" id="eventForm" action="${pageContext.request.contextPath}/student/dashboard/events/new">
                <input type="hidden" name="eventId" id="fEventId">

                <label>Tiêu đề sự kiện *</label>
                <input type="text" name="title" id="fTitle" required placeholder="Nhập tiêu đề sự kiện">

                <label>Ngày giờ *</label>
                <input type="datetime-local" name="eventDate" id="fEventDate" required>

                <div style="margin: 10px 0 4px;">
                    <span class="show-more-link" id="toggleMoreLink" onclick="toggleMore()">Hiển thị thêm...</span>
                </div>

                <div class="extra-fields" id="extraFields" style="display: none;">
                    <label>Khoá học (tùy chọn)</label>
                    <select name="courseId" id="fCourseId">
                        <option value="">-- Không gắn khoá học --</option>
                        <% if (myCourses != null) {
                            for (Course c : myCourses) { %>
                            <option value="<%= c.getId() %>"><%= c.getTitle() %></option>
                        <%  }
                        } %>
                    </select>

                    <label>Địa điểm</label>
                    <input type="text" name="address" id="fAddress" placeholder="Phòng học, địa chỉ...">

                    <label>Ghi chú / Mô tả</label>
                    <textarea name="description" id="fDescription" rows="3"></textarea>

                    <label>Thời lượng</label>
                    <div style="margin: 6px 0; font-size: 13px;">
                        <label style="display:inline; font-weight:normal; cursor:pointer;"><input type="radio" name="durationType" value="none" checked onchange="onDurationChange()"> Không xác định thời lượng</label>
                    </div>
                    <div style="margin: 6px 0; font-size: 13px;">
                        <label style="display:inline; font-weight:normal; cursor:pointer;"><input type="radio" name="durationType" value="until" onchange="onDurationChange()"> Tới</label>
                        <div style="margin-left: 20px; margin-top: 4px;">
                            <input type="datetime-local" name="durationEnd" id="fDurationEnd" disabled>
                        </div>
                    </div>
                    <div style="margin: 6px 0; font-size: 13px;">
                        <label style="display:inline; font-weight:normal; cursor:pointer;"><input type="radio" name="durationType" value="minutes" onchange="onDurationChange()"> Thời lượng tính bằng phút</label>
                        <div style="margin-left: 20px; margin-top: 4px;">
                            <input type="number" name="durationMinutes" id="fDurationMinutes" min="1" disabled placeholder="Số phút">
                        </div>
                    </div>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn btn-secondary" onclick="closeEventModal()">Huỷ</button>
                    <button type="submit" class="btn btn-primary">Lưu</button>
                </div>
            </form>
        </div>
    </div>

    <!-- ================= MODAL: XEM CHI TIẾT SỰ KIỆN ================= -->
    <div class="modal-overlay" id="viewModal">
        <div class="modal-box" style="width: 380px; padding: 0; overflow: hidden;">
            <div style="background: #076FA4; color: #fff; padding: 14px 18px; display: flex; justify-content: space-between; align-items: center; font-weight: 600;">
                <span id="vTitle" style="color: #fff; font-size: 16px;">Chi tiết sự kiện</span>
                <span onclick="closeViewModal()" style="cursor: pointer; font-size: 20px; line-height: 1; opacity: 0.85;">&times;</span>
            </div>
            <div style="padding: 18px;">
                <div class="view-modal-row" style="display: flex; gap: 8px; align-items: center; margin-bottom: 10px; font-size: 14px;"><i class="fa-regular fa-clock" style="color:#076FA4; width: 16px; text-align: center;"></i> <span id="vDate"></span></div>
                <div class="view-modal-row" id="vCourseRow" style="display: none; gap: 8px; align-items: center; margin-bottom: 10px; font-size: 14px;"><i class="fa-solid fa-graduation-cap" style="color:#076FA4; width: 16px; text-align: center;"></i> <span id="vCourse"></span></div>
                <div class="view-modal-row" id="vAddressRow" style="display: none; gap: 8px; align-items: center; margin-bottom: 10px; font-size: 14px;"><i class="fa-solid fa-location-dot" style="color:#076FA4; width: 16px; text-align: center;"></i> <span id="vAddress"></span></div>
                <div class="view-modal-row" id="vDescRow" style="display: none; margin-top: 10px; border-top: 1px solid #E2EEF5; padding-top: 10px; font-size: 14px;"><div id="vDescription"></div></div>
            </div>
            <div class="modal-actions" style="padding: 0 18px 18px; margin-top: 0;">
                <button type="button" class="btn btn-secondary" onclick="closeViewModal()">Đóng</button>
                <button type="button" class="btn btn-danger" onclick="openDeleteConfirm()">Xoá</button>
                <button type="button" class="btn btn-primary" onclick="openEditFromView()">Chỉnh sửa</button>
            </div>
        </div>
    </div>

    <!-- ================= MODAL: XÁC NHẬN XÓA ================= -->
    <div class="modal-overlay" id="deleteModal">
        <div class="modal-box" style="width: 360px;">
            <h3>Xác nhận xoá sự kiện</h3>
            <p style="font-size: 14px; margin-bottom: 20px;">Bạn có chắc chắn muốn xoá sự kiện này khỏi lịch?</p>
            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" onclick="closeDeleteConfirm()">Huỷ bỏ</button>
                <form method="post" id="deleteForm" action="${pageContext.request.contextPath}/student/dashboard/events/delete" style="display:inline;">
                    <input type="hidden" name="eventId" id="dEventId">
                    <input type="hidden" name="year" value="<%= year %>">
                    <input type="hidden" name="month" value="<%= month %>">
                    <button type="submit" class="btn btn-danger">Xác nhận xoá</button>
                </form>
            </div>
        </div>
    </div>

    <script>
        var courseMap = {};
        <% if (myCourses != null) { for (Course c : myCourses) { %>
        courseMap['<%= c.getId() %>'] = '<%= esc.apply(c.getTitle()) %>';
        <% } } %>

        // Khởi tạo TinyMCE
        tinymce.init({
            selector: '#fDescription',
            height: 200,
            menubar: false,
            plugins: 'advlist autolink lists link code preview',
            toolbar: 'undo redo | bold italic underline | alignleft aligncenter alignright | bullist numlist | removeformat',
            base_zindex: 2000,
            setup: function (editor) {
                editor.on('change', function () {
                    editor.save();
                });
            }
        });

        var currentViewEvent = null;

        function openCreateModal(prefillDate) {
            document.getElementById('eventForm').action = '${pageContext.request.contextPath}/student/dashboard/events/new';
            document.getElementById('eventFormTitle').innerText = 'Sự kiện mới';
            document.getElementById('fEventId').value = '';
            document.getElementById('fTitle').value = '';
            document.getElementById('fEventDate').value = prefillDate ? prefillDate : '';
            document.getElementById('fDescription').value = '';
            document.getElementById('fAddress').value = '';
            document.getElementById('fCourseId').value = '';
            document.querySelector('input[name="durationType"][value="none"]').checked = true;
            document.getElementById('fDurationEnd').value = '';
            document.getElementById('fDurationMinutes').value = '';
            onDurationChange();
            collapseExtra();

            if (typeof tinymce !== 'undefined' && tinymce.get('fDescription')) {
                tinymce.get('fDescription').setContent('');
            }
            document.getElementById('eventModal').classList.add('show');
        }

        function closeEventModal() {
            document.getElementById('eventModal').classList.remove('show');
        }

        function toggleMore() {
            var extra = document.getElementById('extraFields');
            var link = document.getElementById('toggleMoreLink');
            if (extra.style.display === 'block') {
                collapseExtra();
            } else {
                extra.style.display = 'block';
                link.innerText = 'Thu gọn...';
            }
        }

        function collapseExtra() {
            document.getElementById('extraFields').style.display = 'none';
            document.getElementById('toggleMoreLink').innerText = 'Hiển thị thêm...';
        }

        function onDurationChange() {
            var type = document.querySelector('input[name="durationType"]:checked').value;
            var endInput = document.getElementById('fDurationEnd');
            var minInput = document.getElementById('fDurationMinutes');
            endInput.disabled = (type !== 'until');
            minInput.disabled = (type !== 'minutes');
        }

        function handleEventClick(el) {
            var id = el.dataset.id;
            var title = el.dataset.title;
            var date = el.dataset.date;
            var description = el.dataset.description;
            var address = el.dataset.address;
            var durationType = el.dataset.durationType;
            var end = el.dataset.end;
            var durationMinutes = el.dataset.durationMinutes || null;
            var courseId = el.dataset.courseId || null;

            openViewModal(id, title, date, description, address, durationType, end, durationMinutes, courseId);
        }

        function formatEventDate(str) {
            if (!str) return '';
            try {
                var parts = str.split('T');
                var dParts = parts[0].split('-');
                var time = parts[1] || '';
                return time + ' - Ngày ' + dParts[2] + '/' + dParts[1] + '/' + dParts[0];
            } catch(e) {
                return str.replace('T', ' ');
            }
        }

        function openViewModal(id, title, eventDate, description, address, durationType, durationEnd, durationMinutes, courseId) {
            currentViewEvent = {
                id: id, title: title, eventDate: eventDate, description: description,
                address: address, durationType: durationType, durationEnd: durationEnd,
                durationMinutes: durationMinutes, courseId: courseId
            };

            document.getElementById('vTitle').innerText = title;
            document.getElementById('vDate').innerText = formatEventDate(eventDate);

            var courseRow = document.getElementById('vCourseRow');
            if (courseId && courseMap[courseId]) {
                courseRow.style.display = 'flex';
                document.getElementById('vCourse').innerText = courseMap[courseId];
            } else {
                courseRow.style.display = 'none';
            }

            var addrRow = document.getElementById('vAddressRow');
            if (address && address.trim() !== '') {
                addrRow.style.display = 'flex';
                document.getElementById('vAddress').innerText = address;
            } else {
                addrRow.style.display = 'none';
            }

            var descRow = document.getElementById('vDescRow');
            if (description && description.trim() !== '') {
                descRow.style.display = 'block';
                document.getElementById('vDescription').innerHTML = description;
            } else {
                descRow.style.display = 'none';
            }

            document.getElementById('viewModal').classList.add('show');
        }

        function closeViewModal() {
            document.getElementById('viewModal').classList.remove('show');
        }

        function openEditFromView() {
            var ev = currentViewEvent;
            closeViewModal();

            document.getElementById('eventForm').action = '${pageContext.request.contextPath}/student/dashboard/events/edit';
            document.getElementById('eventFormTitle').innerText = 'Chỉnh sửa sự kiện';
            document.getElementById('fEventId').value = ev.id;
            document.getElementById('fTitle').value = ev.title;
            document.getElementById('fEventDate').value = ev.eventDate ? ev.eventDate : '';
            document.getElementById('fDescription').value = ev.description || '';
            if (typeof tinymce !== 'undefined' && tinymce.get('fDescription')) {
                tinymce.get('fDescription').setContent(ev.description || '');
            }
            document.getElementById('fAddress').value = ev.address || '';
            document.getElementById('fCourseId').value = ev.courseId || '';

            var durationRadio = document.querySelector('input[name="durationType"][value="' + (ev.durationType || 'none') + '"]');
            if (durationRadio) durationRadio.checked = true;

            document.getElementById('fDurationEnd').value = ev.durationEnd || '';
            document.getElementById('fDurationMinutes').value = ev.durationMinutes || '';
            onDurationChange();

            document.getElementById('extraFields').style.display = 'block';
            document.getElementById('toggleMoreLink').innerText = 'Thu gọn...';

            document.getElementById('eventModal').classList.add('show');
        }

        function openDeleteConfirm() {
            document.getElementById('dEventId').value = currentViewEvent.id;
            closeViewModal();
            document.getElementById('deleteModal').classList.add('show');
        }

        function closeDeleteConfirm() {
            document.getElementById('deleteModal').classList.remove('show');
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
