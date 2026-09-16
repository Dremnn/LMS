<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khám phá khóa học - UTEdu LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
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
                        <a href="<%=request.getContextPath()%>/student/chat" class="quick-action-btn" title="Tin nhắn">
                <i class="fa-solid fa-comment-dots"></i><span class="quick-action-text">Tin nhắn</span>
            </a>
            <a href="<%=request.getContextPath()%>/student/notifications" class="quick-action-btn" title="Thông báo">
                <i class="fa-solid fa-bell"></i><span class="quick-action-text">Thông báo</span>
            </a>
        </div>
        <% } %>
    </div>
    <div class="nav-links">
        <a href="<%=request.getContextPath()%>/courses" class="nav-link active">Khóa học</a>
        <% if (currentUser != null) { %>
            <% if ("student".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/student/dashboard" class="nav-link">Bảng điều khiển</a>
                <a href="<%=request.getContextPath()%>/student/my-courses" class="nav-link">Khóa học của tôi</a>
            <% } %>
            <a href="<%=request.getContextPath()%>/profile" class="nav-link">Hồ sơ</a>
            <div class="user-badge">
                <% if (currentUser.getAvatarUrl() != null && !currentUser.getAvatarUrl().trim().isEmpty()) { %>
                    <img src="<%=currentUser.getAvatarUrl()%>" alt="Avatar" class="user-avatar" style="object-fit: cover;">
                <% } else { %>
                    <div class="user-avatar"><%=currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName().substring(0,1).toUpperCase() : "U"%></div>
                <% } %>
                <span><%=currentUser.getFullName()%></span>
                <span class="role-tag"><%=role%></span>
            </div>
            <% if ("instructor".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/instructor/courses" class="btn btn-outline">Quản lý</a>
            <% } else if ("admin".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/admin" class="btn btn-outline">Quản trị</a>
            <% } %>
            <a href="<%=request.getContextPath()%>/logout" class="btn btn-danger">Đăng xuất</a>
        <% } else { %>
            <a href="<%=request.getContextPath()%>/login" class="btn btn-outline">Đăng nhập</a>
            <a href="<%=request.getContextPath()%>/register" class="btn btn-primary">Đăng ký</a>
        <% } %>
    </div>
</nav>

<!-- PAGE HEADER -->
<div class="page-header">
    <div class="page-header-inner">
        <div>
            <h1><i class="fa-solid fa-compass"></i> Khám phá khóa học</h1>
            <p>Tìm kiếm và học những kỹ năng bạn muốn phát triển</p>
        </div>
    </div>
</div>

<!-- SEARCH -->
<div class="search-section">
    <form action="${pageContext.request.contextPath}/courses" method="get" class="search-form">
        <input type="text" name="keyword" class="search-input"
               placeholder="Tìm kiếm khóa học..." value="<c:out value='${keyword}' default=''/>">
        <select name="categoryId" class="search-select">
            <option value="">Tất cả danh mục</option>
            <c:forEach var="cat" items="${categories}">
                <option value="${cat.id}" <c:if test="${cat.id == selectedCategoryId}">selected</c:if>>
                    <c:out value="${cat.name}"/>
                </option>
            </c:forEach>
        </select>
        <select name="sortBy" class="search-select">
            <option value="newest" <c:if test="${sortBy == 'newest' || empty sortBy}">selected</c:if>>Mới nhất</option>
            <option value="popular" <c:if test="${sortBy == 'popular'}">selected</c:if>>Phổ biến nhất</option>
            <option value="rating" <c:if test="${sortBy == 'rating'}">selected</c:if>>Đánh giá cao nhất</option>
        </select>
        <button type="submit" class="btn-search"><i class="fa-solid fa-magnifying-glass"></i> Tìm kiếm</button>
    </form>
</div>

