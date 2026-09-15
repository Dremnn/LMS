<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${quiz.title} - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <style>
        .hero{background:linear-gradient(135deg,#093C62,#076FA4);color:#fff;padding:40px 36px 48px;}
        .hero-inner{max-width:780px;margin:0 auto;}
        .quiz-title{font-size:26px;font-weight:800;margin-bottom:10px;}
        .quiz-meta{display:flex;gap:24px;font-size:14px;opacity:.85;}
        .main{max-width:780px;margin:-16px auto 48px;padding:0 24px;}
        .alert-danger{background:#fed7d7;color:#822727;border:1px solid #fc8181;padding:12px 16px;border-radius:9px;font-size:14px;margin-bottom:20px;}
        .question-card{background:#fff;border-radius:14px;box-shadow:0 4px 14px rgba(9,60,98,.07);margin-bottom:20px;overflow:hidden;border:1px solid #C6D8E3;}
        .question-header{padding:18px 24px 14px;border-bottom:1px solid #E2EEF5;}
        .question-num{font-size:11px;font-weight:700;color:#5C7688;text-transform:uppercase;margin-bottom:6px;}
        .question-content{font-size:16px;font-weight:600;color:#093C62;line-height:1.55;}
        .question-type-badge{display:inline-block;margin-top:8px;padding:2px 10px;border-radius:20px;font-size:11px;font-weight:700;background:#E2EEF5;color:#093C62;}
        .options-list{padding:16px 24px;display:flex;flex-direction:column;gap:10px;}
        .option-label{display:flex;align-items:center;gap:12px;padding:11px 16px;border:1.5px solid #C6D8E3;border-radius:9px;cursor:pointer;transition:all .15s;font-size:14px;color:#093C62;}
        .option-label:hover{border-color:#076FA4;background:#E2EEF5;}
        .option-label input[type=radio]{accent-color:#076FA4;width:16px;height:16px;flex-shrink:0;}
        .option-label input[type=checkbox]{accent-color:#076FA4;width:16px;height:16px;flex-shrink:0;}
        .submit-bar{background:#fff;border:1px solid #C6D8E3;padding:20px 24px;display:flex;align-items:center;justify-content:space-between;border-radius:14px;box-shadow:0 4px 14px rgba(9,60,98,.07);margin-top:8px;}
        .submit-bar-info{font-size:14px;color:#5C7688;}
        .btn-submit{padding:13px 36px;background:linear-gradient(135deg,#093C62,#076FA4);color:#fff;border:none;border-radius:10px;font-size:16px;font-weight:700;cursor:pointer;transition:opacity .2s;}
        .btn-submit:hover{opacity:.9;}

        /* Dark Theme (Ô 1: #111312, Ô 2: #182535, Ô 3: #093C62) */
        body.dark-theme .hero{background:linear-gradient(135deg,#182535,#093C62);}
        body.dark-theme .question-card{background:#182535;border-color:#093C62;box-shadow:0 4px 14px rgba(0,0,0,.3);}
        body.dark-theme .question-header{border-bottom-color:#093C62;}
        body.dark-theme .question-content{color:#F4F8FA;}
        body.dark-theme .question-num{color:#9DB9CB;}
        body.dark-theme .question-type-badge{background:#093C62;color:#F4F8FA;}
        body.dark-theme .option-label{border-color:#093C62;background:#111312;color:#9DB9CB;}
        body.dark-theme .option-label:hover{border-color:#076FA4;background:#182535;color:#F4F8FA;}
        body.dark-theme .submit-bar{background:#182535;border-color:#093C62;box-shadow:0 4px 14px rgba(0,0,0,.3);}
        body.dark-theme .submit-bar-info{color:#9DB9CB;}
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
                        <a href="<%=request.getContextPath()%>/student/chat" class="quick-action-btn" title="Tin nhắn">
                <i class="fa-solid fa-comment-dots"></i><span class="quick-action-text">Tin nhắn</span>
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

<div class="hero">
    <div class="hero-inner">
        <div class="quiz-title">📝 <c:out value="${quiz.title}"/></div>
        <div class="quiz-meta">
            <span><i class="fa-solid fa-bullseye"></i> Điểm đạt yêu cầu: <strong>${quiz.passScore}/100</strong></span>
            <span>
                🔄 Số lần làm:
                <c:choose>
                    <c:when test="${quiz.maxAttempts != null}"><strong>${quiz.maxAttempts}</strong></c:when>
                    <c:otherwise><strong>Không giới hạn</strong></c:otherwise>
                </c:choose>
            </span>
            <span><i class="fa-solid fa-chart-line"></i> Số câu hỏi: <strong>${questions.size()}</strong></span>
            <c:if test="${remainingSeconds != null}">
                <span>⏱️ Thời gian còn lại: <strong id="countdown" style="color:#fc8181;">--:--</strong></span>
            </c:if>
        </div>
    </div>
</div>

<div class="main">
    <c:if test="${not empty error}">
        <div class="alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> <c:out value="${error}"/></div>
    </c:if>

    <form id="quizForm" action="${pageContext.request.contextPath}/student/quizzes/submit" method="post"
          onsubmit="return window.autoSubmitting || confirm('Bạn chắc chắn muốn nộp bài? Sau khi nộp sẽ không thể thay đổi.')">
        <input type="hidden" name="quizId" value="${quiz.id}" />
        <c:if test="${not empty param.lessonId}">
            <input type="hidden" name="lessonId" value="${param.lessonId}" />
        </c:if>

        <c:forEach var="question" items="${questions}" varStatus="status">
            <div class="question-card">
                <div class="question-header">
                    <div class="question-num">Câu ${status.index + 1} / ${questions.size()}</div>
                    <div class="question-content"><c:out value="${question.content}"/></div>
                    <span class="question-type-badge">
                        <c:choose>
                            <c:when test="${question.questionType == 'single_choice'}">Chọn 1 đáp án</c:when>
                            <c:otherwise>Chọn nhiều đáp án</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="options-list">
                    <c:forEach var="option" items="${question.options}">
                        <label class="option-label">
                            <c:choose>
                                <c:when test="${question.questionType == 'single_choice'}">
                                    <input type="radio" name="answer_${question.id}" value="${option.id}" />
                                </c:when>
                                <c:otherwise>
                                    <input type="checkbox" name="answer_${question.id}" value="${option.id}" />
                                </c:otherwise>
                            </c:choose>
                            <c:out value="${option.content}"/>
                        </label>
                    </c:forEach>
                </div>
            </div>
        </c:forEach>

        <div class="submit-bar">
            <div class="submit-bar-info">
                📋 Tổng <strong>${questions.size()}</strong> câu hỏi · Điểm đạt: <strong>${quiz.passScore}/100</strong>
            </div>
            <button type="submit" class="btn-submit"><i class="fa-solid fa-rocket"></i> Nộp bài</button>
        </div>
    </form>
</div>

<c:if test="${remainingSeconds != null}">
<script>
    // remainingSeconds được server tính sẵn (dựa trên mốc bắt đầu lưu trong session),
    // nên F5 lại trang không làm reset đồng hồ đếm ngược.
    (function () {
        var remaining = parseInt("${remainingSeconds}", 10) || 0;
        var countdownEl = document.getElementById('countdown');
        window.autoSubmitting = false;

        function render() {
            var m = Math.floor(remaining / 60);
            var s = remaining % 60;
            countdownEl.textContent = (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
            if (remaining <= 60) {
                countdownEl.style.color = '#e53e3e';
            }
        }

        render();

        var timer = setInterval(function () {
            remaining--;
            if (remaining <= 0) {
                remaining = 0;
                render();
                clearInterval(timer);
                window.autoSubmitting = true;
                alert('Đã hết thời gian làm bài! Hệ thống sẽ tự động nộp bài của bạn.');
                document.getElementById('quizForm').submit();
                return;
            }
            render();
        }, 1000);
    })();
</script>
</c:if>

<!-- Dynamic Island Theme Toggle -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=30"></script>

</body>
</html>
