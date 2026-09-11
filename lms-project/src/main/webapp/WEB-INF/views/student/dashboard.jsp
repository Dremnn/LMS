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

    // Hàm phụ trợ escape JS string ngay trong scriptlet, tránh lỗi cú pháp khi title có dấu nháy
    java.util.function.Function<String, String> esc = s ->
        s == null ? "" : s.replace("\\", "\\\\").replace("'", "\\'").replace("\n", " ");
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

        .upcoming-item { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 1px solid #eee; }
        .upcoming-item:last-child { border-bottom: none; }
        .upcoming-item a { text-decoration: none; color: #1f2937; font-weight: 500; }
        .upcoming-item .meta { font-size: 12px; color: #888; }
        .no-items { color: #999; text-align: center; padding: 20px; }

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
            width: 600px; /* rộng hơn hẳn, giống ảnh mẫu */
            max-height: 90vh; 
            overflow-y: auto;
        }
        .modal-box h3 { margin-top: 0; } /* Vẫn nên giữ lại dòng này để tiêu đề không bị lệch */

        .modal-box .form-row {
            display: flex; 
            align-items: flex-start; 
            gap: 16px; 
            margin: 14px 0;
        }
        .modal-box .form-row > label {
            width: 140px; 
            flex-shrink: 0; 
            text-align: left; 
            padding-top: 8px;
            font-size: 13px; 
            color: #555; 
            margin: 0;
        }
        .modal-box .form-row .field { flex: 1; }
        .modal-box .form-row input:not([type="radio"]):not([type="hidden"]), 
        .modal-box .form-row select, 
        .modal-box .form-row textarea {
            width: 100%; 
            padding: 8px; 
            border: 1px solid #ccc; 
            border-radius: 6px; 
            box-sizing: border-box;
        }
        
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
    </style>
    <!-- TinyMCE CDN (Phiên bản Open Source không cần API key) -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/tinymce/6.8.3/tinymce.min.js" referrerpolicy="origin"></script>
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
        <% } else { for (Quiz q : upcomingQuizzes) { %>
            <div class="upcoming-item">
                <a href="<%= request.getContextPath() %>/student/quizzes/intro?id=<%= q.getId() %>"><%= q.getTitle() %></a>
                <span class="meta">Hạn: <%= q.getCloseAt() %></span>
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

    <!-- ================= MODAL: TẠO / SỬA SỰ KIỆN ================= -->
    <div class="modal-overlay" id="eventFormModal">
        <div class="modal-box">
            <h3 id="eventFormTitle">Sự kiện mới</h3>
            <form method="post" id="eventForm" action="${pageContext.request.contextPath}/student/dashboard/events/new">
                <input type="hidden" name="eventId" id="fEventId">

                <div class="form-row">
                    <label>Tiêu đề sự kiện *</label>
                    <div class="field">
                        <input type="text" name="title" id="fTitle" required>
                    </div>
                </div>

                <div class="form-row">
                    <label>Ngày *</label>
                    <div class="field">
                        <input type="datetime-local" name="eventDate" id="fEventDate" required>
                    </div>
                </div>

                <div class="form-row">
                    <label></label>
                    <div class="field">
                        <span class="show-more-link" id="toggleMoreLink" onclick="toggleMore()">Show more...</span>
                    </div>
                </div>

                <div class="extra-fields" id="extraFields">
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

                    <div class="form-row">
                        <label>Khoá học (tùy chọn)</label>
                        <div class="field">
                            <select name="courseId" id="fCourseId">
                                <option value="">-- Không gắn khoá học --</option>
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
                                <label style="display:inline;"><input type="radio" name="durationType" value="none" checked onchange="onDurationChange()"> Không xác định thời lượng</label>
                            </div>
                            <div class="duration-option">
                                <label style="display:inline;"><input type="radio" name="durationType" value="until" onchange="onDurationChange()"> Tới</label>
                                <div class="duration-sub">
                                    <input type="datetime-local" name="durationEnd" id="fDurationEnd" disabled>
                                </div>
                            </div>
                            <div class="duration-option">
                                <label style="display:inline;"><input type="radio" name="durationType" value="minutes" onchange="onDurationChange()"> Thời lượng tính bằng phút</label>
                                <div class="duration-sub">
                                    <input type="number" name="durationMinutes" id="fDurationMinutes" min="1" disabled>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn btn-secondary" onclick="closeCreateModal()">Huỷ</button>
                    <button type="submit" class="btn btn-primary">Lưu</button>
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

        // ---------- Modal Tạo/Sửa ----------
        function openCreateModal(prefillDate) {
            document.getElementById('eventForm').action = '${pageContext.request.contextPath}/student/dashboard/events/new';
            document.getElementById('eventFormTitle').innerText = 'Sự kiện mới';
            document.getElementById('fEventId').value = '';
            document.getElementById('fTitle').value = '';
            document.getElementById('fDescription').value = '';
            if (tinymce.get('fDescription')) {
                tinymce.get('fDescription').setContent('');
            }
            document.getElementById('fAddress').value = '';
            document.getElementById('fCourseId').value = '';
            document.querySelector('input[name="durationType"][value="none"]').checked = true;
            document.getElementById('fDurationEnd').value = '';
            document.getElementById('fDurationMinutes').value = '';
            onDurationChange();
            collapseExtra();

            document.getElementById('fEventDate').value = prefillDate ? prefillDate : '';
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
            document.getElementById('fDurationEnd').disabled = (type !== 'until');
            document.getElementById('fDurationMinutes').disabled = (type !== 'minutes');
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
            document.getElementById('fDescription').value = ev.description || '';
            if (tinymce.get('fDescription')) {
                tinymce.get('fDescription').setContent(ev.description || '');
            }
            document.getElementById('fAddress').value = ev.address || '';
            document.getElementById('fCourseId').value = ev.courseId || '';

            document.querySelector('input[name="durationType"][value="' + (ev.durationType || 'none') + '"]').checked = true;
            document.getElementById('fDurationEnd').value = ev.durationEnd || '';
            document.getElementById('fDurationMinutes').value = ev.durationMinutes || '';
            onDurationChange();

            document.getElementById('extraFields').classList.add('show');
            document.getElementById('toggleMoreLink').innerText = 'Show less...';

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

</body>
</html>
