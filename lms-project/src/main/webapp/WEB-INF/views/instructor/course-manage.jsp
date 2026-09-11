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
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=22">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=22">
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
        .page-header{padding:32px 40px;background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;}
        .page-header h1{font-size:24px;font-weight:800;margin-bottom:6px;}
        .main{max-width:900px;margin:36px auto;padding:0 24px;}
        .alert-danger{background:#fff5f5;color:#c53030;border:1px solid #feb2b2;padding:14px 18px;border-radius:9px;font-size:14px;margin-bottom:20px;}
        .alert-info{background:#ebf8ff;color:#2b6cb0;border:1px solid #bee3f8;padding:12px 16px;border-radius:9px;font-size:13px;margin-bottom:20px;}
        .section-block{background:#fff;border-radius:14px;box-shadow:0 4px 14px rgba(0,0,0,.06);margin-bottom:24px;overflow:hidden;}
        .section-head{padding:16px 22px;background:#f7f8ff;border-left:4px solid #667eea;display:flex;align-items:center;justify-content:space-between;}
        .section-head h3{font-size:15px;font-weight:700;color:#1a202c;}
        .lesson-list{padding:0;}
        .lesson-row{display:flex;align-items:center;justify-content:space-between;padding:12px 22px;border-top:1px solid #f0f4f8;}
        .lesson-row:hover{background:#fafbff;}
        .lesson-info{font-size:13px;color:#4a5568;display:flex;align-items:center;gap:8px;}
        .lesson-dur{font-size:12px;color:#a0aec0;}
        .no-lessons{padding:14px 22px;color:#a0aec0;font-size:13px;font-style:italic;}
        .add-lesson-form{padding:18px 22px;border-top:2px dashed #e2e8f0;background:#fafbff;}
        .add-lesson-form h4{font-size:13px;font-weight:700;color:#667eea;margin-bottom:12px;}
        .form-row{display:flex;gap:10px;flex-wrap:wrap;}
        .form-group{flex:1;min-width:160px;}
        .form-group label{display:block;font-size:11px;font-weight:600;color:#4a5568;margin-bottom:4px;}
        .form-control{width:100%;padding:9px 12px;border:1.5px solid #e2e8f0;border-radius:7px;font-size:13px;color:#2d3748;outline:none;}
        .form-control:focus{border-color:#667eea;}
        .add-section-card{background:#fff;border-radius:14px;padding:28px 24px;box-shadow:0 4px 14px rgba(0,0,0,.06);margin-bottom:20px;border:2px dashed #c3dafe;}
        .add-section-card h3{font-size:15px;font-weight:700;color:#667eea;margin-bottom:16px;}
        .section-form-row{display:flex;gap:12px;align-items:flex-end;}
        .submit-section{background:#fff;border-radius:14px;padding:24px;box-shadow:0 4px 14px rgba(0,0,0,.06);text-align:center;margin-bottom:20px;border-top:4px solid #f6ad55;}
        .submit-section p{font-size:14px;color:#718096;margin-bottom:14px;}
        .btn-submit-review{padding:12px 32px;background:linear-gradient(135deg,#f6ad55,#ed8936);color:#fff;border:none;border-radius:9px;font-size:15px;font-weight:700;cursor:pointer;transition:opacity .2s,transform .1s;}
        .btn-submit-review:hover{opacity:.9;transform:translateY(-1px);}
        .readonly-notice{background:#fffff0;border:1px solid #f6e05e;color:#744210;padding:12px 16px;border-radius:9px;font-size:13px;margin-bottom:20px;}
</head>
<body class="mesh-bg">
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
                        <h3><i class="fa-solid fa-book-open"></i> Chương ${st.index + 1}: <c:out value="${section.title}"/></h3>
                        <span style="font-size:12px;color:#a0aec0;">${section.lessons.size()} bài học</span>
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
                                        <span class="lesson-dur">
                                            <c:choose>
                                                <c:when test="${lesson.durationMinutes != null}">${lesson.durationMinutes} phút</c:when>
                                                <c:otherwise>N/A</c:otherwise>
                                            </c:choose>
                                        </span>
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
        <div style="background:#fff;border-radius:14px;box-shadow:0 4px 14px rgba(0,0,0,.06);padding:24px 28px;margin-bottom:24px;border-left:4px solid #f6ad55;">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;">
                <h3 style="font-size:16px;font-weight:700;color:#1a202c;">📝 Quiz khóa học</h3>
                <a href="${pageContext.request.contextPath}/instructor/quizzes/new?courseId=${course.id}"
                   class="btn btn-primary btn-sm">➕ Tạo Quiz mới</a>
            </div>
            <p style="font-size:13px;color:#718096;margin-bottom:16px;">Tạo bài kiểm tra tổng kết cho toàn bộ khóa học hoặc cho từng chương cụ thể.</p>
            
            <c:choose>
                <c:when test="${not empty quizzes}">
                    <div style="display:flex;flex-direction:column;gap:12px;">
                        <c:forEach var="quiz" items="${quizzes}">
                            <div style="display:flex;justify-content:space-between;align-items:center;padding:12px 16px;background:#fffaf0;border:1px solid #feebc8;border-radius:8px;">
                                <div>
                                    <div style="font-size:14px;font-weight:700;color:#c05621;"><c:out value="${quiz.title}"/></div>
                                    <div style="font-size:12px;color:#dd6b20;margin-top:4px;">
                                        ${quiz.totalQuestions} câu hỏi · Điểm đạt: ${quiz.passScore}/100
                                        <c:choose>
                                            <c:when test="${quiz.courseId != null}"> (Quiz tổng kết)</c:when>
                                            <c:otherwise> (Quiz chương ID: ${quiz.sectionId})</c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                <a href="${pageContext.request.contextPath}/instructor/quizzes/manage?id=${quiz.id}" class="btn btn-outline btn-sm" style="border-color:#dd6b20;color:#dd6b20;">Quản lý câu hỏi</a>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="padding:16px;background:#f7fafc;border-radius:8px;text-align:center;font-size:13px;color:#a0aec0;font-style:italic;">
                        Chưa có Quiz nào được tạo.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
</div>
</body>
</html>