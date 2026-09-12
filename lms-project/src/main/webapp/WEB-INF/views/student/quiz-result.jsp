<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả Quiz - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=26">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=26">
    <style>
        .main{max-width:620px;margin:50px auto;padding:0 24px;}
        .result-card{background:#fff;border-radius:20px;box-shadow:0 8px 32px rgba(9,60,98,.1);overflow:hidden;text-align:center;border:1px solid #C6D8E3;}
        .result-top{padding:48px 36px 36px;}
        .score-circle{width:160px;height:160px;border-radius:50%;margin:0 auto 24px;display:flex;flex-direction:column;align-items:center;justify-content:center;font-size:48px;font-weight:900;border:8px solid;}
        .score-circle.passed{border-color:#10B981;color:#047857;background:#ECFDF5;}
        .score-circle.failed{border-color:#EF4444;color:#B91C1C;background:#FEF2F2;}
        .score-unit{font-size:16px;font-weight:600;margin-top:2px;}
        .quiz-name{font-size:20px;font-weight:700;color:#093C62;margin-bottom:8px;}
        .alert{padding:14px 20px;border-radius:10px;font-size:15px;font-weight:600;margin:0 36px 28px;}
        .alert-success{background:#ECFDF5;color:#047857;border:1px solid #A7F3D0;}
        .alert-danger-soft{background:#FEF2F2;color:#B91C1C;border:1px solid #FECACA;}
        .result-meta{background:#F0F6FA;padding:20px 36px;display:flex;flex-direction:column;gap:10px;border-top:1px solid #E2EEF5;}
        .meta-row{display:flex;justify-content:space-between;font-size:14px;}
        .meta-row .label{color:#5C7688;}
        .meta-row .value{font-weight:600;color:#093C62;}
        .result-actions{padding:24px 36px;display:flex;gap:12px;justify-content:center;flex-wrap:wrap;}
        .btn-back{padding:11px 24px;background:#E2EEF5;color:#093C62;border:none;border-radius:9px;font-size:14px;font-weight:600;cursor:pointer;transition:background .2s;}
        .btn-back:hover{background:#C6D8E3;}
        .btn-retry{padding:11px 24px;background:linear-gradient(135deg,#093C62,#076FA4);color:#fff;border:none;border-radius:9px;font-size:14px;font-weight:700;text-decoration:none;transition:opacity .2s;}
        .btn-retry:hover{opacity:.9;}

        /* Dark Theme (Ô 1: #111312, Ô 2: #182535, Ô 3: #093C62) */
        body.dark-theme .result-card{background:#182535;border-color:#093C62;box-shadow:0 8px 32px rgba(0,0,0,.3);}
        body.dark-theme .quiz-name{color:#F4F8FA;}
        body.dark-theme .result-meta{background:#111312;border-top-color:#093C62;}
        body.dark-theme .meta-row .label{color:#9DB9CB;}
        body.dark-theme .meta-row .value{color:#F4F8FA;}
        body.dark-theme .btn-back{background:#093C62;color:#F4F8FA;}
        body.dark-theme .btn-back:hover{background:#076FA4;}
    </style>
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">
<% User currentUser = (User) session.getAttribute("currentUser");
   String role = currentUser != null ? currentUser.getRole() : ""; %>

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
                <a href="<%=request.getContextPath()%>/student/dashboard" class="nav-link">Bảng điều khiển</a>
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
    <div class="result-card">
        <div class="result-top">
            <%-- Vòng điểm số --%>
            <div class="score-circle ${attempt.passed ? 'passed' : 'failed'}">
                <div>${attempt.score}</div>
                <div class="score-unit">/ 100</div>
            </div>

            <div class="quiz-name"><c:out value="${quiz.title}"/></div>

            <%-- Thông báo đạt / không đạt --%>
            <c:choose>
                <c:when test="${attempt.passed}">
                    <div class="alert alert-success">🎉 Chúc mừng! Bạn đã ĐẠT bài kiểm tra này.</div>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-danger-soft">
                        😔 Rất tiếc, bạn chưa đạt điểm yêu cầu (<strong>${quiz.passScore} điểm</strong>). Hãy thử lại nếu còn lượt làm bài!
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- Thông tin chi tiết --%>
        <div class="result-meta">
            <div class="meta-row">
                <span class="label"><i class="fa-solid fa-bullseye"></i> Điểm yêu cầu</span>
                <span class="value">${quiz.passScore}/100</span>
            </div>
            <div class="meta-row">
                <span class="label"><i class="fa-solid fa-chart-line"></i> Điểm của bạn</span>
                <span class="value" style="color:${attempt.passed ? '#276749' : '#9b2c2c'};font-size:16px;">${attempt.score}/100</span>
            </div>
            <div class="meta-row">
                <span class="label"><i class="fa-regular fa-clock"></i> Thời gian nộp</span>
                <span class="value">${attempt.submittedAt}</span>
            </div>
        </div>

        <%-- Nút hành động --%>
        <div class="result-actions">
            <a href="${pageContext.request.contextPath}/student/quizzes/intro?id=${quiz.id}${not empty param.lessonId ? '&lessonId=' : ''}${param.lessonId}" class="btn-back">← Về trang thông tin Quiz</a>
            <a href="${pageContext.request.contextPath}/student/my-courses" class="btn-retry"><i class="fa-solid fa-book-open"></i> Khóa học của tôi</a>
        </div>
    </div>
</div>

<!-- Dynamic Island Theme Toggle -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=26"></script>
</body>
</html>
