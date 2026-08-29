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
    <a href="${pageContext.request.contextPath}/" class="logo">🎓 LMS Admin</a>
    <div class="nav-links">
        <% if (currentUser != null) { %>
            <span class="user-info"><%= currentUser.getFullName() %><span class="badge-admin">admin</span></span>
        <% } %>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-logout">Đăng xuất</a>
    </div>
</nav>

<div class="page-header">
    <h1>⚖️ Duyệt khóa học</h1>
    <p>Xem xét và phê duyệt các khóa học đang chờ kiểm duyệt từ giảng viên</p>
</div>

<div class="main">

    <%-- Flash messages --%>
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success">✅ ${successMessage}</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger">⚠️ ${error}</div>
    </c:if>

    <c:choose>
        <c:when test="${not empty pendingCourses}">

            <%-- Tổng số đang chờ --%>
            <p style="font-size:14px;color:#718096;margin-bottom:18px;">
                Có <strong style="color:#1a202c;">${pendingCourses.size()}</strong> khóa học đang chờ duyệt
            </p>

            <c:forEach var="course" items="${pendingCourses}">
                <div class="course-card">

                    <%-- Header: tiêu đề + meta --%>
                    <div class="card-header">
                        <div class="card-header-left">
                            <div class="course-title"><c:out value="${course.title}"/></div>
                            <div class="course-meta">
                                <span>👨‍🏫 <c:out value="${course.instructorName}"/></span>
                                <c:if test="${not empty course.categoryName}">
                                    <span>📂 <c:out value="${course.categoryName}"/></span>
                                </c:if>
                                <span>📖 ${course.totalLessons} bài học</span>
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
                                <span>📅 ${course.createdAt}</span>
                            </div>
                        </div>
                        <span class="badge-pending">⏳ Chờ duyệt</span>
                    </div>

                    <%-- Body: mô tả + hành động --%>
                    <div class="card-body">
                        <c:if test="${not empty course.description}">
                            <div class="course-desc">
                                <c:out value="${course.description}"/>
                            </div>
                        </c:if>

                        <div class="actions-row">
                            <%-- Form DUYỆT --%>
                            <form action="${pageContext.request.contextPath}/admin/courses/approve"
                                  method="post" style="display:inline;"
                                  onsubmit="return confirm('Xác nhận DUYỆT khóa học: \'${course.title}\'?')">
                                <input type="hidden" name="courseId" value="${course.id}" />
                                <button type="submit" class="btn-approve">✅ Duyệt</button>
                            </form>

                            <%-- Form TỪ CHỐI (có ô nhập lý do) --%>
                            <form action="${pageContext.request.contextPath}/admin/courses/reject"
                                  method="post" class="reject-form">
                                <input type="hidden" name="courseId" value="${course.id}" />
                                <input type="text" name="reason" class="reject-input"
                                       placeholder="Nhập lý do từ chối..." required
                                       maxlength="500" />
                                <button type="submit" class="btn-reject">❌ Từ chối</button>
                            </form>

                            <%-- Link xem chi tiết (readonly) --%>
                            <a href="${pageContext.request.contextPath}/instructor/courses/manage?id=${course.id}"
                               class="btn btn-ghost" target="_blank">👁 Xem nội dung</a>
                        </div>
                    </div>

                </div>
            </c:forEach>

        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <div class="icon">🎉</div>
                <p>Không có khóa học nào đang chờ duyệt.</p>
                <p style="font-size:13px;margin-top:8px;color:#cbd5e0;">Tất cả khóa học đã được xử lý!</p>
            </div>
        </c:otherwise>
    </c:choose>

</div>
</body>
</html>
