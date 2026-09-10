<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${course.title} - UTEdu LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=22">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=22">
    <style>
        .hero-section{background:rgba(255,255,255,0.75);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);border-bottom:1px solid rgba(226,232,240,0.8);padding:50px 40px 60px;}
        .hero-inner{max-width:1160px;margin:0 auto;display:grid;grid-template-columns:1fr 420px;gap:56px;align-items:start;}
        .hero-info h1{font-size:34px;font-weight:800;line-height:1.25;margin-bottom:16px;color:#0F172A;}
        .hero-info .desc{font-size:15px;color:#475569;line-height:1.7;margin-bottom:24px;max-height:90px;overflow:hidden;}
        .hero-meta{display:flex;flex-wrap:wrap;gap:12px;font-size:13px;margin-bottom:28px;}
        .hero-meta span{display:inline-flex;align-items:center;gap:6px;background:#F1F5F9;color:#475569;padding:6px 14px;border-radius:30px;font-weight:600;}
        .hero-meta span.instructor-tag{background:#EEF2FF;color:#4F46E5;}
        .hero-meta span.rating-tag{background:#FEF3C7;color:#D97706;}
        .hero-price{font-size:32px;font-weight:800;margin-bottom:24px;}
        .price-free{color:#10B981;}
        .price-paid{color:#4F46E5;}
        .btn-enroll{padding:14px 36px;background:linear-gradient(135deg,#4F46E5,#06B6D4);color:#fff;border-radius:12px;font-size:16px;font-weight:700;text-decoration:none;transition:all .2s;display:inline-flex;align-items:center;gap:8px;border:none;cursor:pointer;box-shadow:0 8px 24px rgba(79,70,229,.28);}
        .btn-enroll:hover{transform:translateY(-2px);box-shadow:0 12px 32px rgba(79,70,229,.38);color:#fff;}
        .hero-img{border-radius:20px;overflow:hidden;box-shadow:0 16px 40px rgba(0,0,0,.08);border:1px solid #E2E8F0;background:#fff;}
        .hero-img img{width:100%;height:260px;object-fit:cover;display:block;}
        .back-link{display:inline-flex;align-items:center;gap:8px;color:#64748B;text-decoration:none;font-size:14px;font-weight:600;margin-bottom:20px;transition:color .2s;}
        .back-link:hover{color:#4F46E5;}
        .main{max-width:1160px;margin:48px auto;padding:0 24px;}
        .curriculum-title{font-size:24px;font-weight:800;color:#0F172A;margin-bottom:24px;display:flex;align-items:center;gap:12px;}
        .section-card{background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,.04);margin-bottom:20px;border:1px solid #E2E8F0;}
        .section-header{padding:18px 24px;background:#F8FAFC;display:flex;justify-content:space-between;align-items:center;border-left:4px solid #4F46E5;border-bottom:1px solid #F1F5F9;}
        .section-header h3{font-size:16px;font-weight:700;color:#0F172A;}
        .section-body{padding:0;}
        .lesson-item{display:flex;align-items:center;justify-content:space-between;padding:14px 24px;border-top:1px solid #F1F5F9;transition:background .15s;}
        .lesson-item:hover{background:#F8FAFF;}
        .lesson-name{font-size:14px;color:#1E293B;display:flex;align-items:center;gap:10px;font-weight:500;}
        .lesson-name a{color:#1E293B;text-decoration:none;font-weight:600;display:inline-flex;align-items:center;gap:8px;transition:color .15s;}
        .lesson-name a:hover{color:#4F46E5;}
        .lesson-duration{font-size:13px;color:#94A3B8;white-space:nowrap;font-weight:500;}
        .empty-lessons{padding:18px 24px;color:#94A3B8;font-size:14px;font-style:italic;}
        .empty-state{text-align:center;padding:70px 20px;color:#94A3B8;background:#fff;border-radius:16px;border:1px solid #E2E8F0;}
        .progress-box{background:#F8FAFC;border:1px solid #E2E8F0;border-radius:12px;padding:16px 20px;margin-bottom:20px;}
        .progress-bar-bg{background:#E2E8F0;border-radius:10px;height:8px;overflow:hidden;margin-top:10px;}
        .progress-bar-fill{height:100%;border-radius:10px;background:linear-gradient(90deg,#4F46E5,#06B6D4);}
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
                <span style="font-size:13px;color:#4F46E5;background:#EEF2FF;padding:4px 12px;border-radius:20px;font-weight:700;display:inline-block;margin-bottom:12px;">
                    <i class="fa-solid fa-folder-open"></i> <c:out value="${course.categoryName}"/>
                </span>
            </c:if>
            <h1><c:out value="${course.title}"/></h1>
            <c:if test="${not empty error}">
                <div style="background:#fef2f2;color:#991b1b;border:1px solid #fecaca;padding:12px 18px;border-radius:10px;font-size:14px;margin-bottom:16px;">
                    <i class="fa-solid fa-triangle-exclamation"></i> ${error}
                </div>
            </c:if>
            <c:if test="${course.status == 'warning' || course.status == 'appealed'}">
                <div style="background:#fffbeb;border:1px solid #fde68a;padding:14px 18px;border-radius:10px;font-size:14px;margin-bottom:16px;color:#92400e;">
                    <i class="fa-solid fa-triangle-exclamation"></i> <strong>Khóa học này đang bị cảnh cáo</strong> — Nội dung đang được xem xét bởi quản trị viên.
                </div>
            </c:if>
            <p class="desc"><c:out value="${course.description}"/></p>
            <div class="hero-meta">
                <span class="instructor-tag"><i class="fa-solid fa-chalkboard-user"></i> <c:out value="${course.instructorName}"/></span>
                <span class="rating-tag"><i class="fa-solid fa-star"></i> ${course.avgRating} / 5</span>
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
                    <div class="progress-box">
                        <div style="font-size:14px;color:#1E293B;display:flex;justify-content:space-between;font-weight:600;">
                            <span><i class="fa-solid fa-circle-check" style="color:#10B981;"></i> Đã đăng ký khóa học</span>
                            <span>Tiến độ: <strong>${enrollment.progressPercent}%</strong></span>
                        </div>
                        <div class="progress-bar-bg">
                            <div class="progress-bar-fill" style="width:${enrollment.progressPercent}%;"></div>
                        </div>
                    </div>
                    <div style="display:flex; gap:12px; align-items:center; flex-wrap:wrap;">
                        <a href="${pageContext.request.contextPath}/student/lessons/view?lessonId=${course.sectionsCache[0].lessons[0].id}" class="btn-enroll">
                            <i class="fa-solid fa-play"></i> Tiếp tục học
                        </a>
                        <form action="${pageContext.request.contextPath}/enrollments/cancel" method="post" style="display:inline;"
                              onsubmit="return confirm('Bạn có chắc chắn muốn hủy khóa học này không? Mọi tiến độ học tập sẽ bị xóa.')">
                            <input type="hidden" name="courseId" value="${course.id}" />
                            <button type="submit" class="btn" style="background:#FEE2E2;color:#991B1B;padding:12px 20px;border-radius:12px;font-weight:600;border:none;cursor:pointer;">
                                <i class="fa-solid fa-xmark"></i> Hủy khóa học
                            </button>
                        </form>
                    </div>
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
                    <img src="https://via.placeholder.com/420x260/6366F1/ffffff?text=UTEdu+Course" alt="Course Thumbnail">
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
                        <span style="font-size:12px;color:#64748B;font-weight:500;">${section.lessons.size()} bài học</span>
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
                                                       style="color:#4F46E5;text-decoration:none;font-weight:600;"
                                                       onmouseover="this.style.textDecoration='underline'"
                                                       onmouseout="this.style.textDecoration='none'">
                                                        <i class="fa-solid fa-circle-play" style="color:#4F46E5;"></i> <c:out value="${lesson.title}"/>
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <%-- Chưa đăng ký: text tĩnh + icon khóa --%>
                                                    <span style="color:#94A3B8;"><i class="fa-solid fa-lock" style="color:#CBD5E1;"></i> <c:out value="${lesson.title}"/></span>
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