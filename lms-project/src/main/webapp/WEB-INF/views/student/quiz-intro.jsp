<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin Quiz - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=26">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=26">
    <style>
        .main{max-width:680px;margin:60px auto;padding:0 24px;}
        .intro-card{background:#fff;border-radius:16px;box-shadow:0 8px 30px rgba(9,60,98,.08);overflow:hidden;border:1px solid #C6D8E3;}
        .intro-header{background:linear-gradient(135deg,#093C62,#076FA4);color:#fff;padding:40px 36px 36px;text-align:center;}
        .intro-course{font-size:13px;color:#9DB9CB;text-transform:uppercase;letter-spacing:1px;font-weight:700;margin-bottom:12px;}
        .intro-title{font-size:28px;font-weight:800;margin-bottom:20px;}
        .intro-body{padding:36px;}
        .info-grid{display:grid;grid-template-columns:repeat(2, 1fr);gap:24px;margin-bottom:32px;}
        .info-box{background:#F0F6FA;border:1px solid #C6D8E3;padding:20px;border-radius:12px;}
        .info-label{font-size:13px;color:#5C7688;font-weight:600;margin-bottom:6px;display:flex;align-items:center;gap:6px;}
        .info-value{font-size:20px;font-weight:800;color:#093C62;}
        .info-value.highlight{color:#076FA4;}
        .status-box{background:#fffff0;border:1px solid #f6e05e;padding:16px 20px;border-radius:12px;margin-bottom:32px;display:flex;align-items:center;gap:12px;}
        .status-icon{font-size:24px;color:#093C62 !important;}
        .status-icon i{color:#093C62 !important;}
        .status-text{font-size:14px;color:#744210;}
        .actions{display:flex;gap:16px;justify-content:center;}
        .btn-start{padding:14px 40px;background:linear-gradient(135deg,#10B981,#059669);color:#fff;border:none;border-radius:10px;font-size:16px;font-weight:800;text-decoration:none;transition:transform .2s,box-shadow .2s;}
        .btn-start:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(16,185,129,.3);}
        .btn-start.disabled{background:#cbd5e0;color:#718096;pointer-events:none;box-shadow:none;}

        /* Dark Theme (Ô 1: #111312, Ô 2: #182535, Ô 3: #093C62) */
        body.dark-theme .intro-card{background:#182535;border-color:#093C62;box-shadow:0 8px 30px rgba(0,0,0,.3);}
        body.dark-theme .intro-header{background:linear-gradient(135deg,#182535,#093C62);}
        body.dark-theme .info-box{background:#111312;border-color:#093C62;}
        body.dark-theme .info-label{color:#9DB9CB;}
        body.dark-theme .info-value{color:#F4F8FA;}
        body.dark-theme .info-value.highlight{color:#076FA4;}
        body.dark-theme .status-icon,
        body.dark-theme .status-icon i{color:#093C62 !important;}
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
        <a href="<%=request.getContextPath()%>/courses/detail?id=${course.id}" class="nav-link">← Chi tiết khóa học</a>
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
    <div class="intro-card">
        <div class="intro-header">
            <div class="intro-course"><c:out value="${course.title}"/></div>
            <div class="intro-title">📝 <c:out value="${quiz.title}"/></div>
        </div>
        
        <div class="intro-body">
            <div class="info-grid">
                <div class="info-box">
                    <div class="info-label"><i class="fa-solid fa-bullseye"></i> Điểm đạt yêu cầu</div>
                    <div class="info-value highlight">${quiz.passScore} / 100</div>
                </div>
                <div class="info-box">
                    <div class="info-label">🔄 Số lần làm bài</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${quiz.maxAttempts != null}">
                                ${attemptsUsed} / ${quiz.maxAttempts}
                            </c:when>
                            <c:otherwise>
                                ${attemptsUsed} / Không giới hạn
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="info-box">
                    <div class="info-label">⏱️ Thời gian làm bài</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${quiz.timeLimitMinutes != null}">${quiz.timeLimitMinutes} phút</c:when>
                            <c:otherwise>Không giới hạn</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <c:if test="${quiz.openAt != null || quiz.closeAt != null}">
                    <div class="info-box">
                        <div class="info-label">🗓️ Thời gian mở/đóng</div>
                        <div class="info-value" style="font-size:15px;">
                            <c:if test="${quiz.openAt != null}">Mở: ${quiz.openAtFormatted}<br/></c:if>
                            <c:if test="${quiz.closeAt != null}">Đóng: ${quiz.closeAtFormatted}</c:if>
                        </div>
                    </div>
                </c:if>
            </div>

            <c:if test="${!quiz.openNow}">
                <div class="status-box" style="background:#fff5f5;border-color:#fc8181;">
                    <div class="status-icon">🚫</div>
                    <div class="status-text">
                        <c:choose>
                            <c:when test="${quiz.notYetOpen}">
                                <strong>Quiz chưa mở.</strong><br>Quiz sẽ mở lúc ${quiz.openAtFormatted}.
                            </c:when>
                            <c:otherwise>
                                <strong>Quiz đã đóng.</strong><br>Quiz đã đóng lúc ${quiz.closeAtFormatted}, không thể làm bài nữa.
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>

            <div class="status-box">
                <c:choose>
                    <c:when test="${attemptsUsed == 0}">
                        <div class="status-icon">🆕</div>
                        <div class="status-text">
                            <strong>Chưa làm bài.</strong><br>
                            Hãy sẵn sàng trước khi bắt đầu. Bạn phải đạt ít nhất ${quiz.passScore} điểm để qua bài kiểm tra này.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="status-icon"><i class="fa-solid fa-chart-line"></i></div>
                        <div class="status-text">
                            <strong>Đã làm bài (${attemptsUsed} lần).</strong><br>
                            Điểm cao nhất của bạn hiện tại là: <strong style="font-size:16px;">${highestScore != null ? highestScore : 0}</strong> / 100.
                            <c:if test="${highestScore >= quiz.passScore}">
                                <span style="color:#276749;font-weight:bold;"> (Đã Đạt <i class="fa-solid fa-circle-check"></i>)</span>
                            </c:if>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="actions">
                <c:choose>
                    <c:when test="${!quiz.openNow}">
                        <a href="#" class="btn-start disabled">🚫 Quiz không khả dụng lúc này</a>
                    </c:when>
                    <c:when test="${quiz.maxAttempts != null && attemptsUsed >= quiz.maxAttempts}">
                        <a href="#" class="btn-start disabled"><i class="fa-solid fa-xmark"></i> Đã hết lượt làm bài</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/student/quizzes/attempt?id=${quiz.id}${not empty param.lessonId ? '&lessonId=' : ''}${param.lessonId}" class="btn-start">
                            ${attemptsUsed == 0 ? '<i class="fa-solid fa-rocket"></i> Bắt đầu làm bài' : '🔄 Làm lại Quiz'}
                        </a>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${not empty param.lessonId}">
                        <a href="${pageContext.request.contextPath}/student/lessons/view?lessonId=${param.lessonId}" class="btn btn-outline" style="padding:14px 24px;font-size:15px;">Quay lại bài học</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/student/my-courses" class="btn btn-outline" style="padding:14px 24px;font-size:15px;">Quay lại khóa học</a>
                    </c:otherwise>
                </c:choose>
            </div>
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
