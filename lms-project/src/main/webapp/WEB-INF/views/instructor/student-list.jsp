<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String flashError = (String) session.getAttribute("flashError");
    if (flashError != null) session.removeAttribute("flashError");
    String flashSuccess = (String) session.getAttribute("flashSuccess");
    if (flashSuccess != null) session.removeAttribute("flashSuccess");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách Học viên &amp; Tiến độ - ${course.title}</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=50">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <style>
        body { background: #f0f4f8; font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, sans-serif; color: #1e293b; margin: 0; }
        .page-header { padding: 36px 40px; background: linear-gradient(135deg, #093C62, #076FA4); color: #fff; box-shadow: 0 4px 20px rgba(9,60,98,0.15); }
        .page-header h1 { margin: 0 0 8px 0; font-size: 26px; font-weight: 700; display: flex; align-items: center; gap: 12px; }
        .page-header p { margin: 0 0 16px 0; font-size: 15px; opacity: 0.9; }
        .header-nav { display: flex; gap: 14px; flex-wrap: wrap; }
        .header-nav a { color: #bae6fd; text-decoration: none; font-size: 13px; font-weight: 500; display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; background: rgba(255,255,255,0.12); border-radius: 8px; transition: 0.2s; }
        .header-nav a:hover { background: rgba(255,255,255,0.22); color: #fff; }

        .main { max-width: 1240px; margin: 32px auto; padding: 0 24px; }

        /* Stats strip */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 18px; margin-bottom: 24px; }
        .stat-card { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.04); border: 1px solid #e2e8f0; display: flex; align-items: center; gap: 16px; }
        .stat-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 20px; flex-shrink: 0; }
        .stat-val { font-size: 24px; font-weight: 700; color: #0f172a; line-height: 1.2; }
        .stat-label { font-size: 13px; color: #64748b; margin-top: 2px; }

        .card { background: #fff; border-radius: 14px; padding: 24px; box-shadow: 0 2px 12px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; margin-bottom: 24px; }

        /* Search & Filter Toolbar */
        .toolbar { display: flex; justify-content: space-between; align-items: center; gap: 16px; flex-wrap: wrap; margin-bottom: 20px; }
        .search-box { display: flex; align-items: center; gap: 8px; background: #f8fafc; border: 1.5px solid #cbd5e1; border-radius: 8px; padding: 6px 14px; flex: 1; max-width: 380px; }
        .search-box input { border: none; background: transparent; outline: none; width: 100%; font-size: 14px; color: inherit; }
        .filter-buttons { display: flex; gap: 8px; flex-wrap: wrap; }
        .filter-btn { padding: 6px 14px; border-radius: 20px; font-size: 13px; font-weight: 600; border: 1px solid #cbd5e1; background: #fff; color: #64748b; cursor: pointer; transition: 0.2s; }
        .filter-btn:hover, .filter-btn.active { background: #0284c7; color: #fff; border-color: #0284c7; }

        /* Student Table */
        .table-responsive { overflow-x: auto; }
        .student-table { width: 100%; border-collapse: separate; border-spacing: 0; }
        .student-table th { background: #f8fafc; color: #475569; font-size: 13px; font-weight: 700; text-align: left; padding: 14px 16px; border-bottom: 2px solid #e2e8f0; }
        .student-table td { padding: 16px; border-bottom: 1px solid #f1f5f9; font-size: 14px; vertical-align: middle; }
        .student-table tr:hover td { background: #fafafa; }

        .student-info { display: flex; align-items: center; gap: 12px; }
        .student-avatar { width: 38px; height: 38px; border-radius: 50%; background: #0284c7; color: #fff; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 14px; flex-shrink: 0; }
        .student-name { font-weight: 600; color: #0f172a; display: block; }
        .student-email { font-size: 12px; color: #64748b; }

        /* Progress bar */
        .progress-box { width: 150px; }
        .progress-bar-bg { background: #e2e8f0; border-radius: 10px; height: 8px; overflow: hidden; margin-top: 4px; }
        .progress-bar-fill { height: 100%; border-radius: 10px; transition: width 0.3s; }
        .progress-val { font-size: 13px; font-weight: 700; color: #334155; }

        /* Status & Warning badges */
        .badge { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 700; }
        .badge-inprogress { background: #eff6ff; color: #2563eb; }
        .badge-completed { background: #dcfce7; color: #166534; }
        .badge-warning { background: #fed7d7; color: #9b2c2c; }
        .badge-appealed { background: #bee3f8; color: #2a4365; }

        /* Warning box in table cell */
        .warning-box-cell { background: #fffaf0; border: 1px solid #f6ad55; border-radius: 8px; padding: 8px 12px; margin-top: 8px; font-size: 12px; color: #c05621; max-width: 440px; }
        .appeal-box-cell { background: #ebf8ff; border: 1px solid #63b3ed; border-radius: 8px; padding: 8px 12px; margin-top: 6px; font-size: 12px; color: #2a4365; }

        /* Warning Form */
        .warn-form { display: flex; gap: 6px; align-items: center; margin-top: 6px; }
        .warn-input { padding: 6px 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 12px; width: 190px; outline: none; }
        .warn-input:focus { border-color: #ed8936; box-shadow: 0 0 0 2px rgba(237,137,54,0.2); }
        .btn-warn { background: #ed8936; color: #fff; border: none; padding: 6px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; transition: 0.2s; white-space: nowrap; }
        .btn-warn:hover { background: #dd6b20; }
        .btn-clear-warn { background: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; }
        .btn-clear-warn:hover { background: #ef4444; color: #fff; }

        .alert-success { background: #dcfce7; color: #166534; padding: 14px 20px; border-radius: 10px; margin-bottom: 20px; border: 1px solid #bbf7d0; font-size: 14px; font-weight: 500; display: flex; align-items: center; gap: 10px; }
        .alert-danger { background: #fee2e2; color: #991b1b; padding: 14px 20px; border-radius: 10px; margin-bottom: 20px; border: 1px solid #fecaca; font-size: 14px; font-weight: 500; display: flex; align-items: center; gap: 10px; }

        body.dark-theme, [data-theme="dark"] body { background: #0f172a; color: #f8fafc; }
        body.dark-theme .page-header { background: linear-gradient(135deg, #182535, #093C62); }
        body.dark-theme .card, body.dark-theme .stat-card, [data-theme="dark"] .card, [data-theme="dark"] .stat-card { background: #182535; border-color: #093C62; color: #f8fafc; }
        body.dark-theme .stat-val, body.dark-theme .student-name, [data-theme="dark"] .stat-val, [data-theme="dark"] .student-name { color: #f8fafc; }
        body.dark-theme .student-table th, [data-theme="dark"] .student-table th { background: #111312; border-color: #093C62; color: #94a3b8; }
        body.dark-theme .student-table td, [data-theme="dark"] .student-table td { border-color: #093C62; }
        body.dark-theme .student-table tr:hover td, [data-theme="dark"] .student-table tr:hover td { background: #111312; }
        body.dark-theme .search-box, [data-theme="dark"] .search-box { background: #111312; border-color: #093C62; }
        body.dark-theme .filter-btn, [data-theme="dark"] .filter-btn { background: #182535; border-color: #093C62; color: #cbd5e1; }
        body.dark-theme .warn-input, [data-theme="dark"] .warn-input { background: #111312; border-color: #093C62; color: #f8fafc; }
        body.dark-theme .warning-box-cell, [data-theme="dark"] .warning-box-cell { background: rgba(237,137,54,0.15); border-color: #ed8936; color: #fdba74; }
        body.dark-theme .appeal-box-cell, [data-theme="dark"] .appeal-box-cell { background: rgba(59,130,246,0.15); border-color: #3b82f6; color: #93c5fd; }
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
        <a href="<%=request.getContextPath()%>/instructor/courses" class="nav-link">← Danh sách khóa học</a>
        <a href="${pageContext.request.contextPath}/instructor/courses/manage?id=${course.id}" class="nav-link"><i class="fa-solid fa-folder-open"></i> Quản lý nội dung</a>
        <a href="${pageContext.request.contextPath}/instructor/groups?courseId=${course.id}" class="nav-link"><i class="fa-solid fa-people-group"></i> Nhóm học tập</a>
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

<header class="page-header">
    <div style="max-width: 1240px; margin: 0 auto;">
        <h1><i class="fa-solid fa-user-graduate"></i> Danh sách Học viên &amp; Tiến độ học tập</h1>
        <p>Khóa học: <strong><c:out value="${course.title}" /></strong></p>
        <div class="header-nav">
            <a href="${pageContext.request.contextPath}/instructor/courses/manage?id=${course.id}">
                <i class="fa-solid fa-folder-open"></i> Quản lý nội dung khóa học
            </a>
            <a href="${pageContext.request.contextPath}/instructor/groups?courseId=${course.id}">
                <i class="fa-solid fa-people-group"></i> Quản lý Nhóm học tập
            </a>
            <a href="${pageContext.request.contextPath}/instructor/courses">
                <i class="fa-solid fa-list-check"></i> Danh sách khóa học
            </a>
        </div>
    </div>
</header>

<div class="main">
    <c:if test="${not empty flashSuccess}">
        <div class="alert-success"><i class="fa-solid fa-circle-check"></i> ${flashSuccess}</div>
    </c:if>
    <c:if test="${not empty flashError}">
        <div class="alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> ${flashError}</div>
    </c:if>

    <!-- STATS STRIP -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background:#e0f2fe; color:#0284c7;">
                <i class="fa-solid fa-users"></i>
            </div>
            <div>
                <div class="stat-val">${totalStudents}</div>
                <div class="stat-label">Tổng học viên đã ghi danh</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#dcfce7; color:#16a34a;">
                <i class="fa-solid fa-graduation-cap"></i>
            </div>
            <div>
                <div class="stat-val">${completedCount}</div>
                <div class="stat-label">Học viên đã hoàn thành</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#fef3c7; color:#d97706;">
                <i class="fa-solid fa-chart-line"></i>
            </div>
            <div>
                <div class="stat-val">${avgProgress}%</div>
                <div class="stat-label">Tiến độ trung bình</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#fee2e2; color:#dc2626;">
                <i class="fa-solid fa-triangle-exclamation"></i>
            </div>
            <div>
                <div class="stat-val">${warnedCount}</div>
                <div class="stat-label">Học viên đang bị cảnh cáo</div>
            </div>
        </div>
    </div>

    <!-- STUDENT LIST CARD -->
    <div class="card">
        <div class="toolbar">
            <div class="search-box">
                <i class="fa-solid fa-magnifying-glass" style="color:#94a3b8;"></i>
                <input type="text" id="searchInput" placeholder="Tìm kiếm theo họ tên hoặc email..." onkeyup="filterStudents()">
            </div>
            <div class="filter-buttons">
                <button type="button" class="filter-btn active" onclick="setFilter('all', this)">Tất cả (${totalStudents})</button>
                <button type="button" class="filter-btn" onclick="setFilter('in_progress', this)">Đang học</button>
                <button type="button" class="filter-btn" onclick="setFilter('completed', this)">Hoàn thành (${completedCount})</button>
                <button type="button" class="filter-btn" onclick="setFilter('warned', this)" style="color:#dc2626;">Đang bị cảnh cáo (${warnedCount})</button>
            </div>
        </div>

        <c:choose>
            <c:when test="${not empty enrollments}">
                <div class="table-responsive">
                    <table class="student-table" id="studentTable">
                        <thead>
                            <tr>
                                <th>Học viên</th>
                                <th>Nhóm</th>
                                <th>Ngày đăng ký</th>
                                <th>Tiến độ học tập</th>
                                <th>Trạng thái</th>
                                <th style="min-width: 280px;">Cảnh cáo / Phản hồi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="enrollment" items="${enrollments}">
                                <tr class="student-row"
                                    data-name="<c:out value="${enrollment.studentFullName}" />"
                                    data-email="<c:out value="${enrollment.studentEmail}" />"
                                    data-status="${enrollment.status}"
                                    data-warned="${enrollment.warningStatus == 'warning' || enrollment.warningStatus == 'appealed'}">
                                    
                                    <td>
                                        <div class="student-info">
                                            <div class="student-avatar">
                                                <c:choose>
                                                    <c:when test="${not empty enrollment.studentFullName}">
                                                        ${enrollment.studentFullName.substring(0,1).toUpperCase()}
                                                    </c:when>
                                                    <c:otherwise>U</c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div>
                                                <span class="student-name"><c:out value="${enrollment.studentFullName}"/></span>
                                                <span class="student-email"><c:out value="${enrollment.studentEmail}"/></span>
                                            </div>
                                        </div>
                                    </td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty enrollment.groupName}">
                                                <span class="badge" style="background:#e0f2fe; color:#0369a1;">
                                                    <i class="fa-solid fa-people-group"></i> <c:out value="${enrollment.groupName}"/>
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="font-size:12px; color:#94a3b8; font-style:italic;">Chưa vào nhóm</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td style="color:#64748b; font-size:13px;">
                                        ${enrollment.formattedEnrolledAt}
                                    </td>

                                    <td>
                                        <div class="progress-box">
                                            <div style="display:flex; justify-content:space-between; align-items:center;">
                                                <span class="progress-val">${enrollment.progressPercent != null ? enrollment.progressPercent : 0}%</span>
                                                <c:if test="${enrollment.progressPercent >= 100}">
                                                    <i class="fa-solid fa-circle-check" style="color:#10b981; font-size:12px;"></i>
                                                </c:if>
                                            </div>
                                            <div class="progress-bar-bg">
                                                <div class="progress-bar-fill" style="width: ${enrollment.progressPercent != null ? enrollment.progressPercent : 0}%;
                                                     background: ${enrollment.progressPercent >= 100 ? '#10b981' : (enrollment.progressPercent >= 50 ? '#0284c7' : '#f59e0b')};"></div>
                                            </div>
                                        </div>
                                    </td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${enrollment.status == 'completed' || enrollment.progressPercent >= 100}">
                                                <span class="badge badge-completed"><i class="fa-solid fa-circle-check"></i> Đã hoàn thành</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-inprogress"><i class="fa-solid fa-book-open"></i> Đang học</span>
                                            </c:otherwise>
                                        </c:choose>
                                        <c:if test="${enrollment.warningStatus == 'warning'}">
                                            <div style="margin-top:4px;">
                                                <span class="badge badge-warning"><i class="fa-solid fa-triangle-exclamation"></i> Warning</span>
                                            </div>
                                        </c:if>
                                        <c:if test="${enrollment.warningStatus == 'appealed'}">
                                            <div style="margin-top:4px;">
                                                <span class="badge badge-appealed"><i class="fa-solid fa-envelope"></i> Đang kháng cáo</span>
                                            </div>
                                        </c:if>
                                    </td>

                                    <td>
                                        <!-- CẢNH CÁO & PHẢN HỒI SECTION (UI GIỐNG NHƯ ADMIN CẢNH CÁO KHÓA HỌC) -->
                                        <c:choose>
                                            <%-- 1. Đang bị cảnh cáo hoặc đã gửi kháng cáo --%>
                                            <c:when test="${enrollment.warningStatus == 'warning' || enrollment.warningStatus == 'appealed'}">
                                                <div class="warning-box-cell">
                                                    <strong><i class="fa-solid fa-triangle-exclamation"></i> Lý do cảnh cáo:</strong>
                                                    <c:out value="${enrollment.warningMessage}"/>
                                                    <div style="font-size:11px; color:#9a3412; margin-top:2px;">
                                                        Gửi lúc: ${enrollment.formattedWarningAt}
                                                    </div>
                                                </div>

                                                <c:if test="${enrollment.warningStatus == 'appealed' && not empty enrollment.appealMessage}">
                                                    <div class="appeal-box-cell">
                                                        <strong><i class="fa-solid fa-envelope"></i> Học viên phản hồi / kháng cáo:</strong>
                                                        <c:out value="${enrollment.appealMessage}"/>
                                                    </div>
                                                </c:if>

                                                <div style="margin-top:8px; display:flex; gap:8px; align-items:center;">
                                                    <form action="${pageContext.request.contextPath}/instructor/students/remove-warning" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc muốn gỡ cảnh cáo cho học viên này?');">
                                                        <input type="hidden" name="courseId" value="${course.id}">
                                                        <input type="hidden" name="enrollmentId" value="${enrollment.id}">
                                                        <button type="submit" class="btn-clear-warn">
                                                            <i class="fa-solid fa-check"></i> ${enrollment.warningStatus == 'appealed' ? 'Chấp nhận & Gỡ cảnh cáo' : 'Gỡ cảnh cáo'}
                                                        </button>
                                                    </form>
                                                </div>
                                            </c:when>

                                            <%-- 2. Chưa bị cảnh cáo -> Form gửi cảnh cáo --%>
                                            <c:otherwise>
                                                <form action="${pageContext.request.contextPath}/instructor/students/warn" method="post" class="warn-form" onsubmit="return confirm('Xác nhận gửi cảnh cáo đến học viên ${enrollment.studentFullName}?');">
                                                    <input type="hidden" name="courseId" value="${course.id}">
                                                    <input type="hidden" name="enrollmentId" value="${enrollment.id}">
                                                    <input type="text" name="reason" class="warn-input" placeholder="Lý do cảnh cáo tiến độ..." required maxlength="500">
                                                    <button type="submit" class="btn-warn">
                                                        <i class="fa-solid fa-triangle-exclamation"></i> Cảnh cáo
                                                    </button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <div style="text-align:center; padding:48px 24px; color:#94a3b8;">
                    <i class="fa-solid fa-user-xmark" style="font-size:48px; color:#cbd5e1; margin-bottom:16px;"></i>
                    <h3 style="color:#64748b; margin-bottom:8px;">Chưa có học viên nào ghi danh khóa học này</h3>
                    <p style="font-size:14px; max-width:400px; margin:0 auto;">Khi học viên đăng ký tham gia khóa học, thông tin và tiến độ chi tiết sẽ được tự động hiển thị tại đây.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
    let currentFilter = 'all';

    function setFilter(filter, btn) {
        currentFilter = filter;
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        filterStudents();
    }

    function filterStudents() {
        const query = document.getElementById('searchInput').value.toLowerCase().trim();
        const rows = document.querySelectorAll('.student-row');

        rows.forEach(row => {
            const name = (row.getAttribute('data-name') || '').toLowerCase();
            const email = (row.getAttribute('data-email') || '').toLowerCase();
            const status = row.getAttribute('data-status');
            const isWarned = row.getAttribute('data-warned') === 'true';

            const matchQuery = !query || name.includes(query) || email.includes(query);
            let matchFilter = true;

            if (currentFilter === 'in_progress') {
                matchFilter = (status === 'in_progress');
            } else if (currentFilter === 'completed') {
                matchFilter = (status === 'completed');
            } else if (currentFilter === 'warned') {
                matchFilter = isWarned;
            }

            if (matchQuery && matchFilter) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }
</script>

</body>
</html>
