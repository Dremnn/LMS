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
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=22">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=22">
    <style>
        .main{max-width:580px;margin:60px auto;padding:0 24px;}
        .result-card{background:#fff;border-radius:20px;box-shadow:0 8px 32px rgba(0,0,0,.1);overflow:hidden;text-align:center;}
        .result-top{padding:48px 36px 36px;}
        .score-circle{width:160px;height:160px;border-radius:50%;margin:0 auto 24px;display:flex;flex-direction:column;align-items:center;justify-content:center;font-size:48px;font-weight:900;border:8px solid;}
        .score-circle.passed{border-color:#68d391;color:#276749;background:#f0fff4;}
        .score-circle.failed{border-color:#fc8181;color:#9b2c2c;background:#fff5f5;}
        .score-unit{font-size:16px;font-weight:600;margin-top:2px;}
        .quiz-name{font-size:20px;font-weight:700;color:#1a202c;margin-bottom:8px;}
        .alert{padding:14px 20px;border-radius:10px;font-size:15px;font-weight:600;margin:0 36px 28px;}
        .alert-success{background:#c6f6d5;color:#22543d;border:1px solid #9ae6b4;}
        .alert-danger-soft{background:#fed7d7;color:#822727;border:1px solid #fc8181;}
        .result-meta{background:#f7f8ff;padding:20px 36px;display:flex;flex-direction:column;gap:10px;border-top:1px solid #f0f4f8;}
        .meta-row{display:flex;justify-content:space-between;font-size:14px;}
        .meta-row .label{color:#718096;}
        .meta-row .value{font-weight:600;color:#2d3748;}
        .result-actions{padding:24px 36px;display:flex;gap:12px;justify-content:center;flex-wrap:wrap;}
        .btn-back{padding:11px 24px;background:#edf2f7;color:#4a5568;border:none;border-radius:9px;font-size:14px;font-weight:600;cursor:pointer;transition:background .2s;}
        .btn-back:hover{background:#e2e8f0;}
        .btn-retry{padding:11px 24px;background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;border:none;border-radius:9px;font-size:14px;font-weight:700;text-decoration:none;transition:opacity .2s;}
        .btn-retry:hover{opacity:.9;}
    </style>
</head>
<body class="mesh-bg">
<% User currentUser = (User) session.getAttribute("currentUser");
   String role = currentUser != null ? currentUser.getRole() : ""; %>

<!-- NAVBAR -->
<nav class="lms-navbar">
    <a href="<%=request.getContextPath()%>/" class="lms-logo">
        <span class="logo-icon"><i class="fa-solid fa-graduation-cap"></i></span>
        <span class="logo-text">EduViet <span class="logo-tag">LMS</span></span>
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
</body>
</html>
