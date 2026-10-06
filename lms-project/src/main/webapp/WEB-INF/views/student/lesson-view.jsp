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
                    <div class="progress-bar-fill" style="width:${enrollment.progressPercent}%;"></div>
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
                        </a>
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
                                <span class="dot" style="border-color:#0d9488; ${asg.submittedByMe ? 'background:#0d9488;' : 'background:#ccfbf1;'} border-radius:3px;"></span>
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
                                <span class="dot" style="border-color:#0D9488; ${asg.submittedByMe ? 'background:#0D9488;' : 'background:#CCFBF1;'} border-radius:3px;"></span>
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

        <%-- Thông báo lỗi flash (nếu có) --%>
        <c:if test="${not empty error}">
            <div class="alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> ${error}</div>
        </c:if>

        <%-- Video bài học --%>
        <c:choose>
            <%-- Trường hợp 1: Link YouTube -> nhúng bằng iframe --%>
            <c:when test="${not empty youtubeEmbedUrl}">
                <div class="video-wrap" style="position:relative; padding-bottom:56.25%; height:0; overflow:hidden;">
                    <iframe src="${youtubeEmbedUrl}"
                            style="position:absolute; top:0; left:0; width:100%; height:100%; border:0;"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                            allowfullscreen>
                    </iframe>
                </div>
            </c:when>

            <%-- Trường hợp 2: Link video file trực tiếp (.mp4...) -> dùng thẻ video như cũ --%>
            <c:when test="${not empty currentLesson.videoUrl}">
                <div class="video-wrap">
                    <video controls width="100%" preload="metadata">
                        <source src="${currentLesson.videoUrl}" type="video/mp4" />
                        Trình duyệt của bạn không hỗ trợ thẻ video.
                    </video>
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

        <hr class="divider">

        <%-- Form đánh dấu hoàn thành --%>
        <c:choose>
            <c:when test="${enrollment != null}">
                <div class="complete-card">
                    <h3><i class="fa-solid fa-circle-check"></i> Tiến độ bài học</h3>
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
                </div>
            </c:when>
            <c:when test="${isPreview}">
                <div class="complete-card" style="border-left: 4px solid #076FA4; background: #F0F9FF;">
                    <h3 style="color:#0369A1; margin-bottom:12px;"><i class="fa-solid fa-eye" style="color:#076FA4;"></i> Tiến độ bài học (Chế độ xem trước)</h3>
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
                        <i class="fa-solid fa-circle-info"></i> Bạn đang xem giao diện học viên với tư cách Giảng viên / Quản trị viên (chỉ xem, không thể thao tác lưu tiến độ).
                    </p>
                </div>
            </c:when>
        </c:choose>
    </main>
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








