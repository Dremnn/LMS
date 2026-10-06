<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ page import="com.lms.model.IssueReport" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tiếp nhận & Xử lý sự cố - Admin LMS</title>

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">

    <style>
        /* PAGE HEADER */
        .page-header{background:linear-gradient(135deg,#093C62,#076FA4);color:#fff;padding:36px 36px 44px;}
        .page-header h1{font-size:26px;font-weight:800;margin-bottom:6px;display:flex;align-items:center;gap:12px;}
        .page-header p{opacity:.85;font-size:14px;margin-bottom:20px;}

        /* ADMIN SUB-NAV TABS */
        .admin-nav-tabs{display:flex;gap:12px;border-bottom:1px solid rgba(255,255,255,.2);padding-bottom:1px;}
        .admin-tab{padding:10px 20px;border-radius:10px 10px 0 0;font-size:14px;font-weight:700;color:rgba(255,255,255,.8);text-decoration:none;display:inline-flex;align-items:center;gap:8px;transition:all .2s;}
        .admin-tab:hover{color:#fff;background:rgba(255,255,255,.1);}
        .admin-tab.active{color:#093C62;background:#F4F8FA;}

        /* MAIN */
        .main{max-width:1160px;margin:-16px auto 48px;padding:0 24px;}

        /* ALERTS */
        .alert{padding:13px 18px;border-radius:10px;font-size:14px;margin-bottom:20px;display:flex;align-items:center;gap:10px;}
        .alert-success{background:#c6f6d5;color:#22543d;border:1px solid #9ae6b4;}
        .alert-danger{background:#fed7d7;color:#822727;border:1px solid #fc8181;}

        /* STATS CARDS */
        .stats-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:24px;}
        .stat-card{background:#fff;border-radius:14px;padding:20px 22px;border:1px solid #C6D8E3;box-shadow:0 4px 14px rgba(9,60,98,.06);display:flex;align-items:center;gap:18px;transition:transform .2s;}
        .stat-card:hover{transform:translateY(-2px);}
        .stat-icon{width:50px;height:50px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:22px;flex-shrink:0;}
        .stat-icon.total{background:rgba(7,111,164,.12);color:#076FA4;}
        .stat-icon.pending{background:rgba(245,158,11,.14);color:#D97706;}
        .stat-icon.resolved{background:rgba(16,185,129,.14);color:#059669;}
        .stat-icon.rejected{background:rgba(239,68,68,.14);color:#DC2626;}
        .stat-info .num{font-size:24px;font-weight:800;color:#093C62;line-height:1.2;}
        .stat-info .lbl{font-size:13px;color:#5C7688;font-weight:600;}

        /* FILTER BAR */
        .filter-panel{background:#fff;border-radius:14px;padding:18px 24px;border:1px solid #C6D8E3;box-shadow:0 4px 14px rgba(9,60,98,.05);margin-bottom:24px;}
        .filter-form{display:flex;flex-wrap:wrap;gap:14px;align-items:center;justify-content:space-between;}
        .filter-left{display:flex;flex-wrap:wrap;gap:10px;align-items:center;}
        .filter-chip{padding:7px 16px;border-radius:30px;font-size:13px;font-weight:700;color:#5C7688;background:#F0F6FA;border:1px solid #C6D8E3;text-decoration:none;transition:all .2s;}
        .filter-chip:hover{border-color:#076FA4;color:#076FA4;}
        .filter-chip.active{background:#076FA4;color:#fff;border-color:#076FA4;}
        .filter-select{padding:8px 12px;border:1.5px solid #C6D8E3;border-radius:8px;font-size:13px;color:#093C62;background:#fff;font-family:inherit;}
        .search-box{display:flex;gap:8px;align-items:center;}
        .search-input{padding:8px 14px;border:1.5px solid #C6D8E3;border-radius:8px;font-size:13px;color:#093C62;width:240px;outline:none;}
        .search-input:focus{border-color:#076FA4;}
        .btn-search{padding:8px 16px;background:#076FA4;color:#fff;border:none;border-radius:8px;font-size:13px;font-weight:700;cursor:pointer;}
        .btn-search:hover{background:#093C62;}

        /* ISSUE CARDS */
        .issue-card{background:#fff;border-radius:14px;border:1px solid #C6D8E3;box-shadow:0 4px 16px rgba(9,60,98,.06);margin-bottom:20px;overflow:hidden;transition:all .2s;}
        .issue-card.status-pending{border-left:5px solid #F59E0B;}
        .issue-card.status-resolved{border-left:5px solid #10B981;}
        .issue-card.status-rejected{border-left:5px solid #EF4444;}

        .issue-header{padding:18px 24px 14px;border-bottom:1px solid #E2EEF5;display:flex;justify-content:space-between;align-items:flex-start;gap:16px;}
        .issue-title-row{display:flex;align-items:center;gap:10px;flex-wrap:wrap;margin-bottom:8px;}
        .issue-ref{font-size:15px;font-weight:800;color:#093C62;font-family:monospace;letter-spacing:0.5px;}
        .badge-role{display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;}
        .badge-student{background:#EFF6FF;color:#1D4ED8;border:1px solid #BFDBFE;}
        .badge-instructor{background:#FEF3C7;color:#B45309;border:1px solid #FDE68A;}

        .badge-type{display:inline-flex;align-items:center;gap:5px;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;background:#F0F6FA;color:#076FA4;border:1px solid #C6D8E3;}

        .badge-status{display:inline-flex;align-items:center;gap:6px;padding:6px 14px;border-radius:20px;font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;}
        .badge-pending{background:#FFFBEB;color:#D97706;border:1px solid #FDE68A;}
        .badge-resolved{background:#ECFDF5;color:#059669;border:1px solid #A7F3D0;}
        .badge-rejected{background:#FEF2F2;color:#DC2626;border:1px solid #FECACA;}

        .issue-reporter{display:flex;align-items:center;gap:14px;color:#5C7688;font-size:13px;flex-wrap:wrap;}
        .issue-reporter a{color:#076FA4;text-decoration:none;font-weight:600;}
        .issue-reporter a:hover{text-decoration:underline;}

        .issue-body{padding:18px 24px;}
        .issue-desc{font-size:14px;color:#093C62;line-height:1.6;background:#F8FAFC;border-radius:10px;padding:14px 18px;margin-bottom:14px;border:1px solid #E2E8F0;white-space:pre-wrap;word-break:break-word;}
        .issue-url{margin-bottom:14px;font-size:13px;display:flex;align-items:center;gap:8px;color:#5C7688;}
        .issue-url a{color:#076FA4;text-decoration:none;font-weight:600;word-break:break-all;}
        .issue-url a:hover{text-decoration:underline;}

        .screenshots-row{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:16px;}
        .screenshot-thumb{width:90px;height:70px;border-radius:8px;object-fit:cover;border:1.5px solid #C6D8E3;cursor:pointer;transition:transform .2s;}
        .screenshot-thumb:hover{transform:scale(1.05);border-color:#076FA4;}

        .admin-note-box{background:#FFFBEB;border:1px solid #FDE68A;border-radius:8px;padding:12px 16px;margin-bottom:14px;font-size:13px;color:#92400E;display:flex;gap:8px;align-items:flex-start;}
        .admin-note-box.resolved{background:#ECFDF5;border-color:#A7F3D0;color:#065F46;}
        .admin-note-box.rejected{background:#FEF2F2;border-color:#FECACA;color:#991B1B;}

        .issue-footer{padding:14px 24px;background:#F8FAFC;border-top:1px solid #E2EEF5;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:12px;}
        .issue-time{font-size:12px;color:#5C7688;}
        .issue-actions{display:flex;align-items:center;gap:10px;flex-wrap:wrap;}

        /* BUTTONS */
        .btn-action{padding:8px 16px;border-radius:8px;font-size:13px;font-weight:700;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:6px;transition:all .2s;text-decoration:none;}
        .btn-resolve{background:#10B981;color:#fff;}
        .btn-resolve:hover{background:#059669;box-shadow:0 4px 12px rgba(16,185,129,.35);}
        .btn-reject{background:#EF4444;color:#fff;}
        .btn-reject:hover{background:#DC2626;box-shadow:0 4px 12px rgba(239,68,68,.35);}
        .btn-pending{background:#F59E0B;color:#fff;}
        .btn-pending:hover{background:#D97706;}
        .btn-view{background:#F0F6FA;color:#076FA4;border:1px solid #C6D8E3;}
        .btn-view:hover{background:#076FA4;color:#fff;}

        /* MODAL */
        .modal-overlay{display:none;position:fixed;inset:0;background:rgba(9,60,98,.5);backdrop-filter:blur(4px);z-index:9999;align-items:center;justify-content:center;padding:20px;}
        .modal-overlay.show{display:flex;}
        .modal-card{background:#fff;border-radius:16px;max-width:560px;width:100%;box-shadow:0 20px 60px rgba(9,60,98,.25);overflow:hidden;animation:fadeIn .25s ease;}
        .modal-header{padding:20px 24px;border-bottom:1px solid #E2EEF5;display:flex;justify-content:space-between;align-items:center;}
        .modal-header h3{font-size:18px;font-weight:800;color:#093C62;}
        .modal-close{background:none;border:none;font-size:18px;color:#5C7688;cursor:pointer;}
        .modal-close:hover{color:#EF4444;}
        .modal-body{padding:24px;}
        .modal-footer{padding:16px 24px;background:#F8FAFC;border-top:1px solid #E2EEF5;display:flex;justify-content:flex-end;gap:12px;}
        .form-textarea{width:100%;padding:10px 14px;border:1.5px solid #C6D8E3;border-radius:8px;font-size:14px;font-family:inherit;min-height:90px;outline:none;}
        .form-textarea:focus{border-color:#076FA4;}

        /* LIGHTBOX */
        .lightbox-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.85);z-index:10000;align-items:center;justify-content:center;padding:24px;}
        .lightbox-overlay.show{display:flex;}
        .lightbox-img{max-width:90vw;max-height:85vh;border-radius:8px;box-shadow:0 10px 30px rgba(0,0,0,.5);}
        .lightbox-close{position:absolute;top:20px;right:24px;font-size:28px;color:#fff;background:none;border:none;cursor:pointer;}

        /* EMPTY STATE */
        .empty-state{text-align:center;padding:70px 20px;background:#fff;border-radius:14px;box-shadow:0 4px 16px rgba(9,60,98,.06);color:#5C7688;border:1px solid #C6D8E3;}
        .empty-state i{font-size:54px;color:#9DB9CB;margin-bottom:14px;}
        .empty-state h3{font-size:18px;color:#093C62;margin-bottom:6px;}

        /* DARK THEME */
        body.dark-theme .page-header{background:linear-gradient(135deg,#182535,#093C62);}
        body.dark-theme .admin-tab.active{background:#111312;color:#38BDF8;}
        body.dark-theme .stat-card{background:#182535;border-color:#093C62;box-shadow:0 4px 16px rgba(0,0,0,.3);}
        body.dark-theme .stat-info .num{color:#FFFFFF;}
        body.dark-theme .stat-info .lbl{color:#9DB9CB;}
        body.dark-theme .filter-panel{background:#182535;border-color:#093C62;}
        body.dark-theme .filter-chip{background:#111312;border-color:#093C62;color:#9DB9CB;}
        body.dark-theme .filter-chip.active{background:#076FA4;color:#fff;}
        body.dark-theme .filter-select{background:#111312;border-color:#093C62;color:#F4F8FA;}
        body.dark-theme .search-input{background:#111312;border-color:#093C62;color:#F4F8FA;}
        body.dark-theme .issue-card{background:#182535;border-color:#093C62;box-shadow:0 4px 16px rgba(0,0,0,.3);}
        body.dark-theme .issue-header{border-bottom-color:#093C62;}
        body.dark-theme .issue-ref{color:#38BDF8;}
        body.dark-theme .issue-desc{background:#111312;color:#F4F8FA;border-color:#093C62;}
        body.dark-theme .issue-footer{background:#131d2b;border-top-color:#093C62;}
        body.dark-theme .modal-card{background:#182535;border:1px solid #093C62;color:#F4F8FA;}
        body.dark-theme .modal-header{border-bottom-color:#093C62;}
        body.dark-theme .modal-header h3{color:#FFFFFF;}
        body.dark-theme .modal-footer{background:#111312;border-top-color:#093C62;}
        body.dark-theme .form-textarea{background:#111312;border-color:#093C62;color:#F4F8FA;}
        body.dark-theme .empty-state{background:#182535;border-color:#093C62;color:#9DB9CB;}
        body.dark-theme .empty-state h3{color:#FFFFFF;}
        body.dark-theme .btn-view{background:#111312;border-color:#093C62;color:#38BDF8;}
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
                <div class="user-dropdown-menu">
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
            <% if ("admin".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/admin" class="btn btn-outline"><i class="fa-solid fa-book"></i> Quản trị khóa học</a>
                <a href="<%=request.getContextPath()%>/admin/issues" class="btn btn-outline" style="border-color:#076FA4;background:rgba(7,111,164,.1);"><i class="fa-solid fa-triangle-exclamation"></i> Xử lý sự cố</a>
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
    <h1><i class="fa-solid fa-headset"></i> Tiếp nhận & Xử lý sự cố từ Giảng viên / Sinh viên</h1>
    <p>Theo dõi, phản hồi và cập nhật trạng thái các lỗi kỹ thuật và sự cố người dùng gửi về hệ thống.</p>

    <!-- ADMIN TABS -->
    <div class="admin-nav-tabs">
        <a href="<%=request.getContextPath()%>/admin" class="admin-tab">
            <i class="fa-solid fa-graduation-cap"></i> Quản lý khóa học
        </a>
        <a href="<%=request.getContextPath()%>/admin/issues" class="admin-tab active">
            <i class="fa-solid fa-triangle-exclamation"></i> Báo cáo sự cố & Lỗi
        </a>
    </div>
</div>

<div class="main">

    <!-- Flash Messages -->
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> ${successMessage}</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> ${error}</div>
    </c:if>

    <!-- STATS -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon total"><i class="fa-solid fa-inbox"></i></div>
            <div class="stat-info">
                <div class="num">${stats.total != null ? stats.total : 0}</div>
                <div class="lbl">Tổng báo cáo</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon pending"><i class="fa-solid fa-clock-rotate-left"></i></div>
            <div class="stat-info">
                <div class="num">${stats.pending != null ? stats.pending : 0}</div>
                <div class="lbl">Chờ xử lý</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon resolved"><i class="fa-solid fa-circle-check"></i></div>
            <div class="stat-info">
                <div class="num">${stats.resolved != null ? stats.resolved : 0}</div>
                <div class="lbl">Đã xử lý</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon rejected"><i class="fa-solid fa-circle-xmark"></i></div>
            <div class="stat-info">
                <div class="num">${stats.rejected != null ? stats.rejected : 0}</div>
                <div class="lbl">Đã từ chối</div>
            </div>
        </div>
    </div>

    <!-- FILTER & SEARCH PANEL -->
    <div class="filter-panel">
        <form action="<%=request.getContextPath()%>/admin/issues" method="get" class="filter-form">
            <div class="filter-left">
                <!-- Status chips -->
                <a href="<%=request.getContextPath()%>/admin/issues?status=all&role=${currentRole}&keyword=${keyword}"
                   class="filter-chip ${currentStatus == 'all' || empty currentStatus ? 'active' : ''}">
                   Tất cả
                </a>
                <a href="<%=request.getContextPath()%>/admin/issues?status=pending&role=${currentRole}&keyword=${keyword}"
                   class="filter-chip ${currentStatus == 'pending' ? 'active' : ''}">
                   <i class="fa-solid fa-clock"></i> Chờ xử lý (${stats.pending != null ? stats.pending : 0})
                </a>
                <a href="<%=request.getContextPath()%>/admin/issues?status=resolved&role=${currentRole}&keyword=${keyword}"
                   class="filter-chip ${currentStatus == 'resolved' ? 'active' : ''}">
                   <i class="fa-solid fa-check-circle"></i> Đã xử lý (${stats.resolved != null ? stats.resolved : 0})
                </a>
                <a href="<%=request.getContextPath()%>/admin/issues?status=rejected&role=${currentRole}&keyword=${keyword}"
                   class="filter-chip ${currentStatus == 'rejected' ? 'active' : ''}">
                   <i class="fa-solid fa-ban"></i> Từ chối (${stats.rejected != null ? stats.rejected : 0})
                </a>

                <!-- Role Filter -->
                <select name="role" class="filter-select" onchange="this.form.submit()">
                    <option value="all" ${currentRole == 'all' ? 'selected' : ''}>Tất cả người gửi</option>
                    <option value="student" ${currentRole == 'student' ? 'selected' : ''}>🎓 Sinh viên</option>
                    <option value="instructor" ${currentRole == 'instructor' ? 'selected' : ''}>👨‍🏫 Giảng viên</option>
                </select>
                <input type="hidden" name="status" value="${currentStatus}">
            </div>

            <!-- Search box -->
            <div class="search-box">
                <input type="text" name="keyword" value="${keyword}" class="search-input" placeholder="Tìm theo mã, email, nội dung...">
                <button type="submit" class="btn-search"><i class="fa-solid fa-magnifying-glass"></i> Tìm</button>
                <c:if test="${not empty keyword || currentStatus != 'all' || currentRole != 'all'}">
                    <a href="<%=request.getContextPath()%>/admin/issues" class="btn-action btn-view" title="Xóa bộ lọc"><i class="fa-solid fa-rotate-left"></i></a>
                </c:if>
            </div>
        </form>
    </div>

    <!-- ISSUES LIST -->
    <c:choose>
        <c:when test="${not empty issues}">
            <c:forEach var="issue" items="${issues}">
                <div class="issue-card status-${issue.status}">
                    <div class="issue-header">
                        <div>
                            <div class="issue-title-row">
                                <span class="issue-ref">#${issue.referenceCode}</span>

                                <!-- Role badge -->
                                <c:choose>
                                    <c:when test="${issue.role == 'instructor'}">
                                        <span class="badge-role badge-instructor"><i class="fa-solid fa-chalkboard-user"></i> Giảng viên</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-role badge-student"><i class="fa-solid fa-user-graduate"></i> Sinh viên</span>
                                    </c:otherwise>
                                </c:choose>

                                <!-- Type badge -->
                                <span class="badge-type"><i class="fa-solid fa-tag"></i> ${issue.issueTypeDisplay}</span>
                            </div>

                            <div class="issue-reporter">
                                <span><i class="fa-regular fa-envelope"></i> <a href="mailto:${issue.email}">${issue.email}</a></span>
                                <c:if test="${not empty issue.pageUrl}">
                                    <span><i class="fa-solid fa-link"></i> <a href="${issue.pageUrl}" target="_blank" rel="noopener">Trang lỗi <i class="fa-solid fa-arrow-up-right-from-square" style="font-size:11px;"></i></a></span>
                                </c:if>
                            </div>
                        </div>

                        <div>
                            <!-- Status badge -->
                            <c:choose>
                                <c:when test="${issue.status == 'resolved'}">
                                    <span class="badge-status badge-resolved"><i class="fa-solid fa-circle-check"></i> Đã xử lý</span>
                                </c:when>
                                <c:when test="${issue.status == 'rejected'}">
                                    <span class="badge-status badge-rejected"><i class="fa-solid fa-ban"></i> Từ chối</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge-status badge-pending"><i class="fa-solid fa-clock"></i> Chờ xử lý</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="issue-body">
                        <!-- Description -->
                        <div class="issue-desc"><c:out value="${issue.description}"/></div>

                        <!-- Screenshots -->
                        <c:if test="${not empty issue.screenshots && issue.screenshots != '[]'}">
                            <div class="screenshots-container" data-json='<c:out value="${issue.screenshots}"/>'>
                                <div style="font-size:12px;font-weight:700;color:#5C7688;margin-bottom:6px;">
                                    <i class="fa-solid fa-paperclip"></i> Ảnh chụp đính kèm:
                                </div>
                                <div class="screenshots-row" id="screens-row-${issue.id}">
                                    <!-- Rendered dynamically by script -->
                                </div>
                            </div>
                        </c:if>

                        <!-- Admin Note (if any) -->
                        <c:if test="${not empty issue.adminNote}">
                            <div class="admin-note-box ${issue.status}">
                                <i class="fa-solid fa-comment-dots" style="margin-top:2px;"></i>
                                <div>
                                    <strong>Ghi chú / Phản hồi của Admin:</strong>
                                    <div><c:out value="${issue.adminNote}"/></div>
                                    <c:if test="${not empty issue.resolvedByName}">
                                        <div style="font-size:11px;opacity:.8;margin-top:3px;">Người thực hiện: ${issue.resolvedByName}</div>
                                    </c:if>
                                </div>
                            </div>
                        </c:if>
                    </div>

                    <div class="issue-footer">
                        <div class="issue-time">
                            <i class="fa-regular fa-clock"></i> Gửi lúc: <fmt:formatDate value="${issue.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                        </div>

                        <!-- ACTIONS: Admin can "Đã xử lý" / "Từ chối" -->
                        <div class="issue-actions">
                            <c:if test="${issue.status != 'resolved'}">
                                <button type="button" class="btn-action btn-resolve"
                                        onclick="openActionModal(${issue.id}, '${issue.referenceCode}', 'resolve')">
                                    <i class="fa-solid fa-check"></i> Đã xử lý
                                </button>
                            </c:if>

                            <c:if test="${issue.status != 'rejected'}">
                                <button type="button" class="btn-action btn-reject"
                                        onclick="openActionModal(${issue.id}, '${issue.referenceCode}', 'reject')">
                                    <i class="fa-solid fa-xmark"></i> Từ chối
                                </button>
                            </c:if>

                            <c:if test="${issue.status != 'pending'}">
                                <form action="<%=request.getContextPath()%>/admin/issues/update-status" method="post" style="display:inline;" onsubmit="return confirm('Đặt lại sự cố này về trạng thái Chờ xử lý?');">
                                    <input type="hidden" name="issueId" value="${issue.id}">
                                    <input type="hidden" name="action" value="pending">
                                    <input type="hidden" name="filterStatus" value="${currentStatus}">
                                    <button type="submit" class="btn-action btn-pending" title="Đặt lại trạng thái Chờ xử lý">
                                        <i class="fa-solid fa-rotate-left"></i> Chờ xử lý
                                    </button>
                                </form>
                            </c:if>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <i class="fa-solid fa-clipboard-check"></i>
                <h3>Không tìm thấy báo cáo sự cố nào</h3>
                <p>Hiện không có sự cố nào phù hợp với bộ lọc hiện tại.</p>
            </div>
        </c:otherwise>
    </c:choose>

</div>

<!-- ACTION MODAL -->
<div class="modal-overlay" id="action-modal">
    <div class="modal-card">
        <form action="<%=request.getContextPath()%>/admin/issues/update-status" method="post" id="action-form">
            <div class="modal-header">
                <h3 id="modal-title"><i class="fa-solid fa-circle-question"></i> Xác nhận hành động</h3>
                <button type="button" class="modal-close" onclick="closeActionModal()"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="modal-body">
                <p id="modal-desc" style="font-size:14px;color:#5C7688;margin-bottom:14px;"></p>
                <input type="hidden" name="issueId" id="modal-issue-id">
                <input type="hidden" name="action" id="modal-action">
                <input type="hidden" name="filterStatus" value="${currentStatus}">

                <label for="admin-note-input" style="font-size:13px;font-weight:700;display:block;margin-bottom:6px;color:#093C62;">
                    Ghi chú / Phản hồi tới người gửi (tùy chọn):
                </label>
                <textarea name="adminNote" id="admin-note-input" class="form-textarea"
                          placeholder="Nhập ghi chú xử lý hoặc lý do từ chối..."></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action btn-view" onclick="closeActionModal()">Hủy</button>
                <button type="submit" class="btn-action" id="modal-submit-btn">Xác nhận</button>
            </div>
        </form>
    </div>
</div>

<!-- LIGHTBOX MODAL FOR SCREENSHOT PREVIEW -->
<div class="lightbox-overlay" id="lightbox-overlay" onclick="closeLightbox()">
    <button type="button" class="lightbox-close" onclick="closeLightbox()"><i class="fa-solid fa-xmark"></i></button>
    <img src="" alt="Screenshot Full" class="lightbox-img" id="lightbox-img" onclick="event.stopPropagation()">
</div>

<script>
    // Action Modal Logic
    function openActionModal(issueId, refCode, action) {
        const modal = document.getElementById('action-modal');
        const titleEl = document.getElementById('modal-title');
        const descEl = document.getElementById('modal-desc');
        const idInput = document.getElementById('modal-issue-id');
        const actionInput = document.getElementById('modal-action');
        const submitBtn = document.getElementById('modal-submit-btn');
        const noteInput = document.getElementById('admin-note-input');

        idInput.value = issueId;
        actionInput.value = action;
        noteInput.value = '';

        if (action === 'resolve') {
            titleEl.innerHTML = '<i class="fa-solid fa-circle-check" style="color:#10B981;"></i> Đánh dấu sự cố đã xử lý';
            descEl.innerHTML = 'Bạn đang xác nhận đã giải quyết sự cố <strong>#' + refCode + '</strong>. Sinh viên / giảng viên sẽ nhận được thông báo về kết quả này.';
            submitBtn.className = 'btn-action btn-resolve';
            submitBtn.innerHTML = '<i class="fa-solid fa-check"></i> Xác nhận Đã xử lý';
            noteInput.placeholder = 'Ví dụ: Đã khắc phục sự cố hiển thị bài thi, vui lòng thử lại...';
        } else if (action === 'reject') {
            titleEl.innerHTML = '<i class="fa-solid fa-circle-xmark" style="color:#EF4444;"></i> Từ chối sự cố';
            descEl.innerHTML = 'Bạn đang từ chối xử lý sự cố <strong>#' + refCode + '</strong>. Hãy nêu rõ lý do để người gửi hiểu rõ nguyên nhân.';
            submitBtn.className = 'btn-action btn-reject';
            submitBtn.innerHTML = '<i class="fa-solid fa-ban"></i> Xác nhận Từ chối';
            noteInput.placeholder = 'Ví dụ: Hệ thống kiểm tra thấy thông tin tài khoản hợp lệ, lỗi do đường truyền mạng của thiết bị...';
        }

        modal.classList.add('show');
    }

    function closeActionModal() {
        document.getElementById('action-modal').classList.remove('show');
    }

    // Lightbox Logic
    function openLightbox(src) {
        const overlay = document.getElementById('lightbox-overlay');
        const img = document.getElementById('lightbox-img');
        img.src = src;
        overlay.classList.add('show');
    }

    function closeLightbox() {
        document.getElementById('lightbox-overlay').classList.remove('show');
    }

    // Render screenshots from JSON
    document.addEventListener('DOMContentLoaded', () => {
        document.querySelectorAll('.screenshots-container').forEach(container => {
            const raw = container.getAttribute('data-json');
            const row = container.querySelector('.screenshots-row');
            if (!raw || !row) return;

            try {
                let parsed = JSON.parse(raw);
                if (typeof parsed === 'string') {
                    parsed = JSON.parse(parsed);
                }
                if (Array.isArray(parsed)) {
                    parsed.forEach(src => {
                        if (src && src.startsWith('data:image')) {
                            const img = document.createElement('img');
                            img.src = src;
                            img.alt = 'Screenshot';
                            img.className = 'screenshot-thumb';
                            img.title = 'Nhấn để xem kích thước đầy đủ';
                            img.onclick = () => openLightbox(src);
                            row.appendChild(img);
                        }
                    });
                }
            } catch (e) {
                console.error('Error parsing screenshots:', e);
            }
        });
    });
</script>
</body>
</html>
