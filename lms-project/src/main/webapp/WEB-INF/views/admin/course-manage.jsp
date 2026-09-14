<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Duyệt khóa học - Admin LMS</title>

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">

    <style>
        /* PAGE HEADER */
        .page-header{background:linear-gradient(135deg,#093C62,#076FA4);color:#fff;padding:36px 36px 44px;}
        .page-header h1{font-size:26px;font-weight:800;margin-bottom:6px;}
        .page-header p{opacity:.8;font-size:14px;}

        /* MAIN */
        .main{max-width:1100px;margin:-16px auto 48px;padding:0 24px;}

        /* ALERTS */
        .alert{padding:13px 18px;border-radius:10px;font-size:14px;margin-bottom:20px;display:flex;align-items:center;gap:10px;}
        .alert-success{background:#c6f6d5;color:#22543d;border:1px solid #9ae6b4;}
        .alert-danger{background:#fed7d7;color:#822727;border:1px solid #fc8181;}

        /* COURSE CARDS */
        .course-card{background:#fff;border-radius:14px;box-shadow:0 4px 16px rgba(9,60,98,.07);margin-bottom:22px;overflow:hidden;border:1px solid #C6D8E3;border-left:5px solid #076FA4;transition:all .2s;}
        .card-header{padding:18px 24px 16px;border-bottom:1px solid #E2EEF5;display:flex;justify-content:space-between;align-items:center;gap:16px;}
        .card-header-left{flex:1;display:flex;gap:16px;align-items:center;}
        .card-header-right{flex-shrink:0;}
        .course-title{font-size:18px;font-weight:700;color:#093C62;margin-bottom:8px;line-height:1.3;}
        
        /* Course Meta Tags */
        .course-meta{display:flex;flex-wrap:wrap;gap:8px;align-items:center;}
        .course-meta span{display:inline-flex;align-items:center;gap:6px;background:#F0F6FA;color:#093C62;padding:5px 12px;border-radius:20px;font-size:12px;font-weight:600;border:1px solid #C6D8E3;}
        .course-meta span i{color:#076FA4;}
        .course-meta span.instructor-tag{background:rgba(157, 185, 203, 0.25);color:#093C62;border-color:rgba(157, 185, 203, 0.5);}
        .course-meta span.category-tag{background:rgba(7, 111, 164, 0.1);color:#076FA4;border-color:rgba(7, 111, 164, 0.25);}
        .course-meta span.rating-tag{background:#FEF3C7;color:#D97706;border-color:#FDE68A;}
        .course-meta span.rating-tag i{color:#F59E0B;}
        .course-meta span.price-tag{background:#ECFDF5;color:#059669;border-color:#A7F3D0;}
        .course-meta span.price-tag.price-paid{background:#EFF6FF;color:#076FA4;border-color:#BFDBFE;}

        /* Status Badges */
        .badge{display:inline-flex;align-items:center;gap:6px;padding:6px 14px;border-radius:20px;font-size:12px;font-weight:700;letter-spacing:.3px;}
        .badge-published{background:#ECFDF5;color:#059669;border:1px solid #A7F3D0;}
        .badge-draft{background:#F1F5F9;color:#475569;border:1px solid #CBD5E1;}
        .badge-warning{background:#FEF2F2;color:#DC2626;border:1px solid #FECACA;}
        .badge-appealed{background:#EFF6FF;color:#2563EB;border:1px solid #BFDBFE;}

        .card-body{padding:18px 24px;}
        .course-desc{font-size:13px;color:#093C62;line-height:1.65;background:#F0F6FA;border-radius:8px;padding:12px 14px;margin-bottom:16px;max-height:80px;overflow:hidden;}
        .actions-row{display:flex;align-items:center;gap:12px;flex-wrap:wrap;}

        /* Buttons */
        .btn-ghost{padding:8px 16px;background:#F0F6FA;color:#076FA4;border:1px solid #C6D8E3;border-radius:8px;font-size:13px;font-weight:600;text-decoration:none;display:inline-flex;align-items:center;gap:6px;transition:all .2s;}
        .btn-ghost:hover{background:#076FA4;color:#fff;}

        /* FORMS / BUTTONS */
        .btn-approve{padding:9px 22px;background:#276749;color:#fff;border:none;border-radius:8px;font-size:13px;font-weight:700;cursor:pointer;transition:background .2s;}
        .btn-approve:hover{background:#22543d;}
        .reject-form{display:flex;align-items:center;gap:8px;flex-wrap:wrap;}
        .reject-input{padding:9px 12px;border:1.5px solid #C6D8E3;border-radius:8px;font-size:13px;color:#093C62;outline:none;width:260px;transition:border-color .2s;}
        .reject-input:focus{border-color:#e53e3e;}
        .reject-input::placeholder{color:#5C7688;}
        .btn-reject{padding:9px 18px;background:#9b2c2c;color:#fff;border:none;border-radius:8px;font-size:13px;font-weight:700;cursor:pointer;transition:background .2s;}
        .btn-reject:hover{background:#c53030;}

        /* EMPTY STATE */
        .empty-state{text-align:center;padding:80px 20px;background:#fff;border-radius:14px;box-shadow:0 4px 16px rgba(9,60,98,.06);color:#5C7688;border:1px solid #C6D8E3;}
        .empty-state .icon{font-size:60px;margin-bottom:16px;}
        .empty-state p{font-size:16px;}

        /* PRICE */
        .price-free{color:#38a169;font-weight:700;}
        .price-paid{color:#076FA4;font-weight:700;}

        .divider{border:none;border-top:1px solid #E2EEF5;margin:0;}

        /* Dark Theme (Ô 1: #111312, Ô 2: #182535, Ô 3: #093C62) */
        body.dark-theme .page-header{background:linear-gradient(135deg,#182535,#093C62);}
        body.dark-theme .course-card{background:#182535;border-color:#093C62;border-left-color:#076FA4;box-shadow:0 4px 16px rgba(0,0,0,.3);}
        body.dark-theme .card-header{border-bottom-color:#093C62;}
        body.dark-theme .course-title{color:#FFFFFF !important;}
        
        /* Dark Theme Tags */
        body.dark-theme .course-meta span{background:#111312 !important;border-color:#093C62 !important;color:#FFFFFF !important;}
        body.dark-theme .course-meta span i{color:#38BDF8 !important;}
        body.dark-theme .course-meta span.instructor-tag{background:#111312 !important;border-color:#093C62 !important;color:#FFFFFF !important;}
        body.dark-theme .course-meta span.category-tag{background:rgba(7,111,164,.2) !important;border-color:#076FA4 !important;color:#38BDF8 !important;}
        body.dark-theme .course-meta span.rating-tag{background:rgba(245,158,11,.15) !important;border-color:rgba(245,158,11,.3) !important;color:#F59E0B !important;}
        body.dark-theme .course-meta span.rating-tag i{color:#F59E0B !important;}
        body.dark-theme .course-meta span.price-tag{background:rgba(16,185,129,.15) !important;border-color:rgba(16,185,129,.3) !important;color:#34D399 !important;}
        body.dark-theme .course-meta span.price-tag.price-paid{background:rgba(7,111,164,.2) !important;border-color:#093C62 !important;color:#38BDF8 !important;}

        /* Dark Theme Badges */
        body.dark-theme .badge-published{background:rgba(16,185,129,.15) !important;color:#34D399 !important;border:1px solid rgba(16,185,129,.3) !important;}
        body.dark-theme .badge-draft{background:rgba(148,163,184,.15) !important;color:#CBD5E1 !important;border:1px solid rgba(148,163,184,.3) !important;}
        body.dark-theme .badge-warning{background:rgba(239,68,68,.15) !important;color:#F87171 !important;border:1px solid rgba(239,68,68,.3) !important;}
        body.dark-theme .badge-appealed{background:rgba(59,130,246,.15) !important;color:#60A5FA !important;border:1px solid rgba(59,130,246,.3) !important;}

        body.dark-theme .course-desc{color:#F4F8FA;background:#111312;}
        body.dark-theme .btn-ghost{background:#111312 !important;border-color:#093C62 !important;color:#38BDF8 !important;}
        body.dark-theme .btn-ghost:hover{background:#076FA4 !important;color:#fff !important;}
        body.dark-theme .reject-input{background:#111312;border-color:#093C62;color:#F4F8FA;}
        body.dark-theme .empty-state{background:#182535;border-color:#093C62;color:#9DB9CB;}
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
            <a href="javascript:void(0)" onclick="toggleDrawer()" class="quick-action-btn" title="Gần đây">
                <i class="fa-solid fa-clock-rotate-left"></i><span class="quick-action-text">Gần đây</span>
            </a>
            <a href="<%=request.getContextPath()%>/student/notifications" class="quick-action-btn" title="Thông báo">
                <i class="fa-solid fa-bell"></i><span class="quick-action-text">Thông báo</span>
            </a>
        </div>
        <% } %>
    </div>
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

<div class="page-header">
    <h1><i class="fa-solid fa-folder-open"></i> Quản lý khóa học (Admin)</h1>
</div>

<div class="main">

    <%-- Flash messages --%>
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> ${successMessage}</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> ${error}</div>
    </c:if>

    <c:choose>
        <c:when test="${not empty courses}">

            <p style="font-size:14px;color:#718096;margin-bottom:18px;">
                Hệ thống có <strong style="color:#1a202c;">${courses.size()}</strong> khóa học
            </p>

            <c:forEach var="course" items="${courses}">
                <div class="course-card">

                    <div class="card-header">
                        <div class="card-header-left">
                            <c:if test="${not empty course.thumbnailUrl}">
                                <img src="${course.thumbnailUrl}" alt="Thumb" style="width:68px;height:48px;object-fit:cover;border-radius:8px;border:1px solid #E2E8F0;flex-shrink:0;" onerror="this.style.display='none'">
                            </c:if>
                            <div>
                                <div class="course-title"><c:out value="${course.title}"/></div>
                                <div class="course-meta">
                                    <span class="instructor-tag"><i class="fa-solid fa-chalkboard-user"></i> <c:out value="${course.instructorName}"/></span>
                                    <c:if test="${not empty course.categoryName}">
                                        <span class="category-tag"><i class="fa-solid fa-folder-open"></i> <c:out value="${course.categoryName}"/></span>
                                    </c:if>
                                    <c:if test="${course.avgRating != null}">
                                        <span class="rating-tag"><i class="fa-solid fa-star"></i> ${course.avgRating} / 5</span>
                                    </c:if>
                                    <span><i class="fa-solid fa-users"></i> ${course.totalStudents} học viên</span>
                                    <span><i class="fa-solid fa-book-open"></i> ${course.totalLessons} bài học</span>
                                    <c:choose>
                                        <c:when test="${course.price == 0 || course.price == null}">
                                            <span class="price-tag"><i class="fa-solid fa-tag"></i> Miễn phí</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="price-tag price-paid"><i class="fa-solid fa-tag"></i> ${course.price} đ</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                        <div class="card-header-right">
                            <c:choose>
                                <c:when test="${course.status == 'published'}">
                                    <span class="badge badge-published"><i class="fa-solid fa-circle-check"></i> Published</span>
                                </c:when>
                                <c:when test="${course.status == 'draft'}">
                                    <span class="badge badge-draft">Draft</span>
                                </c:when>
                                <c:when test="${course.status == 'warning'}">
                                    <span class="badge badge-warning"><i class="fa-solid fa-triangle-exclamation"></i> Warning</span>
                                </c:when>
                                <c:when test="${course.status == 'appealed'}">
                                    <span class="badge badge-appealed"><i class="fa-solid fa-envelope"></i> Đang kháng cáo</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge">${course.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div class="card-body">
                        <%-- Hiển thị lý do cảnh cáo nếu đang warning hoặc appealed --%>
                        <c:if test="${(course.status == 'warning' || course.status == 'appealed') && not empty course.rejectReason}">
                            <div style="background:#fffaf0;border:1px solid #f6ad55;border-radius:8px;padding:10px 14px;margin-bottom:12px;font-size:13px;color:#c05621;">
                                <strong><i class="fa-solid fa-triangle-exclamation"></i> Lý do cảnh cáo:</strong> <c:out value="${course.rejectReason}"/>
                            </div>
                        </c:if>

                        <%-- Hiển thị nội dung kháng cáo nếu đang appealed --%>
                        <c:if test="${course.status == 'appealed' && not empty course.appealMessage}">
                            <div style="background:#ebf8ff;border:1px solid #63b3ed;border-radius:8px;padding:10px 14px;margin-bottom:12px;font-size:13px;color:#2a4365;">
                                <strong>📩 Instructor kháng cáo:</strong> <c:out value="${course.appealMessage}"/>
                            </div>
                        </c:if>

                        <div class="actions-row">
                            <%-- Link xem chi tiết --%>
                            <a href="${pageContext.request.contextPath}/instructor/courses/manage?id=${course.id}"
                               class="btn btn-ghost" target="_blank" style="margin-right:auto;">👁 Xem nội dung</a>

                            <%-- Nút Approve/Reject kháng cáo (chỉ khi status = appealed) --%>
                            <c:if test="${course.status == 'appealed'}">
                                <form action="${pageContext.request.contextPath}/admin/courses/approve-appeal"
                                      method="post" style="display:inline;">
                                    <input type="hidden" name="courseId" value="${course.id}" />
                                    <button type="submit" class="btn-approve"><i class="fa-solid fa-circle-check"></i> Chấp nhận kháng cáo</button>
                                </form>
                                <form action="${pageContext.request.contextPath}/admin/courses/reject-appeal"
                                      method="post" style="display:inline;"
                                      onsubmit="return confirm('Từ chối kháng cáo? Khóa học sẽ quay lại trạng thái cảnh cáo.')">
                                    <input type="hidden" name="courseId" value="${course.id}" />
                                    <button type="submit" class="btn-reject"><i class="fa-solid fa-xmark"></i> Từ chối kháng cáo</button>
                                </form>
                            </c:if>

                            <c:if test="${course.status == 'published'}">
                                <%-- Form CẢNH CÁO (có ô nhập lý do) --%>
                                <form action="${pageContext.request.contextPath}/admin/courses/warn"
                                      method="post" class="reject-form" style="display:flex; gap:8px; align-items:center;">
                                    <input type="hidden" name="courseId" value="${course.id}" />
                                    <input type="text" name="reason" class="reject-input" style="padding:6px 12px; border:1px solid #e2e8f0; border-radius:6px; font-size:13px;"
                                           placeholder="Nhập lý do cảnh cáo..." required maxlength="500" />
                                    <button type="submit" class="btn-reject" style="background:#ed8936; color:#fff;"><i class="fa-solid fa-triangle-exclamation"></i> Cảnh cáo</button>
                                </form>
                            </c:if>

                            <%-- Nút Xóa Khóa Học --%>
                            <form action="${pageContext.request.contextPath}/admin/courses/delete"
                                  method="post" style="display:inline;"
                                  onsubmit="return confirm('CẢNH BÁO: Xác nhận XÓA vĩnh viễn khóa học \'${course.title}\'? Dữ liệu không thể khôi phục!')">
                                <input type="hidden" name="courseId" value="${course.id}" />
                                <button type="submit" class="btn-reject">🗑 Xóa khóa học</button>
                            </form>
                        </div>
                    </div>
                </div>
            </c:forEach>

        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <div class="icon"><i class="fa-solid fa-magnifying-glass"></i></div>
                <p>Không có khóa học nào trên hệ thống.</p>
            </div>
        </c:otherwise>
    </c:choose>

</div>

<!-- Dynamic Island Theme Toggle -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=30"></script>

    <jsp:include page="/WEB-INF/views/components/drawer.jsp" />
</body>
</html>