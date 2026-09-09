<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Duyệt khóa học - Admin LMS</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',Roboto,Arial,sans-serif;}
        body{background:#f0f4f8;color:#2d3748;}

        /* NAVBAR */
        .navbar{background:#1a202c;padding:13px 36px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 2px 8px rgba(0,0,0,.3);}
        .navbar .logo{font-size:19px;font-weight:800;color:#a78bfa;text-decoration:none;}
        .nav-links{display:flex;align-items:center;gap:12px;}
        .btn{padding:7px 16px;border-radius:7px;font-size:13px;font-weight:600;text-decoration:none;cursor:pointer;border:none;transition:all .2s;display:inline-block;}
        .btn-ghost{background:transparent;color:#a0aec0;border:1px solid #4a5568;}
        .btn-ghost:hover{background:#4a5568;color:#fff;}
        .btn-logout{background:#9b2c2c;color:#fff;}
        .btn-logout:hover{background:#c53030;}
        .badge-admin{display:inline-block;padding:2px 9px;border-radius:12px;font-size:10px;font-weight:700;background:#553c9a;color:#e9d8fd;text-transform:uppercase;margin-left:6px;}
        .user-info{font-size:13px;color:#a0aec0;font-weight:600;}

        /* PAGE HEADER */
        .page-header{background:linear-gradient(135deg,#553c9a,#1a202c);color:#fff;padding:36px 36px 44px;}
        .page-header h1{font-size:26px;font-weight:800;margin-bottom:6px;}
        .page-header p{opacity:.8;font-size:14px;}

        /* MAIN */
        .main{max-width:1100px;margin:-16px auto 48px;padding:0 24px;}

        /* ALERTS */
        .alert{padding:13px 18px;border-radius:10px;font-size:14px;margin-bottom:20px;display:flex;align-items:center;gap:10px;}
        .alert-success{background:#c6f6d5;color:#22543d;border:1px solid #9ae6b4;}
        .alert-danger{background:#fed7d7;color:#822727;border:1px solid #fc8181;}

        /* COURSE CARDS */
        .course-card{background:#fff;border-radius:14px;box-shadow:0 4px 16px rgba(0,0,0,.07);margin-bottom:22px;overflow:hidden;border-left:5px solid #f6ad55;}
        .card-header{padding:18px 24px 14px;border-bottom:1px solid #f0f4f8;display:flex;justify-content:space-between;align-items:flex-start;gap:16px;}
        .card-header-left{flex:1;}
        .course-title{font-size:17px;font-weight:700;color:#1a202c;margin-bottom:6px;}
        .course-meta{display:flex;flex-wrap:wrap;gap:14px;font-size:13px;color:#718096;}
        .course-meta span{display:flex;align-items:center;gap:4px;}
        .badge-pending{background:#fefcbf;color:#744210;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;}
        .card-body{padding:16px 24px;}
        .course-desc{font-size:13px;color:#4a5568;line-height:1.65;background:#f7fafc;border-radius:8px;padding:12px 14px;margin-bottom:16px;max-height:80px;overflow:hidden;}
        .actions-row{display:flex;align-items:center;gap:12px;flex-wrap:wrap;}

        /* FORMS / BUTTONS */
        .btn-approve{padding:9px 22px;background:#276749;color:#fff;border:none;border-radius:8px;font-size:13px;font-weight:700;cursor:pointer;transition:background .2s;}
        .btn-approve:hover{background:#22543d;}
        .reject-form{display:flex;align-items:center;gap:8px;flex-wrap:wrap;}
        .reject-input{padding:9px 12px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:13px;color:#2d3748;outline:none;width:260px;transition:border-color .2s;}
        .reject-input:focus{border-color:#e53e3e;}
        .reject-input::placeholder{color:#a0aec0;}
        .btn-reject{padding:9px 18px;background:#9b2c2c;color:#fff;border:none;border-radius:8px;font-size:13px;font-weight:700;cursor:pointer;transition:background .2s;}
        .btn-reject:hover{background:#c53030;}

        /* EMPTY STATE */
        .empty-state{text-align:center;padding:80px 20px;background:#fff;border-radius:14px;box-shadow:0 4px 16px rgba(0,0,0,.06);color:#a0aec0;}
        .empty-state .icon{font-size:60px;margin-bottom:16px;}
        .empty-state p{font-size:16px;}

        /* PRICE */
        .price-free{color:#38a169;font-weight:700;}
        .price-paid{color:#667eea;font-weight:700;}

        .divider{border:none;border-top:1px solid #f0f4f8;margin:0;}
    </style>
</head>
<body>
<% User currentUser = (User) session.getAttribute("currentUser"); %>

<nav class="navbar">
    <a href="${pageContext.request.contextPath}/" class="logo"><i class="fa-solid fa-graduation-cap"></i> LMS Admin</a>
    <div class="nav-links">
        <% if (currentUser != null) { %>
            <span class="user-info"><%= currentUser.getFullName() %><span class="badge-admin">admin</span></span>
        <% } %>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-logout">Đăng xuất</a>
    </div>
</nav>

<div class="page-header">
    <h1><i class="fa-solid fa-folder-open"></i> Quản lý khóa học (Admin)</h1>
    <p>Xem toàn bộ khóa học trên hệ thống và quản lý (xóa) khi cần thiết</p>
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
                            <div class="course-title"><c:out value="${course.title}"/></div>
                            <div class="course-meta">
                                <span><i class="fa-solid fa-chalkboard-user"></i> <c:out value="${course.instructorName}"/></span>
                                <c:if test="${not empty course.categoryName}">
                                    <span><i class="fa-solid fa-folder-open"></i> <c:out value="${course.categoryName}"/></span>
                                </c:if>
                                <span><i class="fa-solid fa-book-open"></i> ${course.totalLessons} bài học</span>
                                <span>
                                    💰
                                    <c:choose>
                                        <c:when test="${course.price == 0 || course.price == null}">
                                            <span class="price-free">Miễn phí</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="price-paid">${course.price} đ</span>
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>
                        <c:choose>
                            <c:when test="${course.status == 'published'}">
                                <span style="background:#c6f6d5;color:#22543d;padding:4px 10px;border-radius:6px;font-size:12px;font-weight:700;"><i class="fa-solid fa-circle-check"></i> Published</span>
                            </c:when>
                            <c:when test="${course.status == 'draft'}">
                                <span style="background:#e2e8f0;color:#4a5568;padding:4px 10px;border-radius:6px;font-size:12px;font-weight:700;">Draft</span>
                            </c:when>
                            <c:when test="${course.status == 'warning'}">
                                <span style="background:#fed7d7;color:#9b2c2c;padding:4px 10px;border-radius:6px;font-size:12px;font-weight:700;"><i class="fa-solid fa-triangle-exclamation"></i> Warning</span>
                            </c:when>
                            <c:when test="${course.status == 'appealed'}">
                                <span style="background:#bee3f8;color:#2a4365;padding:4px 10px;border-radius:6px;font-size:12px;font-weight:700;">📩 Đang kháng cáo</span>
                            </c:when>
                            <c:otherwise>
                                <span style="background:#feebc8;color:#744210;padding:4px 10px;border-radius:6px;font-size:12px;font-weight:700;">${course.status}</span>
                            </c:otherwise>
                        </c:choose>
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
</body>
</html>