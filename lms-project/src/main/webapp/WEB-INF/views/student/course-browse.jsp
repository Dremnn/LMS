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
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=50">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <style>
        /* Quick Filters Bar */
        .quick-filters {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 14px;
            flex-wrap: wrap;
        }
        .quick-filter-label {
            font-size: 13.5px;
            font-weight: 700;
            color: #64748B;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .filter-pill {
            padding: 7px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            background: rgba(255, 255, 255, 0.85);
            border: 1px solid #CBD5E1;
            color: #334155;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s ease;
        }
        .filter-pill:hover {
            border-color: #076FA4;
            color: #076FA4;
            transform: translateY(-1px);
        }
        .filter-pill.active {
            background: #076FA4;
            border-color: #076FA4;
            color: #FFFFFF;
            box-shadow: 0 4px 12px rgba(7, 111, 164, 0.25);
        }
        .filter-pill.filter-bestseller-pill {
            border-color: #F59E0B;
            color: #B45309;
            background: #FEF3C7;
        }
        .filter-pill.filter-bestseller-pill:hover,
        .filter-pill.filter-bestseller-pill.active {
            background: linear-gradient(135deg, #F59E0B, #EA580C);
            border-color: #EA580C;
            color: #FFFFFF;
            box-shadow: 0 4px 14px rgba(245, 158, 11, 0.35);
        }

        /* Best Seller Badge on Course Card */
        .course-img-wrap {
            position: relative;
        }
        .badge-bestseller {
            position: absolute;
            top: 16px;
            left: 16px;
            z-index: 2;
            background: linear-gradient(135deg, #F59E0B, #EA580C);
            color: #FFFFFF;
            font-size: 11px;
            font-weight: 800;
            padding: 4px 10px;
            border-radius: 20px;
            letter-spacing: 0.3px;
            text-transform: uppercase;
            box-shadow: 0 4px 12px rgba(234, 88, 12, 0.45);
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        /* Banner thông báo khi đang lọc Best Seller */
        .bestseller-filter-notice {
            background: linear-gradient(135deg, #FEF3C7, #FDE68A);
            border: 1px solid #FCD34D;
            color: #92400E;
            padding: 12px 18px;
            border-radius: 12px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 14px;
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(245, 158, 11, 0.15);
        }
        .clear-filter-btn {
            background: #FFFFFF;
            color: #B45309;
            padding: 5px 12px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 12.5px;
            font-weight: 700;
            border: 1px solid #FCD34D;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            transition: all 0.2s ease;
        }
        .clear-filter-btn:hover {
            background: #92400E;
            color: #FFFFFF;
        }

        /* Dark Mode Support */
        body.dark-theme .filter-pill {
            background: #182535;
            border-color: #093C62;
            color: #9DB9CB;
        }
        body.dark-theme .filter-pill:hover {
            color: #FFFFFF;
            border-color: #38BDF8;
        }
        body.dark-theme .filter-pill.active {
            background: #076FA4;
            color: #FFFFFF;
        }
        body.dark-theme .filter-pill.filter-bestseller-pill {
            background: rgba(245, 158, 11, 0.15);
            border-color: rgba(245, 158, 11, 0.4);
            color: #FBBF24;
        }
        body.dark-theme .filter-pill.filter-bestseller-pill.active {
            background: linear-gradient(135deg, #F59E0B, #EA580C);
            color: #FFFFFF;
        }
        body.dark-theme .bestseller-filter-notice {
            background: rgba(245, 158, 11, 0.15);
            border-color: rgba(245, 158, 11, 0.3);
            color: #FDE68A;
        }
        body.dark-theme .clear-filter-btn {
            background: #182535;
            color: #FDE68A;
            border-color: rgba(245, 158, 11, 0.4);
        }
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
        <% if (currentUser != null) { %>

            <%@ include file="/WEB-INF/views/partials/user-dropdown-style.jspf" %>
                        <a href="<%= "student".equals(role) ? (request.getContextPath() + "/wallet/topup") : (request.getContextPath() + "/profile") %>" class="wallet-badge" title="Số dư ví - Bấm để nạp tiền/quản lý ví">
                <i class="fa-solid fa-wallet"></i>
                <span><%= (currentUser.getBalance() != null ? String.format(java.util.Locale.US, "%,dđ", currentUser.getBalance().longValue()) : "0đ") %></span>
            </a>
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
                    <a href="<%= "student".equals(role) ? (request.getContextPath() + "/wallet/topup") : (request.getContextPath() + "/profile") %>" class="user-dropdown-item wallet-dropdown-item">
                        <i class="fa-solid fa-wallet"></i>
                        <span>Ví cá nhân</span>
                        <strong class="wallet-dropdown-balance"><%= (currentUser.getBalance() != null ? String.format(java.util.Locale.US, "%,dđ", currentUser.getBalance().longValue()) : "0đ") %></strong>
                    </a>
                    <% if ("student".equals(role)) { %>
                        <a href="${pageContext.request.contextPath}/dashboard" class="user-dropdown-item">
                            <i class="fa-solid fa-table-columns"></i> Bảng điều khiển
                        </a>
                        <a href="${pageContext.request.contextPath}/student/my-courses" class="user-dropdown-item">
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
            <a href="<%=request.getContextPath()%>/courses" class="nav-link active">Khóa học</a>
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

<!-- ========================================================================= -->
<!-- KHỐI TÌM KIẾM & BỘ LỌC (SEARCH & FILTER) -->
<!-- Gửi GET request về /courses (CourseBrowseServlet -> CourseService.searchCourses) -->
<!-- ========================================================================= -->
<div class="search-section">
    <form action="${pageContext.request.contextPath}/courses" method="get" class="search-form">
        <c:if test="${not empty filter}">
            <input type="hidden" name="filter" value="<c:out value='${filter}'/>">
        </c:if>
        <!-- Ô nhập từ khóa tìm kiếm theo tên/mô tả khóa học (param: keyword) -->
        <input type="text" name="keyword" class="search-input"
               placeholder="Tìm kiếm khóa học..." value="<c:out value='${keyword}' default=''/>">
        <!-- Dropdown lọc theo Danh mục lấy từ categoryDAO.findAll() (param: categoryId) -->
        <select name="categoryId" class="search-select">
            <option value="">Tất cả danh mục</option>
            <c:forEach var="cat" items="${categories}">
                <option value="${cat.id}" <c:if test="${cat.id == selectedCategoryId}">selected</c:if>>
                    <c:out value="${cat.name}"/>
                </option>
            </c:forEach>
        </select>
        <!-- Dropdown sắp xếp: newest (Mới nhất), bestseller (Bán chạy nhất), rating (Sao) (param: sortBy) -->
        <select name="sortBy" class="search-select">
            <option value="newest" <c:if test="${sortBy == 'newest' || empty sortBy}">selected</c:if>>Mới nhất</option>
            <option value="bestseller" <c:if test="${sortBy == 'bestseller' || sortBy == 'popular'}">selected</c:if>>Bán chạy nhất (Best Seller)</option>
            <option value="rating" <c:if test="${sortBy == 'rating'}">selected</c:if>>Đánh giá cao nhất</option>
        </select>
        <!-- Nút Submit thực hiện tìm kiếm -->
        <button type="submit" class="btn-search"><i class="fa-solid fa-magnifying-glass"></i> Tìm kiếm</button>
    </form>

    <!-- Thanh lọc nhanh (Quick Filters) -->
    <div class="quick-filters">
        <span class="quick-filter-label"><i class="fa-solid fa-sliders"></i> Lọc nhanh:</span>
        <a href="${pageContext.request.contextPath}/courses" 
           class="filter-pill ${empty filter && (sortBy == 'newest' || empty sortBy) ? 'active' : ''}">
           Tất cả
        </a>
        <a href="${pageContext.request.contextPath}/courses?filter=bestseller" 
           class="filter-pill filter-bestseller-pill ${filter == 'bestseller' ? 'active' : ''}">
           <i class="fa-solid fa-fire"></i> Khóa học Best Seller
        </a>
        <a href="${pageContext.request.contextPath}/courses?sortBy=bestseller" 
           class="filter-pill ${sortBy == 'bestseller' || sortBy == 'popular' ? 'active' : ''}">
           <i class="fa-solid fa-arrow-trend-up"></i> Sắp xếp bán chạy nhất
        </a>
        <a href="${pageContext.request.contextPath}/courses?sortBy=rating" 
           class="filter-pill ${sortBy == 'rating' ? 'active' : ''}">
           <i class="fa-solid fa-star"></i> Đánh giá cao nhất
        </a>
    </div>
</div>

<!-- ========================================================================= -->
<!-- KHỐI DANH SÁCH KHÓA HỌC HIỂN THỊ (MAIN CONTENT) -->
<!-- Duyệt qua danh sách ${courses} trả về từ CourseBrowseServlet -->
<!-- ========================================================================= -->
<div class="lms-main">
    <c:if test="${filter == 'bestseller'}">
        <div class="bestseller-filter-notice">
            <span><i class="fa-solid fa-fire"></i> Đang lọc khóa học <strong>Bán chạy nhất (Best Seller)</strong> trên hệ thống UTEdu LMS.</span>
            <a href="${pageContext.request.contextPath}/courses" class="clear-filter-btn"><i class="fa-solid fa-xmark"></i> Bỏ lọc</a>
        </div>
    </c:if>

    <p class="result-info">
        <c:choose>
            <c:when test="${not empty courses}">Tìm thấy <strong>${courses.size()}</strong> khóa học</c:when>
            <c:otherwise>Không có kết quả nào</c:otherwise>
        </c:choose>
    </p>

    <c:choose>
        <c:when test="${not empty courses}">
            <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:24px;">
                <!-- Vòng lặp hiển thị từng thẻ khóa học (Course Card) -->
                <c:forEach var="course" items="${courses}" varStatus="vs">
                    <div class="course-card reveal reveal-d${(vs.index % 3) + 1}">
                        <div class="course-img-wrap">
                            <c:if test="${course.bestSeller}">
                                <div class="badge-bestseller"><i class="fa-solid fa-fire"></i> Best Seller</div>
                            </c:if>
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
                <h4 class="footer-title">Khám phá</h4>
                <ul class="footer-links">
                    <li><a href="<%=request.getContextPath()%>/courses?sortBy=popular">Khoá học nổi bật</a></li>
                    <li><a href="<%=request.getContextPath()%>/instructors">Giảng viên tiêu biểu</a></li>
                    <li><a href="<%=request.getContextPath()%>/learning-paths">Lộ trình học tập</a></li>
                    <li><a href="<%=request.getContextPath()%>/resources">Thư viện tài liệu</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h4 class="footer-title">Liên kết</h4>
                <ul class="footer-links">
                    <li><a href="<%=request.getContextPath()%>/courses">Tất cả khóa học</a></li>
                    <li><a href="<%=request.getContextPath()%>/register">Đăng ký thành viên</a></li>
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

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=38"></script>

</body>
</html>








