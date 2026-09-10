<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${course.title} - EduViet LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=22">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=22">
    <style>
        .btn-enroll{padding:14px 32px;background:linear-gradient(135deg,#f093fb,#f5576c);color:#fff;border-radius:10px;font-size:17px;font-weight:700;text-decoration:none;transition:all .2s;display:inline-block;border:none;cursor:pointer;}
        .btn-enroll:hover{transform:translateY(-2px);box-shadow:0 8px 20px rgba(245,87,108,.35);}
        .hero-section{background:linear-gradient(135deg,#1a202c 0%,#2d3748 100%);color:#fff;padding:60px 40px;}
        .hero-inner{max-width:1100px;margin:0 auto;display:grid;grid-template-columns:1fr 400px;gap:48px;align-items:start;}
        .hero-info h1{font-size:32px;font-weight:800;line-height:1.25;margin-bottom:16px;}
        .hero-info .desc{font-size:15px;opacity:.85;line-height:1.7;margin-bottom:20px;max-height:80px;overflow:hidden;}
        .hero-meta{display:flex;flex-wrap:wrap;gap:18px;font-size:14px;opacity:.9;margin-bottom:28px;}
        .hero-meta span{display:flex;align-items:center;gap:6px;}
        .hero-price{font-size:30px;font-weight:800;margin-bottom:20px;}
        .price-free{color:#48bb78;}
        .price-paid{color:#fbd38d;}
        .hero-img{border-radius:14px;overflow:hidden;box-shadow:0 12px 40px rgba(0,0,0,.4);}
        .hero-img img{width:100%;height:240px;object-fit:cover;display:block;}
        .back-link{display:inline-flex;align-items:center;gap:6px;color:rgba(255,255,255,.75);text-decoration:none;font-size:14px;margin-bottom:24px;transition:color .2s;}
        .back-link:hover{color:#fff;}
        .main{max-width:1100px;margin:48px auto;padding:0 24px;}
        .section-card{background:#fff;border-radius:14px;overflow:hidden;box-shadow:0 4px 16px rgba(0,0,0,.06);margin-bottom:16px;}
        .section-header{padding:16px 22px;background:linear-gradient(90deg,#f7f8ff,#fff);display:flex;align-items:center;gap:12px;border-left:4px solid #667eea;}
        .section-header h3{font-size:15px;font-weight:700;color:#1a202c;}
        .section-body{padding:0;}
        .lesson-item{display:flex;align-items:center;justify-content:space-between;padding:12px 22px;border-top:1px solid #f0f4f8;transition:background .15s;}
        .lesson-item:hover{background:#fafbff;}
        .lesson-name{font-size:14px;color:#4a5568;display:flex;align-items:center;gap:8px;}
        .lesson-duration{font-size:12px;color:#a0aec0;white-space:nowrap;}
        .empty-lessons{padding:14px 22px;color:#a0aec0;font-size:13px;font-style:italic;}
        .curriculum-title{font-size:22px;font-weight:700;color:#1a202c;margin-bottom:20px;display:flex;align-items:center;gap:10px;}
        .empty-state{text-align:center;padding:60px 20px;color:#a0aec0;background:#fff;border-radius:14px;}
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
        <span class="logo-text">EduViet <span class="logo-tag">LMS</span></span>
    </a>
    <div class="nav-links">
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

<div class="hero-section">
    <div class="hero-inner">
        <div class="hero-info">
            <a href="${pageContext.request.contextPath}/courses" class="back-link"><i class="fa-solid fa-arrow-left"></i> Quay lại danh sách</a>
            <c:if test="${not empty course.categoryName}">
                <span style="font-size:13px;color:#a78bfa;font-weight:600;display:block;margin-bottom:10px;">
                    <i class="fa-solid fa-folder-open"></i> <c:out value="${course.categoryName}"/>
                </span>
            </c:if>
            <h1><c:out value="${course.title}"/></h1>
            <c:if test="${not empty error}">
                <div style="background:#fed7d7;color:#822727;border:1px solid #fc8181;padding:11px 16px;border-radius:9px;font-size:14px;margin-bottom:14px;">
                    <i class="fa-solid fa-triangle-exclamation"></i> ${error}
                </div>
            </c:if>
            <c:if test="${course.status == 'warning' || course.status == 'appealed'}">
                <div style="background:rgba(237,137,54,.15);border:1px solid rgba(237,137,54,.5);padding:12px 16px;border-radius:9px;font-size:14px;margin-bottom:14px;color:#fbd38d;">
                    <i class="fa-solid fa-triangle-exclamation"></i> <strong>Khóa học này đang bị cảnh cáo</strong> — Nội dung đang được xem xét bởi quản trị viên.
                </div>
            </c:if>
            <p class="desc"><c:out value="${course.description}"/></p>
            <div class="hero-meta">
                <span><i class="fa-solid fa-chalkboard-user"></i> <c:out value="${course.instructorName}"/></span>
                <span><i class="fa-solid fa-star"></i> ${course.avgRating} / 5</span>
                <span><i class="fa-solid fa-users"></i> ${course.totalStudents} học viên</span>
                <span><i class="fa-solid fa-book-open"></i> ${course.totalLessons} bài học</span>
            </div>
            <div class="hero-price">
                <c:choose>
                    <c:when test="${course.price == 0 || course.price == null}">
                        <span class="price-free">Miễn phí</span>
                    </c:when>
                    <c:otherwise>
                        <span class="price-paid">${course.price} đ</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <c:choose>
                <c:when test="${not empty enrollment}">
                    <%-- Đã đăng ký: hiện tiến độ + nút vào học --%>
                    <div style="background:rgba(255,255,255,.12);border:1px solid rgba(255,255,255,.25);border-radius:10px;padding:14px 18px;margin-bottom:16px;">
                        <div style="font-size:13px;opacity:.85;margin-bottom:8px;">
                            <i class="fa-solid fa-circle-check"></i> Bạn đã đăng ký · Tiến độ: <strong>${enrollment.progressPercent}%</strong>
                        </div>
                        <div style="background:rgba(255,255,255,.2);border-radius:10px;height:8px;overflow:hidden;">
                            <div style="height:100%;border-radius:10px;background:#68d391;width:${enrollment.progressPercent}%;"></div>
                        </div>
                    </div>
                    <form action="${pageContext.request.contextPath}/enrollments/cancel" method="post" style="display:inline;"
                          onsubmit="return confirm('Bạn có chắc chắn muốn hủy khóa học này không? Mọi tiến độ học tập sẽ bị xóa.')">
                        <input type="hidden" name="courseId" value="${course.id}" />
                        <button type="submit" class="btn-enroll" style="background:linear-gradient(135deg,#f56565,#c53030);">
                            <i class="fa-solid fa-xmark"></i> Hủy khóa học
                        </button>
                    </form>
                </c:when>
                <c:otherwise>
                    <%-- Chưa đăng ký: hiện form đăng ký --%>
                    <form action="${pageContext.request.contextPath}/enrollments/new" method="post" style="display:inline;">
                        <input type="hidden" name="courseId" value="${course.id}" />
                        <button type="submit" class="btn-enroll"><i class="fa-solid fa-rocket"></i> Đăng ký học ngay</button>
                    </form>
                </c:otherwise>
            </c:choose>
        </div>
        <div class="hero-img">
            <c:choose>
                <c:when test="${not empty course.thumbnailUrl}">
                    <img src="${course.thumbnailUrl}" alt="<c:out value='${course.title}'/>">
                </c:when>
                <c:otherwise>
                    <img src="https://via.placeholder.com/400x240/667eea/ffffff?text=EduViet+Course" alt="Course Thumbnail">
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<div class="main">
    <div class="curriculum-title"><i class="fa-solid fa-list-check"></i> Chương trình học</div>
    <c:choose>
        <c:when test="${not empty course.sectionsCache}">
            <c:forEach var="section" items="${course.sectionsCache}" varStatus="st">
                <div class="section-card">
                    <div class="section-header">
                        <h3>Chương ${st.index + 1}: <c:out value="${section.title}"/></h3>
                        <span style="font-size:12px;color:#a0aec0;">${section.lessons.size()} bài học</span>
                    </div>
                    <div class="section-body">
                        <c:choose>
                            <c:when test="${not empty section.lessons}">
                                <c:forEach var="lesson" items="${section.lessons}">
                                    <div class="lesson-item">
                                        <span class="lesson-name">
                                            <c:choose>
                                                <c:when test="${not empty enrollment}">
                                                    <%-- Đã đăng ký: tên bài là link dẫn vào xem nội dung --%>
                                                    <a href="${pageContext.request.contextPath}/student/lessons/view?lessonId=${lesson.id}"
                                                       style="color:#667eea;text-decoration:none;font-weight:600;"
                                                       onmouseover="this.style.textDecoration='underline'"
                                                       onmouseout="this.style.textDecoration='none'">
                                                        <i class="fa-solid fa-play"></i> <c:out value="${lesson.title}"/>
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <%-- Chưa đăng ký: text tĩnh + icon khóa --%>
                                                    <span style="color:#a0aec0;"><i class="fa-solid fa-lock"></i> <c:out value="${lesson.title}"/></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                        <span class="lesson-duration">
                                            <c:choose>
                                                <c:when test="${lesson.durationMinutes != null}">${lesson.durationMinutes} phút</c:when>
                                                <c:otherwise>N/A</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <p class="empty-lessons">Chương này chưa có bài học nào.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <div style="font-size:48px;margin-bottom:12px;"><i class="fa-solid fa-inbox"></i></div>
                <p>Khóa học này chưa có nội dung. Vui lòng quay lại sau!</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>