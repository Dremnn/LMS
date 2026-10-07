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
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=50">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <style>
        .page-header {
            padding: 60px 20px 70px !important;
            margin-bottom: -40px !important;
            border-bottom: none !important;
        }
        .main { max-width: 1040px; margin: 0 auto 60px; padding: 0 24px; }
        .result-info { color: var(--text-muted); margin-bottom: 24px; font-size: 15px; text-align: center; font-weight: 500; }

        /* Thanh tìm kiếm bo tròn hiện đại, mượt mà */
        .search-section {
            background: #FFFFFF;
            max-width: 960px;
            margin: 0 auto 36px auto;
            padding: 10px 14px;
            border-radius: 50px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.07), 0 2px 6px rgba(0, 0, 0, 0.04);
            position: relative;
            z-index: 10;
            display: flex;
            gap: 10px;
            border: 1px solid #E2E8F0;
            transition: all 0.3s ease;
        }
        .search-section:focus-within {
            box-shadow: 0 12px 36px rgba(7, 111, 164, 0.16);
            border-color: #076FA4;
        }
        .search-form {
            display: flex;
            align-items: center;
            gap: 10px;
            width: 100%;
        }
        .search-input-wrap {
            flex: 2;
            position: relative;
            display: flex;
            align-items: center;
            min-width: 220px;
        }
        .search-input-wrap .search-icon {
            position: absolute;
            left: 18px;
            color: #94A3B8;
            font-size: 14px;
            pointer-events: none;
            transition: color 0.2s ease;
        }
        .search-input {
            width: 100%;
            padding: 11px 38px 11px 44px;
            border: 1.5px solid #E2E8F0;
            border-radius: 50px;
            font-size: 14px;
            background: #F8FAFC;
            color: #0F172A;
            outline: none;
            transition: all 0.25s ease;
            font-family: inherit;
        }
        .search-input:focus {
            background: #FFFFFF;
            border-color: #076FA4;
            box-shadow: 0 0 0 3px rgba(7, 111, 164, 0.12);
        }
        .search-input-wrap:focus-within .search-icon {
            color: #076FA4;
        }
        .search-select {
            flex: 1;
            min-width: 150px;
            padding: 11px 18px;
            border: 1.5px solid #E2E8F0;
            border-radius: 50px;
            font-size: 14px;
            background: #F8FAFC;
            color: #334155;
            outline: none;
            cursor: pointer;
            transition: all 0.25s ease;
            font-family: inherit;
        }
        .search-select:focus {
            background: #FFFFFF;
            border-color: #076FA4;
            box-shadow: 0 0 0 3px rgba(7, 111, 164, 0.12);
        }
        .btn-search {
            padding: 11px 26px;
            background: linear-gradient(135deg, #093C62, #076FA4);
            color: #FFFFFF;
            border: none;
            border-radius: 50px;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.25s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            white-space: nowrap;
            box-shadow: 0 4px 14px rgba(7, 111, 164, 0.25);
        }
        .btn-search:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(7, 111, 164, 0.35);
            background: linear-gradient(135deg, #076FA4, #0284C7);
        }
        .btn-clear-search {
            position: absolute;
            right: 12px;
            background: #E2E8F0;
            border: none;
            color: #64748B;
            cursor: pointer;
            width: 22px;
            height: 22px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            transition: all 0.2s ease;
        }
        .btn-clear-search:hover {
            background: #FEE2E2;
            color: #EF4444;
        }

        /* Card khóa học nằm ngang */
        .mycourse-card {
            background: #FFFFFF;
            border-radius: 18px;
            border: 1px solid #E2E8F0;
            box-shadow: 0 4px 20px rgba(0,0,0,.04);
            overflow: hidden;
            display: flex !important;
            flex-direction: row !important;
            align-items: stretch;
            margin-bottom: 24px;
            transition: all .25s ease;
        }
        .mycourse-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 32px rgba(79,70,229,.12);
            border-color: #C7D2FE;
        }

        /* Thumbnail bên trái */
        .mycourse-thumb {
            width: 280px;
            min-width: 280px;
            position: relative;
            background: #F1F5F9;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .mycourse-thumb img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
            transition: transform .3s ease;
        }
        .mycourse-card:hover .mycourse-thumb img {
            transform: scale(1.04);
        }

        /* Nội dung bên phải */
        .mycourse-body {
            flex: 1;
            padding: 24px 28px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .mycourse-title {
            font-size: 19px;
            font-weight: 800;
            color: #0F172A;
            line-height: 1.35;
        }
        .mycourse-meta {
            display: flex;
            align-items: center;
            gap: 16px;
            font-size: 13px;
            color: #64748B;
            margin-top: 6px;
            margin-bottom: 16px;
            font-weight: 500;
        }

        .badge-status { display: inline-flex; align-items: center; gap: 6px; padding: 5px 12px; border-radius: 30px; font-size: 12px; font-weight: 700; }
        .badge-inprogress { background: #EFF6FF; color: #2563EB; border: 1px solid #DBEAFE; }
        .badge-completed { background: #ECFDF5; color: #059669; border: 1px solid #D1FAE5; }

        .progress-wrap { margin: 12px 0 18px; }
        .progress-label { display: flex; justify-content: space-between; font-size: 13px; color: #475569; margin-bottom: 6px; font-weight: 600; }
        .progress-bar-bg { background: #E2E8F0; border-radius: 10px; height: 9px; overflow: hidden; }
        .progress-bar-fill { height: 100%; border-radius: 10px; background: linear-gradient(90deg, #093C62, #076FA4); transition: width .4s ease; }
        .progress-bar-fill.completed { background: linear-gradient(90deg, #10B981, #059669); }

        .course-footer { display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #F1F5F9; padding-top: 16px; margin-top: auto; }
        .enrolled-date { font-size: 12px; color: #94A3B8; font-weight: 500; }

        .empty-state { text-align: center; padding: 80px 20px; background: #fff; border-radius: 18px; border: 1px solid #E2E8F0; box-shadow: 0 4px 20px rgba(0,0,0,.03); color: #94A3B8; }
        .empty-state .icon { font-size: 60px; margin-bottom: 16px; color: #CBD5E1; }
        .empty-state p { font-size: 16px; margin-bottom: 20px; color: #64748B; }

        .search-empty-state {
            text-align: center;
            padding: 60px 20px;
            background: #FFFFFF;
            border-radius: 18px;
            border: 1px solid #E2E8F0;
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
            margin-bottom: 24px;
        }
        .search-empty-state .empty-icon {
            font-size: 48px;
            color: #CBD5E1;
            margin-bottom: 16px;
        }
        .search-empty-state h3 {
            font-size: 18px;
            font-weight: 700;
            color: #0F172A;
            margin-bottom: 8px;
        }
        .search-empty-state p {
            color: #64748B;
            font-size: 14px;
            margin-bottom: 16px;
        }

        @media (max-width: 768px) {
            .mycourse-card { flex-direction: column !important; }
            .mycourse-thumb { width: 100%; min-width: 100%; height: 190px; }
            .mycourse-body { padding: 20px; }
            .search-section { border-radius: 24px; padding: 14px; }
            .search-form { flex-direction: column; align-items: stretch; }
            .search-input-wrap { width: 100%; min-width: 100%; }
            .search-select { width: 100%; min-width: 100%; }
            .btn-search { justify-content: center; width: 100%; }
        }

        /* Dark Theme overrides for My Courses */
        body.dark-theme .page-header {
            border-bottom: none !important;
        }
        body.dark-theme .result-info {
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
        body.dark-theme .search-empty-state {
            background: #182535 !important;
            border-color: #093C62 !important;
            color: #9DB9CB !important;
        }
        body.dark-theme .search-empty-state h3 {
            color: #FFFFFF !important;
        }
        body.dark-theme .search-empty-state p {
            color: #9DB9CB !important;
        }
        body.dark-theme .search-empty-state .empty-icon {
            color: #076FA4 !important;
        }
        body.dark-theme .search-section {
            background: #182535 !important;
            border-color: #093C62 !important;
            box-shadow: 0 10px 32px rgba(0, 0, 0, 0.45);
        }
        body.dark-theme .search-section:focus-within {
            box-shadow: 0 12px 36px rgba(7, 111, 164, 0.35);
            border-color: #076FA4 !important;
        }
        body.dark-theme .search-input {
            background: #111312 !important;
            border-color: #093C62 !important;
            color: #FFFFFF !important;
        }
        body.dark-theme .search-input:focus {
            background: #182535 !important;
            border-color: #076FA4 !important;
            box-shadow: 0 0 0 3px rgba(7, 111, 164, 0.25) !important;
        }
        body.dark-theme .search-select {
            background: #111312 !important;
            border-color: #093C62 !important;
            color: #F4F8FA !important;
        }
        body.dark-theme .search-select:focus {
            background: #182535 !important;
            border-color: #076FA4 !important;
            box-shadow: 0 0 0 3px rgba(7, 111, 164, 0.25) !important;
        }
        body.dark-theme .search-input-wrap .search-icon {
            color: #9DB9CB !important;
        }
        body.dark-theme .search-input-wrap:focus-within .search-icon {
            color: #38BDF8 !important;
        }
        body.dark-theme .btn-clear-search {
            background: #093C62 !important;
            color: #9DB9CB !important;
        }
        body.dark-theme .btn-clear-search:hover {
            background: rgba(239, 68, 68, 0.25) !important;
            color: #F87171 !important;
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
                        <a href="<%= "student".equals(role) ? (request.getContextPath() + "/wallet/topup") : (request.getContextPath() + "/profile") %>" class="wallet-badge" title="Số dư ví - Bấm để nạp tiền/quản lý ví">
                <i class="fa-solid fa-wallet"></i>
                <span><%= (currentUser.getBalance() != null ? String.format(java.util.Locale.US, "%,dđ", currentUser.getBalance().longValue()) : "0đ") %></span>
            </a>
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
                    <a href="<%= "student".equals(role) ? (request.getContextPath() + "/wallet/topup") : (request.getContextPath() + "/profile") %>" class="user-dropdown-item wallet-dropdown-item">
                        <i class="fa-solid fa-wallet"></i>
                        <span>Ví cá nhân</span>
                        <strong class="wallet-dropdown-balance"><%= (currentUser.getBalance() != null ? String.format(java.util.Locale.US, "%,dđ", currentUser.getBalance().longValue()) : "0đ") %></strong>
                    </a>
                    <% if ("student".equals(role)) { %>
                        <a href="${pageContext.request.contextPath}/dashboard" class="user-dropdown-item">
                            <i class="fa-solid fa-table-columns"></i> Bảng điều khiển
                        </a>
                        <a href="${pageContext.request.contextPath}/student/my-courses" class="user-dropdown-item">
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

<!-- PAGE HEADER -->
<div class="page-header">
    <div class="page-header-inner">
        <div>
            <h1><i class="fa-solid fa-book-open"></i> Khóa học của tôi</h1>
            <p>Theo dõi tiến độ học tập và tiếp tục các khóa học bạn đã tham gia</p>
        </div>
    </div>
</div>

<!-- SEARCH SECTION BO TRÒN HIỆN ĐẠI -->
<div class="search-section">
    <form class="search-form" id="myCoursesSearchForm" onsubmit="return false;">
        <div class="search-input-wrap">
            <i class="fa-solid fa-magnifying-glass search-icon"></i>
            <input type="text" id="courseSearchInput" class="search-input" 
                   placeholder="Tìm kiếm khóa học theo tên..." autocomplete="off">
            <button type="button" id="clearSearchBtn" class="btn-clear-search" title="Xóa tìm kiếm" style="display: none;">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <select id="statusFilterSelect" class="search-select">
            <option value="all">Tất cả trạng thái</option>
            <option value="inprogress">Đang học</option>
            <option value="completed">Đã hoàn thành</option>
        </select>
        <select id="sortFilterSelect" class="search-select">
            <option value="default">Sắp xếp: Mới nhất</option>
            <option value="progress-desc">Tiến độ: Cao đến thấp</option>
            <option value="progress-asc">Tiến độ: Thấp đến cao</option>
            <option value="title-asc">Tên: A - Z</option>
            <option value="title-desc">Tên: Z - A</option>
        </select>
        <button type="button" class="btn-search" id="myCoursesSearchBtn">
            <i class="fa-solid fa-magnifying-glass"></i> Tìm kiếm
        </button>
    </form>
</div>

<!-- MAIN -->
<div class="main">
    <c:if test="${not empty error}">
        <div class="alert alert-danger" style="margin-bottom:20px;"><i class="fa-solid fa-triangle-exclamation"></i> <span>${error}</span></div>
    </c:if>
    <c:if test="${not empty success}">
        <div class="alert alert-success" style="margin-bottom:20px;"><i class="fa-solid fa-circle-check"></i> <span>${success}</span></div>
    </c:if>
    <c:set var="defaultThumb" value="${pageContext.request.contextPath}/assets/images/default-course.svg"/>

    <p class="result-info" id="courseResultInfo">
        <c:choose>
            <c:when test="${not empty enrollments}">Tìm thấy <strong>${enrollments.size()}</strong> khóa học</c:when>
            <c:otherwise>Không có khóa học nào</c:otherwise>
        </c:choose>
    </p>

    <!-- EMPTY SEARCH RESULTS STATE -->
    <div id="noSearchResults" class="search-empty-state" style="display:none;">
        <div class="empty-icon"><i class="fa-solid fa-magnifying-glass"></i></div>
        <h3>Không tìm thấy khóa học phù hợp</h3>
        <p>Không có khóa học nào khớp với điều kiện tìm kiếm.</p>
        <button type="button" class="btn btn-outline" id="resetSearchBtn" style="padding:9px 20px;border-radius:10px;font-weight:600;">
            <i class="fa-solid fa-rotate-left"></i> Xóa bộ lọc
        </button>
    </div>

    <c:choose>
        <c:when test="${not empty enrollments}">
            <div id="coursesContainer">
                <c:forEach var="enrollment" items="${enrollments}" varStatus="vs">
                    <div class="mycourse-card" 
                         data-title="<c:out value='${enrollment.courseTitle}'/>" 
                         data-status="${enrollment.status}"
                         data-progress="${enrollment.progressPercent}"
                         data-index="${vs.index}">
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
                            <span style="display:flex;gap:8px;flex-wrap:wrap;">
                                <a href="${pageContext.request.contextPath}/student/assignments?courseId=${enrollment.courseId}"
                                   class="btn btn-outline" style="padding:10px 18px;border-radius:10px;font-weight:700;">
                                    <i class="fa-solid fa-paperclip"></i> Bài tập
                                </a>
                                <a href="${pageContext.request.contextPath}/courses/detail?id=${enrollment.courseId}"
                                   class="btn btn-primary" style="padding:10px 22px;border-radius:10px;font-weight:700;">
                                    <i class="fa-solid fa-play"></i> Vào học
                                </a>
                            </span>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
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

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=38"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    var searchInput = document.getElementById('courseSearchInput');
    var clearBtn = document.getElementById('clearSearchBtn');
    var statusSelect = document.getElementById('statusFilterSelect');
    var sortSelect = document.getElementById('sortFilterSelect');
    var searchBtn = document.getElementById('myCoursesSearchBtn');
    var resetBtn = document.getElementById('resetSearchBtn');
    var noResults = document.getElementById('noSearchResults');
    var resultInfo = document.getElementById('courseResultInfo');
    var container = document.getElementById('coursesContainer');
    var cards = container ? Array.from(container.querySelectorAll('.mycourse-card')) : [];

    if (!cards.length) return;

    function removeVietnameseTones(str) {
        if (!str) return '';
        str = str.toLowerCase();
        str = str.replace(/à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ/g, "a");
        str = str.replace(/è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ/g, "e");
        str = str.replace(/ì|í|ị|ỉ|ĩ/g, "i");
        str = str.replace(/ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ/g, "o");
        str = str.replace(/ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ/g, "u");
        str = str.replace(/ỳ|ý|ỵ|ỷ|ỹ/g, "y");
        str = str.replace(/đ/g, "d");
        str = str.replace(/\u0300|\u0301|\u0303|\u0309|\u0323/g, "");
        str = str.replace(/\u02C6|\u0306|\u031B/g, "");
        return str.trim();
    }

    function escapeHtml(text) {
        var div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    function filterAndSortCourses() {
        var query = searchInput ? searchInput.value.trim() : '';
        var normQuery = removeVietnameseTones(query);
        var statusFilter = statusSelect ? statusSelect.value : 'all';
        var sortBy = sortSelect ? sortSelect.value : 'default';

        if (clearBtn) {
            clearBtn.style.display = query.length > 0 ? 'inline-block' : 'none';
        }

        var visibleCount = 0;

        // Lọc hiển thị
        cards.forEach(function(card) {
            var rawTitle = card.getAttribute('data-title') || '';
            var normTitle = removeVietnameseTones(rawTitle);
            var status = card.getAttribute('data-status') || '';

            var matchQuery = (normQuery === '') || (normTitle.indexOf(normQuery) !== -1);
            var matchStatus = (statusFilter === 'all') || 
                (statusFilter === 'completed' && status === 'completed') || 
                (statusFilter === 'inprogress' && status !== 'completed');

            if (matchQuery && matchStatus) {
                card.style.display = 'flex';
                visibleCount++;
            } else {
                card.style.display = 'none';
            }
        });

        // Sắp xếp các card
        var sortedCards = cards.slice().sort(function(a, b) {
            if (sortBy === 'progress-desc') {
                return (parseFloat(b.getAttribute('data-progress')) || 0) - (parseFloat(a.getAttribute('data-progress')) || 0);
            } else if (sortBy === 'progress-asc') {
                return (parseFloat(a.getAttribute('data-progress')) || 0) - (parseFloat(b.getAttribute('data-progress')) || 0);
            } else if (sortBy === 'title-asc') {
                return (a.getAttribute('data-title') || '').localeCompare(b.getAttribute('data-title') || '', 'vi');
            } else if (sortBy === 'title-desc') {
                return (b.getAttribute('data-title') || '').localeCompare(a.getAttribute('data-title') || '', 'vi');
            } else {
                return (parseInt(a.getAttribute('data-index')) || 0) - (parseInt(b.getAttribute('data-index')) || 0);
            }
        });

        sortedCards.forEach(function(c) {
            container.appendChild(c);
        });

        // Cập nhật thông báo số lượng kết quả
        if (resultInfo) {
            if (visibleCount === 0) {
                resultInfo.textContent = 'Không có kết quả nào';
            } else if (query.length > 0 || statusFilter !== 'all') {
                resultInfo.innerHTML = 'Tìm thấy <strong>' + visibleCount + '</strong> khóa học' + 
                    (query.length > 0 ? ' với từ khóa "<strong>' + escapeHtml(query) + '</strong>"' : '');
            } else {
                resultInfo.innerHTML = 'Tìm thấy <strong>' + visibleCount + '</strong> khóa học';
            }
        }

        // Trạng thái trống nếu không có kết quả
        if (visibleCount === 0) {
            if (noResults) noResults.style.display = 'block';
        } else {
            if (noResults) noResults.style.display = 'none';
        }
    }

    if (searchInput) {
        searchInput.addEventListener('input', filterAndSortCourses);
        searchInput.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                searchInput.value = '';
                filterAndSortCourses();
            } else if (e.key === 'Enter') {
                e.preventDefault();
                filterAndSortCourses();
            }
        });
    }

    if (statusSelect) {
        statusSelect.addEventListener('change', filterAndSortCourses);
    }

    if (sortSelect) {
        sortSelect.addEventListener('change', filterAndSortCourses);
    }

    if (searchBtn) {
        searchBtn.addEventListener('click', function(e) {
            e.preventDefault();
            filterAndSortCourses();
        });
    }

    if (clearBtn) {
        clearBtn.addEventListener('click', function() {
            if (searchInput) {
                searchInput.value = '';
                searchInput.focus();
            }
            filterAndSortCourses();
        });
    }

    if (resetBtn) {
        resetBtn.addEventListener('click', function() {
            if (searchInput) searchInput.value = '';
            if (statusSelect) statusSelect.value = 'all';
            if (sortSelect) sortSelect.value = 'default';
            if (searchInput) searchInput.focus();
            filterAndSortCourses();
        });
    }
});
</script>
</body>
</html>