<!-- MAIN -->
<div class="lms-main">
    <p class="result-info">
        <c:choose>
            <c:when test="${not empty courses}">Tìm thấy <strong>${courses.size()}</strong> khóa học</c:when>
            <c:otherwise>Không có kết quả nào</c:otherwise>
        </c:choose>
    </p>

    <c:choose>
        <c:when test="${not empty courses}">
            <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:24px;">
                <c:forEach var="course" items="${courses}" varStatus="vs">
                    <div class="course-card reveal reveal-d${(vs.index % 3) + 1}">
                        <div class="course-img-wrap">
                            <c:choose>
                                <c:when test="${not empty course.thumbnailUrl}">
                                    <img class="course-card-img" src="${course.thumbnailUrl}" alt="<c:out value='${course.title}'/>"
                                         onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/default-course.svg';">
                                </c:when>
                                <c:otherwise>
                                    <img class="course-card-img" src="${pageContext.request.contextPath}/assets/images/default-course.svg" alt="Default Thumbnail">
                                </c:otherwise>
                            </c:choose>
                            <c:if test="${not empty course.categoryName}">
                                <div class="course-category-chip"><c:out value="${course.categoryName}"/></div>
                            </c:if>
                        </div>
                        <div class="course-card-body">
                            <h3 class="course-card-title">
                                <a href="${pageContext.request.contextPath}/courses/detail?id=${course.id}">
                                    <c:out value="${course.title}"/>
                                </a>
                            </h3>
                            <c:if test="${course.status == 'warning' || course.status == 'appealed'}">
                                <div style="background:#fed7d7;color:#9b2c2c;padding:4px 10px;border-radius:6px;font-size:11px;font-weight:700;margin-bottom:6px;display:inline-block;">
                                    <i class="fa-solid fa-triangle-exclamation"></i> Đang bị cảnh cáo
                                </div>
                            </c:if>
                            <p class="course-card-instructor"><i class="fa-solid fa-chalkboard-user"></i> <c:out value="${course.instructorName}"/></p>
                            <div class="course-card-meta">
                                <span><i class="fa-solid fa-star"></i> ${course.avgRating}</span>
                                <span><i class="fa-solid fa-users"></i> ${course.totalStudents} học viên</span>
                                <span><i class="fa-solid fa-book-open"></i> ${course.totalLessons} bài</span>
                            </div>
                            <div class="course-card-footer">
                                <span>
                                    <c:choose>
                                        <c:when test="${course.price == 0 || course.price == null}">
                                            <span class="price-free">Miễn phí</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="price-paid">${course.price} đ</span>
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                                <a href="${pageContext.request.contextPath}/courses/detail?id=${course.id}"
                                   class="btn btn-primary btn-sm">Xem chi tiết</a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <span class="empty-state-icon"><i class="fa-solid fa-magnifying-glass"></i></span>
                <h3>Không tìm thấy khóa học</h3>
                <p>Hãy thử từ khóa hoặc danh mục khác nhé!</p>
                <a href="${pageContext.request.contextPath}/courses" class="btn btn-primary">Xem tất cả khóa học</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- FOOTER -->
<footer class="lms-footer modern-footer">
    <div class="container">
        <div class="footer-grid" style="align-items: flex-start;">
            <div class="footer-col brand-col">
                <a href="<%=request.getContextPath()%>/" class="lms-logo footer-logo" style="margin-bottom: 16px;">
                    <span class="logo-icon"><i class="fa-solid fa-graduation-cap"></i></span><span class="logo-text">UTEdu LMS</span>
                </a>
                <p class="footer-desc">Nền tảng học trực tuyến hàng đầu Việt Nam.</p>
            </div>
            <div class="footer-col">
                <h4 class="footer-title">Liên kết</h4>
                <ul class="footer-links">
                    <li><a href="<%=request.getContextPath()%>/courses">Khóa học</a></li>
                    <li><a href="<%=request.getContextPath()%>/register">Đăng ký</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h4 class="footer-title">Hỗ trợ</h4>
                <ul class="footer-links">
                    <li><a href="#">Hướng dẫn</a></li>
                    <li><a href="#">Liên hệ</a></li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; 2026 UTEdu LMS</p>
        </div>
    </div>
</footer>

<!-- Dynamic Island Theme Toggle (Lưu tùy chọn vào Cookie 365 ngày) -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=30"></script>

</body>
</html>