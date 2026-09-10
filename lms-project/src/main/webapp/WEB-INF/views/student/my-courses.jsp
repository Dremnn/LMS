<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khóa học của tôi - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=22">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=22">
    <style>
        .page-header{background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;padding:40px 40px 48px;}
        .page-header h1{font-size:28px;font-weight:800;margin-bottom:6px;}
        .page-header p{opacity:.85;font-size:14px;}
        .main{max-width:1000px;margin:-20px auto 40px;padding:0 24px;}
        .course-card{background:#fff;border-radius:14px;box-shadow:0 4px 16px rgba(0,0,0,.07);overflow:hidden;display:flex;margin-bottom:20px;transition:box-shadow .2s;}
        .course-card:hover{box-shadow:0 8px 28px rgba(0,0,0,.12);}
        .course-thumb{width:220px;flex-shrink:0;overflow:hidden;}
        .course-thumb img{width:100%;height:100%;object-fit:cover;display:block;}
        .course-body{flex:1;padding:22px 26px;display:flex;flex-direction:column;justify-content:space-between;}
        .course-title{font-size:17px;font-weight:700;color:#1a202c;margin-bottom:10px;line-height:1.4;}
        .course-meta{display:flex;align-items:center;gap:16px;font-size:13px;color:#718096;margin-bottom:14px;}
        .badge-status{display:inline-block;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;}
        .badge-inprogress{background:#ebf8ff;color:#2b6cb0;}
        .badge-completed{background:#c6f6d5;color:#22543d;}
        .progress-wrap{margin-bottom:16px;}
        .progress-label{display:flex;justify-content:space-between;font-size:12px;color:#718096;margin-bottom:5px;}
        .progress-bar-bg{background:#e2e8f0;border-radius:10px;height:10px;overflow:hidden;}
        .progress-bar-fill{height:100%;border-radius:10px;background:linear-gradient(90deg,#667eea,#764ba2);transition:width .4s ease;}
        .progress-bar-fill.completed{background:linear-gradient(90deg,#48bb78,#38a169);}
        .course-footer{display:flex;justify-content:space-between;align-items:center;}
        .enrolled-date{font-size:12px;color:#a0aec0;}
        .empty-state{text-align:center;padding:80px 20px;background:#fff;border-radius:14px;box-shadow:0 4px 16px rgba(0,0,0,.06);color:#a0aec0;}
        .empty-state .icon{font-size:60px;margin-bottom:16px;}
        .empty-state p{font-size:16px;margin-bottom:20px;}
    </style>
</head>
<body class="mesh-bg">
<% 
    User currentUser = (User) session.getAttribute("currentUser"); 
    String role = currentUser != null ? currentUser.getRole() : "";
%>
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

<div class="page-header">
    <h1><i class="fa-solid fa-book-open"></i> Khóa học của tôi</h1>
    <p>Theo dõi tiến độ học tập và tiếp tục các khóa học đang dở</p>
</div>

<div class="main">
    <c:choose>
        <c:when test="${not empty enrollments}">
            <c:forEach var="enrollment" items="${enrollments}">
                <div class="course-card">
                    <div class="course-thumb">
                        <c:choose>
                            <c:when test="${not empty enrollment.courseThumbnailUrl}">
                                <img src="${enrollment.courseThumbnailUrl}"
                                     alt="<c:out value='${enrollment.courseTitle}'/>">
                            </c:when>
                            <c:otherwise>
                                <img src="https://via.placeholder.com/220x160/667eea/ffffff?text=LMS"
                                     alt="No Image">
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="course-body">
                        <div>
                            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px;">
                                <h3 class="course-title" style="margin-bottom:0;">
                                    <c:out value="${enrollment.courseTitle}"/>
                                </h3>
                                <c:choose>
                                    <c:when test="${enrollment.status == 'completed'}">
                                        <span class="badge-status badge-completed"><i class="fa-solid fa-circle-check"></i> Đã hoàn thành</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-status badge-inprogress"><i class="fa-solid fa-book-open"></i> Đang học</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="course-meta">
                                <span><i class="fa-solid fa-book-open"></i> ${enrollment.totalLessons} bài học</span>
                            </div>
                            <div class="progress-wrap">
                                <div class="progress-label">
                                    <span>Tiến độ</span>
                                    <span><strong>${enrollment.progressPercent}%</strong></span>
                                </div>
                                <div class="progress-bar-bg">
                                    <div class="progress-bar-fill ${enrollment.status == 'completed' ? 'completed' : ''}"
                                         style="width: ${enrollment.progressPercent}%;"></div>
                                </div>
                            </div>
                        </div>
                        <div class="course-footer">
                            <span class="enrolled-date">
                                📅 Đăng ký: ${enrollment.enrolledAt}
                            </span>
                            <a href="${pageContext.request.contextPath}/courses/detail?id=${enrollment.courseId}"
                               class="btn btn-primary"><i class="fa-solid fa-play"></i> Vào học</a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <div class="icon"><i class="fa-solid fa-inbox"></i></div>
                <p>Bạn chưa đăng ký khóa học nào.</p>
                <a href="${pageContext.request.contextPath}/courses" class="btn btn-primary">
                    <i class="fa-solid fa-rocket"></i> Khám phá khóa học ngay
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>
