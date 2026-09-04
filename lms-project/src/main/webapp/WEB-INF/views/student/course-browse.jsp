<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khám phá khóa học - LMS</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',Roboto,Arial,sans-serif;}
        body{background:#f0f4f8;color:#2d3748;}
        .navbar{background:#fff;box-shadow:0 2px 8px rgba(0,0,0,.07);padding:14px 40px;display:flex;justify-content:space-between;align-items:center;position:sticky;top:0;z-index:100;}
        .navbar .logo{font-size:20px;font-weight:800;color:#667eea;text-decoration:none;}
        .nav-links{display:flex;align-items:center;gap:12px;}
        .nav-link{color:#4a5568;text-decoration:none;font-size:14px;font-weight:500;padding:6px 2px;border-bottom:2px solid transparent;}
        .nav-link.active,.nav-link:hover{color:#667eea;border-bottom-color:#667eea;}
        .btn{padding:8px 18px;border-radius:8px;font-size:14px;font-weight:600;text-decoration:none;cursor:pointer;border:none;transition:all .2s;display:inline-block;}
        .btn-outline{border:1.5px solid #667eea;color:#667eea;background:transparent;}
        .btn-outline:hover{background:#667eea;color:#fff;}
        .btn-primary{background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;}
        .btn-danger{background:#fc8181;color:#742a2a;}
        .btn-danger:hover{background:#f56565;color:#fff;}
        .page-header{background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;padding:48px 40px;}
        .page-header h1{font-size:32px;font-weight:800;margin-bottom:8px;}
        .page-header p{opacity:.88;font-size:15px;}
        .search-section{background:#fff;padding:24px 40px;box-shadow:0 2px 8px rgba(0,0,0,.05);}
        .search-form{display:flex;gap:12px;flex-wrap:wrap;align-items:center;}
        .search-input{flex:1;min-width:220px;padding:10px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;outline:none;transition:border-color .2s;}
        .search-input:focus{border-color:#667eea;}
        .search-select{padding:10px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;color:#2d3748;outline:none;cursor:pointer;background:#fff;}
        .btn-search{padding:10px 22px;background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;border:none;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer;}
        .main{max-width:1200px;margin:36px auto;padding:0 24px;}
        .result-info{color:#718096;font-size:14px;margin-bottom:20px;}
        .course-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:24px;}
        .course-card{background:#fff;border-radius:14px;overflow:hidden;box-shadow:0 4px 16px rgba(0,0,0,.07);transition:transform .2s,box-shadow .2s;}
        .course-card:hover{transform:translateY(-4px);box-shadow:0 10px 30px rgba(0,0,0,.12);}
        .course-card img{width:100%;height:185px;object-fit:cover;}
        .course-body{padding:20px;}
        .course-title{font-size:16px;font-weight:700;color:#1a202c;margin-bottom:8px;line-height:1.4;}
        .course-title a{color:inherit;text-decoration:none;}
        .course-title a:hover{color:#667eea;}
        .course-instructor{font-size:13px;color:#718096;margin-bottom:10px;}
        .course-meta{display:flex;gap:14px;font-size:12px;color:#a0aec0;margin-bottom:14px;flex-wrap:wrap;}
        .course-meta span{display:flex;align-items:center;gap:4px;}
        .course-footer{display:flex;justify-content:space-between;align-items:center;border-top:1px solid #f0f4f8;padding-top:14px;}
        .price{font-size:18px;font-weight:800;}
        .price-free{color:#38a169;}
        .price-paid{color:#667eea;}
        .btn-detail{padding:7px 16px;background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;border-radius:7px;font-size:13px;font-weight:600;text-decoration:none;transition:opacity .2s;}
        .btn-detail:hover{opacity:.88;}
        .empty-state{text-align:center;padding:80px 20px;color:#a0aec0;}
        .empty-state .icon{font-size:64px;margin-bottom:16px;}
        .empty-state p{font-size:16px;}
        .badge{display:inline-block;padding:2px 9px;border-radius:12px;font-size:11px;font-weight:700;background:#ebf8ff;color:#2b6cb0;text-transform:uppercase;margin-left:6px;}
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
        <a href="${pageContext.request.contextPath}/courses" class="nav-link active">Khóa học</a>
        <% if (currentUser != null) { %>
            <span style="font-size:14px;color:#4a5568;font-weight:600;"><%=currentUser.getFullName()%><span class="badge"><%=role%></span></span>
            <% if ("instructor".equals(role)) { %>
                <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-outline">Quản lý</a>
            <% } %>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">Đăng xuất</a>
        <% } else { %>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-outline">Đăng nhập</a>
            <a href="${pageContext.request.contextPath}/register" class="btn btn-primary">Đăng ký</a>
        <% } %>
    </div>
</nav>

<div class="page-header">
    <h1>📚 Khám phá khóa học</h1>
    <p>Tìm kiếm và học những kỹ năng bạn muốn phát triển</p>
</div>

<div class="search-section">
    <form action="${pageContext.request.contextPath}/courses" method="get" class="search-form">
        <input type="text" name="keyword" class="search-input"
               placeholder="🔍 Tìm kiếm khóa học..." value="<c:out value='${keyword}' default=''/>">
        <select name="categoryId" class="search-select">
            <option value="">📂 Tất cả danh mục</option>
            <c:forEach var="cat" items="${categories}">
                <option value="${cat.id}" <c:if test="${cat.id == selectedCategoryId}">selected</c:if>>
                    <c:out value="${cat.name}"/>
                </option>
            </c:forEach>
        </select>
        <select name="sortBy" class="search-select">
            <option value="newest" <c:if test="${sortBy == 'newest' || empty sortBy}">selected</c:if>>🕐 Mới nhất</option>
            <option value="popular" <c:if test="${sortBy == 'popular'}">selected</c:if>>🔥 Phổ biến nhất</option>
            <option value="rating" <c:if test="${sortBy == 'rating'}">selected</c:if>>⭐ Đánh giá cao nhất</option>
        </select>
        <button type="submit" class="btn-search">Tìm kiếm</button>
    </form>
</div>

<div class="main">
    <p class="result-info">
        <c:choose>
            <c:when test="${not empty courses}">Tìm thấy <strong>${courses.size()}</strong> khóa học</c:when>
            <c:otherwise>Không có kết quả nào</c:otherwise>
        </c:choose>
    </p>

    <c:choose>
        <c:when test="${not empty courses}">
            <div class="course-grid">
                <c:forEach var="course" items="${courses}">
                    <div class="course-card">
                        <a href="${pageContext.request.contextPath}/courses/detail?id=${course.id}">
                            <c:choose>
                                <c:when test="${not empty course.thumbnailUrl}">
                                    <img src="${course.thumbnailUrl}" alt="<c:out value='${course.title}'/>">
                                </c:when>
                                <c:otherwise>
                                    <img src="https://via.placeholder.com/400x200/667eea/ffffff?text=No+Image" alt="No Image">
                                </c:otherwise>
                            </c:choose>
                        </a>
                        <div class="course-body">
                            <h3 class="course-title">
                                <a href="${pageContext.request.contextPath}/courses/detail?id=${course.id}">
                                    <c:out value="${course.title}"/>
                                </a>
                            </h3>
                            <c:if test="${course.status == 'warning' || course.status == 'appealed'}">
                                <div style="background:#fed7d7;color:#9b2c2c;padding:4px 10px;border-radius:6px;font-size:11px;font-weight:700;margin-bottom:6px;display:inline-block;">⚠️ Đang bị cảnh cáo</div>
                            </c:if>
                            <p class="course-instructor">👨‍🏫 <c:out value="${course.instructorName}"/></p>
                            <div class="course-meta">
                                <span>⭐ ${course.avgRating}</span>
                                <span>👤 ${course.totalStudents} học viên</span>
                                <span>📖 ${course.totalLessons} bài học</span>
                                <c:if test="${not empty course.categoryName}">
                                    <span>📂 <c:out value="${course.categoryName}"/></span>
                                </c:if>
                            </div>
                            <div class="course-footer">
                                <span class="price">
                                    <c:choose>
                                        <c:when test="${course.price == 0 || course.price == null}">
                                            <span class="price-free">Miễn phí</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="price-paid">${course.price} đ</span>
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                                <a href="${pageContext.request.contextPath}/courses/detail?id=${course.id}" class="btn-detail">Xem chi tiết</a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <div class="icon">🔍</div>
                <p>Không tìm thấy khóa học phù hợp.<br>Hãy thử từ khóa hoặc danh mục khác!</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>
