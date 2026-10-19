<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${currentLesson.title} - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=50">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <style>
        body{min-height:100vh;}

        .btn-success{background:linear-gradient(135deg,#10B981,#059669);color:#fff;padding:12px 28px;font-size:14px;font-weight:700;border:none;border-radius:10px;cursor:pointer;box-shadow:0 4px 14px rgba(16,185,129,.25);transition:all .2s;}
        .btn-success:hover{transform:translateY(-1px);box-shadow:0 6px 20px rgba(16,185,129,.35);}

        /* ---- LAYOUT 2 CỘT ---- */
        .layout{display:flex;min-height:calc(100vh - 68px);}

        /* ---- SIDEBAR ---- */
        .sidebar{width:340px;flex-shrink:0;background:rgba(255,255,255,0.92);backdrop-filter:blur(12px);border-right:1px solid #C6D8E3;display:flex;flex-direction:column;box-shadow:2px 0 16px rgba(9,60,98,.04);transition:all .3s ease;}
        .sidebar-header{padding:20px 24px;border-bottom:1px solid #C6D8E3;background:#FFFFFF;}
        .sidebar-course-title{font-size:15px;font-weight:700;color:#093C62;margin-bottom:12px;line-height:1.4;}
        .progress-label{display:flex;justify-content:space-between;font-size:13px;color:#5C7688;margin-bottom:8px;font-weight:500;}
        .progress-bar-bg{background:#E2EEF5;border-radius:10px;height:8px;overflow:hidden;}
        .progress-bar-fill{height:100%;border-radius:10px;background:linear-gradient(90deg,#093C62,#076FA4);}
        .sidebar-body{flex:1;overflow-y:auto;}
        .section-group{border-bottom:1px solid #C6D8E3;}
        .section-title{padding:12px 20px;font-size:12px;font-weight:700;color:#093C62;text-transform:uppercase;letter-spacing:.5px;background:#F0F6FA;border-bottom:1px solid #E2EEF5;}
        .lesson-link{display:flex;align-items:center;gap:12px;padding:12px 20px;font-size:14px;color:#093C62;text-decoration:none;transition:all .15s;cursor:pointer;border-left:3px solid transparent;border-bottom:1px solid #F0F6FA;}
        .lesson-link:hover{background:#E2EEF5;color:#076FA4;}
        .lesson-link.active{background:#E2EEF5;color:#076FA4;font-weight:700;border-left-color:#076FA4;}
        .lesson-link.locked{color:#94a3b8;cursor:not-allowed;background:rgba(241,245,249,0.5);opacity:0.75;}
        .lesson-link.locked:hover{background:rgba(241,245,249,0.7);color:#94a3b8;}
        .lesson-link .tick{color:#10B981;font-size:14px;font-weight:800;flex-shrink:0;}
        .lesson-link .dot{width:9px;height:9px;border-radius:50%;border:2px solid #9DB9CB;flex-shrink:0;}
        .lesson-link.active .dot{background:#076FA4;border-color:#076FA4;}
        .quiz-link{background:#FFFBEB;color:#D97706;font-weight:600;}
        .quiz-link:hover{background:#FEF3C7;color:#B45309;}

        /* ---- CONTENT ---- */
        .content{flex:1;overflow-y:auto;padding:36px 48px;max-width:1020px;margin:0 auto;}
        .lesson-title{font-size:28px;font-weight:800;color:#093C62;margin-bottom:24px;line-height:1.3;}
        .alert-danger{background:#FEF2F2;border:1px solid #FECACA;color:#991B1B;padding:14px 20px;border-radius:12px;font-size:14px;margin-bottom:24px;}
        .video-wrap{background:#000;border-radius:16px;overflow:hidden;margin-bottom:28px;box-shadow:0 12px 36px rgba(0,0,0,.15);}
        .video-wrap video{display:block;width:100%;}
        .no-video{background:#FFFFFF;border:2px dashed #9DB9CB;border-radius:16px;padding:56px 24px;text-align:center;color:#5C7688;margin-bottom:28px;}
        .no-video .icon{font-size:48px;margin-bottom:12px;}
        .doc-link{display:inline-flex;align-items:center;gap:10px;padding:12px 24px;background:#FFFFFF;border:1.5px solid #C6D8E3;border-radius:12px;color:#076FA4;text-decoration:none;font-size:14px;font-weight:600;margin-bottom:28px;box-shadow:0 2px 8px rgba(9,60,98,.04);transition:all .2s;}
        .doc-link:hover{border-color:#076FA4;box-shadow:0 6px 20px rgba(7,111,164,.15);transform:translateY(-2px);}
        .complete-card{background:#FFFFFF;border-radius:16px;padding:24px 28px;border:1px solid #C6D8E3;box-shadow:0 4px 20px rgba(9,60,98,.05);margin-top:12px;}
        .complete-card h3{font-size:16px;font-weight:700;color:#093C62;margin-bottom:14px;display:flex;align-items:center;gap:8px;}
        .form-check{display:flex;align-items:center;gap:12px;margin-bottom:18px;}
        .form-check input[type=checkbox]{width:20px;height:20px;accent-color:#076FA4;cursor:pointer;flex-shrink:0;}
        .form-check-label{font-size:15px;color:#093C62;cursor:pointer;font-weight:500;}
        .divider{border:none;border-top:1px solid #C6D8E3;margin:28px 0;}
        .lesson-desc-box{background:#FFFFFF;border-radius:16px;padding:22px 26px;border:1px solid #C6D8E3;box-shadow:0 4px 20px rgba(9,60,98,.05);margin-top:20px;}
        .lesson-desc-header{font-size:15px;font-weight:700;color:#093C62;margin-bottom:10px;display:flex;align-items:center;gap:8px;}
        .lesson-desc-header i{color:#076FA4;}
        .lesson-desc-body{font-size:14.5px;color:#334155;line-height:1.7;white-space:pre-wrap;}

        /* ---- DARK THEME CHO LESSON VIEW (Ô 1: #111312, Ô 2: #182535, Ô 3: #093C62) ---- */
        body.dark-theme .sidebar{background:rgba(24,37,53,0.96);border-right-color:#093C62;box-shadow:2px 0 16px rgba(0,0,0,.4);}
        body.dark-theme .sidebar-header{background:#182535;border-bottom-color:#093C62;}
        body.dark-theme .sidebar-course-title{color:#F4F8FA;}
        body.dark-theme .progress-label{color:#9DB9CB;}
        body.dark-theme .progress-bar-bg{background:#093C62;}
        body.dark-theme .section-group{border-bottom-color:#093C62;}
        body.dark-theme .section-title{background:#111312;color:#9DB9CB;border-bottom-color:#093C62;}
        body.dark-theme .lesson-link{color:#9DB9CB;border-bottom-color:#182535;}
        body.dark-theme .lesson-link:hover{background:#182535;color:#F4F8FA;}
        body.dark-theme .lesson-link.active{background:#093C62;color:#F4F8FA;border-left-color:#076FA4;}
        body.dark-theme .lesson-link.locked{background:rgba(17,19,18,0.5);color:#475569;}
        body.dark-theme .lesson-link.locked:hover{background:rgba(17,19,18,0.7);color:#475569;}
        body.dark-theme .lesson-link .dot{border-color:#9DB9CB;}
        body.dark-theme .lesson-link.active .dot{background:#076FA4;border-color:#076FA4;}
        body.dark-theme .lesson-title{color:#F4F8FA;}
        body.dark-theme .no-video{background:#182535;border-color:#093C62;color:#9DB9CB;}
        body.dark-theme .doc-link{background:#182535;border-color:#093C62;color:#9DB9CB;}
        body.dark-theme .doc-link:hover{border-color:#076FA4;color:#F4F8FA;box-shadow:0 6px 20px rgba(7,111,164,.25);}
        body.dark-theme .lesson-desc-box{background:#182535;border-color:#093C62;box-shadow:0 4px 20px rgba(0,0,0,.3);}
        body.dark-theme .lesson-desc-header{color:#F4F8FA;}
        body.dark-theme .lesson-desc-header i{color:#38BDF8;}
        body.dark-theme .lesson-desc-body{color:#9DB9CB;}
        body.dark-theme .resource-card{background:#182535 !important;border-color:#093C62 !important;}
        body.dark-theme .resource-card div > div:first-child{color:#F4F8FA !important;}
        body.dark-theme .resource-card div > div:last-child{color:#9DB9CB !important;}
        body.dark-theme .activities-box{background:#182535 !important;border-color:#093C62 !important;}
        body.dark-theme .activities-box > div:first-child{color:#F4F8FA !important;}
        body.dark-theme .complete-card{background:#182535;border-color:#093C62;box-shadow:0 4px 20px rgba(0,0,0,.3);}
        body.dark-theme .complete-card h3{color:#F4F8FA;}
        body.dark-theme .form-check-label{color:#9DB9CB;}
        body.dark-theme .divider{border-top-color:#093C62;}
        /* ---- CUSTOM VIDEO CONTROLS & CHECKPOINT MARKERS ---- */
        .video-wrap { margin-bottom: 0 !important; }
        .custom-yt-controls { background: #093C62; display: flex; align-items: center; padding: 12px 16px; border-bottom-left-radius: 16px; border-bottom-right-radius: 16px; margin-bottom: 28px; gap: 12px; box-shadow: 0 12px 36px rgba(0,0,0,.15); user-select: none; }
        .yt-control-btn { background: none; border: none; color: #fff; font-size: 18px; cursor: pointer; padding: 4px 8px; transition: color 0.2s, transform 0.1s; display: inline-flex; align-items: center; justify-content: center; }
        .yt-control-btn:hover { color: #10B981; transform: scale(1.1); }
        .yt-time-display { color: #C6D8E3; font-size: 13px; font-weight: 500; min-width: 95px; text-align: center; font-family: monospace; }
        .yt-progress-container { flex: 1; cursor: pointer; padding: 10px 0; position: relative; }
        .yt-progress-bg { background: rgba(255,255,255,0.22); height: 6px; border-radius: 4px; overflow: hidden; position: relative; }
        .yt-progress-fill { background: #10B981; height: 100%; width: 0%; border-radius: 4px; transition: width 0.08s linear; }

        /* Checkpoint Markers on Video Timeline */
        .checkpoint-marker-dot {
            position: absolute;
            top: 50%;
            transform: translate(-50%, -50%);
            width: 14px;
            height: 14px;
            border-radius: 50%;
            background: #f59e0b;
            border: 2px solid #ffffff;
            box-shadow: 0 0 10px rgba(245, 158, 11, 0.95), 0 2px 5px rgba(0,0,0,0.4);
            cursor: pointer;
            z-index: 10;
            transition: transform 0.15s ease, background 0.2s ease, box-shadow 0.2s ease;
        }
        .checkpoint-marker-dot:hover {
            transform: translate(-50%, -50%) scale(1.4);
            background: #fbbf24;
            box-shadow: 0 0 14px rgba(251, 191, 36, 1), 0 2px 8px rgba(0,0,0,0.6);
        }
        .checkpoint-marker-dot.passed {
            background: #10b981;
            box-shadow: 0 0 8px rgba(16, 185, 129, 0.9), 0 2px 4px rgba(0,0,0,0.3);
        }
        .checkpoint-marker-dot .checkpoint-tooltip {
            visibility: hidden;
            opacity: 0;
            position: absolute;
            bottom: calc(100% + 8px);
            left: 50%;
            transform: translateX(-50%);
            background: rgba(15, 23, 42, 0.95);
            color: #f8fafc;
            padding: 5px 10px;
            border-radius: 6px;
            font-size: 11.5px;
            font-weight: 600;
            white-space: nowrap;
            border: 1px solid rgba(255, 255, 255, 0.15);
            box-shadow: 0 4px 12px rgba(0,0,0,0.4);
            pointer-events: none;
            transition: opacity 0.2s ease, visibility 0.2s ease;
            z-index: 25;
        }
        .checkpoint-marker-dot .checkpoint-tooltip::after {
            content: '';
            position: absolute;
            top: 100%;
            left: 50%;
            transform: translateX(-50%);
            border-width: 4px;
            border-style: solid;
            border-color: rgba(15, 23, 42, 0.95) transparent transparent transparent;
        }
        .checkpoint-marker-dot:hover .checkpoint-tooltip {
            visibility: visible;
            opacity: 1;
        }
    </style>
    <!-- CodeMirror & Compiler Styles -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.13/codemirror.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.13/theme/dracula.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.13/codemirror.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.13/mode/clike/clike.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.13/mode/python/python.min.js"></script>
    <style>
        .compiler-section { margin-top: 32px; border-radius: 12px; overflow: hidden; border: 1px solid #334155; background: #1e293b; color: #fff; font-family: 'Segoe UI', Roboto, sans-serif; display: none; }
        .compiler-toolbar { display: flex; justify-content: space-between; align-items: center; padding: 12px 20px; background: #0f172a; border-bottom: 1px solid #334155; }
        .compiler-toolbar select { background: #334155; color: #fff; border: 1px solid #475569; padding: 6px 12px; border-radius: 6px; outline: none; }
        .btn-run-code { background: #10b981; color: #fff; border: none; padding: 8px 16px; border-radius: 6px; cursor: pointer; font-weight: 600; display: flex; align-items: center; gap: 8px; transition: background 0.2s; }
        .btn-run-code:hover { background: #059669; }
        .btn-run-code:disabled { background: #64748b; cursor: not-allowed; }
        .CodeMirror { height: 350px; font-size: 15px; font-family: 'Consolas', 'Courier New', monospace; }
        .compiler-console { height: 180px; background: #000; padding: 16px; overflow-y: auto; font-family: 'Consolas', 'Courier New', monospace; font-size: 14px; color: #a7f3d0; border-top: 1px solid #334155; white-space: pre-wrap; }
        .toggle-compiler-btn { background: #6366f1; color: white; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer; margin-left: 12px; display: inline-flex; align-items: center; gap: 8px; transition: 0.2s; }
        .toggle-compiler-btn:hover { background: #4f46e5; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(99,102,241,0.3); }
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
        <a href="<%=request.getContextPath()%>/courses/detail?id=${course.id}" class="nav-link">← Chi tiết khóa học</a>
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

<div class="layout">

    <%-- ===================== SIDEBAR ===================== --%>
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="sidebar-course-title"><i class="fa-solid fa-book-open"></i> <c:out value="${course.title}"/></div>
            <c:if test="${enrollment != null}">
                <div class="progress-label">
                    <span>Tiến độ của bạn</span>
                    <span><strong>${enrollment.progressPercent}%</strong></span>
                </div>
                <div class="progress-bar-bg">
                    <div class="progress-bar-fill" style="--progress: ${not empty enrollment.progressPercent ? enrollment.progressPercent : 0}%; width: var(--progress);"></div>
                </div>
            </c:if>
            <c:if test="${enrollment == null}">
                <div class="progress-label">
                    <span>Chế độ xem trước (Admin/Instructor)</span>
                </div>
            </c:if>
        </div>

        <div class="sidebar-body">
            <c:forEach var="section" items="${course.sectionsCache}" varStatus="st">
                <div class="section-group">
                    <div class="section-title">Chương ${st.index + 1}: <c:out value="${section.title}"/></div>
                    <c:forEach var="lesson" items="${section.lessons}">
                        <c:set var="isLessonLocked" value="${lessonLockedMap != null && lessonLockedMap[lesson.id] == true}" />
                        <c:choose>
                            <c:when test="${isLessonLocked}">
                                <div class="lesson-link locked" title="Bài học đang bị khóa. Bạn cần hoàn thành bài học trước để mở khóa!" onclick="alert('Bài học này đang bị khóa. Bạn cần hoàn thành bài học trước để mở khóa!');">
                                    <span class="lock-icon" style="color:#94a3b8;font-size:12px;margin-right:2px;"><i class="fa-solid fa-lock"></i></span>
                                    <span><c:out value="${lesson.title}"/></span>
                                    <c:if test="${lesson.assessmentType == 'quiz'}"><span class="badge" style="background:#fef3c7;color:#b45309;font-size:10px;padding:2px 6px;margin-left:auto;"><i class="fa-solid fa-circle-question"></i> Quiz</span></c:if>
                                    <c:if test="${lesson.assessmentType == 'code'}"><span class="badge" style="background:#e0e7ff;color:#4338ca;font-size:10px;padding:2px 6px;margin-left:auto;"><i class="fa-solid fa-code"></i> Code</span></c:if>
                                    <c:if test="${lesson.assessmentType == 'assignment'}"><span class="badge" style="background:#ccfbf1;color:#0f766e;font-size:10px;padding:2px 6px;margin-left:auto;"><i class="fa-solid fa-paperclip"></i> Bài tập</span></c:if>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/student/lessons/view?lessonId=${lesson.id}"
                                   class="lesson-link ${lesson.id == currentLesson.id ? 'active' : ''}">
                                    <c:choose>
                                        <c:when test="${completedLessonIds.contains(lesson.id)}">
                                            <span class="tick">✓</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="dot"></span>
                                        </c:otherwise>
                                    </c:choose>
                                    <span><c:out value="${lesson.title}"/></span>
                                    <c:if test="${lesson.assessmentType == 'quiz'}"><span class="badge" style="background:#fef3c7;color:#b45309;font-size:10px;padding:2px 6px;margin-left:auto;"><i class="fa-solid fa-circle-question"></i> Quiz</span></c:if>
                                    <c:if test="${lesson.assessmentType == 'code'}"><span class="badge" style="background:#e0e7ff;color:#4338ca;font-size:10px;padding:2px 6px;margin-left:auto;"><i class="fa-solid fa-code"></i> Code</span></c:if>
                                    <c:if test="${lesson.assessmentType == 'assignment'}"><span class="badge" style="background:#ccfbf1;color:#0f766e;font-size:10px;padding:2px 6px;margin-left:auto;"><i class="fa-solid fa-paperclip"></i> Bài tập</span></c:if>
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>

                    <%-- Quiz cho chương này --%>
                    <c:forEach var="quiz" items="${quizzes}">
                        <c:if test="${quiz.sectionId == section.id}">
                            <a href="${pageContext.request.contextPath}/student/quizzes/intro?id=${quiz.id}&lessonId=${currentLesson.id}" class="lesson-link quiz-link">
                                <span class="dot" style="border-color:#d97706; background:#fef3c7; border-radius:3px;"></span>
                                <span><i class="fa-solid fa-file-lines" style="color:#d97706; margin-right:4px;"></i> <c:out value="${quiz.title}"/></span>
                            </a>
                        </c:if>
                    </c:forEach>

                    <%-- Bài tập cho chương này --%>
                    <c:forEach var="asg" items="${assignments}">
                        <c:if test="${asg.sectionId == section.id}">
                            <a href="${pageContext.request.contextPath}/student/assignments/view?id=${asg.id}" class="lesson-link quiz-link">
                                <span class="dot" style="border-color:#0d9488; --bg: ${asg.submittedByMe ? '#0d9488' : '#ccfbf1'}; background: var(--bg); border-radius:3px;"></span>
                                <span>
                                    <i class="fa-solid fa-paperclip" style="color:#0d9488; margin-right:4px;"></i> <c:out value="${asg.title}"/>
                                    <c:if test="${not empty asg.dueAt}">
                                        <span style="display:block;font-size:11px;font-weight:400;opacity:.8;color:#134e4a;">
                                            <c:choose>
                                                <c:when test="${asg.submittedByMe}">Đã nộp</c:when>
                                                <c:when test="${asg.overdue}">Quá hạn</c:when>
                                                <c:otherwise>Hạn: ${asg.dueAtDisplay}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </c:if>
                                </span>
                            </a>
                        </c:if>
                    </c:forEach>
                </div>
            </c:forEach>

            <%-- Quiz tổng kết khóa học --%>
            <c:set var="hasCourseQuiz" value="false"/>
            <c:forEach var="quiz" items="${quizzes}">
                <c:if test="${quiz.courseId != null}">
                    <c:set var="hasCourseQuiz" value="true"/>
                </c:if>
            </c:forEach>
            <c:if test="${hasCourseQuiz}">
                <div class="section-group" style="border-bottom:none;">
                    <div class="section-title" style="background:#FEF3C7; color:#92400E; border-bottom:1px solid #FDE68A;"><i class="fa-solid fa-trophy" style="color:#D97706;"></i> Quiz Tổng Kết Khóa Học</div>
                    <c:forEach var="quiz" items="${quizzes}">
                        <c:if test="${quiz.courseId != null}">
                            <a href="${pageContext.request.contextPath}/student/quizzes/intro?id=${quiz.id}&lessonId=${currentLesson.id}" class="lesson-link quiz-link" style="background:#FFFBEB;">
                                <span class="dot" style="border-color:#F59E0B; background:#F59E0B; border-radius:3px;"></span>
                                <span style="font-weight:700; color:#B45309;"><i class="fa-solid fa-star" style="color:#F59E0B; margin-right:4px;"></i> <c:out value="${quiz.title}"/></span>
                            </a>
                        </c:if>
                    </c:forEach>
                </div>
            </c:if>

            <%-- Bài tập toàn khóa học --%>
            <c:set var="hasCourseAssignment" value="false"/>
            <c:forEach var="asg" items="${assignments}">
                <c:if test="${asg.sectionId == null}">
                    <c:set var="hasCourseAssignment" value="true"/>
                </c:if>
            </c:forEach>
            <c:if test="${hasCourseAssignment}">
                <div class="section-group" style="border-bottom:none;">
                    <div class="section-title" style="background:#CCFBF1; color:#115E59; border-bottom:1px solid #99F6E4;"><i class="fa-solid fa-paperclip" style="color:#0D9488;"></i> Bài Tập Toàn Khóa</div>
                    <c:forEach var="asg" items="${assignments}">
                        <c:if test="${asg.sectionId == null}">
                            <a href="${pageContext.request.contextPath}/student/assignments/view?id=${asg.id}" class="lesson-link quiz-link" style="background:#F0FDFA;">
                                <span class="dot" style="border-color:#0D9488; --bg: ${asg.submittedByMe ? '#0D9488' : '#CCFBF1'}; background: var(--bg); border-radius:3px;"></span>
                                <span>
                                    <span style="font-weight:700; color:#0F766E;"><i class="fa-solid fa-paperclip" style="color:#0D9488; margin-right:4px;"></i> <c:out value="${asg.title}"/></span>
                                    <c:if test="${not empty asg.dueAt}">
                                        <span style="display:block;font-size:11px;font-weight:400;opacity:.8;color:#134e4a;">
                                            <c:choose>
                                                <c:when test="${asg.submittedByMe}">Đã nộp</c:when>
                                                <c:when test="${asg.overdue}">Quá hạn</c:when>
                                                <c:otherwise>Hạn: ${asg.dueAtDisplay}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </c:if>
                                </span>
                            </a>
                        </c:if>
                    </c:forEach>
                </div>
            </c:if>
        </div>
    </aside>

    <%-- ===================== NỘI DUNG CHÍNH ===================== --%>
    <main class="content">
        <h1 class="lesson-title"><c:out value="${currentLesson.title}"/></h1>

        <%-- Cảnh cáo từ giảng viên (nếu có) --%>
        <c:if test="${enrollment != null && (enrollment.warningStatus == 'warning' || enrollment.warningStatus == 'appealed')}">
            <div style="background:#fffaf0; border:1px solid #f6ad55; border-left:4px solid #ed8936; border-radius:8px; padding:12px 18px; margin-bottom:20px; font-size:13px; color:#c05621; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;">
                <div>
                    <strong><i class="fa-solid fa-triangle-exclamation"></i> CẢNH CÁO TỪ GIẢNG VIÊN:</strong>
                    <span style="margin-left:4px;"><c:out value="${enrollment.warningMessage}"/></span>
                    <c:if test="${enrollment.warningStatus == 'appealed'}">
                        <div style="font-size:12px; color:#2a4365; margin-top:4px;">📩 Bạn đã gửi kháng cáo: <c:out value="${enrollment.appealMessage}"/></div>
                    </c:if>
                </div>
                <a href="${pageContext.request.contextPath}/student/my-courses" class="btn btn-sm" style="background:#ed8936; color:#fff; text-decoration:none; padding:5px 12px; border-radius:6px; font-weight:600; font-size:12px;">
                    Xem &amp; Phản hồi
                </a>
            </div>
        </c:if>

        <%-- Thông báo lỗi flash (nếu có) --%>
        <c:if test="${not empty error}">
            <div class="alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> ${error}</div>
        </c:if>

        <%-- Video bài học --%>
        <c:choose>
            <%-- Trường hợp 1: Link YouTube -> nhúng bằng iframe --%>
            <c:when test="${not empty youtubeEmbedUrl}">
                <div class="video-wrap" style="position:relative; padding-bottom:56.25%; height:0; overflow:hidden; border-bottom-left-radius: 0; border-bottom-right-radius: 0;">
                    <iframe id="youtube-player" src="${youtubeEmbedUrl}"
                            style="position:absolute; top:0; left:0; width:100%; height:100%; border:0;"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                            allowfullscreen>
                    </iframe>
                    <%-- IN-VIDEO INTERACTIVE QUIZ OVERLAY (H5P / COURSERA STYLE) --%>
                    <div id="inVideoQuizOverlay" class="in-video-quiz-overlay" style="display:none !important; position:absolute; top:0; left:0; right:0; bottom:0; width:100%; height:100%; background:rgba(15,23,42,0.92); backdrop-filter:blur(8px); z-index:99; padding:20px; box-sizing:border-box; color:#fff; flex-direction:column; justify-content:center; align-items:center; overflow-y:auto;">
                        <div style="max-width:580px; width:95%; background:#1e293b; border:1.5px solid #3b82f6; border-radius:14px; padding:22px 26px; box-shadow:0 16px 40px rgba(0,0,0,0.6); text-align:left; margin:auto;">
                            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                                <span style="background:#2563eb; color:#fff; font-size:11px; font-weight:700; padding:3px 10px; border-radius:20px; text-transform:uppercase; letter-spacing:0.5px;">
                                    <i class="fa-solid fa-lightbulb"></i> CÂU HỎI TƯƠNG TÁC GIỮA VIDEO
                                </span>
                                <span style="font-size:11.5px; color:#94a3b8;"><i class="fa-solid fa-lock"></i> Video đã tạm dừng</span>
                            </div>
                            <h3 id="ivqContent" class="ivq-content" style="margin:0 0 16px 0; font-size:15.5px; color:#f8fafc; font-weight:600; line-height:1.5;">...</h3>
                            <div id="ivqOptionsList" class="ivq-options-list" style="display:flex; flex-direction:column; gap:9px; margin-bottom:16px;">
                                <!-- Radio options -->
                            </div>
                            <div id="ivqMessage" class="ivq-message" style="font-size:13px; margin-bottom:14px; display:none; padding:10px 14px; border-radius:8px;"></div>
                            <div style="display:flex; justify-content:space-between; align-items:center; gap:10px; margin-top:8px;">
                                <button type="button" class="btn" style="background:#334155; color:#cbd5e1; border:none; padding:9px 16px; border-radius:8px; cursor:pointer; font-size:13px; font-weight:600; display:inline-flex; align-items:center; gap:6px;" onclick="rewindVideo(10)">
                                    <i class="fa-solid fa-rotate-left"></i> Xem lại 10s trước
                                </button>
                                <button type="button" id="ivqSubmitBtn" class="btn ivq-submit-btn" style="background:#3b82f6; color:#fff; font-weight:700; font-size:13px; padding:9px 20px; border-radius:8px; border:none; cursor:pointer;" onclick="verifyInVideoQuiz()">
                                    Kiểm Tra Đáp Án <i class="fa-solid fa-arrow-right"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    <%-- IN-VIDEO CODE CHECKPOINT LOCK OVERLAY --%>
                    <div id="inVideoCodeLockOverlay" class="in-video-code-overlay" style="display:none !important; position:absolute; top:0; left:0; right:0; bottom:0; width:100%; height:100%; background:rgba(15,23,42,0.94); backdrop-filter:blur(8px); z-index:99; padding:20px; box-sizing:border-box; color:#fff; flex-direction:column; justify-content:center; align-items:center; overflow-y:auto;">
                        <div style="max-width:540px; width:95%; background:#1e293b; border:1.5px solid #f59e0b; border-radius:14px; padding:24px 28px; box-shadow:0 16px 40px rgba(0,0,0,0.6); text-align:center; margin:auto;">
                            <div style="width:52px; height:52px; border-radius:50%; background:#78350f; color:#fde68a; display:inline-flex; align-items:center; justify-content:center; font-size:24px; margin-bottom:14px;">
                                <i class="fa-solid fa-lock"></i>
                            </div>
                            <h3 style="margin:0 0 10px 0; font-size:18px; color:#fef3c7; font-weight:700;">ĐIỂM DỪNG BÀI HỌC (CHECKPOINT CODE)</h3>
                            <p style="margin:0 0 18px 0; font-size:13.5px; color:#cbd5e1; line-height:1.6;">
                                Video đã bị tạm dừng tại mốc thời gian này. Bạn cần làm bài tập thực hành ở khung bên dưới và <strong>Nộp bài ĐẠT (Pass 100% Test Cases)</strong> để mở khóa xem tiếp video!
                            </p>
                            <div style="display:flex; justify-content:center; gap:12px; flex-wrap:wrap;">
                                <button type="button" class="btn" style="background:#334155; color:#cbd5e1; border:none; padding:10px 18px; border-radius:8px; cursor:pointer; font-size:13px; font-weight:600; display:inline-flex; align-items:center; gap:6px;" onclick="rewindVideo(10)">
                                    <i class="fa-solid fa-rotate-left"></i> Xem lại 10s trước
                                </button>
                                <button type="button" class="btn" style="background:#d97706; color:#fff; font-weight:700; font-size:14px; padding:11px 24px; border-radius:8px; border:none; cursor:pointer; display:inline-flex; align-items:center; gap:8px;" onclick="focusOnExercise()">
                                    <i class="fa-solid fa-code"></i> Thực Hành Viết Code Ngay <i class="fa-solid fa-arrow-down"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <%-- Custom Video Controls --%>
                <div class="custom-yt-controls" id="customControls">
                    <button id="ytPlayPauseBtn" type="button" class="yt-control-btn" title="Phát / Tạm dừng"><i class="fa-solid fa-play"></i></button>
                    <span id="ytVideoTime" class="yt-time-display">0:00 / 0:00</span>
                    <div class="yt-progress-container" id="ytProgressBarContainer" title="Tua video (Click trên thanh)">
                        <div class="yt-progress-bg">
                            <div class="yt-progress-fill" id="ytProgressBarFill"></div>
                        </div>
                    </div>
                    <button id="ytMuteBtn" type="button" class="yt-control-btn" title="Bật / Tắt âm thanh"><i class="fa-solid fa-volume-high"></i></button>
                </div>
                <%-- BANNER ĐIỂM DỪNG VIDEO CHECKPOINT --%>
                <div id="videoCheckpointNotice" style="display:none; background: #FFFBEB; border: 2px solid #F59E0B; border-radius: 12px; padding: 16px 20px; margin-top: 14px; margin-bottom: 20px; box-shadow: 0 4px 20px rgba(245,158,11,0.25); animation: pulse 2s infinite;">
                    <div style="display:flex; align-items:center; justify-content:space-between; gap:16px;">
                        <div style="display:flex; align-items:center; gap:14px;">
                            <div style="width:42px; height:42px; border-radius:50%; background:#FEF3C7; color:#D97706; display:flex; align-items:center; justify-content:center; font-size:20px; flex-shrink:0;">
                                <i class="fa-solid fa-circle-pause"></i>
                            </div>
                            <div>
                                <div style="font-weight:700; color:#92400E; font-size:15px;"><i class="fa-solid fa-lock"></i> ĐIỂM DỪNG VIDEO (INTERACTIVE CHECKPOINT)</div>
                                <div style="font-size:13px; color:#B45309;" id="checkpointNoticeMsg">Video đã tự động tạm dừng tại mốc thời gian bài học. Bạn cần thực hành và <strong>Nộp bài ĐẠT (Pass 100% Test cases)</strong> để mở khóa xem tiếp!</div>
                            </div>
                        </div>
                        <button type="button" class="btn" style="background:#D97706; color:#fff; font-weight:700; font-size:13px; padding:10px 18px; border-radius:8px; border:none; cursor:pointer;" onclick="focusOnExercise()">
                            <i class="fa-solid fa-code"></i> Thực Hành Ngay <i class="fa-solid fa-arrow-down"></i>
                        </button>
                    </div>
                </div>
            </c:when>

            <%-- Trường hợp 2: Link video file trực tiếp (.mp4...) -> dùng thẻ video với thanh điều khiển tuỳ biến --%>
            <c:when test="${not empty currentLesson.videoUrl}">
                <div class="video-wrap" style="position:relative; border-bottom-left-radius: 0; border-bottom-right-radius: 0;">
                    <video id="html5-video" width="100%" preload="metadata" style="display:block; width:100%; cursor:pointer;">
                        <source src="${currentLesson.videoUrl}" type="video/mp4" />
                        Trình duyệt của bạn không hỗ trợ thẻ video.
                    </video>
                    <%-- IN-VIDEO INTERACTIVE QUIZ OVERLAY FOR HTML5 VIDEO --%>
                    <div id="inVideoQuizOverlayHtml5" class="in-video-quiz-overlay" style="display:none !important; position:absolute; top:0; left:0; right:0; bottom:0; width:100%; height:100%; background:rgba(15,23,42,0.92); backdrop-filter:blur(8px); z-index:99; padding:20px; box-sizing:border-box; color:#fff; flex-direction:column; justify-content:center; align-items:center; overflow-y:auto;">
                        <div style="max-width:580px; width:95%; background:#1e293b; border:1.5px solid #3b82f6; border-radius:14px; padding:22px 26px; box-shadow:0 16px 40px rgba(0,0,0,0.6); text-align:left; margin:auto;">
                            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                                <span style="background:#2563eb; color:#fff; font-size:11px; font-weight:700; padding:3px 10px; border-radius:20px; text-transform:uppercase; letter-spacing:0.5px;">
                                    <i class="fa-solid fa-lightbulb"></i> CÂU HỎI TƯƠNG TÁC GIỮA VIDEO
                                </span>
                                <span style="font-size:11.5px; color:#94a3b8;"><i class="fa-solid fa-lock"></i> Video đã tạm dừng</span>
                            </div>
                            <h3 class="ivq-content" style="margin:0 0 16px 0; font-size:15.5px; color:#f8fafc; font-weight:600; line-height:1.5;">...</h3>
                            <div class="ivq-options-list" style="display:flex; flex-direction:column; gap:9px; margin-bottom:16px;">
                                <!-- Radio options -->
                            </div>
                            <div class="ivq-message" style="font-size:13px; margin-bottom:14px; display:none; padding:10px 14px; border-radius:8px;"></div>
                            <div style="display:flex; justify-content:space-between; align-items:center; gap:10px; margin-top:8px;">
                                <button type="button" class="btn" style="background:#334155; color:#cbd5e1; border:none; padding:9px 16px; border-radius:8px; cursor:pointer; font-size:13px; font-weight:600; display:inline-flex; align-items:center; gap:6px;" onclick="rewindVideo(10)">
                                    <i class="fa-solid fa-rotate-left"></i> Xem lại 10s trước
                                </button>
                                <button type="button" class="btn ivq-submit-btn" style="background:#3b82f6; color:#fff; font-weight:700; font-size:13px; padding:9px 20px; border-radius:8px; border:none; cursor:pointer;" onclick="verifyInVideoQuiz()">
                                    Kiểm Tra Đáp Án <i class="fa-solid fa-arrow-right"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    <%-- IN-VIDEO CODE CHECKPOINT LOCK OVERLAY FOR HTML5 VIDEO --%>
                    <div id="inVideoCodeLockOverlayHtml5" class="in-video-code-overlay" style="display:none !important; position:absolute; top:0; left:0; right:0; bottom:0; width:100%; height:100%; background:rgba(15,23,42,0.94); backdrop-filter:blur(8px); z-index:99; padding:20px; box-sizing:border-box; color:#fff; flex-direction:column; justify-content:center; align-items:center; overflow-y:auto;">
                        <div style="max-width:540px; width:95%; background:#1e293b; border:1.5px solid #f59e0b; border-radius:14px; padding:24px 28px; box-shadow:0 16px 40px rgba(0,0,0,0.6); text-align:center; margin:auto;">
                            <div style="width:52px; height:52px; border-radius:50%; background:#78350f; color:#fde68a; display:inline-flex; align-items:center; justify-content:center; font-size:24px; margin-bottom:14px;">
                                <i class="fa-solid fa-lock"></i>
                            </div>
                            <h3 style="margin:0 0 10px 0; font-size:18px; color:#fef3c7; font-weight:700;">ĐIỂM DỪNG BÀI HỌC (CHECKPOINT CODE)</h3>
                            <p style="margin:0 0 18px 0; font-size:13.5px; color:#cbd5e1; line-height:1.6;">
                                Video đã bị tạm dừng tại mốc thời gian này. Bạn cần làm bài tập thực hành ở khung bên dưới và <strong>Nộp bài ĐẠT (Pass 100% Test Cases)</strong> để mở khóa xem tiếp video!
                            </p>
                            <div style="display:flex; justify-content:center; gap:12px; flex-wrap:wrap;">
                                <button type="button" class="btn" style="background:#334155; color:#cbd5e1; border:none; padding:10px 18px; border-radius:8px; cursor:pointer; font-size:13px; font-weight:600; display:inline-flex; align-items:center; gap:6px;" onclick="rewindVideo(10)">
                                    <i class="fa-solid fa-rotate-left"></i> Xem lại 10s trước
                                </button>
                                <button type="button" class="btn" style="background:#d97706; color:#fff; font-weight:700; font-size:14px; padding:11px 24px; border-radius:8px; border:none; cursor:pointer; display:inline-flex; align-items:center; gap:8px;" onclick="focusOnExercise()">
                                    <i class="fa-solid fa-code"></i> Thực Hành Viết Code Ngay <i class="fa-solid fa-arrow-down"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <%-- Custom Video Controls for HTML5 Video --%>
                <div class="custom-yt-controls" id="customControlsHtml5">
                    <button id="html5PlayPauseBtn" type="button" class="yt-control-btn" title="Phát / Tạm dừng"><i class="fa-solid fa-play"></i></button>
                    <span id="html5VideoTime" class="yt-time-display">0:00 / 0:00</span>
                    <div class="yt-progress-container" id="html5ProgressBarContainer" title="Tua video (Click trên thanh)">
                        <div class="yt-progress-bg">
                            <div class="yt-progress-fill" id="html5ProgressBarFill"></div>
                        </div>
                    </div>
                    <button id="html5MuteBtn" type="button" class="yt-control-btn" title="Bật / Tắt âm thanh"><i class="fa-solid fa-volume-high"></i></button>
                </div>
                <%-- BANNER ĐIỂM DỪNG VIDEO CHECKPOINT --%>
                <div id="videoCheckpointNotice" style="display:none; background: #FFFBEB; border: 2px solid #F59E0B; border-radius: 12px; padding: 16px 20px; margin-top: 14px; margin-bottom: 20px; box-shadow: 0 4px 20px rgba(245,158,11,0.25); animation: pulse 2s infinite;">
                    <div style="display:flex; align-items:center; justify-content:space-between; gap:16px;">
                        <div style="display:flex; align-items:center; gap:14px;">
                            <div style="width:42px; height:42px; border-radius:50%; background:#FEF3C7; color:#D97706; display:flex; align-items:center; justify-content:center; font-size:20px; flex-shrink:0;">
                                <i class="fa-solid fa-circle-pause"></i>
                            </div>
                            <div>
                                <div style="font-weight:700; color:#92400E; font-size:15px;"><i class="fa-solid fa-lock"></i> ĐIỂM DỪNG VIDEO (INTERACTIVE CHECKPOINT)</div>
                                <div style="font-size:13px; color:#B45309;" id="checkpointNoticeMsg">Video đã tự động tạm dừng tại mốc thời gian bài học. Bạn cần thực hành và <strong>Nộp bài ĐẠT (Pass 100% Test cases)</strong> để mở khóa xem tiếp!</div>
                            </div>
                        </div>
                        <button type="button" class="btn" style="background:#D97706; color:#fff; font-weight:700; font-size:13px; padding:10px 18px; border-radius:8px; border:none; cursor:pointer;" onclick="focusOnExercise()">
                            <i class="fa-solid fa-code"></i> Thực Hành Ngay <i class="fa-solid fa-arrow-down"></i>
                        </button>
                    </div>
                </div>
            </c:when>

            <%-- Trường hợp 3: Không có video nào cả --%>
            <c:otherwise>
                <div class="no-video">
                    <div class="icon">🎬</div>
                    <p>Bài học này chưa có video.</p>
                </div>
            </c:otherwise>
        </c:choose>

        <%-- KHUNG THỰC HÀNH CODE (ONLINE COMPILER IDE) --%>
        <div class="resource-card" style="background:#FFFFFF;border:1px solid #C6D8E3;border-radius:14px;padding:18px 24px;margin-bottom:24px;display:flex;align-items:center;justify-content:space-between;gap:16px;box-shadow:0 4px 16px rgba(9,60,98,.04);">
            <div style="display:flex;align-items:center;gap:14px;">
                <div style="width:44px;height:44px;border-radius:10px;background:#EEF2FF;color:#4F46E5;display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;">
                    <i class="fa-solid fa-code"></i>
                </div>
                <div>
                    <div style="font-size:14px;font-weight:700;color:#093C62;">Trình biên dịch &amp; Thực hành Code Online</div>
                    <div style="font-size:12.5px;color:#64748B;">Lập trình, chạy thử code Java / Python / C++ trực tiếp ngay dưới bài học</div>
                </div>
            </div>
            <button type="button" onclick="toggleCompiler()" class="btn" style="background:#4F46E5;color:#fff;padding:10px 18px;font-size:13px;font-weight:700;border-radius:8px;border:none;cursor:pointer;display:inline-flex;align-items:center;gap:8px;box-shadow:0 4px 12px rgba(79,70,229,0.3);">
                <i class="fa-solid fa-laptop-code"></i> <span id="compilerBtnText">Bật Trình Viết Code</span>
            </button>
        </div>

                <%-- KHOANG ONLINE COMPILER & BÀI TẬP TEST CASES --%>
        <div id="compiler-section" class="compiler-section" style="margin-bottom: 24px; display: none;">
            
            <%-- KHUNG HIỂN THỊ ĐỀ BÀI (NẾU CÓ BÀI TẬP) --%>
            <div id="exercise-box" style="display:none; padding: 20px 24px; background: #0f172a; border-bottom: 2px solid #334155;">
                <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom: 12px;">
                    <div>
                        <span style="display:inline-block; font-size:11px; font-weight:700; text-transform:uppercase; background:#4338ca; color:#e0e7ff; padding:3px 10px; border-radius:20px; margin-bottom:6px;">
                            <i class="fa-solid fa-file-code"></i> BÀI TẬP THỰC HÀNH CỦA BÀI HỌC
                        </span>
                        <h3 id="ex-title" style="margin:0; font-size:19px; color:#f8fafc; font-weight:700;"></h3>
                    </div>
                    <div id="ex-status-badge" style="padding:6px 14px; border-radius:20px; font-size:12.5px; font-weight:700; display:inline-flex; align-items:center; gap:6px;">
                        <!-- Badge status -->
                    </div>
                </div>
                <div id="ex-desc" style="font-size:14px; color:#cbd5e1; line-height:1.6; white-space:pre-wrap; background:#1e293b; padding:14px 18px; border-radius:8px; border:1px solid #334155;"></div>
            </div>

            <%-- TOOLBAR TRÌNH SOẠN THẢO --%>
            <div class="compiler-toolbar" style="padding: 12px 20px;">
                <div style="font-weight: 600; font-size: 15px; display:flex; align-items:center; gap:8px;">
                    <i class="fa-solid fa-terminal" style="color:#10b981;"></i> 
                    <span id="compiler-mode-title">Online Multi-Language Compiler &amp; Sandbox</span>
                </div>
                <div style="display: flex; gap: 10px; align-items:center;">
                    <select id="compiler-lang" onchange="changeLang()">
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
                        <option value="ruby">Ruby</option>
                        <option value="sql">SQL (SQLite 3)</option>
                    </select>

                    <%-- Nút Chạy tự do --%>
                    <button id="btn-run" class="btn-run-code" style="background:#3b82f6;" onclick="runCode()">
                        <i class="fa-solid fa-play"></i> Run Code
                    </button>

                    <%-- Nút Chạy Test Case (chỉ hiện khi có bài tập) --%>
                    <button id="btn-test" class="btn-run-code" style="background:#10b981; display:none;" onclick="testCode()">
                        <i class="fa-solid fa-vial-circle-check"></i> Chạy Test Cases
                    </button>

                    <%-- Nút Nộp Bài Xác Thực (chỉ hiện khi có bài tập) --%>
                    <button id="btn-submit" class="btn-run-code" style="background:#6366f1; display:none;" onclick="submitCode()">
                        <i class="fa-solid fa-paper-plane"></i> Nộp Bài Chấm Điểm
                    </button>
                </div>
            </div>

            <div id="editor-wrapper">
                <textarea id="code-editor"></textarea>
            </div>

            <%-- BẢNG KẾT QUẢ KIỂM THỬ TEST CASES (NẾU CÓ BÀI TẬP) --%>
            <div id="testcases-result-box" style="display:none; background:#0f172a; padding:16px 20px; border-top:1px solid #334155;">
                <div style="font-weight:700; font-size:13.5px; color:#94a3b8; margin-bottom:10px; display:flex; justify-content:space-between; align-items:center;">
                    <span><i class="fa-solid fa-list-check" style="color:#38bdf8;"></i> KẾT QUẢ KIỂM THỬ TỰ ĐỘNG (TEST CASES)</span>
                    <span id="testcase-summary-score" style="font-size:13px; font-weight:700;"></span>
                </div>
                <div style="overflow-x:auto;">
                    <table style="width:100%; border-collapse:collapse; font-size:13px; font-family:Consolas, monospace;" id="testcases-table">
                        <thead>
                            <tr style="background:#1e293b; color:#94a3b8; text-align:left;">
                                <th style="padding:8px 12px; width:70px;">Test</th>
                                <th style="padding:8px 12px;">Đầu vào (Input)</th>
                                <th style="padding:8px 12px;">Kết quả mong đợi</th>
                                <th style="padding:8px 12px;">Kết quả chạy của bạn</th>
                                <th style="padding:8px 12px; width:120px; text-align:center;">Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody id="testcases-body">
                            <!-- Dynamic test cases -->
                        </tbody>
                    </table>
                </div>
            </div>

            <%-- CONSOLE OUTPUT --%>
            <div class="compiler-console" id="compiler-console">Ready. Chọn ngôn ngữ, viết code và bấm Run Code để chạy thử.</div>
        </div>

        <%-- Tài liệu đính kèm bài học --%>
        <c:if test="${not empty currentLesson.documentUrl}">
            <div class="resource-card" style="background:#FFFFFF;border:1px solid #C6D8E3;border-radius:14px;padding:18px 24px;margin-bottom:24px;display:flex;align-items:center;justify-content:space-between;gap:16px;box-shadow:0 4px 16px rgba(9,60,98,.04);">
                <div style="display:flex;align-items:center;gap:14px;">
                    <div style="width:44px;height:44px;border-radius:10px;background:#E0F2FE;color:#0284C7;display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;">
                        <i class="fa-solid fa-file-pdf"></i>
                    </div>
                    <div>
                        <div style="font-size:14px;font-weight:700;color:#093C62;">Tài liệu bài học</div>
                        <div style="font-size:12.5px;color:#64748B;">Tài liệu / Giáo trình đính kèm cho bài học này</div>
                    </div>
                </div>
                <a href="${currentLesson.documentUrl}" target="_blank" class="btn btn-outline" style="padding:10px 18px;font-size:13px;font-weight:700;border-radius:8px;text-decoration:none;display:inline-flex;align-items:center;gap:8px;">
                    <i class="fa-solid fa-arrow-up-right-from-square"></i> Mở tài liệu
                </a>
            </div>
        </c:if>

        <%-- Mô tả nội dung bài học (luôn hiển thị nếu có) --%>
        <c:if test="${not empty currentLesson.description}">
            <div class="lesson-desc-box">
                <div class="lesson-desc-header">
                    <i class="fa-solid fa-circle-info"></i> Mô tả bài học
                </div>
                <div class="lesson-desc-body"><c:out value="${fn:trim(currentLesson.description)}"/></div>
            </div>
        </c:if>

        <%-- Danh sách Bài kiểm tra & Bài tập liên quan đến chương hoặc khóa học --%>
        <c:set var="hasRelatedQuiz" value="false" />
        <c:forEach var="q" items="${quizzes}">
            <c:if test="${q.sectionId == currentLesson.sectionId || q.courseId != null}">
                <c:set var="hasRelatedQuiz" value="true" />
            </c:if>
        </c:forEach>

        <c:set var="hasRelatedAssignment" value="false" />
        <c:forEach var="asg" items="${assignments}">
            <c:if test="${asg.sectionId == currentLesson.sectionId || asg.sectionId == null}">
                <c:set var="hasRelatedAssignment" value="true" />
            </c:if>
        </c:forEach>

        <c:if test="${hasRelatedQuiz || hasRelatedAssignment}">
            <div class="activities-box" style="margin-top:28px;background:#FFFFFF;border:1px solid #C6D8E3;border-radius:16px;padding:22px 26px;box-shadow:0 4px 20px rgba(9,60,98,.05);">
                <div style="font-size:16px;font-weight:700;color:#093C62;margin-bottom:16px;display:flex;align-items:center;gap:8px;">
                    <i class="fa-solid fa-list-check" style="color:#076FA4;"></i> Bài kiểm tra & Bài tập liên quan
                </div>

                <div style="display:grid;grid-template-columns:repeat(auto-fit, minmax(280px, 1fr));gap:16px;">
                    <%-- Quizzes --%>
                    <c:forEach var="q" items="${quizzes}">
                        <c:if test="${q.sectionId == currentLesson.sectionId || q.courseId != null}">
                            <div style="border:1px solid #FDE68A;background:#FFFBEB;border-radius:12px;padding:16px;display:flex;flex-direction:column;justify-content:space-between;gap:12px;">
                                <div>
                                    <div style="display:flex;align-items:center;gap:8px;font-size:12px;font-weight:700;color:#B45309;text-transform:uppercase;">
                                        <i class="fa-solid fa-file-lines"></i> ${q.courseId != null ? 'Quiz Tổng Kết Khóa' : 'Quiz Chương'}
                                    </div>
                                    <div style="font-size:15px;font-weight:700;color:#92400E;margin-top:6px;"><c:out value="${q.title}"/></div>
                                    <div style="font-size:12.5px;color:#78350F;margin-top:4px;">
                                        Điểm đạt: <strong>${q.passScore}/100</strong>
                                        <c:if test="${q.timeLimitMinutes != null}"> · Thời gian: <strong>${q.timeLimitMinutes} phút</strong></c:if>
                                    </div>
                                </div>
                                <a href="${pageContext.request.contextPath}/student/quizzes/intro?id=${q.id}&lessonId=${currentLesson.id}" class="btn" style="background:#D97706;color:#fff;font-size:13px;font-weight:700;padding:9px 14px;border-radius:8px;text-decoration:none;display:inline-flex;align-items:center;justify-content:center;gap:6px;">
                                    <i class="fa-solid fa-eye"></i> Xem bài kiểm tra
                                </a>
                            </div>
                        </c:if>
                    </c:forEach>

                    <%-- Assignments --%>
                    <c:forEach var="asg" items="${assignments}">
                        <c:if test="${asg.sectionId == currentLesson.sectionId || asg.sectionId == null}">
                            <div style="border:1px solid #B2F5EA;background:#E6FFFA;border-radius:12px;padding:16px;display:flex;flex-direction:column;justify-content:space-between;gap:12px;">
                                <div>
                                    <div style="display:flex;align-items:center;gap:8px;font-size:12px;font-weight:700;color:#234E52;text-transform:uppercase;">
                                        <i class="fa-solid fa-paperclip"></i> ${asg.sectionId == null ? 'Bài Tập Toàn Khóa' : 'Bài Tập Chương'}
                                    </div>
                                    <div style="font-size:15px;font-weight:700;color:#234E52;margin-top:6px;"><c:out value="${asg.title}"/></div>
                                    <c:if test="${not empty asg.dueAt}">
                                        <div style="font-size:12.5px;color:#285E61;margin-top:4px;">
                                            Hạn nộp: <strong>${asg.dueAtDisplay}</strong>
                                        </div>
                                    </c:if>
                                </div>
                                <a href="${pageContext.request.contextPath}/student/assignments/view?id=${asg.id}" class="btn" style="background:#319795;color:#fff;font-size:13px;font-weight:700;padding:9px 14px;border-radius:8px;text-decoration:none;display:inline-flex;align-items:center;justify-content:center;gap:6px;">
                                    <i class="fa-solid fa-eye"></i> Xem bài tập
                                </a>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
            </div>
        </c:if>

                <%-- Nút vào không gian Nhóm (Chỉ hiện cho Student đã enroll và Giáo viên) --%>
        <c:if test="${enrollment != null || isPreview}">
            <a href="${pageContext.request.contextPath}/student/my-group?courseId=${course.id}" class="doc-link" style="background:#0ea5e9; color:#fff; border-color:#0ea5e9; --ml: ${empty currentLesson.documentUrl ? '0' : '12px'}; margin-left: var(--ml);">
                <i class="fa-solid fa-users"></i> Xem Nhóm Của Tôi & Nộp Bài
            </a>
            
            <%-- Nút Bật giao diện Code (Tính năng mới) --%>
            <button onclick="toggleCompiler()" class="toggle-compiler-btn" style="margin-left: 12px; margin-top: 12px;">
                <i class="fa-solid fa-code"></i> Thực hành Code
            </button>
        </c:if>

        <hr class="divider">

        <%-- Form đánh dấu hoàn thành & Thẻ đánh giá điều kiện mở khóa --%>
        <c:choose>
            <c:when test="${enrollment != null}">
                <div class="complete-card">
                    <h3><i class="fa-solid fa-circle-check"></i> Tiến độ bài học</h3>

                    <c:choose>
                        <%-- Trường hợp 1: Bài học yêu cầu Quiz --%>
                        <c:when test="${currentLesson.assessmentType == 'quiz'}">
                            <c:choose>
                                <c:when test="${hasPassedAssessment || completedLessonIds.contains(currentLesson.id)}">
                                    <div style="background:#ecfdf5; border:1.5px solid #a7f3d0; border-radius:12px; padding:16px 20px; display:flex; align-items:center; justify-content:space-between; gap:16px; margin-bottom:12px;">
                                        <div style="display:flex; align-items:center; gap:12px;">
                                            <div style="width:40px; height:40px; border-radius:50%; background:#d1fae5; color:#059669; display:flex; align-items:center; justify-content:center; font-size:18px; flex-shrink:0;">
                                                <i class="fa-solid fa-check"></i>
                                            </div>
                                            <div>
                                                <div style="font-weight:700; color:#065f46; font-size:14.5px;">Bạn đã hoàn thành bài kiểm tra Quiz!</div>
                                                <div style="font-size:13px; color:#047857;">Bài học này đã được hệ thống tự động ghi nhận hoàn thành. Bài học tiếp theo đã được mở khóa.</div>
                                            </div>
                                        </div>
                                        <c:if test="${assessmentQuiz != null}">
                                            <a href="${pageContext.request.contextPath}/student/quizzes/intro?id=${assessmentQuiz.id}&lessonId=${currentLesson.id}" class="btn" style="background:#059669; color:#fff; font-size:13px; font-weight:700; padding:8px 16px; border-radius:8px; text-decoration:none; flex-shrink:0;">
                                                <i class="fa-solid fa-rotate-right"></i> Xem lại Quiz
                                            </a>
                                        </c:if>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="background:#fffbeb; border:2px solid #f59e0b; border-radius:14px; padding:20px 24px; box-shadow:0 4px 16px rgba(245,158,11,0.12); margin-bottom:12px;">
                                        <div style="display:flex; align-items:flex-start; justify-content:space-between; gap:16px; flex-wrap:wrap;">
                                            <div style="display:flex; gap:14px; flex:1; min-width:260px;">
                                                <div style="width:46px; height:46px; border-radius:12px; background:#fef3c7; color:#d97706; display:flex; align-items:center; justify-content:center; font-size:22px; flex-shrink:0;">
                                                    <i class="fa-solid fa-lock"></i>
                                                </div>
                                                <div>
                                                    <div style="font-weight:800; color:#92400e; font-size:16px;">Yêu cầu hoàn thành: Bài kiểm tra Quiz</div>
                                                    <div style="font-size:13.5px; color:#b45309; margin-top:4px; line-height:1.5;">
                                                        Bài học này có bài kiểm tra bắt buộc: <strong><c:out value="${assessmentQuiz != null ? assessmentQuiz.title : 'Quiz'}"/></strong>.
                                                        <c:if test="${assessmentQuiz != null}">
                                                            (Điểm cần đạt: <strong>${assessmentQuiz.passScore}/100</strong>)
                                                        </c:if>
                                                        <br>Bạn phải vượt qua bài kiểm tra này để hoàn thành bài học và mở khóa bài tiếp theo!
                                                    </div>
                                                </div>
                                            </div>
                                            <c:if test="${assessmentQuiz != null}">
                                                <a href="${pageContext.request.contextPath}/student/quizzes/intro?id=${assessmentQuiz.id}&lessonId=${currentLesson.id}" class="btn" style="background:#d97706; color:#fff; font-size:14px; font-weight:700; padding:11px 20px; border-radius:10px; text-decoration:none; display:inline-flex; align-items:center; gap:8px; flex-shrink:0; box-shadow:0 4px 12px rgba(217,119,6,0.3);">
                                                    <i class="fa-solid fa-pen-to-square"></i> Làm bài Quiz ngay
                                                </a>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:when>

                        <%-- Trường hợp 2: Bài học yêu cầu Code --%>
                        <c:when test="${currentLesson.assessmentType == 'code'}">
                            <c:choose>
                                <c:when test="${hasPassedAssessment || completedLessonIds.contains(currentLesson.id)}">
                                    <div style="background:#ecfdf5; border:1.5px solid #a7f3d0; border-radius:12px; padding:16px 20px; display:flex; align-items:center; justify-content:space-between; gap:16px; margin-bottom:12px;">
                                        <div style="display:flex; align-items:center; gap:12px;">
                                            <div style="width:40px; height:40px; border-radius:50%; background:#d1fae5; color:#059669; display:flex; align-items:center; justify-content:center; font-size:18px; flex-shrink:0;">
                                                <i class="fa-solid fa-check"></i>
                                            </div>
                                            <div>
                                                <div style="font-weight:700; color:#065f46; font-size:14.5px;">Bạn đã hoàn thành bài tập Code (100% Test Cases Passed)!</div>
                                                <div style="font-size:13px; color:#047857;">Bài học này đã được hệ thống tự động ghi nhận hoàn thành. Bài học tiếp theo đã được mở khóa.</div>
                                            </div>
                                        </div>
                                        <button type="button" onclick="focusOnExercise()" class="btn" style="background:#059669; color:#fff; font-size:13px; font-weight:700; padding:8px 16px; border-radius:8px; border:none; cursor:pointer; flex-shrink:0;">
                                            <i class="fa-solid fa-code"></i> Xem lại Code
                                        </button>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="background:#eff6ff; border:2px solid #3b82f6; border-radius:14px; padding:20px 24px; box-shadow:0 4px 16px rgba(59,130,246,0.12); margin-bottom:12px;">
                                        <div style="display:flex; align-items:flex-start; justify-content:space-between; gap:16px; flex-wrap:wrap;">
                                            <div style="display:flex; gap:14px; flex:1; min-width:260px;">
                                                <div style="width:46px; height:46px; border-radius:12px; background:#dbeafe; color:#1d4ed8; display:flex; align-items:center; justify-content:center; font-size:22px; flex-shrink:0;">
                                                    <i class="fa-solid fa-laptop-code"></i>
                                                </div>
                                                <div>
                                                    <div style="font-weight:800; color:#1e40af; font-size:16px;">Yêu cầu hoàn thành: Bài tập lập trình Code</div>
                                                    <div style="font-size:13.5px; color:#1d4ed8; margin-top:4px; line-height:1.5;">
                                                        Bài học này có bài tập thực hành viết code bắt buộc. Bạn cần lập trình và nộp bài vượt qua <strong>100% Test Cases</strong> trong khung biên dịch bên dưới để hoàn thành bài học và mở khóa bài tiếp theo!
                                                    </div>
                                                </div>
                                            </div>
                                            <button type="button" onclick="focusOnExercise()" class="btn" style="background:#2563eb; color:#fff; font-size:14px; font-weight:700; padding:11px 20px; border-radius:10px; border:none; cursor:pointer; display:inline-flex; align-items:center; gap:8px; flex-shrink:0; box-shadow:0 4px 12px rgba(37,99,235,0.3);">
                                                <i class="fa-solid fa-terminal"></i> Viết Code & Nộp bài <i class="fa-solid fa-arrow-down"></i>
                                            </button>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:when>

                        <%-- Trường hợp 3: Bài học yêu cầu Nộp Assignment --%>
                        <c:when test="${currentLesson.assessmentType == 'assignment'}">
                            <c:choose>
                                <c:when test="${hasPassedAssessment || completedLessonIds.contains(currentLesson.id)}">
                                    <div style="background:#ecfdf5; border:1.5px solid #a7f3d0; border-radius:12px; padding:16px 20px; display:flex; align-items:center; justify-content:space-between; gap:16px; margin-bottom:12px;">
                                        <div style="display:flex; align-items:center; gap:12px;">
                                            <div style="width:40px; height:40px; border-radius:50%; background:#d1fae5; color:#059669; display:flex; align-items:center; justify-content:center; font-size:18px; flex-shrink:0;">
                                                <i class="fa-solid fa-check"></i>
                                            </div>
                                            <div>
                                                <div style="font-weight:700; color:#065f46; font-size:14.5px;">Bạn đã nộp bài tập Assignment thành công!</div>
                                                <div style="font-size:13px; color:#047857;">Bài học này đã được hệ thống tự động ghi nhận hoàn thành. Bài học tiếp theo đã được mở khóa.</div>
                                            </div>
                                        </div>
                                        <c:if test="${assessmentAssignment != null}">
                                            <a href="${pageContext.request.contextPath}/student/assignments/view?id=${assessmentAssignment.id}" class="btn" style="background:#059669; color:#fff; font-size:13px; font-weight:700; padding:8px 16px; border-radius:8px; text-decoration:none; flex-shrink:0;">
                                                <i class="fa-solid fa-eye"></i> Xem bài nộp
                                            </a>
                                        </c:if>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="background:#f0fdfa; border:2px solid #0d9488; border-radius:14px; padding:20px 24px; box-shadow:0 4px 16px rgba(13,148,136,0.12); margin-bottom:12px;">
                                        <div style="display:flex; align-items:flex-start; justify-content:space-between; gap:16px; flex-wrap:wrap;">
                                            <div style="display:flex; gap:14px; flex:1; min-width:260px;">
                                                <div style="width:46px; height:46px; border-radius:12px; background:#ccfbf1; color:#0f766e; display:flex; align-items:center; justify-content:center; font-size:22px; flex-shrink:0;">
                                                    <i class="fa-solid fa-paperclip"></i>
                                                </div>
                                                <div>
                                                    <div style="font-weight:800; color:#134e4a; font-size:16px;">Yêu cầu hoàn thành: Nộp bài tập Assignment</div>
                                                    <div style="font-size:13.5px; color:#0f766e; margin-top:4px; line-height:1.5;">
                                                        Bài học này yêu cầu bạn nộp bài tập: <strong><c:out value="${assessmentAssignment != null ? assessmentAssignment.title : 'Bài tập'}"/></strong>.
                                                        <br>Bạn cần tải lên tệp bài làm để hoàn thành bài học và mở khóa bài tiếp theo!
                                                    </div>
                                                </div>
                                            </div>
                                            <c:if test="${assessmentAssignment != null}">
                                                <a href="${pageContext.request.contextPath}/student/assignments/view?id=${assessmentAssignment.id}" class="btn" style="background:#0d9488; color:#fff; font-size:14px; font-weight:700; padding:11px 20px; border-radius:10px; text-decoration:none; display:inline-flex; align-items:center; gap:8px; flex-shrink:0; box-shadow:0 4px 12px rgba(13,148,136,0.3);">
                                                    <i class="fa-solid fa-upload"></i> Nộp bài tập ngay
                                                </a>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:when>

                        <%-- Trường hợp 4: Không có assessment (none hoặc rỗng) -> Thủ công như cũ --%>
                        <c:otherwise>
                            <form action="${pageContext.request.contextPath}/student/lessons/complete" method="post">
                                <input type="hidden" name="lessonId" value="${currentLesson.id}" />
                                <input type="hidden" name="courseId" value="${course.id}" />
                                <div class="form-check">
                                    <input type="checkbox" name="completed" id="completedCheck"
                                           <c:if test="${completedLessonIds.contains(currentLesson.id)}">checked</c:if> />
                                    <label class="form-check-label" for="completedCheck">
                                        Đánh dấu bài học này đã hoàn thành
                                    </label>
                                </div>
                                <button type="submit" class="btn btn-success">💾 Lưu tiến độ</button>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:when>
            <c:when test="${isPreview}">
                <div class="complete-card" style="border-left: 4px solid #076FA4; background: #F0F9FF;">
                    <h3 style="color:#0369A1; margin-bottom:12px;"><i class="fa-solid fa-eye" style="color:#076FA4;"></i> Tiến độ bài học (Chế độ xem trước)</h3>
                    <c:if test="${currentLesson.assessmentType != null && currentLesson.assessmentType != 'none'}">
                        <div style="background:#e0f2fe; border:1px solid #7dd3fc; border-radius:8px; padding:10px 14px; margin-bottom:12px; font-size:13px; color:#0369a1;">
                            <i class="fa-solid fa-lock"></i> <strong>Cấu hình bài học:</strong> 
                            <c:choose>
                                <c:when test="${currentLesson.assessmentType == 'quiz'}">Học viên phải đạt Quiz: <strong><c:out value="${assessmentQuiz != null ? assessmentQuiz.title : ''}"/></strong> để mở khóa bài tiếp theo.</c:when>
                                <c:when test="${currentLesson.assessmentType == 'code'}">Học viên phải hoàn thành 100% test cases bài tập Code để mở khóa bài tiếp theo.</c:when>
                                <c:when test="${currentLesson.assessmentType == 'assignment'}">Học viên phải nộp bài tập: <strong><c:out value="${assessmentAssignment != null ? assessmentAssignment.title : ''}"/></strong> để mở khóa bài tiếp theo.</c:when>
                            </c:choose>
                        </div>
                    </c:if>
                    <div class="form-check" style="margin-bottom:12px; opacity:0.75;">
                        <input type="checkbox" id="previewCompletedCheck" disabled />
                        <label class="form-check-label" for="previewCompletedCheck" style="cursor:not-allowed; color:#64748B;">
                            Đánh dấu bài học này đã hoàn thành (Khóa trong chế độ xem trước)
                        </label>
                    </div>
                    <button type="button" class="btn btn-success" disabled style="opacity:0.6; cursor:not-allowed; background:#94A3B8; box-shadow:none;">
                        <i class="fa-solid fa-lock"></i> Chỉ xem nội dung (Không thể tick tiến độ)
                    </button>
                    <p style="font-size:13px; color:#64748B; margin-top:12px; margin-bottom:0;">
                        <i class="fa-solid fa-circle-info"></i> Bạn đang xem giao diện học viên với tư cách Giảng viên / Quản trị viên (được mở khóa xem trước tất cả bài học trong khóa).
                    </p>
                </div>
            </c:when>
        </c:choose>
    </main>
<!-- Code Compiler -->
<script>
    let codeEditor = null;
    let isCompilerVisible = false;

    function toggleCompiler() {
        const section = document.getElementById('compiler-section');
        isCompilerVisible = !isCompilerVisible;
        
        if(isCompilerVisible) {
            section.style.display = 'block';
            if(!codeEditor) {
                const lang = document.getElementById('compiler-lang').value || 'java';
                codeEditor = CodeMirror.fromTextArea(document.getElementById('code-editor'), {
                    mode: modes[lang] || 'text/x-java',
                    theme: 'dracula',
                    lineNumbers: true,
                    indentUnit: 4,
                    matchBrackets: true
                });
                if(cachedExercise && (cachedExercise.initialCode || cachedExercise.starterCode)) {
                    codeEditor.setValue(cachedExercise.initialCode || cachedExercise.starterCode);
                    if(modes[cachedExercise.language]) {
                        codeEditor.setOption('mode', modes[cachedExercise.language]);
                    }
                } else {
                    changeLang();
                }
            }
            // Cuộn trang xuống chỗ compiler mượt mà
            setTimeout(() => {
                section.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }, 100);
        } else {
            section.style.display = 'none';
        }
    }

    const boilerplates = {
        'java': "public class Main {\n    public static void main(String[] args) {\n        System.out.println(\"Hello LMS Compiler!\");\n    }\n}",
        'python': "print(\"Hello LMS Compiler!\")\n",
        'cpp': "#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << \"Hello LMS Compiler!\" << endl;\n    return 0;\n}"
    };

    const modes = {
        'java': 'text/x-java',
        'python': 'text/x-python',
        'cpp': 'text/x-c++src'
    };

    function changeLang() {
        if(!codeEditor) return;
        const lang = document.getElementById('compiler-lang').value;
        codeEditor.setOption('mode', modes[lang]);
        if(codeEditor.getValue().trim() === '' || codeEditor.getValue().includes("Hello LMS")) {
            codeEditor.setValue(boilerplates[lang]);
        }
    }

    function runCode() {
        if(!codeEditor) return;
        if(currentExerciseId) {
            testCode();
            return;
        }
        const code = codeEditor.getValue();
        const lang = document.getElementById('compiler-lang').value;
        const consoleEl = document.getElementById('compiler-console');
        const btnRun = document.getElementById('btn-run');
        
        consoleEl.innerHTML = '<span style="color:#fbbf24;">[Chạy code...] Đang biên dịch và thực thi trên Sandbox...</span>';
        btnRun.disabled = true;
        btnRun.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Running...';

        fetch('${pageContext.request.contextPath}/api/compiler/run', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ language: lang, code: code, stdin: '' })
        })
        .then(res => res.json())
        .then(data => {
            btnRun.disabled = false;
            btnRun.innerHTML = '<i class="fa-solid fa-play"></i> Run Code';
            
            if(data.success) {
                consoleEl.innerHTML = '<span style="color:#a7f3d0;">[Thành công] Output:</span>\n' + escapeHtml(data.output);
            } else {
                consoleEl.innerHTML = '<span style="color:#f87171;">[Lỗi]</span>\n' + escapeHtml(data.output);
            }
        })
        .catch(err => {
            btnRun.disabled = false;
            btnRun.innerHTML = '<i class="fa-solid fa-play"></i> Run Code';
            consoleEl.innerHTML = '<span style="color:#f87171;">[Lỗi Hệ Thống] Không thể kết nối tới Server. Chi tiết: ' + err + '</span>';
        });
    }

    function escapeHtml(text) {
        if (!text) return "";
        return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    }

    function formatTime(seconds) {
        if (!seconds || isNaN(seconds)) return "0:00";
        var m = Math.floor(seconds / 60);
        var s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    var isPreview = '${isPreview}' === 'true';
    let currentExerciseId = null;
    let checkpointData = null;
    let checkpointPassed = isPreview ? true : false;
    let suppressCheckpointCheck = false;

    document.addEventListener("DOMContentLoaded", function() {
        loadLessonExercise();
        loadLessonCheckpoint();

        // Cấu hình sự kiện cho Video HTML5 (nếu có)
        const html5Vid = document.getElementById('html5-video');
        const html5PlayBtn = document.getElementById('html5PlayPauseBtn');
        const html5MuteBtn = document.getElementById('html5MuteBtn');
        const html5Prog = document.getElementById('html5ProgressBarContainer');

        if(html5Vid) {
            function toggleHtml5Play() {
                if(!isPreview && !checkpointPassed && isCheckpointBlocked(html5Vid.currentTime)) {
                    lockVideoAtCheckpoint();
                    return;
                }
                if(html5Vid.paused) {
                    html5Vid.play();
                } else {
                    html5Vid.pause();
                }
            }

            if(html5PlayBtn) html5PlayBtn.addEventListener('click', toggleHtml5Play);
            html5Vid.addEventListener('click', toggleHtml5Play);

            html5Vid.addEventListener('play', function() {
                if(html5PlayBtn) html5PlayBtn.innerHTML = '<i class="fa-solid fa-pause"></i>';
            });
            html5Vid.addEventListener('pause', function() {
                if(html5PlayBtn) html5PlayBtn.innerHTML = '<i class="fa-solid fa-play"></i>';
            });

            html5Vid.addEventListener('timeupdate', function() {
                const current = html5Vid.currentTime;
                const duration = html5Vid.duration || 0;
                
                if (duration > 0) {
                    const percent = (current / duration) * 100;
                    const fill = document.getElementById('html5ProgressBarFill');
                    if (fill) fill.style.width = percent + '%';
                }
                const timeDisplay = document.getElementById('html5VideoTime');
                if (timeDisplay) {
                    timeDisplay.innerText = formatTime(current) + " / " + formatTime(duration);
                }

                renderAllCheckpointMarkers();
                checkVideoCheckpoint(current);
            });

            html5Vid.addEventListener('loadedmetadata', function() {
                const duration = html5Vid.duration || 0;
                const timeDisplay = document.getElementById('html5VideoTime');
                if (timeDisplay) {
                    timeDisplay.innerText = formatTime(0) + " / " + formatTime(duration);
                }
                renderAllCheckpointMarkers();
            });

            if(html5MuteBtn) {
                html5MuteBtn.addEventListener('click', function() {
                    html5Vid.muted = !html5Vid.muted;
                    html5MuteBtn.innerHTML = html5Vid.muted
                        ? '<i class="fa-solid fa-volume-xmark"></i>'
                        : '<i class="fa-solid fa-volume-high"></i>';
                });
            }

            if(html5Prog) {
                html5Prog.addEventListener('click', function(e) {
                    onProgressBarClick(e, html5Prog, () => html5Vid.duration, (t) => {
                        html5Vid.currentTime = t;
                    });
                });
            }
        }
    });

    let cachedExercise = null;

    function loadLessonExercise() {
        fetch('${pageContext.request.contextPath}/api/compiler/exercise?lessonId=${currentLesson.id}')
            .then(res => res.json())
            .then(data => {
                if(data.success && data.hasExercise) {
                    const ex = data.exercise || data;
                    cachedExercise = ex;
                    currentExerciseId = ex.exerciseId || ex.id;
                    const exBox = document.getElementById('exercise-box');
                    if(exBox) exBox.style.display = 'block';
                    const exTitle = document.getElementById('ex-title');
                    if(exTitle) exTitle.innerText = ex.title || 'Bài tập thực hành';
                    const exDesc = document.getElementById('ex-desc');
                    if(exDesc) exDesc.innerText = ex.description || '';

                    const statusBadge = document.getElementById('ex-status-badge');
                    if(statusBadge) {
                        if(data.isPassed || data.passed || isPreview) {
                            checkpointPassed = true;
                            renderAllCheckpointMarkers();
                            statusBadge.style.background = '#065f46';
                            statusBadge.style.color = '#34d399';
                            statusBadge.innerHTML = '<i class="fa-solid fa-circle-check"></i> ĐÃ HOÀN THÀNH (ĐẠT 100%)';
                        } else {
                            statusBadge.style.background = '#78350f';
                            statusBadge.style.color = '#fde68a';
                            statusBadge.innerHTML = '<i class="fa-solid fa-clock"></i> CHƯA ĐẠT (CẦN NỘP BÀI)';
                        }
                    }

                    if(ex.language) {
                        const langSelect = document.getElementById('compiler-lang');
                        if(langSelect) {
                            langSelect.value = ex.language;
                        }
                        const initialCode = ex.initialCode || ex.starterCode;
                        if(initialCode) {
                            boilerplates[ex.language] = initialCode;
                            if(codeEditor) {
                                codeEditor.setValue(initialCode);
                                if(modes[ex.language]) codeEditor.setOption('mode', modes[ex.language]);
                            }
                        }
                    }

                    const btnTest = document.getElementById('btn-test');
                    if(btnTest) btnTest.style.display = 'inline-flex';
                    const btnSub = document.getElementById('btn-submit');
                    if(btnSub) btnSub.style.display = 'inline-flex';

                    const tcases = ex.testCases || [];
                    if(tcases.length > 0) {
                        renderInitialTestCases(tcases);
                    }
                }
            })
            .catch(err => console.error("Error loading exercise:", err));
    }

    function renderInitialTestCases(testCases) {
        const tbody = document.getElementById('testcases-body');
        if(!tbody) return;
        tbody.innerHTML = '';
        const summaryScore = document.getElementById('testcase-summary-score');
        if(summaryScore) {
            summaryScore.style.color = '#94a3b8';
            summaryScore.innerText = 'Tổng số: ' + testCases.length + ' Test Cases';
        }
        testCases.forEach((tc, idx) => {
            const tr = document.createElement('tr');
            tr.style.borderBottom = '1px solid #1e293b';
            const inText = tc.isHidden ? '<span style="color:#64748b; font-style:italic;">(Test case ẩn)</span>' : escapeHtml(tc.inputData || tc.input || '(None)');
            const outText = tc.isHidden ? '<span style="color:#64748b; font-style:italic;">(Test case ẩn)</span>' : escapeHtml(tc.expectedOutput || tc.expected || '');
            tr.innerHTML = '<td style="padding:10px 12px; color:#94a3b8; font-weight:700;">#' + (idx + 1) + '</td>' +
                '<td style="padding:10px 12px; color:#e2e8f0; font-family:monospace;">' + inText + '</td>' +
                '<td style="padding:10px 12px; color:#38bdf8; font-family:monospace;">' + outText + '</td>' +
                '<td style="padding:10px 12px; color:#94a3b8; font-style:italic;">Chưa chạy</td>' +
                '<td style="padding:10px 12px; text-align:center;">' +
                    '<span style="background:#334155; color:#94a3b8; padding:3px 10px; border-radius:12px; font-size:11px; font-weight:700;">CHƯA CHẠY</span>' +
                '</td>';
            tbody.appendChild(tr);
        });
        const resBox = document.getElementById('testcases-result-box');
        if(resBox) resBox.style.display = 'block';
    }

    function loadLessonCheckpoint() {
        fetch('${pageContext.request.contextPath}/api/checkpoint?lessonId=${currentLesson.id}')
            .then(res => res.json())
            .then(data => {
                if(data.success && data.hasCheckpoint) {
                    checkpointData = data;
                    if(data.isPassed || isPreview) {
                        checkpointPassed = true;
                    }
                    renderAllCheckpointMarkers();
                }
            })
            .catch(err => console.error("Error loading checkpoint:", err));
    }

    function isCheckpointBlocked(currentTime) {
        if(isPreview || checkpointPassed) return false;
        if(!checkpointData || !checkpointData.hasCheckpoint || !checkpointData.checkpointSeconds || checkpointData.checkpointSeconds <= 0) return false;
        if(typeof currentTime !== 'number' || isNaN(currentTime)) return false;
        return currentTime >= checkpointData.checkpointSeconds;
    }

    function checkVideoCheckpoint(currentTime) {
        if(suppressCheckpointCheck || isPreview || checkpointPassed) return;
        if(!checkpointData || !checkpointData.hasCheckpoint) return;
        if(isCheckpointBlocked(currentTime)) {
            lockVideoAtCheckpoint();
        }
    }

    function lockVideoAtCheckpoint() {
        if(isPreview || checkpointPassed || !checkpointData) return;

        // Dừng video ngay lập tức và đưa về mốc checkpoint
        if(player) {
            if(typeof player.pauseVideo === 'function') player.pauseVideo();
            if(typeof player.seekTo === 'function') player.seekTo(checkpointData.checkpointSeconds, true);
        }
        const html5Vid = document.getElementById('html5-video');
        if(html5Vid) {
            html5Vid.pause();
            html5Vid.currentTime = checkpointData.checkpointSeconds;
        }

        const ytPlayBtn = document.getElementById('ytPlayPauseBtn');
        if(ytPlayBtn) ytPlayBtn.innerHTML = '<i class="fa-solid fa-play"></i>';
        const html5PlayBtn = document.getElementById('html5PlayPauseBtn');
        if(html5PlayBtn) html5PlayBtn.innerHTML = '<i class="fa-solid fa-play"></i>';

        // Kích hoạt overlay tương ứng
        const cpType = (checkpointData.checkpointType || '').toLowerCase();
        if(cpType === 'quiz') {
            showInVideoQuizOverlay();
        } else if(cpType === 'code') {
            showInVideoCodeLockOverlay();
            showCodeCheckpointNotice();
        }
    }

    function hideAllCheckpointOverlays() {
        const overlays = document.querySelectorAll('.in-video-quiz-overlay, .in-video-code-overlay, #inVideoQuizOverlay, #inVideoCodeLockOverlay');
        overlays.forEach(ov => ov.style.setProperty('display', 'none', 'important'));
    }

    function rewindVideo(seconds) {
        hideAllCheckpointOverlays();
        suppressCheckpointCheck = true;
        const cpSec = (checkpointData && checkpointData.checkpointSeconds) ? checkpointData.checkpointSeconds : 10;
        const target = Math.max(0, cpSec - (seconds || 10));

        if(player && typeof player.seekTo === 'function') {
            player.seekTo(target, true);
            player.playVideo();
            const ytPlayBtn = document.getElementById('ytPlayPauseBtn');
            if(ytPlayBtn) ytPlayBtn.innerHTML = '<i class="fa-solid fa-pause"></i>';
        }
        const html5Vid = document.getElementById('html5-video');
        if(html5Vid) {
            html5Vid.currentTime = target;
            html5Vid.play();
            const html5PlayBtn = document.getElementById('html5PlayPauseBtn');
            if(html5PlayBtn) html5PlayBtn.innerHTML = '<i class="fa-solid fa-pause"></i>';
        }

        setTimeout(() => {
            suppressCheckpointCheck = false;
        }, 800);
    }

    function seekVideoTo(targetTime) {
        suppressCheckpointCheck = true;
        if(player && typeof player.seekTo === 'function') {
            player.seekTo(targetTime, true);
        }
        const html5Vid = document.getElementById('html5-video');
        if(html5Vid) {
            html5Vid.currentTime = targetTime;
        }
        setTimeout(() => {
            suppressCheckpointCheck = false;
        }, 800);
    }

    function onProgressBarClick(e, container, getDurationFn, seekToFn) {
        const rect = container.getBoundingClientRect();
        const pos = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
        const duration = getDurationFn();
        if(!duration || duration <= 0) return;
        const targetTime = pos * duration;

        if(!isPreview && !checkpointPassed && checkpointData && checkpointData.hasCheckpoint && checkpointData.checkpointSeconds) {
            if(targetTime >= checkpointData.checkpointSeconds) {
                // Tua vượt qua checkpoint bị chặn -> dừng lại ở checkpoint và hiển thị câu hỏi/bài tập
                seekToFn(checkpointData.checkpointSeconds);
                lockVideoAtCheckpoint();
                return;
            }
        }

        // Tua lùi hoặc tua trong khoảng hợp lệ -> cho phép tự do
        hideAllCheckpointOverlays();
        suppressCheckpointCheck = true;
        seekToFn(targetTime);
        setTimeout(() => {
            suppressCheckpointCheck = false;
        }, 800);
    }

    function renderCheckpointMarker(containerEl, duration) {
        if(!containerEl || !checkpointData || !checkpointData.checkpointSeconds || duration <= 0) return;
        const cpSec = checkpointData.checkpointSeconds;
        const percent = Math.min(100, Math.max(0, (cpSec / duration) * 100));

        let marker = containerEl.querySelector('.checkpoint-marker-dot');
        if(!marker) {
            marker = document.createElement('div');
            marker.className = 'checkpoint-marker-dot' + (checkpointPassed ? ' passed' : '');

            const tooltip = document.createElement('span');
            tooltip.className = 'checkpoint-tooltip';
            marker.appendChild(tooltip);

            marker.addEventListener('click', function(e) {
                e.stopPropagation();
                if(isPreview || checkpointPassed) {
                    seekVideoTo(cpSec);
                } else {
                    seekVideoTo(cpSec);
                    lockVideoAtCheckpoint();
                }
            });

            containerEl.appendChild(marker);
        }

        marker.style.left = percent + '%';
        if(checkpointPassed) {
            marker.classList.add('passed');
        } else {
            marker.classList.remove('passed');
        }

        const tooltip = marker.querySelector('.checkpoint-tooltip');
        if(tooltip) {
            const isQuiz = (checkpointData.checkpointType || '').toLowerCase() === 'quiz';
            const typeLabel = isQuiz ? 'Quiz trắc nghiệm' : 'Bài tập Code';
            const timeStr = formatTime(cpSec);
            if(checkpointPassed) {
                tooltip.innerHTML = '<i class="fa-solid fa-circle-check" style="color:#34d399;"></i> Điểm dừng ' + typeLabel + ' (' + timeStr + ') - ĐÃ QUA';
            } else {
                tooltip.innerHTML = '<i class="fa-solid fa-flag" style="color:#f59e0b;"></i> Điểm dừng: ' + typeLabel + ' (' + timeStr + ')';
            }
        }
    }

    function renderAllCheckpointMarkers() {
        if(!checkpointData || !checkpointData.hasCheckpoint || !checkpointData.checkpointSeconds) return;

        let duration = 0;
        if(player && typeof player.getDuration === 'function') {
            duration = player.getDuration();
        }
        const html5Vid = document.getElementById('html5-video');
        if(html5Vid && html5Vid.duration && !isNaN(html5Vid.duration)) {
            duration = html5Vid.duration;
        }

        if(duration <= 0) return;

        const ytProg = document.getElementById('ytProgressBarContainer');
        if(ytProg) renderCheckpointMarker(ytProg, duration);

        const html5Prog = document.getElementById('html5ProgressBarContainer');
        if(html5Prog) renderCheckpointMarker(html5Prog, duration);
    }

    function showInVideoQuizOverlay() {
        const overlays = document.querySelectorAll('.in-video-quiz-overlay, #inVideoQuizOverlay');
        if(!overlays || overlays.length === 0) return;

        overlays.forEach(overlay => {
            if(!checkpointData || !checkpointData.quiz || !checkpointData.quiz.content) {
                // Fallback nếu chưa cấu hình câu hỏi
                const qContent = overlay.querySelector('.ivq-content, #ivqContent');
                if(qContent) qContent.innerText = 'Điểm dừng tương tác (Chưa cấu hình câu hỏi)';
                const listEl = overlay.querySelector('.ivq-options-list, #ivqOptionsList');
                if(listEl) listEl.innerHTML = '<p style="color:#94a3b8; font-size:13px; margin:0;">Giảng viên chưa chọn câu hỏi trắc nghiệm cho điểm dừng này. Bạn có thể nhấn Tiếp tục để xem video.</p>';
                const btn = overlay.querySelector('.ivq-submit-btn, #ivqSubmitBtn');
                if(btn) {
                    btn.innerHTML = 'Tiếp tục xem video <i class="fa-solid fa-arrow-right"></i>';
                    btn.onclick = function() {
                        checkpointPassed = true;
                        hideAllCheckpointOverlays();
                        renderAllCheckpointMarkers();
                        if(player && typeof player.playVideo === 'function') player.playVideo();
                        const html5Vid = document.getElementById('html5-video');
                        if(html5Vid) html5Vid.play();
                    };
                }
                overlay.style.setProperty('display', 'flex', 'important');
                return;
            }

            const qContent = overlay.querySelector('.ivq-content, #ivqContent');
            if(qContent) qContent.innerText = checkpointData.quiz.content;
            const listEl = overlay.querySelector('.ivq-options-list, #ivqOptionsList');
            if(listEl) {
                listEl.innerHTML = '';
                (checkpointData.quiz.options || []).forEach((opt) => {
                    const label = document.createElement('label');
                    label.style.display = 'flex';
                    label.style.alignItems = 'center';
                    label.style.gap = '10px';
                    label.style.padding = '10px 14px';
                    label.style.background = '#0f172a';
                    label.style.borderRadius = '8px';
                    label.style.cursor = 'pointer';
                    label.style.border = '1px solid #334155';
                    label.style.transition = 'all 0.2s';
                    label.innerHTML = '<input type="radio" name="ivqOption" value="' + opt.id + '" style="accent-color:#3b82f6; width:16px; height:16px; cursor:pointer;" />' +
                        '<span style="font-size:14px; color:#e2e8f0;">' + escapeHtml(opt.content) + '</span>';
                    listEl.appendChild(label);
                });
            }

            const msgEl = overlay.querySelector('.ivq-message, #ivqMessage');
            if(msgEl) {
                msgEl.style.display = 'none';
                msgEl.innerText = '';
            }
            const btn = overlay.querySelector('.ivq-submit-btn, #ivqSubmitBtn');
            if(btn) {
                btn.disabled = false;
                btn.innerHTML = 'Kiểm Tra Đáp Án <i class="fa-solid fa-arrow-right"></i>';
                btn.onclick = verifyInVideoQuiz;
            }
            overlay.style.setProperty('display', 'flex', 'important');
        });
    }

    function showInVideoCodeLockOverlay() {
        const lockOvs = document.querySelectorAll('.in-video-code-overlay, #inVideoCodeLockOverlay');
        lockOvs.forEach(ov => {
            ov.style.setProperty('display', 'flex', 'important');
        });
    }

    function verifyInVideoQuiz() {
        const selected = document.querySelector('input[name="ivqOption"]:checked');
        const msgs = document.querySelectorAll('.ivq-message, #ivqMessage');
        const btns = document.querySelectorAll('.ivq-submit-btn, #ivqSubmitBtn');

        if(!selected) {
            msgs.forEach(msgEl => {
                msgEl.style.display = 'block';
                msgEl.style.background = '#7f1d1d';
                msgEl.style.color = '#fca5a5';
                msgEl.innerText = 'Vui lòng chọn 1 câu trả lời trước khi kiểm tra!';
            });
            return;
        }

        if(!checkpointData || !checkpointData.quiz) return;

        btns.forEach(btn => {
            btn.disabled = true;
            btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang kiểm tra...';
        });

        fetch('${pageContext.request.contextPath}/api/checkpoint/verify-quiz', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                questionId: checkpointData.quiz.questionId,
                selectedOptionId: parseInt(selected.value),
                lessonId: Number('${currentLesson.id}')
            })
        })
        .then(res => res.json())
        .then(data => {
            btns.forEach(btn => {
                btn.disabled = false;
                btn.innerHTML = 'Kiểm Tra Đáp Án <i class="fa-solid fa-arrow-right"></i>';
            });

            if(data.success && data.isCorrect) {
                msgs.forEach(msgEl => {
                    msgEl.style.display = 'block';
                    msgEl.style.background = '#065f46';
                    msgEl.style.color = '#a7f3d0';
                    msgEl.innerHTML = '<i class="fa-solid fa-circle-check"></i> ' + (data.explanation || 'Chính xác! Bạn đã trả lời đúng.');
                });
                checkpointPassed = true;
                renderAllCheckpointMarkers();

                setTimeout(() => {
                    hideAllCheckpointOverlays();
                    if(player && typeof player.playVideo === 'function') {
                        player.playVideo();
                        const ytPlayBtn = document.getElementById('ytPlayPauseBtn');
                        if(ytPlayBtn) ytPlayBtn.innerHTML = '<i class="fa-solid fa-pause"></i>';
                    }
                    const html5Vid = document.getElementById('html5-video');
                    if(html5Vid) {
                        html5Vid.play();
                        const html5PlayBtn = document.getElementById('html5PlayPauseBtn');
                        if(html5PlayBtn) html5PlayBtn.innerHTML = '<i class="fa-solid fa-pause"></i>';
                    }
                }, 1400);
            } else {
                msgs.forEach(msgEl => {
                    msgEl.style.display = 'block';
                    msgEl.style.background = '#7f1d1d';
                    msgEl.style.color = '#fca5a5';
                    msgEl.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> ' + (data.message || 'Đáp án chưa chính xác. Vui lòng suy nghĩ và chọn lại!');
                });
            }
        })
        .catch(err => {
            btns.forEach(btn => {
                btn.disabled = false;
                btn.innerHTML = 'Kiểm Tra Đáp Án <i class="fa-solid fa-arrow-right"></i>';
            });
            msgs.forEach(msgEl => {
                msgEl.style.display = 'block';
                msgEl.style.background = '#7f1d1d';
                msgEl.style.color = '#fca5a5';
                msgEl.innerText = 'Lỗi kết nối máy chủ: ' + err;
            });
        });
    }

    function showCodeCheckpointNotice() {
        const notices = document.querySelectorAll('#videoCheckpointNotice');
        notices.forEach(n => n.style.display = 'block');
        if(!isCompilerVisible) {
            toggleCompiler();
        }
    }

    function focusOnExercise() {
        if(!isCompilerVisible) {
            toggleCompiler();
        }
        const box = document.getElementById('exercise-box') || document.getElementById('compiler-section');
        if(box) {
            box.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }

    function testCode() {
        if(!codeEditor || !currentExerciseId) return;
        const code = codeEditor.getValue();
        const lang = document.getElementById('compiler-lang').value;
        const btnTest = document.getElementById('btn-test');
        const consoleEl = document.getElementById('compiler-console');

        btnTest.disabled = true;
        btnTest.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang test...';
        consoleEl.innerHTML = '<span style="color:#fbbf24;">[Kiểm thử] Đang chạy code qua các Test Cases...</span>';

        fetch('${pageContext.request.contextPath}/api/compiler/test', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ exerciseId: currentExerciseId, language: lang, code: code })
        })
        .then(res => res.json())
        .then(data => {
            btnTest.disabled = false;
            btnTest.innerHTML = '<i class="fa-solid fa-vial-circle-check"></i> Chạy Test Cases';

            if(data.success) {
                const results = data.details || data.testResults;
                const passed = data.passedTests !== undefined ? data.passedTests : (data.passedCases || 0);
                const total = data.totalTests !== undefined ? data.totalTests : (data.totalCases || 0);
                renderTestCasesResult(results, passed, total, false);
                consoleEl.innerHTML = '<span style="color:#a7f3d0;">[Kết quả kiểm thử]</span> Đạt ' + passed + '/' + total + ' test cases.';
            } else {
                consoleEl.innerHTML = '<span style="color:#f87171;">[Lỗi Kiểm Thử]</span> ' + escapeHtml(data.output || data.message || 'Lỗi không xác định');
            }
        })
        .catch(err => {
            btnTest.disabled = false;
            btnTest.innerHTML = '<i class="fa-solid fa-vial-circle-check"></i> Chạy Test Cases';
            consoleEl.innerHTML = '<span style="color:#f87171;">[Lỗi Hệ Thống] ' + err + '</span>';
        });
    }

    function submitCode() {
        if(!codeEditor || !currentExerciseId) return;
        const code = codeEditor.getValue();
        const lang = document.getElementById('compiler-lang').value;
        const btnSubmit = document.getElementById('btn-submit');
        const consoleEl = document.getElementById('compiler-console');

        btnSubmit.disabled = true;
        btnSubmit.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang chấm...';
        consoleEl.innerHTML = '<span style="color:#6366f1;">[Nộp bài] Đang chấm điểm và xác thực bài nộp với toàn bộ Test Cases (kể cả ẩn)...</span>';

        fetch('${pageContext.request.contextPath}/api/compiler/submit', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ exerciseId: currentExerciseId, language: lang, code: code })
        })
        .then(res => res.json())
        .then(data => {
            btnSubmit.disabled = false;
            btnSubmit.innerHTML = '<i class="fa-solid fa-paper-plane"></i> Nộp Bài Chấm Điểm';

            if(data.success) {
                const results = data.details || data.testResults;
                const passed = data.passedTests !== undefined ? data.passedTests : (data.passedCases || 0);
                const total = data.totalTests !== undefined ? data.totalTests : (data.totalCases || 0);
                renderTestCasesResult(results, passed, total, true);
                const statusBadge = document.getElementById('ex-status-badge');
                if(data.status === 'PASSED' || data.allPassed) {
                    checkpointPassed = true;
                    if(statusBadge) {
                        statusBadge.style.background = '#065f46';
                        statusBadge.style.color = '#34d399';
                        statusBadge.innerHTML = '<i class="fa-solid fa-circle-check"></i> ĐÃ HOÀN THÀNH (ĐẠT 100%)';
                    }

                    consoleEl.innerHTML = '<span style="color:#34d399; font-weight:bold;">🎉 CHÚC MỪNG! Bạn đã xuất sắc vượt qua toàn bộ Test Cases (' + passed + '/' + total + ').</span>';
                    
                    const lockOvs = document.querySelectorAll('#inVideoCodeLockOverlay');
                    lockOvs.forEach(o => o.style.setProperty('display', 'none', 'important'));
                    const notices = document.querySelectorAll('#videoCheckpointNotice');
                    notices.forEach(n => n.style.display = 'none');
                    if(player && typeof player.playVideo === 'function') {
                        player.playVideo();
                    }
                    const html5Vid = document.getElementById('html5-video');
                    if(html5Vid) {
                        html5Vid.play();
                    }
                } else {
                    if(statusBadge) {
                        statusBadge.style.background = '#7f1d1d';
                        statusBadge.style.color = '#fca5a5';
                        statusBadge.innerHTML = '<i class="fa-solid fa-xmark"></i> CHƯA ĐẠT (' + passed + '/' + total + ' TESTS)';
                    }
                    consoleEl.innerHTML = '<span style="color:#f87171;">[Chưa Đạt]</span> Kết quả chấm: ' + passed + '/' + total + ' test cases passed. Hãy kiểm tra lại logic và nộp lại nhé!';
                }
            } else {
                consoleEl.innerHTML = '<span style="color:#f87171;">[Lỗi Chấm Bài]</span> ' + escapeHtml(data.output || data.message || 'Lỗi không xác định');
            }
        })
        .catch(err => {
            btnSubmit.disabled = false;
            btnSubmit.innerHTML = '<i class="fa-solid fa-paper-plane"></i> Nộp Bài Chấm Điểm';
            consoleEl.innerHTML = '<span style="color:#f87171;">[Lỗi Hệ Thống] ' + err + '</span>';
        });
    }

    function renderTestCasesResult(results, passed, total, isFinalSubmit) {
        if(!results) return;
        const tbody = document.getElementById('testcases-body');
        if(!tbody) return;
        tbody.innerHTML = '';
        const summaryScore = document.getElementById('testcase-summary-score');
        
        if(summaryScore) {
            if(passed === total && total > 0) {
                summaryScore.style.color = '#34d399';
                summaryScore.innerText = 'ĐẠT: ' + passed + ' / ' + total + ' Test Cases (100%)';
            } else {
                summaryScore.style.color = '#f87171';
                summaryScore.innerText = 'CHƯA ĐẠT: ' + passed + ' / ' + total + ' Test Cases';
            }
        }

        results.forEach((r, idx) => {
            const tr = document.createElement('tr');
            tr.style.borderBottom = '1px solid #1e293b';
            const isPass = r.passed;
            const badgeBg = isPass ? '#065f46' : '#7f1d1d';
            const badgeColor = isPass ? '#a7f3d0' : '#fca5a5';
            const badgeText = isPass ? 'PASSED' : 'FAILED';

            const inputTxt = r.isHidden ? '<span style="color:#64748b; font-style:italic;">(Test case ẩn)</span>' : escapeHtml(r.input || '(None)');
            const expTxt = r.isHidden ? '<span style="color:#64748b; font-style:italic;">(Test case ẩn)</span>' : escapeHtml(r.expected || '');
            const actTxt = r.isHidden ? '<span style="color:' + (isPass ? '#34d399' : '#f87171') + '; font-weight:bold;">' + (r.message || (isPass ? 'ĐẠT' : 'KHÔNG ĐẠT')) + '</span>' : escapeHtml(r.actual || '(Trống)');

            tr.innerHTML = '<td style="padding:10px 12px; color:#94a3b8; font-weight:700;">#' + (idx + 1) + '</td>' +
                '<td style="padding:10px 12px; color:#e2e8f0; font-family:monospace;">' + inputTxt + '</td>' +
                '<td style="padding:10px 12px; color:#38bdf8; font-family:monospace;">' + expTxt + '</td>' +
                '<td style="padding:10px 12px; color:' + (isPass ? '#a7f3d0' : '#fca5a5') + '; font-family:monospace;">' + actTxt + '</td>' +
                '<td style="padding:10px 12px; text-align:center;">' +
                    '<span style="background:' + badgeBg + '; color:' + badgeColor + '; padding:4px 10px; border-radius:12px; font-size:11px; font-weight:700;">' + badgeText + '</span>' +
                '</td>';
            tbody.appendChild(tr);
        });

        const resBox = document.getElementById('testcases-result-box');
        if(resBox) resBox.style.display = 'block';
    }

</script>
</div>

<!-- Dynamic Island Theme Toggle -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=38"></script>

<!-- Video checkpoint -->
<c:if test="${not empty youtubeEmbedUrl}">
<script>
    var player = null;
    var timeUpdater = null;

    function initYouTubePlayer() {
        if (player) return;
        var el = document.getElementById('youtube-player');
        if (!el) return;
        player = new YT.Player('youtube-player', {
            events: {
                'onReady': onPlayerReady,
                'onStateChange': onPlayerStateChange
            }
        });
    }

    if (window.YT && window.YT.Player) {
        initYouTubePlayer();
    } else {
        var oldYTReady = window.onYouTubeIframeAPIReady;
        window.onYouTubeIframeAPIReady = function() {
            if (typeof oldYTReady === 'function') oldYTReady();
            initYouTubePlayer();
        };
    }

    function onPlayerReady(event) {
        // Toggle Play/Pause
        var playBtn = document.getElementById('ytPlayPauseBtn');
        if (playBtn) {
            playBtn.addEventListener('click', function() {
                if (!isPreview && !checkpointPassed && isCheckpointBlocked(player.getCurrentTime())) {
                    lockVideoAtCheckpoint();
                    return;
                }
                var state = player.getPlayerState();
                if (state == YT.PlayerState.PLAYING) {
                    player.pauseVideo();
                } else {
                    player.playVideo();
                }
            });
        }

        // Toggle Mute
        var muteBtn = document.getElementById('ytMuteBtn');
        if (muteBtn) {
            muteBtn.addEventListener('click', function() {
                if (player.isMuted()) {
                    player.unMute();
                    this.innerHTML = '<i class="fa-solid fa-volume-high"></i>';
                } else {
                    player.mute();
                    this.innerHTML = '<i class="fa-solid fa-volume-xmark"></i>';
                }
            });
        }

        // Seek (Tua video) - Hỗ trợ tua tới, tua lùi tự do trước checkpoint
        var ytProg = document.getElementById('ytProgressBarContainer');
        if (ytProg) {
            ytProg.addEventListener('click', function(e) {
                onProgressBarClick(e, ytProg, () => player.getDuration(), (t) => {
                    player.seekTo(t, true);
                });
            });
        }

        updateTimeDisplay();
        renderAllCheckpointMarkers();
    }

    function onPlayerStateChange(event) {
        var playBtn = document.getElementById('ytPlayPauseBtn');
        if (event.data == YT.PlayerState.PLAYING || event.data == YT.PlayerState.BUFFERING) {
            if (!suppressCheckpointCheck && !isPreview && !checkpointPassed && isCheckpointBlocked(player.getCurrentTime())) {
                lockVideoAtCheckpoint();
                return;
            }
            if (event.data == YT.PlayerState.PLAYING) {
                if (playBtn) playBtn.innerHTML = '<i class="fa-solid fa-pause"></i>';
                if (!timeUpdater) {
                    timeUpdater = setInterval(updateTimeDisplay, 250);
                }
            }
        } else {
            if (playBtn) playBtn.innerHTML = '<i class="fa-solid fa-play"></i>';
            clearInterval(timeUpdater);
            timeUpdater = null;
        }
        renderAllCheckpointMarkers();
    }

    function updateTimeDisplay() {
        if (player && typeof player.getCurrentTime === 'function') {
            var current = player.getCurrentTime();
            if (!suppressCheckpointCheck && !isPreview && !checkpointPassed && isCheckpointBlocked(current)) {
                lockVideoAtCheckpoint();
                return;
            }
            var duration = typeof player.getDuration === 'function' ? player.getDuration() : 0;

            if (duration > 0) {
                var percent = (current / duration) * 100;
                var fill = document.getElementById('ytProgressBarFill');
                if (fill) fill.style.width = percent + '%';
            }

            var timeEl = document.getElementById('ytVideoTime');
            if (timeEl) timeEl.innerText = formatTime(current) + " / " + formatTime(duration);

            renderAllCheckpointMarkers();
        }
    }
</script>
<script src="https://www.youtube.com/iframe_api"></script>
</c:if>

<!-- ========================================================================= -->
<!-- NÚT ICON NỔI MỞ BÌNH LUẬN & HỎI ĐÁP BÀI HỌC (FLOATING BUTTON) -->
<!-- ========================================================================= -->
<button id="openCommentsBtn" onclick="toggleCommentsDrawer()" class="floating-comments-btn" title="Hỏi đáp & Thảo luận bài học">
    <i class="fa-solid fa-comments"></i>
    <span class="floating-comments-badge" id="commentsCountBadge">0</span>
</button>

<!-- ========================================================================= -->
<!-- KHUNG BÌNH LUẬN TRƯỢT TỪ BÊN PHẢI (SLIDE-OUT COMMENTS DRAWER) -->
<!-- ========================================================================= -->
<div id="commentsDrawerOverlay" class="comments-drawer-overlay" onclick="toggleCommentsDrawer()"></div>

<div id="commentsDrawer" class="comments-drawer">
    <!-- Header của Drawer -->
    <div class="comments-drawer-header">
        <div style="display:flex; align-items:center; gap:10px;">
            <div style="width:36px; height:36px; border-radius:10px; background:rgba(7,111,164,0.12); color:#076FA4; display:flex; align-items:center; justify-content:center; font-size:16px;">
                <i class="fa-solid fa-comments"></i>
            </div>
            <div>
                <h3 style="font-size:16px; font-weight:800; color:#093C62; margin:0;">Hỏi đáp & Thảo luận</h3>
                <span style="font-size:12px; color:#64748B;">Bài học: <c:out value="${currentLesson.title}"/></span>
            </div>
        </div>
        <button type="button" onclick="toggleCommentsDrawer()" class="comments-drawer-close">&times;</button>
    </div>

    <!-- Danh sách câu hỏi & thảo luận -->
    <div class="comments-drawer-body" id="commentsContainer">
        <div style="text-align:center; padding:40px 20px; color:#94A3B8;">
            <i class="fa-solid fa-spinner fa-spin" style="font-size:24px; margin-bottom:10px;"></i>
            <p style="margin:0; font-size:13px;">Đang tải thảo luận...</p>
        </div>
    </div>

    <!-- Form gửi bình luận câu hỏi mới -->
    <div class="comments-drawer-footer">
        <div id="replyingNotice" style="display:none; justify-content:space-between; align-items:center; background:#EFF6FF; border:1px solid #BFDBFE; border-radius:8px; padding:6px 12px; margin-bottom:8px; font-size:12px; color:#1E40AF;">
            <span><i class="fa-solid fa-reply"></i> Đang trả lời <strong id="replyingToName">...</strong></span>
            <button type="button" onclick="cancelReply()" style="background:none; border:none; color:#EF4444; font-weight:700; cursor:pointer;">&times; Hủy</button>
        </div>
        <form id="commentForm" onsubmit="submitComment(event)" style="display:flex; gap:8px;">
            <input type="hidden" id="replyParentId" value="" />
            <input type="text" id="commentInput" placeholder="Viết câu hỏi hoặc chia sẻ thắc mắc..." 
                   required maxlength="1000" autocomplete="off" class="comment-input-box" />
            <button type="submit" id="btnSendComment" class="comment-send-btn" title="Gửi câu hỏi">
                <i class="fa-solid fa-paper-plane"></i>
            </button>
        </form>
    </div>
</div>

<style>
/* Nút tròn nổi mở bình luận */
.floating-comments-btn {
    position: fixed;
    right: 24px;
    bottom: 28px;
    width: 56px;
    height: 56px;
    border-radius: 50%;
    background: linear-gradient(135deg, #076FA4, #093C62);
    color: #fff;
    border: none;
    box-shadow: 0 8px 24px rgba(7, 111, 164, 0.35);
    font-size: 22px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 998;
    transition: transform 0.2s, box-shadow 0.2s;
}
.floating-comments-btn:hover {
    transform: scale(1.08);
    box-shadow: 0 12px 28px rgba(7, 111, 164, 0.45);
}
.floating-comments-badge {
    position: absolute;
    top: -2px;
    right: -2px;
    background: #EF4444;
    color: #fff;
    font-size: 11px;
    font-weight: 700;
    min-width: 20px;
    height: 20px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0 5px;
    border: 2px solid #fff;
}

/* Overlay làm mờ nền */
.comments-drawer-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(15, 23, 42, 0.45);
    backdrop-filter: blur(2px);
    z-index: 9998;
}
.comments-drawer-overlay.active {
    display: block;
}

/* Khung Side Drawer trượt ra từ bên phải */
.comments-drawer {
    position: fixed;
    top: 0;
    right: -420px;
    width: 400px;
    max-width: 90vw;
    height: 100vh;
    background: #FFFFFF;
    box-shadow: -8px 0 32px rgba(15, 23, 42, 0.15);
    z-index: 9999;
    display: flex;
    flex-direction: column;
    transition: right 0.32s cubic-bezier(0.16, 1, 0.3, 1);
}
.comments-drawer.open {
    right: 0;
}

.comments-drawer-header {
    padding: 18px 20px;
    border-bottom: 1px solid #E2E8F0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #F8FAFC;
}
.comments-drawer-close {
    background: none;
    border: none;
    font-size: 26px;
    color: #94A3B8;
    cursor: pointer;
    line-height: 1;
    padding: 0 4px;
}
.comments-drawer-close:hover {
    color: #0F172A;
}

.comments-drawer-body {
    flex: 1;
    overflow-y: auto;
    padding: 16px 20px;
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.comment-card {
    background: #F8FAFC;
    border: 1px solid #E2E8F0;
    border-radius: 12px;
    padding: 14px 16px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    transition: background 0.15s;
}
.comment-card:hover {
    background: #F1F5F9;
}
.comment-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.comment-author-info {
    display: flex;
    align-items: center;
    gap: 10px;
}
.comment-avatar {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    object-fit: cover;
    background: #E2E8F0;
}
.comment-avatar-placeholder {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: linear-gradient(135deg, #076FA4, #093C62);
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    font-weight: 700;
}
.comment-author-name {
    font-size: 13.5px;
    font-weight: 700;
    color: #0F172A;
}
.comment-role-badge {
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    padding: 2px 7px;
    border-radius: 12px;
}
.role-badge-instructor {
    background: #FEF3C7;
    color: #B45309;
    border: 1px solid #FDE68A;
}
.role-badge-student {
    background: #E0F2FE;
    color: #0369A1;
}
.role-badge-admin {
    background: #FEE2E2;
    color: #B91C1C;
}

.comment-text {
    font-size: 13.5px;
    color: #334155;
    line-height: 1.55;
    word-break: break-word;
    margin: 0;
}
.comment-actions {
    display: flex;
    align-items: center;
    gap: 14px;
    font-size: 12px;
    color: #64748B;
    margin-top: 2px;
}
.comment-action-btn {
    background: none;
    border: none;
    color: #076FA4;
    font-size: 12px;
    font-weight: 600;
    cursor: pointer;
    padding: 0;
    display: inline-flex;
    align-items: center;
    gap: 4px;
}
.comment-action-btn:hover {
    text-decoration: underline;
}
.comment-delete-btn {
    color: #EF4444;
}

/* Luồng trả lời con (Replies) */
.replies-thread {
    margin-left: 18px;
    padding-left: 14px;
    border-left: 2px solid #CBD5E1;
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin-top: 8px;
}

/* Footer & ô nhập */
.comments-drawer-footer {
    padding: 14px 18px;
    border-top: 1px solid #E2E8F0;
    background: #FFFFFF;
}
.comment-input-box {
    flex: 1;
    border: 1.5px solid #CBD5E1;
    border-radius: 20px;
    padding: 10px 16px;
    font-size: 13.5px;
    outline: none;
    transition: border-color 0.2s;
}
.comment-input-box:focus {
    border-color: #076FA4;
}
.comment-send-btn {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: #076FA4;
    color: #fff;
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    transition: background 0.15s, transform 0.15s;
    flex-shrink: 0;
}
.comment-send-btn:hover {
    background: #093C62;
    transform: scale(1.05);
}

/* Dark Theme support */
body.dark-theme .comments-drawer {
    background: #182535;
    box-shadow: -8px 0 32px rgba(0,0,0,0.4);
}
body.dark-theme .comments-drawer-header {
    background: #111312;
    border-bottom-color: #093C62;
}
body.dark-theme .comments-drawer-header h3 {
    color: #FFFFFF !important;
}
body.dark-theme .comment-card {
    background: #111312;
    border-color: #093C62;
}
body.dark-theme .comment-author-name {
    color: #FFFFFF;
}
body.dark-theme .comment-text {
    color: #CBD5E1;
}
body.dark-theme .comments-drawer-footer {
    background: #182535;
    border-top-color: #093C62;
}
body.dark-theme .comment-input-box {
    background: #111312;
    border-color: #093C62;
    color: #FFFFFF;
}
</style>

<!-- Comment -->
<script>
const currentLessonId = Number('${currentLesson.id}');
const currentUserId = Number('${currentUser != null ? currentUser.id : -1}');
const currentUserRole = '${currentUser != null ? currentUser.role : ""}';

function toggleCommentsDrawer() {
    const drawer = document.getElementById('commentsDrawer');
    const overlay = document.getElementById('commentsDrawerOverlay');
    if (!drawer) return;

    if (drawer.classList.contains('open')) {
        drawer.classList.remove('open');
        overlay.classList.remove('active');
    } else {
        drawer.classList.add('open');
        overlay.classList.add('active');
        loadComments();
    }
}

function loadComments() {
    fetch('${pageContext.request.contextPath}/lesson-comments?lessonId=' + currentLessonId)
        .then(res => res.json())
        .then(comments => {
            renderComments(comments);
        })
        .catch(err => {
            console.error(err);
            document.getElementById('commentsContainer').innerHTML = 
                '<div style="text-align:center; padding:30px; color:#EF4444;"><i class="fa-solid fa-triangle-exclamation"></i> Không thể tải bình luận.</div>';
        });
}

function renderComments(comments) {
    const container = document.getElementById('commentsContainer');
    const badge = document.getElementById('commentsCountBadge');
    
    let totalCount = 0;
    comments.forEach(function(c) {
        totalCount++;
        if (c.replies) totalCount += c.replies.length;
    });
    badge.innerText = totalCount;

    if (!comments || comments.length === 0) {
        container.innerHTML = 
            '<div style="text-align:center; padding:50px 20px; color:#94A3B8;">' +
                '<div style="font-size:36px; margin-bottom:12px; color:#CBD5E1;"><i class="fa-regular fa-comments"></i></div>' +
                '<h4 style="margin:0 0 6px 0; color:#64748B; font-size:15px;">Chưa có câu hỏi nào</h4>' +
                '<p style="margin:0; font-size:13px;">Hãy là người đầu tiên đặt câu hỏi hoặc chia sẻ về bài học này!</p>' +
            '</div>';
        return;
    }

    let html = '';
    comments.forEach(function(c) {
        html += renderSingleComment(c, false);
    });
    container.innerHTML = html;
}

function renderSingleComment(c, isReply) {
    const isOwner = (currentUserId === c.userId);
    const canDelete = isOwner || currentUserRole === 'admin' || currentUserRole === 'instructor';

    let roleBadge = '';
    if (c.userRole === 'instructor') {
        roleBadge = '<span class="comment-role-badge role-badge-instructor"><i class="fa-solid fa-chalkboard-user"></i> Giảng viên</span>';
    } else if (c.userRole === 'admin') {
        roleBadge = '<span class="comment-role-badge role-badge-admin"><i class="fa-solid fa-shield-halved"></i> Quản trị</span>';
    } else {
        roleBadge = '<span class="comment-role-badge role-badge-student">Học viên</span>';
    }

    let avatarHtml = '';
    if (c.userAvatar && c.userAvatar.trim() !== '') {
        avatarHtml = '<img src="' + c.userAvatar + '" class="comment-avatar" onerror="this.outerHTML=\'<div class=\\\'comment-avatar-placeholder\\\'>' + (c.userName ? c.userName.charAt(0).toUpperCase() : 'U') + '</div>\'" />';
    } else {
        avatarHtml = '<div class="comment-avatar-placeholder">' + (c.userName ? c.userName.charAt(0).toUpperCase() : 'U') + '</div>';
    }

    let repliesHtml = '';
    if (c.replies && c.replies.length > 0) {
        repliesHtml += '<div class="replies-thread">';
        c.replies.forEach(function(rep) {
            repliesHtml += renderSingleComment(rep, true);
        });
        repliesHtml += '</div>';
    }

    let replyBtnHtml = '';
    if (!isReply) {
        replyBtnHtml = '<button type="button" class="comment-action-btn" onclick="startReply(' + c.id + ', \'' + escapeHtml(c.userName) + '\')"><i class="fa-solid fa-reply"></i> Trả lời</button>';
    }

    let deleteBtnHtml = '';
    if (canDelete) {
        deleteBtnHtml = '<button type="button" class="comment-action-btn comment-delete-btn" onclick="deleteComment(' + c.id + ')"><i class="fa-solid fa-trash-can"></i> Xóa</button>';
    }

    return '<div class="comment-card" id="comment-item-' + c.id + '">' +
        '<div class="comment-header">' +
            '<div class="comment-author-info">' +
                avatarHtml +
                '<div>' +
                    '<div style="display:flex; align-items:center; gap:6px;">' +
                        '<span class="comment-author-name">' + escapeHtml(c.userName) + '</span>' +
                        roleBadge +
                    '</div>' +
                    '<span style="font-size:11px; color:#94A3B8;">' + c.createdAtFormatted + '</span>' +
                '</div>' +
            '</div>' +
        '</div>' +
        '<p class="comment-text">' + escapeHtml(c.content) + '</p>' +
        '<div class="comment-actions">' +
            replyBtnHtml +
            deleteBtnHtml +
        '</div>' +
        repliesHtml +
    '</div>';
}

function startReply(commentId, authorName) {
    document.getElementById('replyParentId').value = commentId;
    document.getElementById('replyingToName').innerText = authorName;
    document.getElementById('replyingNotice').style.display = 'flex';
    const input = document.getElementById('commentInput');
    input.focus();
    input.placeholder = 'Trả lời ' + authorName + '...';
}

function cancelReply() {
    document.getElementById('replyParentId').value = '';
    document.getElementById('replyingNotice').style.display = 'none';
    const input = document.getElementById('commentInput');
    input.placeholder = 'Viết câu hỏi hoặc chia sẻ thắc mắc...';
}

function submitComment(e) {
    e.preventDefault();
    const input = document.getElementById('commentInput');
    const content = input.value.trim();
    const parentId = document.getElementById('replyParentId').value;

    if (!content) return;

    const btn = document.getElementById('btnSendComment');
    btn.disabled = true;

    const formData = new URLSearchParams();
    formData.append('lessonId', currentLessonId);
    formData.append('content', content);
    if (parentId) formData.append('parentId', parentId);

    fetch('${pageContext.request.contextPath}/lesson-comments', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
        body: formData.toString()
    })
    .then(res => res.json())
    .then(data => {
        btn.disabled = false;
        if (data.success) {
            input.value = '';
            cancelReply();
            loadComments();
        } else {
            alert(data.message || 'Lỗi gửi bình luận!');
        }
    })
    .catch(err => {
        btn.disabled = false;
        console.error(err);
        alert('Lỗi kết nối máy chủ!');
    });
}

function deleteComment(commentId) {
    if (!confirm('Bạn có chắc muốn xóa bình luận này không?')) return;

    const formData = new URLSearchParams();
    formData.append('commentId', commentId);

    fetch('${pageContext.request.contextPath}/lesson-comments/delete', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
        body: formData.toString()
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            loadComments();
        } else {
            alert(data.message || 'Không thể xóa bình luận!');
        }
    })
    .catch(err => console.error(err));
}

function escapeHtml(text) {
    if (!text) return '';
    return text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

// Tự động load số lượng bình luận ngay khi mở bài học
document.addEventListener('DOMContentLoaded', function() {
    fetch('${pageContext.request.contextPath}/lesson-comments?lessonId=' + currentLessonId)
        .then(res => res.json())
        .then(comments => {
            let totalCount = 0;
            comments.forEach(c => {
                totalCount++;
                if (c.replies) totalCount += c.replies.length;
            });
            document.getElementById('commentsCountBadge').innerText = totalCount;
        })
        .catch(err => console.log('Comments count load error', err));
});
</script>

</body>
</html>









