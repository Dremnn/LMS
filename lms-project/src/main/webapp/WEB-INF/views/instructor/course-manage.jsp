<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String flashError = (String) session.getAttribute("flashError");
    if (flashError != null) session.removeAttribute("flashError");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý nội dung - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=50">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',Roboto,Arial,sans-serif;}
        body{background:#f0f4f8;color:#2d3748;}
        .btn-sm{padding:6px 14px;font-size:12px;}
        .btn-success{background:#c6f6d5;color:#22543d;}
        .btn-success:hover{background:#9ae6b4;}
        .badge{display:inline-block;padding:4px 10px;border-radius:20px;font-size:11px;font-weight:700;text-transform:uppercase;}
        .badge-draft{background:#e2e8f0;color:#4a5568;}
        .badge-pending{background:#fefcbf;color:#744210;}
        .badge-published{background:#c6f6d5;color:#22543d;}
        .badge-rejected{background:#fed7d7;color:#822727;}
        .page-header{padding:32px 40px;background:linear-gradient(135deg,#093C62,#076FA4);color:#fff;}
        .page-header h1{font-size:24px;font-weight:800;margin-bottom:6px;}
        .main{max-width:900px;margin:36px auto;padding:0 24px;}
        .alert-danger{background:#fff5f5;color:#c53030;border:1px solid #feb2b2;padding:14px 18px;border-radius:9px;font-size:14px;margin-bottom:20px;}
        .alert-info{background:#ebf8ff;color:#2b6cb0;border:1px solid #bee3f8;padding:12px 16px;border-radius:9px;font-size:13px;margin-bottom:20px;}
        .section-block{background:#fff;border-radius:14px;box-shadow:0 4px 14px rgba(9,60,98,.06);margin-bottom:24px;overflow:hidden;border:1px solid #C6D8E3;}
        .section-head{padding:16px 22px;background:#F0F6FA;border-left:4px solid #076FA4;display:flex;align-items:center;justify-content:space-between;}
        .section-head h3{font-size:15px;font-weight:700;color:#093C62;}
        .lesson-list{padding:0;}
        .lesson-row{display:flex;align-items:center;justify-content:space-between;padding:12px 22px;border-top:1px solid #E2EEF5;}
        .lesson-row:hover{background:#F4F8FA;}
        .lesson-info{font-size:13px;color:#093C62;display:flex;align-items:center;gap:8px;}
        .lesson-dur{font-size:12px;color:#5C7688;}
        .no-lessons{padding:14px 22px;color:#5C7688;font-size:13px;font-style:italic;}
        .add-lesson-form{padding:18px 22px;border-top:2px dashed #C6D8E3;background:#F8FAFC;}
        .add-lesson-form h4{font-size:13px;font-weight:700;color:#076FA4;margin-bottom:12px;}
        .form-row{display:flex;gap:10px;flex-wrap:wrap;}
        .form-group{flex:1;min-width:160px;}
        .form-group label{display:block;font-size:11px;font-weight:600;color:#093C62;margin-bottom:4px;}
        .form-control{width:100%;padding:9px 12px;border:1.5px solid #C6D8E3;border-radius:7px;font-size:13px;color:#093C62;outline:none;}
        .form-control:focus{border-color:#076FA4;box-shadow:0 0 0 3px rgba(7,111,164,.15);}
        .add-section-card{background:#fff;border-radius:14px;padding:28px 24px;box-shadow:0 4px 14px rgba(9,60,98,.06);margin-bottom:20px;border:2px dashed #9DB9CB;}
        .add-section-card h3{font-size:15px;font-weight:700;color:#076FA4;margin-bottom:16px;}
        .section-form-row{display:flex;gap:12px;align-items:flex-end;}
        .submit-section{background:#fff;border-radius:14px;padding:24px;box-shadow:0 4px 14px rgba(9,60,98,.06);text-align:center;margin-bottom:20px;border:1px solid #C6D8E3;border-top:4px solid #f6ad55;}
        .submit-section p{font-size:14px;color:#5C7688;margin-bottom:14px;}
        .btn-submit-review{padding:12px 32px;background:linear-gradient(135deg,#f6ad55,#ed8936);color:#fff;border:none;border-radius:9px;font-size:15px;font-weight:700;cursor:pointer;transition:opacity .2s,transform .1s;}
        .btn-submit-review:hover{opacity:.9;transform:translateY(-1px);}
        .readonly-notice{background:#fffff0;border:1px solid #f6e05e;color:#744210;padding:12px 16px;border-radius:9px;font-size:13px;margin-bottom:20px;}
        .modal-overlay{display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(15,23,42,.6);backdrop-filter:blur(4px);z-index:9999;align-items:center;justify-content:center;}
        .modal-overlay.active{display:flex;}
        .modal-card{background:#fff;border-radius:16px;padding:24px 28px;width:90%;max-width:520px;box-shadow:0 20px 60px rgba(0,0,0,.25);animation:modalSlide .25s ease;}
        @keyframes modalSlide{from{transform:translateY(-20px) scale(.96);opacity:0;}to{transform:translateY(0) scale(1);opacity:1;}}
        .modal-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;}
        .modal-header h3{font-size:17px;font-weight:700;color:#093C62;}
        .btn-close{background:none;border:none;font-size:20px;color:#9DB9CB;cursor:pointer;line-height:1;}
        .btn-close:hover{color:#093C62;}
        .btn-danger-sm{background:#fed7d7;color:#9b2c2c;border:none;padding:5px 10px;border-radius:6px;font-size:12px;cursor:pointer;font-weight:600;display:inline-flex;align-items:center;gap:4px;transition:background .2s;}
        .btn-danger-sm:hover{background:#feb2b2;}
        .btn-action-sm{background:#E2EEF5;color:#093C62;border:none;padding:5px 10px;border-radius:6px;font-size:12px;cursor:pointer;font-weight:600;display:inline-flex;align-items:center;gap:4px;transition:background .2s;}
        .btn-action-sm:hover{background:#C6D8E3;color:#076FA4;}

        /* Quiz section styles */
        .quiz-section-block{background:#fff;border-radius:14px;box-shadow:0 4px 14px rgba(9,60,98,.06);padding:24px 28px;margin-bottom:24px;border:1px solid #C6D8E3;border-left:4px solid #076FA4;}
        .quiz-section-block h3{font-size:16px;font-weight:700;color:#093C62;}
        .quiz-section-desc{font-size:13px;color:#5C7688;margin-bottom:16px;}
        .quiz-item-card{display:flex;justify-content:space-between;align-items:center;padding:12px 16px;background:#F0F6FA;border:1px solid #C6D8E3;border-radius:8px;transition:all .2s;}
        .quiz-item-title{font-size:14px;font-weight:700;color:#093C62;}
        .quiz-item-meta{font-size:12px;color:#076FA4;margin-top:4px;}
        .quiz-item-btn{border:1px solid #076FA4;color:#076FA4;background:transparent;transition:all .2s;}
        .quiz-item-btn:hover{background:#076FA4;color:#fff;}
        .quiz-empty-card{padding:16px;background:#f7fafc;border-radius:8px;text-align:center;font-size:13px;color:#a0aec0;font-style:italic;}

        /* Dark Theme (Ô 1: #111312, Ô 2: #182535, Ô 3: #093C62) */
        body.dark-theme .page-header{background:linear-gradient(135deg,#182535,#093C62);}
        body.dark-theme .section-block{background:#182535;border-color:#093C62;box-shadow:0 4px 14px rgba(0,0,0,.3);}
        body.dark-theme .section-head{background:#111312;border-left-color:#076FA4;}
        body.dark-theme .section-head h3{color:#F4F8FA;}
        body.dark-theme .lesson-row{border-top-color:#093C62;}
        body.dark-theme .lesson-row:hover{background:#111312;}
        body.dark-theme .lesson-info{color:#9DB9CB;}
        body.dark-theme .lesson-dur{color:#5C7688;}
        body.dark-theme .add-lesson-form{background:#111312;border-top-color:#093C62;}
        body.dark-theme .form-group label{color:#9DB9CB;}
        body.dark-theme .form-control{background:#182535;border-color:#093C62;color:#F4F8FA;}
        body.dark-theme .form-control:focus{border-color:#076FA4;}
        body.dark-theme .add-section-card{background:#182535;border-color:#093C62;box-shadow:0 4px 14px rgba(0,0,0,.3);}
        body.dark-theme .submit-section{background:#182535;border-color:#093C62;box-shadow:0 4px 14px rgba(0,0,0,.3);}
        body.dark-theme .submit-section p{color:#9DB9CB;}
        body.dark-theme .modal-card{background:#182535;border:1px solid #093C62;color:#F4F8FA;box-shadow:0 20px 60px rgba(0,0,0,.5);}
        body.dark-theme .modal-header h3{color:#F4F8FA;}
        body.dark-theme .btn-action-sm{background:#093C62;color:#F4F8FA;}
        body.dark-theme .btn-action-sm:hover{background:#076FA4;}

        /* Dark Theme Quiz styles */
        body.dark-theme .quiz-section-block{background:#182535 !important;border-color:#093C62 !important;border-left-color:#076FA4 !important;box-shadow:0 4px 14px rgba(0,0,0,.3) !important;}
        body.dark-theme .quiz-section-block h3{color:#FFFFFF !important;}
        body.dark-theme .quiz-section-desc{color:#9DB9CB !important;}
        body.dark-theme .quiz-item-card{background:#111312 !important;border-color:#093C62 !important;}
        body.dark-theme .quiz-item-title{color:#FFFFFF !important;}
        body.dark-theme .quiz-item-meta{color:#9DB9CB !important;}
        body.dark-theme .quiz-item-btn{border-color:#093C62 !important;color:#38BDF8 !important;background:rgba(7,111,164,.15) !important;}
        body.dark-theme .quiz-item-btn:hover{background:#076FA4 !important;color:#FFFFFF !important;border-color:#076FA4 !important;}
        body.dark-theme .quiz-empty-card{background:#111312 !important;border:1px solid #093C62 !important;color:#9DB9CB !important;}
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
        <a href="<%=request.getContextPath()%>/instructor/courses" class="nav-link">← Danh sách khóa học</a>
        <c:choose>
            <c:when test="${not empty firstLessonId}">
                <a href="<%=request.getContextPath()%>/student/lessons/view?lessonId=${firstLessonId}" class="nav-link"><i class="fa-solid fa-play"></i> Xem bài học</a>
            </c:when>
            <c:otherwise>
                <a href="<%=request.getContextPath()%>/courses/detail?id=${course.id}" class="nav-link"><i class="fa-solid fa-eye"></i> Xem khóa học</a>
            </c:otherwise>
        </c:choose>
        <a href="<%=request.getContextPath()%>/courses/detail?id=${course.id}" class="nav-link"><i class="fa-solid fa-circle-info"></i> Giới thiệu khóa học</a>
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

<div class="page-header" style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:16px;">
    <div>
        <h1><i class="fa-solid fa-folder-open"></i> <c:out value="${course.title}"/></h1>
        <div style="display:flex;align-items:center;gap:10px;margin-top:8px;">
            <span style="font-size:14px;opacity:.85;">Quản lý nội dung khóa học</span>
            <c:choose>
                <c:when test="${course.status == 'draft'}"><span class="badge badge-draft">Draft</span></c:when>
                <c:when test="${course.status == 'published'}"><span class="badge badge-published"><i class="fa-solid fa-circle-check"></i> Published</span></c:when>
                <c:when test="${course.status == 'warning'}"><span class="badge badge-rejected" style="background:#fed7d7; color:#9b2c2c;"><i class="fa-solid fa-triangle-exclamation"></i> Warning</span></c:when>
                <c:when test="${course.status == 'appealed'}"><span class="badge badge-published" style="background:#bee3f8; color:#2a4365;">📩 Đang kháng cáo</span></c:when>
            </c:choose>
        </div>
    </div>
    <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
        <c:choose>
            <c:when test="${not empty firstLessonId}">
                <a href="${pageContext.request.contextPath}/student/lessons/view?lessonId=${firstLessonId}" class="btn" style="background:#10B981;color:#fff;border-radius:10px;padding:10px 18px;font-size:14px;font-weight:700;display:inline-flex;align-items:center;gap:8px;text-decoration:none;box-shadow:0 4px 14px rgba(16,185,129,0.35);">
                    <i class="fa-solid fa-play"></i> Xem bài học (Giao diện học viên)
                </a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/courses/detail?id=${course.id}" class="btn" style="background:#10B981;color:#fff;border-radius:10px;padding:10px 18px;font-size:14px;font-weight:700;display:inline-flex;align-items:center;gap:8px;text-decoration:none;">
                    <i class="fa-solid fa-eye"></i> Xem khóa học
                </a>
            </c:otherwise>
        </c:choose>
        <a href="${pageContext.request.contextPath}/courses/detail?id=${course.id}" class="btn" style="background:rgba(255,255,255,0.18);color:#fff;border:1.5px solid rgba(255,255,255,0.4);border-radius:10px;padding:10px 18px;font-size:14px;font-weight:600;display:inline-flex;align-items:center;gap:8px;text-decoration:none;transition:all 0.2s;">
            <i class="fa-solid fa-circle-info"></i> Trang giới thiệu
        </a>
    </div>
</div>

<div class="main">
    <% if (flashError != null && !flashError.isEmpty()) { %>
        <div class="alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> <%=flashError%></div>
    <% } %>

    <c:if test="${(course.status == 'warning' || course.status == 'appealed') && not empty course.rejectReason}">
        <div class="alert-danger" style="background:#fffaf0; border-color:#f6ad55; color:#c05621; margin-bottom:20px;">
            <strong><i class="fa-solid fa-triangle-exclamation"></i> Admin đã cảnh cáo khóa học này:</strong> <c:out value="${course.rejectReason}"/>
            <c:choose>
                <c:when test="${course.status == 'warning'}">
                    <div style="font-size:13px; margin-top:6px;">Bạn có thể kháng cáo từ trang danh sách khóa học hoặc chỉnh sửa nội dung theo yêu cầu.</div>
                </c:when>
                <c:when test="${course.status == 'appealed'}">
                    <div style="font-size:13px; margin-top:6px; color:#2a4365;">📩 Kháng cáo của bạn đã được gửi. Đang chờ Admin xem xét...</div>
                </c:when>
            </c:choose>
        </div>
    </c:if>

    <%-- Removed readonly-notice because instructor can now edit at any time --%>

    <%-- Danh sách chương + bài học --%>
    <c:choose>
        <c:when test="${not empty course.sectionsCache}">
            <c:forEach var="section" items="${course.sectionsCache}" varStatus="st">
                <div class="section-block">
                    <div class="section-head">
                        <div>
                            <h3><i class="fa-solid fa-book-open"></i> Chương ${st.index + 1}: <c:out value="${section.title}"/></h3>
                            <span style="font-size:12px;color:#a0aec0;">${section.lessons.size()} bài học</span>
                        </div>
                        <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;">
                            <%-- Đổi thứ tự chương (tự động dồn các chương khác) --%>
                            <form action="${pageContext.request.contextPath}/instructor/courses/sections/reorder" method="post" style="display:inline-flex;align-items:center;gap:4px;">
                                <input type="hidden" name="courseId" value="${course.id}">
                                <input type="hidden" name="sectionId" value="${section.id}">
                                <span style="font-size:12px;color:#718096;font-weight:600;">Vị trí:</span>
                                <select name="targetOrder" onchange="this.form.submit()" class="form-control" style="width:auto;padding:3px 8px;font-size:12px;height:30px;cursor:pointer;background:#fff;">
                                    <c:forEach var="i" begin="1" end="${course.sectionsCache.size()}">
                                        <option value="${i}" ${i == (st.index + 1) ? 'selected' : ''}>Chương ${i}</option>
                                    </c:forEach>
                                </select>
                            </form>

                            <%-- Đổi tên chương --%>
                            <button type="button" class="btn-action-sm" data-id="${section.id}" data-title="<c:out value="${section.title}" escapeXml="true"/>" onclick="openEditSectionModal(this)">
                                <i class="fa-solid fa-pen-to-square"></i> Đổi tên
                            </button>

                            <%-- Xóa chương --%>
                            <form action="${pageContext.request.contextPath}/instructor/courses/sections/delete" method="post" style="display:inline;"
                                  onsubmit="return confirm('Bạn có chắc chắn muốn xóa Chương ${st.index + 1}: ${section.title}? Tất cả bài học trong chương này sẽ bị xóa và các chương sau sẽ tự động dồn số thứ tự!');">
                                <input type="hidden" name="courseId" value="${course.id}">
                                <input type="hidden" name="sectionId" value="${section.id}">
                                <button type="submit" class="btn-danger-sm">
                                    <i class="fa-solid fa-trash"></i> Xóa
                                </button>
                            </form>
                        </div>
                    </div>
                    <div class="lesson-list">
                        <c:choose>
                            <c:when test="${not empty section.lessons}">
                                <c:forEach var="lesson" items="${section.lessons}">
                                    <div class="lesson-row">
                                        <span class="lesson-info"><i class="fa-solid fa-play"></i> 
                                            <a href="${pageContext.request.contextPath}/student/lessons/view?lessonId=${lesson.id}" style="color:inherit; text-decoration:underline; font-weight:600;">
                                                <c:out value="${lesson.title}"/>
                                            </a>
                                            <c:if test="${not empty lesson.description}">
                                                <span title="<c:out value="${lesson.description}"/>" style="font-size:11px;color:#6b7280;margin-left:8px;font-weight:normal;background:#edf2f7;padding:2px 6px;border-radius:4px;">
                                                    <i class="fa-solid fa-align-left"></i> Có mô tả
                                                </span>
                                            </c:if>
                                        </span>
                                        <div style="display:flex;align-items:center;gap:8px;">
                                            <span class="lesson-dur">
                                                <c:choose>
                                                     <c:when test="${lesson.durationMinutes != null}">${lesson.durationMinutes} phút</c:when>
                                                     <c:otherwise>N/A</c:otherwise>
                                                </c:choose>
                                            </span>
                                            <a href="${pageContext.request.contextPath}/student/lessons/view?lessonId=${lesson.id}"
                                               class="btn-action-sm" style="padding:3px 8px;font-size:11px;background:#0284c7;color:#fff;text-decoration:none;display:inline-flex;align-items:center;gap:4px;"
                                               title="Xem bài học này ở giao diện học viên">
                                                <i class="fa-solid fa-eye"></i> Xem bài học
                                            </a>
                                            <button type="button" class="btn-action-sm" style="padding:3px 8px;font-size:11px;"
                                                    data-id="${lesson.id}"
                                                    data-title="<c:out value="${lesson.title}" escapeXml="true"/>"
                                                    data-duration="${lesson.durationMinutes != null ? lesson.durationMinutes : ''}"
                                                    data-video="<c:out value="${lesson.videoUrl}" escapeXml="true"/>"
                                                    data-doc="<c:out value="${lesson.documentUrl}" escapeXml="true"/>"
                                                    data-desc="<c:out value="${lesson.description}" escapeXml="true"/>"
                                                    onclick="openEditLessonModal(this)">
                                                
                                              <button type="button" class="btn-action-sm" style="padding:3px 8px;font-size:11px;background:#6366f1;color:#fff;border-color:#6366f1;" onclick="openCodingExerciseModal(${lesson.id}, '<c:out value="${lesson.title}" escapeXml="true"/>')" title="Thiết lập bài tập code & test case cho bài học này"><i class="fa-solid fa-code"></i> Bài tập Code</button>
                                            <form action="${pageContext.request.contextPath}/instructor/courses/lessons/delete" method="post" style="display:inline;"
                                                  onsubmit="return confirm('Bạn có chắc muốn xóa bài học: ${lesson.title}?');">
                                                <input type="hidden" name="courseId" value="${course.id}">
                                                <input type="hidden" name="lessonId" value="${lesson.id}">
                                                <button type="submit" class="btn-danger-sm" style="padding:3px 8px;font-size:11px;">
                                                    <i class="fa-solid fa-trash"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <p class="no-lessons">Chưa có bài học nào trong chương này.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <%-- Form thêm bài học --%>
                    <div class="add-lesson-form">
                        <h4>➕ Thêm bài học mới vào chương này</h4>
                        <form action="${pageContext.request.contextPath}/instructor/courses/lessons/add" method="post">
                            <input type="hidden" name="sectionId" value="${section.id}">
                            <input type="hidden" name="courseId" value="${course.id}">
                            <div class="form-row">
                                <div class="form-group" style="flex:2;">
                                    <label>Tên bài học *</label>
                                    <input type="text" name="title" class="form-control" placeholder="Ví dụ: Giới thiệu về vòng lặp" required>
                                </div>
                                <div class="form-group">
                                    <label>Thời lượng (phút)</label>
                                    <input type="number" name="durationMinutes" class="form-control" placeholder="15" min="1">
                                </div>
                                <div class="form-group" style="flex:2;">
                                    <label>URL Video</label>
                                    <input type="text" name="videoUrl" class="form-control" placeholder="https://youtube.com/...">
                                </div>
                                <div class="form-group" style="flex:2;">
                                    <label>URL Tài liệu</label>
                                    <input type="text" name="documentUrl" class="form-control" placeholder="https://drive.google.com/...">
                                </div>
                            </div>
                            <div class="form-group" style="margin-top:10px;">
                                <label>Mô tả nội dung bài học (tùy chọn)</label>
                                <textarea name="description" class="form-control" rows="2" placeholder="Tóm tắt ngắn gọn nội dung bài học, mục tiêu học tập..."></textarea>
                            </div>
                            <div class="form-row" style="margin-top:10px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; padding:10px 12px; display:flex; gap:12px; align-items:flex-end;">
                                <div class="form-group" style="flex:1;">
                                    <label style="font-weight:700; color:#475569; font-size:12px;"><i class="fa-solid fa-flag-checkered"></i> Điểm dừng Video (giây)</label>
                                    <input type="number" name="videoCheckpointSeconds" class="form-control" placeholder="Ví dụ: 30" min="1" style="font-size:12.5px;">
                                </div>
                                <div class="form-group" style="flex:1.5;">
                                    <label style="font-weight:700; color:#475569; font-size:12px;"><i class="fa-solid fa-layer-group"></i> Loại Điểm Dừng</label>
                                    <select name="checkpointType" class="form-control add-cp-type" onchange="toggleAddCpType(this)" style="font-size:12.5px;">
                                        <option value="">-- Không có điểm dừng --</option>
                                        <option value="quiz">Trả lời câu hỏi Quiz trắc nghiệm</option>
                                        <option value="code">Làm bài tập Code thực hành</option>
                                    </select>
                                </div>
                                <div class="form-group add-cp-quiz-group" style="flex:2; display:none;">
                                    <label style="font-weight:700; color:#475569; font-size:12px;"><i class="fa-solid fa-circle-question"></i> Chọn câu hỏi Quiz</label>
                                    <select name="checkpointRefId" class="form-control add-cp-quiz-select" style="font-size:12.5px;">
                                        <option value="">-- Chọn câu hỏi trắc nghiệm --</option>
                                    </select>
                                </div>
                            </div>
                            <div style="margin-top:12px;">
                                <button type="submit" class="btn btn-primary btn-sm">➕ Thêm bài học</button>
                            </div>
                        </form>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="alert-info"><i class="fa-solid fa-inbox"></i> Khóa học này chưa có chương nào. Hãy thêm chương đầu tiên bên dưới!</div>
        </c:otherwise>
    </c:choose>

    <%-- Form thêm chương mới --%>
    <div class="add-section-card">
        <h3>📌 Thêm chương mới</h3>
        <form action="${pageContext.request.contextPath}/instructor/courses/sections/add" method="post">
            <input type="hidden" name="courseId" value="${course.id}">
            <div class="section-form-row">
                <div class="form-group" style="flex:1;">
                    <label>Tên chương *</label>
                    <input type="text" name="title" class="form-control" placeholder="Ví dụ: Giới thiệu Java cơ bản" required>
                </div>
                <div>
                    <button type="submit" class="btn btn-primary">➕ Thêm chương</button>
                </div>
            </div>
        </form>
    </div>

    <c:if test="${not empty course.sectionsCache && course.status == 'draft'}">
        <div class="submit-section">
            <p><i class="fa-solid fa-circle-check"></i> Khóa học đã có nội dung. Đăng khóa học để học viên có thể vào học ngay?</p>
            <form action="${pageContext.request.contextPath}/instructor/courses/submit" method="post">
                <input type="hidden" name="id" value="${course.id}">
                <button type="submit" class="btn-submit-review"><i class="fa-solid fa-rocket"></i> Đăng khóa học</button>
            </form>
        </div>
    </c:if>

    <%-- ===== PHẦN QUIZ ===== --%>
    <div class="quiz-section-block">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;">
            <h3>📝 Quiz khóa học</h3>
            <a href="${pageContext.request.contextPath}/instructor/quizzes/new?courseId=${course.id}"
               class="btn btn-primary btn-sm">➕ Tạo Quiz mới</a>
        </div>
        <p class="quiz-section-desc">Tạo bài kiểm tra tổng kết cho toàn bộ khóa học hoặc cho từng chương cụ thể.</p>
        
        <c:choose>
            <c:when test="${not empty quizzes}">
                <div style="display:flex;flex-direction:column;gap:12px;">
                    <c:forEach var="quiz" items="${quizzes}">
                        <div class="quiz-item-card">
                            <div>
                                <div class="quiz-item-title"><c:out value="${quiz.title}"/></div>
                                <div class="quiz-item-meta">
                                    ${quiz.totalQuestions} câu hỏi · Điểm đạt: ${quiz.passScore}/100
                                    <c:choose>
                                        <c:when test="${quiz.courseId != null}"> (Quiz tổng kết)</c:when>
                                        <c:otherwise> (Quiz chương ID: ${quiz.sectionId})</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div style="display:flex;align-items:center;gap:8px;">
                                <a href="${pageContext.request.contextPath}/student/quizzes/intro?id=${quiz.id}" class="btn btn-sm"
                                   style="background:#e0f2fe;color:#0284c7;border:1px solid #bae6fd;text-decoration:none;display:inline-flex;align-items:center;gap:4px;"
                                   title="Xem giao diện làm bài của học viên">
                                    <i class="fa-solid fa-eye"></i> Xem Quiz
                                </a>
                                <a href="${pageContext.request.contextPath}/instructor/quizzes/manage?id=${quiz.id}" class="btn btn-sm quiz-item-btn">
                                    <i class="fa-solid fa-pen-to-square"></i> Quản lý câu hỏi
                                </a>
                                <form action="${pageContext.request.contextPath}/instructor/quizzes/delete" method="post" style="display:inline;"
                                      onsubmit="return confirm('Bạn có chắc muốn xóa Quiz: ${quiz.title}? Toàn bộ câu hỏi và kết quả làm bài của quiz này sẽ bị xóa!');">
                                    <input type="hidden" name="courseId" value="${course.id}">
                                    <input type="hidden" name="quizId" value="${quiz.id}">
                                    <button type="submit" class="btn-danger-sm">
                                        <i class="fa-solid fa-trash"></i> Xóa
                                    </button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="quiz-empty-card">
                    Chưa có Quiz nào được tạo.
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <%-- ===== PHẦN BÀI TẬP ===== --%>
    <div class="quiz-section-block" style="margin-top:24px;">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;">
            <h3>📎 Bài tập khóa học</h3>
            <a href="${pageContext.request.contextPath}/instructor/assignments/new?courseId=${course.id}"
               class="btn btn-primary btn-sm">➕ Tạo bài tập mới</a>
        </div>
        <p class="quiz-section-desc">Giao bài tập để học viên nộp file (doc, docx, txt, pdf, ...). Có thể đặt hạn nộp; học viên sẽ được nhắc trước hạn 24 giờ.</p>

        <c:choose>
            <c:when test="${not empty assignments}">
                <div style="display:flex;flex-direction:column;gap:12px;">
                    <c:forEach var="asg" items="${assignments}">
                        <div class="quiz-item-card">
                            <div>
                                <div class="quiz-item-title"><c:out value="${asg.title}"/></div>
                                <div class="quiz-item-meta">
                                    <c:choose>
                                        <c:when test="${asg.sectionId != null}"> (Chương: <c:out value="${asg.sectionTitle}"/>)</c:when>
                                        <c:otherwise> (Toàn khóa học)</c:otherwise>
                                    </c:choose>
                                    · <c:choose>
                                        <c:when test="${not empty asg.dueAt}">Hạn nộp: ${asg.dueAtDisplay}<c:if test="${asg.overdue}"> (đã hết hạn)</c:if></c:when>
                                        <c:otherwise>Không đặt hạn nộp</c:otherwise>
                                    </c:choose>
                                    · Đã nộp: ${asg.submissionCount}/${asg.enrolledCount}
                                    <c:if test="${asg.hasAttachment}"> · 📎 <c:out value="${asg.attachName}"/></c:if>
                                </div>
                            </div>
                            <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;">
                                <a href="${pageContext.request.contextPath}/student/assignments/view?id=${asg.id}" class="btn btn-sm"
                                   style="background:#e0f2fe;color:#0284c7;border:1px solid #bae6fd;text-decoration:none;display:inline-flex;align-items:center;gap:4px;"
                                   title="Xem giao diện nộp bài của học viên">
                                    <i class="fa-solid fa-eye"></i> Xem Bài tập
                                </a>
                                <a href="${pageContext.request.contextPath}/instructor/assignments/submissions?id=${asg.id}" class="btn btn-sm quiz-item-btn">
                                    <i class="fa-solid fa-inbox"></i> Bài nộp (${asg.submissionCount})
                                </a>
                                <a href="${pageContext.request.contextPath}/instructor/assignments/edit?id=${asg.id}" class="btn btn-sm quiz-item-btn">
                                    <i class="fa-solid fa-pen-to-square"></i> Sửa
                                </a>
                                <form action="${pageContext.request.contextPath}/instructor/assignments/delete" method="post" style="display:inline;"
                                      onsubmit="return confirm('Bạn có chắc muốn xóa bài tập này? Toàn bộ bài nộp của học viên cũng sẽ bị xóa!');">
                                    <input type="hidden" name="courseId" value="${course.id}">
                                    <input type="hidden" name="assignmentId" value="${asg.id}">
                                    <button type="submit" class="btn-danger-sm"><i class="fa-solid fa-trash"></i> Xóa</button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="quiz-empty-card">Chưa có bài tập nào được tạo.</div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%-- MODAL SỬA TÊN CHƯƠNG --%>
<div class="modal-overlay" id="editSectionModal" onclick="if(event.target===this)closeEditSectionModal()">
    <div class="modal-card">
        <div class="modal-header">
            <h3>✏️ Đổi tên chương học</h3>
            <button type="button" class="btn-close" onclick="closeEditSectionModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/instructor/courses/sections/edit" method="post">
            <input type="hidden" name="courseId" value="${course.id}">
            <input type="hidden" name="sectionId" id="modalEditSectionId">
            <div class="form-group" style="margin-bottom:18px;">
                <label>Tên chương mới *</label>
                <input type="text" name="title" id="modalEditSectionTitle" class="form-control" required style="margin-top:6px;">
            </div>
            <div style="display:flex;justify-content:flex-end;gap:10px;">
                <button type="button" class="btn btn-outline btn-sm" onclick="closeEditSectionModal()">Hủy</button>
                <button type="submit" class="btn btn-primary btn-sm">💾 Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<%-- MODAL SỬA BÀI HỌC --%>
<div class="modal-overlay" id="editLessonModal" onclick="if(event.target===this)closeEditLessonModal()">
    <div class="modal-card">
        <div class="modal-header">
            <h3>✏️ Chỉnh sửa bài học</h3>
            <button type="button" class="btn-close" onclick="closeEditLessonModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/instructor/courses/lessons/edit" method="post">
            <input type="hidden" name="courseId" value="${course.id}">
            <input type="hidden" name="lessonId" id="modalEditLessonId">
            <div class="form-group" style="margin-bottom:14px;">
                <label>Tên bài học *</label>
                <input type="text" name="title" id="modalEditLessonTitle" class="form-control" required style="margin-top:4px;">
            </div>
            <div class="form-group" style="margin-bottom:14px;">
                <label>Thời lượng (phút)</label>
                <input type="number" name="durationMinutes" id="modalEditLessonDuration" class="form-control" min="1" style="margin-top:4px;">
            </div>
            <div class="form-group" style="margin-bottom:14px;">
                <label>URL Video</label>
                <input type="text" name="videoUrl" id="modalEditLessonVideo" class="form-control" placeholder="https://youtube.com/..." style="margin-top:4px;">
            </div>
            <div class="form-group" style="margin-bottom:18px;">
                <label>URL Tài liệu</label>
                <input type="text" name="documentUrl" id="modalEditLessonDoc" class="form-control" placeholder="https://drive.google.com/..." style="margin-top:4px;">
            </div>
            <div class="form-group" style="margin-bottom:18px;">
                <label>Mô tả nội dung bài học</label>
                <textarea name="description" id="modalEditLessonDesc" class="form-control" rows="3" placeholder="Tóm tắt nội dung bài học..." style="margin-top:4px;"></textarea>
            </div>
            <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; padding:12px 14px; margin-bottom:16px;">
                <div style="font-weight:700; color:#334155; font-size:13px; margin-bottom:8px;">
                    <i class="fa-solid fa-flag-checkered" style="color:#6366f1;"></i> Điểm Dừng Video (Interactive Checkpoint)
                </div>
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px; margin-bottom:10px;">
                    <div class="form-group">
                        <label style="font-size:12px;">Điểm dừng Video (giây)</label>
                        <input type="number" name="videoCheckpointSeconds" id="modalEditLessonCpSeconds" class="form-control" placeholder="Ví dụ: 30" min="1" style="margin-top:4px;">
                    </div>
                    <div class="form-group">
                        <label style="font-size:12px;">Loại điểm dừng</label>
                        <select name="checkpointType" id="modalEditLessonCpType" class="form-control" onchange="toggleEditCpType()" style="margin-top:4px;">
                            <option value="">-- Không có điểm dừng --</option>
                            <option value="quiz">Trả lời câu hỏi Quiz trắc nghiệm</option>
                            <option value="code">Làm bài tập Code thực hành</option>
                        </select>
                    </div>
                </div>
                <div class="form-group" id="modalEditLessonCpQuizGroup" style="display:none;">
                    <label style="font-size:12px;">Chọn câu hỏi trắc nghiệm</label>
                    <select name="checkpointRefId" id="modalEditLessonCpRefId" class="form-control" style="margin-top:4px;">
                        <option value="">-- Chọn câu hỏi --</option>
                    </select>
                </div>
            </div>
            <div style="display:flex;justify-content:flex-end;gap:10px;">
                <button type="button" class="btn btn-outline btn-sm" onclick="closeEditLessonModal()">Hủy</button>
                <button type="submit" class="btn btn-primary btn-sm">💾 Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openEditSectionModal(arg1, title) {
        if (typeof arg1 === 'object' && arg1 !== null) {
            document.getElementById('modalEditSectionId').value = arg1.dataset.id || '';
            document.getElementById('modalEditSectionTitle').value = arg1.dataset.title || '';
        } else {
            document.getElementById('modalEditSectionId').value = arg1 || '';
            document.getElementById('modalEditSectionTitle').value = title || '';
        }
        document.getElementById('editSectionModal').classList.add('active');
    }
    function closeEditSectionModal() {
        document.getElementById('editSectionModal').classList.remove('active');
    }
    function openEditLessonModal(arg1, title, duration, videoUrl, docUrl, desc) {
        if (typeof arg1 === 'object' && arg1 !== null) {
            document.getElementById('modalEditLessonId').value = arg1.dataset.id || '';
            document.getElementById('modalEditLessonTitle').value = arg1.dataset.title || '';
            document.getElementById('modalEditLessonDuration').value = arg1.dataset.duration || '';
            document.getElementById('modalEditLessonVideo').value = arg1.dataset.video || '';
            document.getElementById('modalEditLessonDoc').value = arg1.dataset.doc || '';
            document.getElementById('modalEditLessonDesc').value = (arg1.dataset.desc || '').trim();
        } else {
            document.getElementById('modalEditLessonId').value = arg1 || '';
            document.getElementById('modalEditLessonTitle').value = title || '';
            document.getElementById('modalEditLessonDuration').value = duration || '';
            document.getElementById('modalEditLessonVideo').value = videoUrl || '';
            document.getElementById('modalEditLessonDoc').value = docUrl || '';
            document.getElementById('modalEditLessonDesc').value = (desc || '').trim();
        }
        document.getElementById('editLessonModal').classList.add('active');
    }
    function closeEditLessonModal() {
        document.getElementById('editLessonModal').classList.remove('active');
    }
</script>

<!-- Dynamic Island Theme Toggle -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=38"></script>


<!-- MODAL QUẢN LÝ BÀI TẬP CODE & TEST CASE -->
<div class="modal-overlay" id="codingExerciseModal" onclick="if(event.target===this)closeCodingExerciseModal()">
    <div class="modal-card" style="max-width: 820px; width: 95%; max-height: 90vh; display: flex; flex-direction: column;">
        <div class="modal-header" style="background:#4f46e5; color:#fff; border-radius: 12px 12px 0 0; padding: 14px 20px;">
            <h3 style="color:#fff; margin:0; font-size:17px;"><i class="fa-solid fa-code"></i> Thiết Lập Bài Tập Code &amp; Test Cases: <span id="ceModalLessonTitle" style="color:#c7d2fe; font-weight:normal;"></span></h3>
            <button type="button" class="btn-close" style="color:#fff; filter: brightness(2);" onclick="closeCodingExerciseModal()">&times;</button>
        </div>
        <div style="padding: 20px; overflow-y: auto; flex: 1;">
            <input type="hidden" id="ceLessonId">
            <input type="hidden" id="ceExerciseId">

            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 16px; margin-bottom: 14px;">
                <div class="form-group">
                    <label style="font-weight: 700; font-size: 13px;">Tiêu đề bài tập *</label>
                    <input type="text" id="ceTitle" class="form-control" placeholder="VD: Tính tổng 2 số nguyên, Thuật toán sắp xếp..." required style="margin-top: 4px;">
                </div>
                <div class="form-group">
                    <label style="font-weight: 700; font-size: 13px;">Ngôn ngữ lập trình mặc định</label>
                    <select id="ceLanguage" class="form-control" style="margin-top: 4px;">
                        <option value="cpp">C++ (GCC)</option>
                        <option value="c">C (GCC)</option>
                        <option value="java">Java (OpenJDK 21)</option>
                        <option value="python">Python (3.12)</option>
                        <option value="javascript">JavaScript (Node.js 20)</option>
                        <option value="typescript">TypeScript</option>
                        <option value="go">Golang (1.23)</option>
                        <option value="php">PHP (8.3)</option>
                        <option value="rust">Rust (1.82)</option>
                        <option value="csharp">C# (Mono)</option>
                        <option value="sql">SQL (SQLite 3)</option>
                    </select>
                </div>
            </div>

                        <div class="form-group" style="margin-bottom: 14px; background: #f8fafc; border: 1.5px dashed #818cf8; border-radius: 10px; padding: 14px 18px;">
                <label style="font-weight: 700; font-size: 13.5px; color: #4338ca;"><i class="fa-solid fa-circle-pause"></i> Điểm Dừng Video Tương Tác (Interactive Video Checkpoint)</label>
                <div style="display: grid; grid-template-columns: 180px 1fr; gap: 14px; margin-top: 8px; align-items: center;">
                    <div>
                        <label style="font-size: 12px; font-weight: 600; color: #64748b;">Dừng tại giây thứ:</label>
                        <input type="number" id="ceCheckpointSeconds" class="form-control" placeholder="VD: 45 hoặc 90" min="1" style="font-size: 13px;">
                    </div>
                    <div>
                        <label style="font-size: 12px; font-weight: 600; color: #64748b;">Loại tương tác khi dừng video:</label>
                        <select id="ceCheckpointType" class="form-control" style="font-size: 13px;" onchange="toggleCheckpointTypeFields()">
                            <option value="code">💻 Thực hành Viết Code &amp; Test Cases</option>
                            <option value="quiz">❓ Câu hỏi Quiz Trắc Nghiệm (In-Video Quiz)</option>
                        </select>
                    </div>
                </div>

                <div id="ceQuizQuestionContainer" style="display:none; margin-top: 10px; background: #eef2ff; padding: 10px 14px; border-radius: 8px;">
                    <label style="font-size: 12px; font-weight: 700; color: #3730a3;">Chọn câu hỏi trắc nghiệm tương tác:</label>
                    <select id="ceQuizQuestionSelect" class="form-control" style="font-size: 12.5px; margin-top: 4px;">
                        <option value="">-- Đang tải danh sách câu hỏi... --</option>
                    </select>
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label style="font-weight: 700; font-size: 13px;">Đề bài / Yêu cầu chi tiết</label>
                <textarea id="ceDescription" class="form-control" rows="4" placeholder="Mô tả đề bài, ràng buộc đầu vào (Input), định dạng đầu ra (Output), ví dụ..." style="margin-top: 4px; font-family: inherit;"></textarea>
            </div>

            <div class="form-group" style="margin-bottom: 18px;">
                <label style="font-weight: 700; font-size: 13px;">Mã nguồn mẫu / Khởi tạo cho học viên (Starter Code)</label>
                <textarea id="ceInitialCode" class="form-control" rows="5" placeholder="// Nhập khung code gợi ý sẵn cho học sinh..." style="margin-top: 4px; font-family: Consolas, monospace; font-size: 13px; background: #0f172a; color: #f8fafc;"></textarea>
            </div>

            <div style="margin-bottom: 14px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                    <label style="font-weight: 700; font-size: 14px; color: #0f172a;"><i class="fa-solid fa-vial-circle-check" style="color: #10b981;"></i> Danh Sách Test Cases (Kiểm thử tự động)</label>
                    <button type="button" class="btn btn-sm" style="background:#10b981; color:#fff; font-size:12px;" onclick="addTestCaseRow('', '', false, 10)">
                        <i class="fa-solid fa-plus"></i> Thêm Test Case
                    </button>
                </div>
                <div style="max-height: 240px; overflow-y: auto; border: 1px solid #e2e8f0; border-radius: 8px;">
                    <table style="width: 100%; border-collapse: collapse; font-size: 12.5px;" id="ceTestCasesTable">
                        <thead>
                            <tr style="background: #f1f5f9; text-align: left; color: #475569;">
                                <th style="padding: 8px 10px; width: 40px;">#</th>
                                <th style="padding: 8px 10px;">Đầu vào (Input / Stdin)</th>
                                <th style="padding: 8px 10px;">Kết quả mong đợi (Expected Output) *</th>
                                <th style="padding: 8px 10px; width: 100px; text-align: center;">Ẩn với HS?</th>
                                <th style="padding: 8px 10px; width: 70px;">Điểm</th>
                                <th style="padding: 8px 10px; width: 50px;">Xóa</th>
                            </tr>
                        </thead>
                        <tbody id="ceTestCasesBody">
                            <!-- Rows injected dynamically -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center; padding: 14px 20px; border-top: 1px solid #e2e8f0; background: #f8fafc; border-radius: 0 0 12px 12px;">
            <button type="button" id="ceBtnDelete" class="btn btn-danger-sm" style="display:none;" onclick="deleteCodingExercise()">
                <i class="fa-solid fa-trash"></i> Xóa Bài Tập Này
            </button>
            <div style="display: flex; gap: 10px; margin-left: auto;">
                <button type="button" class="btn btn-outline btn-sm" onclick="closeCodingExerciseModal()">Hủy</button>
                <button type="button" class="btn btn-primary btn-sm" style="background:#4f46e5; border-color:#4f46e5;" onclick="saveCodingExercise()">
                    <i class="fa-solid fa-floppy-disk"></i> Lưu Bài Tập &amp; Test Cases
                </button>
            </div>
        </div>
    </div>
</div>

<script>
        function toggleCheckpointTypeFields() {
        const type = document.getElementById('ceCheckpointType').value;
        const quizContainer = document.getElementById('ceQuizQuestionContainer');
        if (type === 'quiz') {
            quizContainer.style.display = 'block';
            loadCourseQuizQuestions();
        } else {
            quizContainer.style.display = 'none';
        }
    }

    function loadCourseQuizQuestions(selectedQId) {
        const select = document.getElementById('ceQuizQuestionSelect');
        fetch('${pageContext.request.contextPath}/api/checkpoint/questions?courseId=${course.id}')
            .then(res => res.json())
            .then(questions => {
                select.innerHTML = '';
                if (!questions || questions.length === 0) {
                    select.innerHTML = '<option value="">(Khóa học chưa có Quiz nào để chọn)</option>';
                    return;
                }
                questions.forEach(q => {
                    const opt = document.createElement('option');
                    opt.value = q.id;
                    opt.innerText = '[' + q.quizTitle + '] ' + q.content;
                    if (selectedQId && q.id == selectedQId) {
                        opt.selected = true;
                    }
                    select.appendChild(opt);
                });
            })
            .catch(err => {
                select.innerHTML = '<option value="">Lỗi tải câu hỏi: ' + err + '</option>';
            });
    }
    function openCodingExerciseModal(lessonId, lessonTitle) {
        document.getElementById('ceLessonId').value = lessonId;
        document.getElementById('ceModalLessonTitle').innerText = lessonTitle;
        document.getElementById('ceExerciseId').value = '';
        document.getElementById('ceTitle').value = '';
        document.getElementById('ceDescription').value = '';
        document.getElementById('ceInitialCode').value = '';
        document.getElementById('ceCheckpointSeconds').value = '';
        document.getElementById('ceTestCasesBody').innerHTML = '';
        document.getElementById('ceBtnDelete').style.display = 'none';

        // Fetch existing exercise info
        fetch('${pageContext.request.contextPath}/instructor/courses/lessons/exercise?lessonId=' + lessonId)
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    if (data.videoCheckpointSeconds) {
                        document.getElementById('ceCheckpointSeconds').value = data.videoCheckpointSeconds;
                    }
                    if (data.checkpointType) {
                        document.getElementById('ceCheckpointType').value = data.checkpointType;
                    } else {
                        document.getElementById('ceCheckpointType').value = 'code';
                    }
                    toggleCheckpointTypeFields();
                    if (data.checkpointRefId && data.checkpointType === 'quiz') {
                        loadCourseQuizQuestions(data.checkpointRefId);
                    }
                    if (data.hasExercise) {
                        document.getElementById('ceExerciseId').value = data.exerciseId;
                        document.getElementById('ceTitle').value = data.title || '';
                        document.getElementById('ceDescription').value = data.description || '';
                        document.getElementById('ceLanguage').value = data.language || 'cpp';
                        document.getElementById('ceInitialCode').value = data.initialCode || '';
                        document.getElementById('ceBtnDelete').style.display = 'inline-block';

                        if (data.testCases && data.testCases.length > 0) {
                            data.testCases.forEach(tc => {
                                addTestCaseRow(tc.inputData, tc.expectedOutput, tc.isHidden, tc.points);
                            });
                        } else {
                            addTestCaseRow('', '', false, 10);
                        }
                    } else {
                        // Tạo sẵn 2 dòng mẫu
                        addTestCaseRow('1 2', '3', false, 10);
                        addTestCaseRow('10 20', '30', true, 10);
                    }
                }
                document.getElementById('codingExerciseModal').classList.add('active');
            })
            .catch(err => {
                alert('Lỗi tải thông tin bài tập: ' + err);
            });
    }

    function closeCodingExerciseModal() {
        document.getElementById('codingExerciseModal').classList.remove('active');
    }

    function addTestCaseRow(input, expected, isHidden, points) {
        const tbody = document.getElementById('ceTestCasesBody');
        const rowIndex = tbody.children.length + 1;
        const tr = document.createElement('tr');
        tr.style.borderBottom = '1px solid #f1f5f9';
        tr.innerHTML = 
            '<td style="padding: 8px 10px; font-weight: bold; color: #64748b;">' + rowIndex + '</td>' +
            '<td style="padding: 8px 10px;">' +
                '<input type="text" class="form-control tc-input" value="' + (input || '').replace(/"/g, '&quot;') + '" placeholder="Đầu vào stdin..." style="font-size:12px; font-family:monospace; padding:4px 8px;">' +
            '</td>' +
            '<td style="padding: 8px 10px;">' +
                '<input type="text" class="form-control tc-expected" value="' + (expected || '').replace(/"/g, '&quot;') + '" placeholder="Kết quả stdout mong đợi..." required style="font-size:12px; font-family:monospace; padding:4px 8px;">' +
            '</td>' +
            '<td style="padding: 8px 10px; text-align: center;">' +
                '<input type="checkbox" class="tc-hidden" ' + (isHidden ? 'checked' : '') + ' title="Tích chọn để ẩn input/output này với học sinh">' +
            '</td>' +
            '<td style="padding: 8px 10px;">' +
                '<input type="number" class="form-control tc-points" value="' + (points || 10) + '" min="1" style="font-size:12px; padding:4px 6px; width:60px;">' +
            '</td>' +
            '<td style="padding: 8px 10px; text-align: center;">' +
                '<button type="button" class="btn-danger-sm" style="padding:2px 6px; font-size:11px;" onclick="this.closest(\'tr\').remove()">&times;</button>' +
            '</td>';
        tbody.appendChild(tr);
    }

    function saveCodingExercise() {
        const lessonId = document.getElementById('ceLessonId').value;
        const title = document.getElementById('ceTitle').value.trim();
        const description = document.getElementById('ceDescription').value.trim();
        const language = document.getElementById('ceLanguage').value;
        const initialCode = document.getElementById('ceInitialCode').value;
        const videoCheckpointSeconds = document.getElementById('ceCheckpointSeconds').value.trim();

        if (!title) {
            alert('Vui lòng nhập tiêu đề bài tập!');
            return;
        }

        const rows = document.querySelectorAll('#ceTestCasesBody tr');
        const testCases = [];
        for (let row of rows) {
            const inputData = row.querySelector('.tc-input').value;
            const expectedOutput = row.querySelector('.tc-expected').value.trim();
            const isHidden = row.querySelector('.tc-hidden').checked;
            const points = parseInt(row.querySelector('.tc-points').value) || 10;

            if (!expectedOutput) {
                alert('Vui lòng nhập kết quả mong đợi (Expected Output) cho tất cả các test case!');
                return;
            }
            testCases.push({ inputData, expectedOutput, isHidden, points });
        }

        if (testCases.length === 0) {
            alert('Vui lòng thêm ít nhất 1 Test Case để hệ thống kiểm thử!');
            return;
        }

        const checkpointType = document.getElementById('ceCheckpointType').value;
        const checkpointRefId = document.getElementById('ceQuizQuestionSelect').value;

        const payload = {
            lessonId: parseInt(lessonId),
            title,
            description,
            language,
            initialCode,
            videoCheckpointSeconds: videoCheckpointSeconds ? parseInt(videoCheckpointSeconds) : null,
            checkpointType: checkpointType,
            checkpointRefId: checkpointRefId ? parseInt(checkpointRefId) : null,
            testCases
        };

        fetch('${pageContext.request.contextPath}/instructor/courses/lessons/exercise/save', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                alert('Đã lưu bài tập code & test cases thành công!');
                closeCodingExerciseModal();
                location.reload();
            } else {
                alert('Lỗi: ' + data.message);
            }
        })
        .catch(err => alert('Lỗi kết nối máy chủ: ' + err));
    }


    let cachedCourseQuestions = null;

    function loadAllCourseQuestionsForDropdowns() {
        fetch('${pageContext.request.contextPath}/api/checkpoint/questions?courseId=${course.id}')
            .then(res => res.json())
            .then(questions => {
                cachedCourseQuestions = questions || [];
                populateQuestionDropdowns();
            })
            .catch(err => console.error('Error fetching questions:', err));
    }

    function populateQuestionDropdowns() {
        if (!cachedCourseQuestions) return;
        const selects = document.querySelectorAll('.add-cp-quiz-select, #modalEditLessonCpRefId, #ceQuizQuestionSelect');
        selects.forEach(sel => {
            const currentVal = sel.value;
            sel.innerHTML = '<option value="">-- Chọn câu hỏi trắc nghiệm --</option>';
            if (cachedCourseQuestions.length === 0) {
                sel.innerHTML = '<option value="">(Khóa học chưa có câu hỏi Quiz nào)</option>';
                return;
            }
            cachedCourseQuestions.forEach(q => {
                const opt = document.createElement('option');
                opt.value = q.id;
                opt.innerText = '[' + (q.quizTitle || 'Quiz') + '] ' + q.content;
                if (currentVal && q.id == currentVal) {
                    opt.selected = true;
                }
                sel.appendChild(opt);
            });
        });
    }

    function toggleAddCpType(selectEl) {
        const form = selectEl.closest('form');
        const quizGroup = form.querySelector('.add-cp-quiz-group');
        if (selectEl.value === 'quiz') {
            quizGroup.style.display = 'block';
            if (cachedCourseQuestions && cachedCourseQuestions.length > 0) {
                populateQuestionDropdowns();
            } else {
                loadAllCourseQuestionsForDropdowns();
            }
        } else {
            quizGroup.style.display = 'none';
        }
    }

    function toggleEditCpType() {
        const typeSelect = document.getElementById('modalEditLessonCpType');
        const quizGroup = document.getElementById('modalEditLessonCpQuizGroup');
        if (typeSelect.value === 'quiz') {
            quizGroup.style.display = 'block';
            if (cachedCourseQuestions && cachedCourseQuestions.length > 0) {
                populateQuestionDropdowns();
            } else {
                loadAllCourseQuestionsForDropdowns();
            }
        } else {
            quizGroup.style.display = 'none';
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        loadAllCourseQuestionsForDropdowns();
    });

    function deleteCodingExercise() {
        if (!confirm('Bạn có chắc chắn muốn xóa bài tập code này?')) return;
        const lessonId = document.getElementById('ceLessonId').value;
        const exerciseId = document.getElementById('ceExerciseId').value;

        fetch('${pageContext.request.contextPath}/instructor/courses/lessons/exercise/delete', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ lessonId: parseInt(lessonId), exerciseId: parseInt(exerciseId) })
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                alert('Đã xóa bài tập code thành công!');
                closeCodingExerciseModal();
                location.reload();
            } else {
                alert('Lỗi: ' + data.message);
            }
        })
        .catch(err => alert('Lỗi kết nối máy chủ: ' + err));
    }
</script>
</body>
</html>








