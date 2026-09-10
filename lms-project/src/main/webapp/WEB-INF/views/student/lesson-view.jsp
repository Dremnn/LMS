<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${currentLesson.title} - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=22">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=22">
    <style>
        body{background:#F8FAFF;color:#0F172A;min-height:100vh;}

        .btn-success{background:linear-gradient(135deg,#10B981,#059669);color:#fff;padding:12px 28px;font-size:14px;font-weight:700;border:none;border-radius:10px;cursor:pointer;box-shadow:0 4px 14px rgba(16,185,129,.25);transition:all .2s;}
        .btn-success:hover{transform:translateY(-1px);box-shadow:0 6px 20px rgba(16,185,129,.35);}

        /* ---- LAYOUT 2 CỘT ---- */
        .layout{display:flex;min-height:calc(100vh - 68px);}

        /* ---- SIDEBAR ---- */
        .sidebar{width:340px;flex-shrink:0;background:rgba(255,255,255,0.92);backdrop-filter:blur(12px);border-right:1px solid #E2E8F0;display:flex;flex-direction:column;box-shadow:2px 0 16px rgba(0,0,0,.02);}
        .sidebar-header{padding:20px 24px;border-bottom:1px solid #E2E8F0;background:#FFFFFF;}
        .sidebar-course-title{font-size:15px;font-weight:700;color:#0F172A;margin-bottom:12px;line-height:1.4;}
        .progress-label{display:flex;justify-content:space-between;font-size:13px;color:#64748B;margin-bottom:8px;font-weight:500;}
        .progress-bar-bg{background:#E2E8F0;border-radius:10px;height:8px;overflow:hidden;}
        .progress-bar-fill{height:100%;border-radius:10px;background:linear-gradient(90deg,#4F46E5,#06B6D4);}
        .sidebar-body{flex:1;overflow-y:auto;}
        .section-group{border-bottom:1px solid #E2E8F0;}
        .section-title{padding:12px 20px;font-size:12px;font-weight:700;color:#475569;text-transform:uppercase;letter-spacing:.5px;background:#F8FAFC;border-bottom:1px solid #F1F5F9;}
        .lesson-link{display:flex;align-items:center;gap:12px;padding:12px 20px;font-size:14px;color:#334155;text-decoration:none;transition:all .15s;cursor:pointer;border-left:3px solid transparent;border-bottom:1px solid #F8FAFC;}
        .lesson-link:hover{background:#EEF2FF;color:#4F46E5;}
        .lesson-link.active{background:#EEF2FF;color:#4F46E5;font-weight:700;border-left-color:#4F46E5;}
        .lesson-link .tick{color:#10B981;font-size:14px;font-weight:800;flex-shrink:0;}
        .lesson-link .dot{width:9px;height:9px;border-radius:50%;border:2px solid #94A3B8;flex-shrink:0;}
        .lesson-link.active .dot{background:#4F46E5;border-color:#4F46E5;}
        .quiz-link{background:#FFFBEB;color:#D97706;font-weight:600;}
        .quiz-link:hover{background:#FEF3C7;color:#B45309;}

        /* ---- CONTENT ---- */
        .content{flex:1;overflow-y:auto;padding:36px 48px;max-width:1020px;margin:0 auto;}
        .lesson-title{font-size:28px;font-weight:800;color:#0F172A;margin-bottom:24px;line-height:1.3;}
        .alert-danger{background:#FEF2F2;border:1px solid #FECACA;color:#991B1B;padding:14px 20px;border-radius:12px;font-size:14px;margin-bottom:24px;}
        .video-wrap{background:#000;border-radius:16px;overflow:hidden;margin-bottom:28px;box-shadow:0 12px 36px rgba(0,0,0,.08);}
        .video-wrap video{display:block;width:100%;}
        .no-video{background:#FFFFFF;border:2px dashed #CBD5E1;border-radius:16px;padding:56px 24px;text-align:center;color:#64748B;margin-bottom:28px;}
        .no-video .icon{font-size:48px;margin-bottom:12px;}
        .doc-link{display:inline-flex;align-items:center;gap:10px;padding:12px 24px;background:#FFFFFF;border:1.5px solid #E2E8F0;border-radius:12px;color:#4F46E5;text-decoration:none;font-size:14px;font-weight:600;margin-bottom:28px;box-shadow:0 2px 8px rgba(0,0,0,.03);transition:all .2s;}
        .doc-link:hover{border-color:#818CF8;box-shadow:0 6px 20px rgba(79,70,229,.12);transform:translateY(-2px);}
        .complete-card{background:#FFFFFF;border-radius:16px;padding:24px 28px;border:1px solid #E2E8F0;box-shadow:0 4px 20px rgba(0,0,0,.04);margin-top:12px;}
        .complete-card h3{font-size:16px;font-weight:700;color:#0F172A;margin-bottom:14px;display:flex;align-items:center;gap:8px;}
        .form-check{display:flex;align-items:center;gap:12px;margin-bottom:18px;}
        .form-check input[type=checkbox]{width:20px;height:20px;accent-color:#4F46E5;cursor:pointer;flex-shrink:0;}
        .form-check-label{font-size:15px;color:#334155;cursor:pointer;font-weight:500;}
        .divider{border:none;border-top:1px solid #E2E8F0;margin:28px 0;}
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
        <span class="logo-text">UTEdu <span class="logo-tag">LMS</span></span>
    </a>
    <div class="nav-links">
        <a href="<%=request.getContextPath()%>/courses/detail?id=${course.id}" class="nav-link">← Chi tiết khóa học</a>
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

        <%-- Tài liệu đính kèm --%>
        <c:if test="${not empty currentLesson.documentUrl}">
            <a href="${currentLesson.documentUrl}" target="_blank" class="doc-link">
                📄 Tải/Mở tài liệu bài học
            </a>
        </c:if>

        <hr class="divider">

        <%-- Form đánh dấu hoàn thành (chỉ hiện cho Student đã enroll) --%>
        <c:if test="${enrollment != null}">
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
        </c:if>
    </main>
</div>
</body>
</html>
