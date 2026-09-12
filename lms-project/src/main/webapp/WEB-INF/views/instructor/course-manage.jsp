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
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=26">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=26">
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
    <a href="<%=request.getContextPath()%>/" class="lms-logo">
        <img src="<%=request.getContextPath()%>/assets/images/utedu-logo.png" alt="UTEdu" class="lms-logo-img">
        <span class="logo-tag">LMS</span>
    </a>
    <div class="nav-links">
        <a href="<%=request.getContextPath()%>/instructor/courses" class="nav-link">← Danh sách khóa học</a>
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
                            <button type="button" class="btn-action-sm" onclick="openEditSectionModal(${section.id}, '<c:out value="${section.title}" escapeXml="true"/>')">
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
                                        </span>
                                        <div style="display:flex;align-items:center;gap:8px;">
                                            <span class="lesson-dur">
                                                <c:choose>
                                                    <c:when test="${lesson.durationMinutes != null}">${lesson.durationMinutes} phút</c:when>
                                                    <c:otherwise>N/A</c:otherwise>
                                                </c:choose>
                                            </span>
                                            <button type="button" class="btn-action-sm" style="padding:3px 8px;font-size:11px;"
                                                    onclick="openEditLessonModal(${lesson.id}, '<c:out value="${lesson.title}" escapeXml="true"/>', '${lesson.durationMinutes != null ? lesson.durationMinutes : ''}', '<c:out value="${lesson.videoUrl}" escapeXml="true"/>', '<c:out value="${lesson.documentUrl}" escapeXml="true"/>')">
                                                <i class="fa-solid fa-pen"></i> Sửa
                                            </button>
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
            <div style="display:flex;justify-content:flex-end;gap:10px;">
                <button type="button" class="btn btn-outline btn-sm" onclick="closeEditLessonModal()">Hủy</button>
                <button type="submit" class="btn btn-primary btn-sm">💾 Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openEditSectionModal(sectionId, title) {
        document.getElementById('modalEditSectionId').value = sectionId;
        document.getElementById('modalEditSectionTitle').value = title;
        document.getElementById('editSectionModal').classList.add('active');
    }
    function closeEditSectionModal() {
        document.getElementById('editSectionModal').classList.remove('active');
    }
    function openEditLessonModal(lessonId, title, duration, videoUrl, docUrl) {
        document.getElementById('modalEditLessonId').value = lessonId;
        document.getElementById('modalEditLessonTitle').value = title;
        document.getElementById('modalEditLessonDuration').value = duration || '';
        document.getElementById('modalEditLessonVideo').value = videoUrl || '';
        document.getElementById('modalEditLessonDoc').value = docUrl || '';
        document.getElementById('editLessonModal').classList.add('active');
    }
    function closeEditLessonModal() {
        document.getElementById('editLessonModal').classList.remove('active');
</script>

<!-- Dynamic Island Theme Toggle -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=26"></script>
</body>
</html>