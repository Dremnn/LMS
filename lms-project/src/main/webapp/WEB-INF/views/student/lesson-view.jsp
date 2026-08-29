<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${currentLesson.title} - LMS</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',Roboto,Arial,sans-serif;}
        body{background:#1a202c;color:#e2e8f0;min-height:100vh;}

        /* ---- NAVBAR ---- */
        .navbar{background:#2d3748;padding:12px 24px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 2px 8px rgba(0,0,0,.3);position:sticky;top:0;z-index:200;}
        .navbar .logo{font-size:18px;font-weight:800;color:#a78bfa;text-decoration:none;}
        .nav-right{display:flex;align-items:center;gap:12px;}
        .btn{padding:7px 16px;border-radius:7px;font-size:13px;font-weight:600;text-decoration:none;cursor:pointer;border:none;transition:all .2s;display:inline-block;}
        .btn-ghost{background:transparent;color:#a0aec0;border:1px solid #4a5568;}
        .btn-ghost:hover{background:#4a5568;color:#fff;}
        .btn-danger{background:#9b2c2c;color:#fff;}
        .btn-danger:hover{background:#c53030;}
        .btn-success{background:#276749;color:#fff;padding:9px 20px;font-size:14px;font-weight:700;}
        .btn-success:hover{background:#22543d;}
        .badge-role{display:inline-block;padding:2px 8px;border-radius:12px;font-size:10px;font-weight:700;background:#553c9a;color:#e9d8fd;text-transform:uppercase;margin-left:6px;}

        /* ---- LAYOUT 2 CỘT ---- */
        .layout{display:flex;min-height:calc(100vh - 52px);}

        /* ---- SIDEBAR ---- */
        .sidebar{width:300px;flex-shrink:0;background:#2d3748;overflow-y:auto;border-right:1px solid #4a5568;display:flex;flex-direction:column;}
        .sidebar-header{padding:18px 18px 14px;border-bottom:1px solid #4a5568;background:#1a202c;}
        .sidebar-course-title{font-size:13px;font-weight:700;color:#e2e8f0;margin-bottom:10px;line-height:1.4;}
        .progress-label{display:flex;justify-content:space-between;font-size:11px;color:#a0aec0;margin-bottom:5px;}
        .progress-bar-bg{background:#4a5568;border-radius:10px;height:7px;overflow:hidden;}
        .progress-bar-fill{height:100%;border-radius:10px;background:linear-gradient(90deg,#667eea,#764ba2);}
        .sidebar-body{flex:1;overflow-y:auto;}
        .section-group{border-bottom:1px solid #4a5568;}
        .section-title{padding:12px 16px;font-size:11px;font-weight:700;color:#a78bfa;text-transform:uppercase;letter-spacing:.5px;background:#1e2a38;}
        .lesson-link{display:flex;align-items:center;gap:10px;padding:10px 16px;font-size:13px;color:#cbd5e0;text-decoration:none;transition:background .15s;cursor:pointer;}
        .lesson-link:hover{background:#3d4f6e;color:#fff;}
        .lesson-link.active{background:#4c3f9e;color:#fff;font-weight:700;}
        .lesson-link .tick{color:#68d391;font-size:14px;flex-shrink:0;}
        .lesson-link .dot{width:8px;height:8px;border-radius:50%;border:2px solid #4a5568;flex-shrink:0;}
        .lesson-link.active .dot{background:#a78bfa;border-color:#a78bfa;}

        /* ---- CONTENT ---- */
        .content{flex:1;overflow-y:auto;padding:32px 40px;max-width:900px;}
        .lesson-title{font-size:24px;font-weight:800;color:#f7fafc;margin-bottom:20px;line-height:1.3;}
        .alert-danger{background:#742a2a;border:1px solid #9b2c2c;color:#fed7d7;padding:12px 16px;border-radius:9px;font-size:14px;margin-bottom:20px;}
        .video-wrap{background:#000;border-radius:12px;overflow:hidden;margin-bottom:24px;}
        .video-wrap video{display:block;width:100%;}
        .no-video{background:#2d3748;border-radius:12px;padding:48px;text-align:center;color:#718096;margin-bottom:24px;}
        .no-video .icon{font-size:48px;margin-bottom:12px;}
        .doc-link{display:inline-flex;align-items:center;gap:8px;padding:10px 20px;background:#2d3748;border:1px solid #4a5568;border-radius:8px;color:#90cdf4;text-decoration:none;font-size:14px;font-weight:600;margin-bottom:24px;transition:background .15s;}
        .doc-link:hover{background:#3d4f6e;color:#bee3f8;}
        .complete-card{background:#2d3748;border-radius:12px;padding:22px 26px;border:1px solid #4a5568;margin-top:8px;}
        .complete-card h3{font-size:15px;font-weight:700;color:#e2e8f0;margin-bottom:14px;}
        .form-check{display:flex;align-items:center;gap:10px;margin-bottom:16px;}
        .form-check input[type=checkbox]{width:18px;height:18px;accent-color:#667eea;cursor:pointer;flex-shrink:0;}
        .form-check-label{font-size:14px;color:#cbd5e0;cursor:pointer;line-height:1.4;}
        .divider{border:none;border-top:1px solid #4a5568;margin:24px 0;}
        .nav-lessons{display:flex;justify-content:space-between;margin-top:24px;}
        .btn-nav{padding:9px 18px;background:#3d4f6e;color:#cbd5e0;border:1px solid #4a5568;border-radius:8px;font-size:13px;font-weight:600;text-decoration:none;transition:background .15s;}
        .btn-nav:hover{background:#4a5568;color:#fff;}
    </style>
</head>
<body>
<% User currentUser = (User) session.getAttribute("currentUser"); %>

<nav class="navbar">
    <a href="${pageContext.request.contextPath}/" class="logo">🎓 LMS System</a>
    <div class="nav-right">
        <a href="${pageContext.request.contextPath}/courses/detail?id=${course.id}" class="btn btn-ghost">← Chi tiết khóa học</a>
        <% if (currentUser != null) { %>
            <span style="font-size:13px;color:#a0aec0;font-weight:600;">
                <%= currentUser.getFullName() %><span class="badge-role">student</span>
            </span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">Đăng xuất</a>
        <% } %>
    </div>
</nav>

<div class="layout">

    <%-- ===================== SIDEBAR ===================== --%>
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="sidebar-course-title">📚 <c:out value="${course.title}"/></div>
            <div class="progress-label">
                <span>Tiến độ của bạn</span>
                <span><strong>${enrollment.progressPercent}%</strong></span>
            </div>
            <div class="progress-bar-bg">
                <div class="progress-bar-fill" style="width:${enrollment.progressPercent}%;"></div>
            </div>
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
                </div>
            </c:forEach>
        </div>
    </aside>

    <%-- ===================== NỘI DUNG CHÍNH ===================== --%>
    <main class="content">
        <h1 class="lesson-title"><c:out value="${currentLesson.title}"/></h1>

        <%-- Thông báo lỗi flash (nếu có) --%>
        <c:if test="${not empty error}">
            <div class="alert-danger">⚠️ ${error}</div>
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

        <%-- Tài liệu đính kèm --%>
        <c:if test="${not empty currentLesson.documentUrl}">
            <a href="${currentLesson.documentUrl}" target="_blank" class="doc-link">
                📄 Tải/Mở tài liệu bài học
            </a>
        </c:if>

        <hr class="divider">

        <%-- Form đánh dấu hoàn thành --%>
        <div class="complete-card">
            <h3>✅ Tiến độ bài học</h3>
            <form action="${pageContext.request.contextPath}/student/lessons/complete" method="post">
                <input type="hidden" name="lessonId" value="${currentLesson.id}" />
                <input type="hidden" name="courseId" value="${course.id}" />
                <div class="form-check">
                    <input type="checkbox" name="completed" id="completedCheck"
                           <c:if test="${completedLessonIds.contains(currentLesson.id)}">checked</c:if>
                           onchange="this.form.submit()" />
                    <label class="form-check-label" for="completedCheck">
                        Đánh dấu bài học này đã hoàn thành
                    </label>
                </div>
                <button type="submit" class="btn btn-success">💾 Lưu tiến độ</button>
            </form>
        </div>
    </main>
</div>
</body>
</html>
