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
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=50">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <style>
        .main{max-width:760px;margin:50px auto;padding:0 24px;}
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

        /* Review Section */
        .review-section{margin-top:36px;text-align:left;}
        .review-header-title{font-size:20px;font-weight:700;color:#093C62;margin-bottom:18px;display:flex;align-items:center;gap:10px;}
        .review-card{background:#fff;border-radius:16px;border:1px solid #C6D8E3;box-shadow:0 4px 16px rgba(9,60,98,.06);padding:22px 24px;margin-bottom:18px;}
        .review-q-header{display:flex;align-items:flex-start;gap:12px;margin-bottom:14px;}
        .q-badge{background:#E2EEF5;color:#093C62;padding:4px 10px;border-radius:8px;font-size:13px;font-weight:700;white-space:nowrap;}
        .q-content{font-size:15.5px;font-weight:600;color:#182535;line-height:1.5;}
        .review-options{display:flex;flex-direction:column;gap:8px;margin-bottom:14px;}
        .review-opt{display:flex;align-items:center;gap:12px;padding:10px 14px;border-radius:10px;border:1px solid #E2EEF5;background:#F9FCFD;font-size:14px;transition:all .15s;}
        .review-opt.opt-correct{background:#ECFDF5;border-color:#A7F3D0;color:#065F46;}
        .review-opt.opt-wrong{background:#FEF2F2;border-color:#FECACA;color:#991B1B;}
        .opt-status-icon{width:20px;display:flex;align-items:center;justify-content:center;font-size:15px;}
        .opt-content{flex:1;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px;}
        .badge-chosen{font-size:11.5px;padding:2px 8px;border-radius:6px;background:rgba(9,60,98,.1);color:#093C62;font-weight:600;}
        .badge-correct{font-size:11.5px;padding:2px 8px;border-radius:6px;background:#D1FAE5;color:#065F46;font-weight:600;}
        .review-explanation{background:rgba(7,111,164,.08);border-left:4px solid #076FA4;border-radius:8px;padding:12px 16px;margin-top:12px;}
        .explanation-badge{font-size:13px;font-weight:700;color:#076FA4;margin-bottom:4px;display:flex;align-items:center;gap:6px;}
        .explanation-body{font-size:14px;color:#182535;line-height:1.6;}

        /* Dark Theme (Ô 1: #111312, Ô 2: #182535, Ô 3: #093C62) */
        body.dark-theme .result-card,
        body.dark-theme .review-card{background:#182535;border-color:#093C62;box-shadow:0 8px 32px rgba(0,0,0,.3);}
        body.dark-theme .quiz-name,
        body.dark-theme .review-header-title{color:#F4F8FA;}
        body.dark-theme .q-badge{background:#093C62;color:#F4F8FA;}
        body.dark-theme .q-content{color:#F4F8FA;}
        body.dark-theme .review-opt{background:#111312;border-color:#1c2d42;color:#CBD5E1;}
        body.dark-theme .review-opt.opt-correct{background:#064E3B;border-color:#059669;color:#A7F3D0;}
        body.dark-theme .review-opt.opt-wrong{background:#7F1D1D;border-color:#DC2626;color:#FECACA;}
        body.dark-theme .badge-chosen{background:#093C62;color:#9DB9CB;}
        body.dark-theme .badge-correct{background:#065F46;color:#D1FAE5;}
        body.dark-theme .review-explanation{background:rgba(7,111,164,.15);border-left-color:#38bdf8;}
        body.dark-theme .explanation-badge{color:#38bdf8;}
        body.dark-theme .explanation-body{color:#F4F8FA;}
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
        <% if (currentUser != null) { %>

            <%@ include file="/WEB-INF/views/partials/user-dropdown-style.jspf" %>
            <div class="user-dropdown">
                <div class="user-badge">
                    <% if (currentUser.getAvatarUrl() != null && !currentUser.getAvatarUrl().trim().isEmpty()) { %>
                        <img src="<%=currentUser.getAvatarUrl()%>" alt="Avatar" class="user-avatar" style="object-fit: cover;">
                    <% } else { %>
                        <div class="user-avatar"><%=currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName().substring(0,1).toUpperCase() : "U"%></div>
                    <% } %>
                    <span><%=currentUser.getFullName()%></span>
                    <span class="role-tag"><%=role%></span>
                    <i class="fa-solid fa-chevron-down user-dropdown-chevron"></i>
                </div>
                <div class="user-dropdown-menu" style="display: none;">
                    <% if ("student".equals(role)) { %>
                        <a href="<%=request.getContextPath()%>/dashboard" class="user-dropdown-item">
                            <i class="fa-solid fa-table-columns"></i> Bảng điều khiển
                        </a>
                        <a href="<%=request.getContextPath()%>/student/my-courses" class="user-dropdown-item">
                            <i class="fa-solid fa-book-open"></i> Khóa học của tôi
                        </a>
                    <% } %>
                    <a href="<%=request.getContextPath()%>/courses" class="user-dropdown-item">
                        <i class="fa-solid fa-graduation-cap"></i> Khóa học
                    </a>
                    <a href="<%=request.getContextPath()%>/profile" class="user-dropdown-item">
                        <i class="fa-solid fa-id-badge"></i> Hồ sơ
                    </a>
                    <% if (!"admin".equals(role)) { %>
                        <a href="<%=request.getContextPath()%>/report-issue.jsp" class="user-dropdown-item">
                            <i class="fa-solid fa-triangle-exclamation"></i> Báo cáo
                        </a>
                    <% } %>
                </div>
            </div>
            <% if ("instructor".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/instructor/courses" class="btn btn-outline">Quản lý</a>
            <% } else if ("admin".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/admin" class="btn btn-outline">Quản trị</a>
            <% } %>
            <a href="<%=request.getContextPath()%>/logout" class="btn btn-danger">Đăng xuất</a>
        <% } else { %>
            <a href="<%=request.getContextPath()%>/courses" class="nav-link">Khóa học</a>
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
                        Rất tiếc, bạn chưa đạt điểm yêu cầu (<strong>${quiz.passScore} điểm</strong>). Hãy thử lại nếu còn lượt làm bài!
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
                <span class="value">${attempt.submittedAtFormatted}</span>
            </div>
        </div>

        <%-- Nút hành động --%>
        <div class="result-actions">
            <a href="${pageContext.request.contextPath}/student/quizzes/intro?id=${quiz.id}${not empty param.lessonId ? '&lessonId=' : ''}${param.lessonId}" class="btn-back">← Về trang thông tin Quiz</a>
            <a href="${pageContext.request.contextPath}/student/my-courses" class="btn-retry"><i class="fa-solid fa-book-open"></i> Khóa học của tôi</a>
        </div>
    </div>

    <%-- Phần xem lại câu hỏi & giải thích đáp án --%>
    <c:if test="${not empty questions}">
        <div class="review-section">
            <div class="review-header-title">
                <i class="fa-solid fa-list-check" style="color:#076FA4;"></i> Chi tiết bài làm &amp; Giải thích đáp án
            </div>

            <c:forEach var="q" items="${questions}" varStatus="st">
                <div class="review-card">
                    <div class="review-q-header">
                        <span class="q-badge">Câu ${st.index + 1}</span>
                        <span class="q-content"><c:out value="${q.content}"/></span>
                    </div>

                    <div class="review-options">
                        <c:forEach var="opt" items="${q.options}">
                            <c:set var="isSelected" value="${not empty selectedMap[q.id] and selectedMap[q.id].contains(opt.id)}" />
                            <div class="review-opt ${opt.correct ? 'opt-correct' : ''} ${isSelected && !opt.correct ? 'opt-wrong' : ''}">
                                <div class="opt-status-icon">
                                    <c:choose>
                                        <c:when test="${opt.correct}">
                                            <i class="fa-solid fa-circle-check" style="color:#059669;"></i>
                                        </c:when>
                                        <c:when test="${isSelected && !opt.correct}">
                                            <i class="fa-solid fa-circle-xmark" style="color:#DC2626;"></i>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fa-regular fa-circle" style="color:var(--text-muted);opacity:0.4;"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="opt-content">
                                    <span><c:out value="${opt.content}"/></span>
                                    <div style="display:flex;gap:6px;align-items:center;">
                                        <c:if test="${isSelected}">
                                            <span class="badge-chosen"><i class="fa-solid fa-user-check"></i> Đã chọn</span>
                                        </c:if>
                                        <c:if test="${opt.correct}">
                                            <span class="badge-correct"><i class="fa-solid fa-check"></i> Đáp án đúng</span>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <c:if test="${not empty q.explanation}">
                        <div class="review-explanation">
                            <div class="explanation-badge"><i class="fa-solid fa-lightbulb"></i> Giải thích:</div>
                            <div class="explanation-body"><c:out value="${q.explanation}"/></div>
                        </div>
                    </c:if>
                </div>
            </c:forEach>
        </div>
    </c:if>
</div>

<!-- Dynamic Island Theme Toggle -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=38"></script>

</body>
</html>








