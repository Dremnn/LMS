<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khóa học của tôi - UTEdu LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=26">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=26">
    <style>
        .page-header{background:rgba(255,255,255,0.75);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);border-bottom:1px solid rgba(226,232,240,0.8);padding:44px 40px;text-align:center;}
        .page-header h1{font-size:28px;font-weight:800;color:#0F172A;margin-bottom:8px;}
        .page-header p{color:#64748B;font-size:15px;font-weight:500;}
        .main{max-width:1040px;margin:36px auto 60px;padding:0 24px;}

        /* Card khóa học nằm ngang */
        .mycourse-card{
            background:#FFFFFF;
            border-radius:18px;
            border:1px solid #E2E8F0;
            box-shadow:0 4px 20px rgba(0,0,0,.04);
            overflow:hidden;
            display:flex !important;
            flex-direction:row !important;
            align-items:stretch;
            margin-bottom:24px;
            transition:all .25s ease;
        }
        .mycourse-card:hover{
            transform:translateY(-3px);
            box-shadow:0 12px 32px rgba(79,70,229,.12);
            border-color:#C7D2FE;
        }

        /* Thumbnail bên trái */
        .mycourse-thumb{
            width:280px;
            min-width:280px;
            position:relative;
            background:#F1F5F9;
            overflow:hidden;
            display:flex;
            align-items:center;
            justify-content:center;
        }
        .mycourse-thumb img{
            width:100%;
            height:100%;
            object-fit:cover;
            display:block;
            transition:transform .3s ease;
        }
        .mycourse-card:hover .mycourse-thumb img{
            transform:scale(1.04);
        }

        /* Nội dung bên phải */
        .mycourse-body{
            flex:1;
            padding:24px 28px;
            display:flex;
            flex-direction:column;
            justify-content:space-between;
        }
        .mycourse-title{
            font-size:19px;
            font-weight:800;
            color:#0F172A;
            line-height:1.35;
        }
        .mycourse-meta{
            display:flex;
            align-items:center;
            gap:16px;
            font-size:13px;
            color:#64748B;
            margin-top:6px;
            margin-bottom:16px;
            font-weight:500;
        }

        .badge-status{display:inline-flex;align-items:center;gap:6px;padding:5px 12px;border-radius:30px;font-size:12px;font-weight:700;}
        .badge-inprogress{background:#EFF6FF;color:#2563EB;border:1px solid #DBEAFE;}
        .badge-completed{background:#ECFDF5;color:#059669;border:1px solid #D1FAE5;}

        .progress-wrap{margin:12px 0 18px;}
        .progress-label{display:flex;justify-content:space-between;font-size:13px;color:#475569;margin-bottom:6px;font-weight:600;}
        .progress-bar-bg{background:#E2E8F0;border-radius:10px;height:9px;overflow:hidden;}
        .progress-bar-fill{height:100%;border-radius:10px;background:linear-gradient(90deg,#093C62,#076FA4);transition:width .4s ease;}
        .progress-bar-fill.completed{background:linear-gradient(90deg,#10B981,#059669);}

        .course-footer{display:flex;justify-content:space-between;align-items:center;border-top:1px solid #F1F5F9;padding-top:16px;margin-top:auto;}
        .enrolled-date{font-size:12px;color:#94A3B8;font-weight:500;}

        .empty-state{text-align:center;padding:80px 20px;background:#fff;border-radius:18px;border:1px solid #E2E8F0;box-shadow:0 4px 20px rgba(0,0,0,.03);color:#94A3B8;}
        .empty-state .icon{font-size:60px;margin-bottom:16px;color:#CBD5E1;}
        .empty-state p{font-size:16px;margin-bottom:20px;color:#64748B;}

        @media (max-width: 768px) {
            .mycourse-card{flex-direction:column !important;}
            .mycourse-thumb{width:100%;min-width:100%;height:190px;}
            .mycourse-body{padding:20px;}
        }

        /* Dark Theme overrides for My Courses */
        body.dark-theme .page-header {
            background: linear-gradient(135deg, #182535, #093C62) !important;
            border-bottom: 1px solid #093C62 !important;
        }
        body.dark-theme .page-header h1 {
            color: #FFFFFF !important;
        }
        body.dark-theme .page-header p {
            color: #9DB9CB !important;
        }
        body.dark-theme .btn-outline.active,
        body.dark-theme .btn-outline:active {
            background: #093C62 !important;
            border-color: #076FA4 !important;
            color: #FFFFFF !important;
        }
        body.dark-theme .mycourse-card {
            background: #182535 !important;
            border-color: #093C62 !important;
            box-shadow: 0 4px 20px rgba(0,0,0,.35) !important;
        }
        body.dark-theme .mycourse-card:hover {
            border-color: #076FA4 !important;
            box-shadow: 0 12px 32px rgba(7, 111, 164, 0.25) !important;
        }
        body.dark-theme .mycourse-thumb {
            background: #111312 !important;
        }
        body.dark-theme .mycourse-title {
            color: #FFFFFF !important;
        }
        body.dark-theme .mycourse-meta {
            color: #9DB9CB !important;
        }
        body.dark-theme .progress-label {
            color: #9DB9CB !important;
        }
        body.dark-theme .progress-bar-bg {
            background: #111312 !important;
            border: 1px solid #093C62;
        }
        body.dark-theme .course-footer {
            border-top-color: #093C62 !important;
        }
        body.dark-theme .enrolled-date {
            color: #9DB9CB !important;
        }
        body.dark-theme .empty-state {
            background: #182535 !important;
            border-color: #093C62 !important;
            color: #9DB9CB !important;
        }
        body.dark-theme .empty-state p {
            color: #9DB9CB !important;
        }
        body.dark-theme .empty-state .icon {
            color: #093C62 !important;
        }
    </style>
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">
<% 
    User currentUser = (User) session.getAttribute("currentUser"); 
    String role = currentUser != null ? currentUser.getRole() : "";
%>
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
                <a href="<%=request.getContextPath()%>/student/my-courses" class="btn btn-outline active">Của tôi</a>
            <% } %>
            <a href="<%=request.getContextPath()%>/logout" class="btn btn-danger">Đăng xuất</a>
        <% } else { %>
            <a href="<%=request.getContextPath()%>/login" class="btn btn-outline">Đăng nhập</a>
            <a href="<%=request.getContextPath()%>/register" class="btn btn-primary">Đăng ký</a>
        <% } %>
    </div>
</nav>

<div class="page-header">
    <h1><i class="fa-solid fa-book-open" style="color:#076FA4;"></i> Khóa học của tôi</h1>
    <p>Theo dõi tiến độ học tập và tiếp tục các khóa học bạn đã tham gia</p>
</div>

<div class="main">
    <c:set var="defaultThumb" value="${pageContext.request.contextPath}/assets/images/default-course.svg"/>

    <c:choose>
        <c:when test="${not empty enrollments}">
            <c:forEach var="enrollment" items="${enrollments}">
                <div class="mycourse-card">
                    <%-- THUMBNAIL BÊN TRÁI --%>
                    <div class="mycourse-thumb">
                        <img src="${not empty enrollment.courseThumbnailUrl ? enrollment.courseThumbnailUrl : defaultThumb}"
                             alt="<c:out value='${enrollment.courseTitle}'/>"
                             onerror="this.onerror=null;this.src='${defaultThumb}';">
                    </div>

                    <%-- NỘI DUNG BÊN PHẢI --%>
                    <div class="mycourse-body">
                        <div>
                            <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:8px;">
                                <h3 class="mycourse-title">
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

                            <div class="mycourse-meta">
                                <span><i class="fa-solid fa-layer-group" style="color:#076FA4;"></i> ${enrollment.totalLessons} bài học</span>
                            </div>

                            <div class="progress-wrap">
                                <div class="progress-label">
                                    <span>Tiến độ học tập</span>
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
                                <i class="fa-regular fa-calendar-check"></i> Đăng ký: ${enrollment.formattedEnrolledAt}
                            </span>
                            <a href="${pageContext.request.contextPath}/courses/detail?id=${enrollment.courseId}"
                               class="btn btn-primary" style="padding:10px 22px;border-radius:10px;font-weight:700;">
                                <i class="fa-solid fa-play"></i> Vào học
                            </a>
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

<!-- Dynamic Island Theme Toggle (Lưu tùy chọn vào Cookie 365 ngày) -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=26"></script>
</body>
</html>
