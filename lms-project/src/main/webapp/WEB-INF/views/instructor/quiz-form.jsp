<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo Quiz - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <style>
        .main{max-width:680px;margin:40px auto;padding:0 24px;}
        .page-title{font-size:24px;font-weight:800;color:#093C62;margin-bottom:24px;}
        .card{background:#fff;border-radius:14px;box-shadow:0 4px 16px rgba(9,60,98,.07);padding:32px;border:1px solid #C6D8E3;}
        .alert-danger{background:#fed7d7;color:#822727;border:1px solid #fc8181;padding:12px 16px;border-radius:9px;font-size:14px;margin-bottom:20px;}
        .form-group{margin-bottom:20px;}
        .form-group label{display:block;font-size:14px;font-weight:600;color:#093C62;margin-bottom:7px;}
        .form-group input[type=text],
        .form-group input[type=number]{width:100%;padding:10px 14px;border:1.5px solid #C6D8E3;border-radius:8px;font-size:14px;color:#093C62;outline:none;transition:border-color .2s;}
        .form-group input:focus{border-color:#076FA4;box-shadow:0 0 0 3px rgba(7,111,164,.15);}
        .form-group .hint{font-size:12px;color:#5C7688;margin-top:5px;}
        .radio-group{display:flex;flex-direction:column;gap:10px;margin-top:4px;}
        .radio-option{display:flex;align-items:flex-start;gap:10px;padding:12px 14px;border:1.5px solid #C6D8E3;border-radius:8px;cursor:pointer;transition:border-color .2s;}
        .radio-option:hover{border-color:#076FA4;}
        .radio-option input[type=radio]{margin-top:2px;accent-color:#076FA4;flex-shrink:0;}
        .radio-option-label{font-size:14px;font-weight:600;color:#093C62;}
        .radio-option-sub{font-size:13px;color:#5C7688;margin-top:3px;}
        #sectionIdWrap{margin-top:10px;padding:12px 14px;background:#F0F6FA;border-radius:8px;border:1px solid #C6D8E3;display:none;}
        #sectionIdWrap label{font-size:13px;font-weight:600;color:#093C62;margin-bottom:6px;display:block;}
        #sectionIdWrap input{width:100%;padding:8px 12px;border:1.5px solid #C6D8E3;border-radius:7px;font-size:14px;outline:none;color:#093C62;}
        #sectionIdWrap input:focus{border-color:#076FA4;}
        .form-actions{display:flex;gap:12px;margin-top:28px;}
        .btn-submit{padding:11px 28px;background:linear-gradient(135deg,#093C62,#076FA4);color:#fff;border:none;border-radius:9px;font-size:15px;font-weight:700;cursor:pointer;transition:opacity .2s;}
        .btn-submit:hover{opacity:.9;}

        /* Dark Theme (Ô 1: #111312, Ô 2: #182535, Ô 3: #093C62) */
        body.dark-theme .page-title{color:#F4F8FA;}
        body.dark-theme .card{background:#182535;border-color:#093C62;box-shadow:0 4px 16px rgba(0,0,0,.3);}
        body.dark-theme .form-group label{color:#F4F8FA;}
        body.dark-theme .form-group input[type=text],
        body.dark-theme .form-group input[type=number]{background:#111312;border-color:#093C62;color:#F4F8FA;}
        body.dark-theme .form-group input:focus{border-color:#076FA4;}
        body.dark-theme .form-group .hint{color:#9DB9CB;}
        body.dark-theme .radio-option{background:#182535;border-color:#093C62;}
        body.dark-theme .radio-option:hover{border-color:#076FA4;}
        body.dark-theme .radio-option-label{color:#F4F8FA;}
        body.dark-theme .radio-option-sub{color:#9DB9CB;}
        body.dark-theme #sectionIdWrap{background:#111312;border-color:#093C62;}
        body.dark-theme #sectionIdWrap label{color:#F4F8FA;}
        body.dark-theme #sectionIdWrap input{background:#182535;border-color:#093C62;color:#F4F8FA;}
    </style>
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">
<% User currentUser = (User) session.getAttribute("currentUser");
   String role = currentUser != null ? currentUser.getRole() : ""; %>

<!-- NAVBAR -->
<nav class="lms-navbar">
    <div class="nav-left">
        <a href="<%=request.getContextPath()%>/" class="lms-logo">
        <img src="<%=request.getContextPath()%>/assets/images/utedu-logo.png" alt="UTEdu" class="lms-logo-img" style="height: 36px !important; width: auto; max-height: 36px;">
        <span class="logo-tag">LMS</span>
    </a>
        <% if (currentUser != null) { %>
        <div class="quick-actions">
                        <a href="<%=request.getContextPath()%>/chat" class="quick-action-btn" title="Tin nhắn">
                <i class="fa-solid fa-comment-dots"></i><span class="quick-action-text">Tin nhắn</span>
            </a>
            <a href="<%=request.getContextPath()%>/notifications" class="quick-action-btn" title="Thông báo">
                <i class="fa-solid fa-bell"></i><span class="quick-action-text">Thông báo</span>
            </a>
        </div>
        <% } %>
    </div>
    <div class="nav-links">
        <a href="<%=request.getContextPath()%>/instructor/courses" class="nav-link">← Danh sách khóa học</a>
        <a href="<%=request.getContextPath()%>/courses" class="nav-link">Khóa học</a>
        <% if (currentUser != null) { %>
            <% if ("student".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/dashboard" class="nav-link">Bảng điều khiển</a>
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

<div class="main">
    <div class="page-title">📝 Tạo Quiz mới</div>

    <div class="card">
        <c:if test="${not empty error}">
            <div class="alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> <c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/instructor/quizzes/new" method="post">
            <input type="hidden" name="courseId" value="${courseId}" />

            <div class="form-group">
                <label for="title">Tiêu đề Quiz *</label>
                <input type="text" id="title" name="title" required placeholder="VD: Quiz tổng kết chương 1" />
            </div>

            <div class="form-group">
                <label for="passScore">Điểm đạt (thang 100) *</label>
                <input type="number" id="passScore" name="passScore" min="0" max="100" step="0.01" required placeholder="VD: 70" />
            </div>

            <div class="form-group">
                <label for="maxAttempts">Số lần làm bài tối đa</label>
                <input type="number" id="maxAttempts" name="maxAttempts" min="1" placeholder="Để trống = không giới hạn" />
                <div class="hint">💡 Để trống nếu muốn cho phép làm lại không giới hạn số lần.</div>
            </div>

            <div class="form-group">
                <label for="timeLimitMinutes">Thời gian làm bài (phút)</label>
                <input type="number" id="timeLimitMinutes" name="timeLimitMinutes" min="1" placeholder="Để trống = không giới hạn thời gian" />
                <div class="hint">💡 Học viên sẽ thấy đồng hồ đếm ngược và bài tự động nộp khi hết giờ.</div>
            </div>

            <div class="form-group">
                <label for="openAt">Mở quiz lúc</label>
                <input type="datetime-local" id="openAt" name="openAt" style="width:100%;padding:10px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;color:#2d3748;outline:none;" />
                <div class="hint">💡 Để trống nếu muốn mở ngay khi tạo quiz.</div>
            </div>

            <div class="form-group">
                <label for="closeAt">Đóng quiz lúc</label>
                <input type="datetime-local" id="closeAt" name="closeAt" style="width:100%;padding:10px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;color:#2d3748;outline:none;" />
                <div class="hint">💡 Để trống nếu không muốn tự động đóng quiz.</div>
            </div>

            <div class="form-group">
                <label>Gắn Quiz vào *</label>
                <div class="radio-group">
                    <label class="radio-option">
                        <input type="radio" name="attachType" value="course" checked onchange="toggleSectionInput(this.value)" />
                        <div>
                            <div class="radio-option-label"><i class="fa-solid fa-book-open"></i> Toàn bộ khóa học</div>
                            <div class="radio-option-sub">Quiz tổng kết — xuất hiện sau khi học xong tất cả các chương</div>
                        </div>
                    </label>
                    <label class="radio-option">
                        <input type="radio" name="attachType" value="section" onchange="toggleSectionInput(this.value)" />
                        <div>
                            <div class="radio-option-label"><i class="fa-solid fa-folder-open"></i> Một chương cụ thể</div>
                            <div class="radio-option-sub">Quiz cuối chương — gắn với 1 section nhất định</div>
                        </div>
                    </label>
                </div>
                <div id="sectionIdWrap">
                    <label for="sectionId">Chọn chương muốn gắn</label>
                    <select id="sectionId" name="sectionId" style="width:100%;padding:10px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;color:#2d3748;outline:none;background:#fff;">
                        <option value="">-- Chọn một chương --</option>
                        <c:forEach var="section" items="${course.sectionsCache}">
                            <option value="${section.id}"><c:out value="${section.title}"/></option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn-submit">💾 Tạo Quiz</button>
                <a href="${pageContext.request.contextPath}/instructor/courses/manage?id=${courseId}" class="btn btn-outline">Hủy</a>
            </div>
        </form>
    </div>
</div>

<script>
    function toggleSectionInput(val) {
        var wrap = document.getElementById('sectionIdWrap');
        var input = document.getElementById('sectionId');
        if (val === 'section') {
            wrap.style.display = 'block';
            input.required = true;
        } else {
            wrap.style.display = 'none';
            input.required = false;
            input.value = '';
        }
    }
</script>

<!-- Dynamic Island Theme Toggle -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=30"></script>

</body>
</html>
