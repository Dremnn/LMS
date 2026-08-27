<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${course.title} - LMS</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',Roboto,Arial,sans-serif;}
        body{background:#f0f4f8;color:#2d3748;}
        .navbar{background:#fff;box-shadow:0 2px 8px rgba(0,0,0,.07);padding:14px 40px;display:flex;justify-content:space-between;align-items:center;position:sticky;top:0;z-index:100;}
        .navbar .logo{font-size:20px;font-weight:800;color:#667eea;text-decoration:none;}
        .nav-links{display:flex;align-items:center;gap:12px;}
        .btn{padding:8px 18px;border-radius:8px;font-size:14px;font-weight:600;text-decoration:none;cursor:pointer;border:none;transition:all .2s;display:inline-block;}
        .btn-outline{border:1.5px solid #667eea;color:#667eea;background:transparent;}
        .btn-outline:hover{background:#667eea;color:#fff;}
        .btn-primary{background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;}
        .btn-danger{background:#fc8181;color:#742a2a;}
        .btn-enroll{padding:14px 32px;background:linear-gradient(135deg,#f093fb,#f5576c);color:#fff;border-radius:10px;font-size:17px;font-weight:700;text-decoration:none;transition:all .2s;display:inline-block;}
        .btn-enroll:hover{transform:translateY(-2px);box-shadow:0 8px 20px rgba(245,87,108,.35);}
        .badge{display:inline-block;padding:2px 9px;border-radius:12px;font-size:11px;font-weight:700;background:#ebf8ff;color:#2b6cb0;text-transform:uppercase;margin-left:6px;}
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
<body>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";
%>
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/" class="logo">🎓 LMS System</a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/courses" class="btn btn-outline">← Danh sách khóa học</a>
        <% if (currentUser != null) { %>
            <span style="font-size:14px;color:#4a5568;font-weight:600;"><%=currentUser.getFullName()%><span class="badge"><%=role%></span></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">Đăng xuất</a>
        <% } else { %>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">Đăng nhập</a>
        <% } %>
    </div>
</nav>

<div class="hero-section">
    <div class="hero-inner">
        <div class="hero-info">
            <a href="${pageContext.request.contextPath}/courses" class="back-link">← Quay lại danh sách</a>
            <c:if test="${not empty course.categoryName}">
                <span style="font-size:13px;color:#a78bfa;font-weight:600;display:block;margin-bottom:10px;">📂 <c:out value="${course.categoryName}"/></span>
            </c:if>
            <h1><c:out value="${course.title}"/></h1>
            <p class="desc"><c:out value="${course.description}"/></p>
            <div class="hero-meta">
                <span>👨‍🏫 <c:out value="${course.instructorName}"/></span>
                <span>⭐ ${course.avgRating} / 5</span>
                <span>👥 ${course.totalStudents} học viên</span>
                <span>📖 ${course.totalLessons} bài học</span>
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
            <a href="${pageContext.request.contextPath}/enrollments/new?courseId=${course.id}" class="btn-enroll">
                🚀 Đăng ký học ngay
            </a>
        </div>
        <div class="hero-img">
            <c:choose>
                <c:when test="${not empty course.thumbnailUrl}">
                    <img src="${course.thumbnailUrl}" alt="<c:out value='${course.title}'/>">
                </c:when>
                <c:otherwise>
                    <img src="https://via.placeholder.com/400x240/667eea/ffffff?text=LMS+Course" alt="Course Thumbnail">
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<div class="main">
    <div class="curriculum-title">📚 Chương trình học</div>
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
                                        <span class="lesson-name">▶ <c:out value="${lesson.title}"/></span>
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
                <div style="font-size:48px;margin-bottom:12px;">📭</div>
                <p>Khóa học này chưa có nội dung. Vui lòng quay lại sau!</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>
