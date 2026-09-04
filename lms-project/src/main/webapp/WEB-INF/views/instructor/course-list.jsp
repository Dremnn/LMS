<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khóa học của tôi - LMS Instructor</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',Roboto,Arial,sans-serif;}
        body{background:#f0f4f8;color:#2d3748;}
        .navbar{background:#fff;box-shadow:0 2px 8px rgba(0,0,0,.07);padding:14px 40px;display:flex;justify-content:space-between;align-items:center;}
        .navbar .logo{font-size:20px;font-weight:800;color:#667eea;text-decoration:none;}
        .nav-links{display:flex;align-items:center;gap:12px;}
        .btn{padding:8px 18px;border-radius:8px;font-size:13px;font-weight:600;text-decoration:none;cursor:pointer;border:none;transition:all .2s;display:inline-block;}
        .btn-primary{background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;}
        .btn-primary:hover{opacity:.9;transform:translateY(-1px);}
        .btn-danger{background:#fc8181;color:#742a2a;}
        .btn-danger:hover{background:#f56565;color:#fff;}
        .btn-sm{padding:5px 12px;font-size:12px;}
        .btn-info{background:#bee3f8;color:#2b6cb0;}
        .btn-info:hover{background:#90cdf4;}
        .btn-warning{background:#fefcbf;color:#744210;}
        .btn-warning:hover{background:#faf089;}
        .btn-secondary{background:#e2e8f0;color:#4a5568;}
        .btn-secondary:hover{background:#cbd5e0;}
        .btn-error{background:#fed7d7;color:#822727;}
        .btn-error:hover{background:#fca5a5;}
        .badge{display:inline-block;padding:4px 10px;border-radius:20px;font-size:11px;font-weight:700;text-transform:uppercase;}
        .badge-draft{background:#e2e8f0;color:#4a5568;}
        .badge-pending{background:#fefcbf;color:#744210;}
        .badge-published{background:#c6f6d5;color:#22543d;}
        .badge-rejected{background:#fed7d7;color:#822727;}
        .page-header{padding:36px 40px;background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;}
        .page-header-inner{max-width:1100px;margin:0 auto;display:flex;justify-content:space-between;align-items:center;}
        .page-header h1{font-size:28px;font-weight:800;}
        .main{max-width:1100px;margin:36px auto;padding:0 24px;}
        table{width:100%;border-collapse:collapse;background:#fff;border-radius:14px;overflow:hidden;box-shadow:0 4px 16px rgba(0,0,0,.06);}
        thead{background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;}
        th{padding:14px 16px;text-align:left;font-size:13px;font-weight:600;}
        td{padding:14px 16px;font-size:13px;border-top:1px solid #f0f4f8;vertical-align:middle;}
        tr:hover td{background:#fafbff;}
        .course-name{font-weight:700;color:#1a202c;font-size:14px;}
        .reject-reason{font-size:11px;color:#e53e3e;margin-top:4px;max-width:260px;}
        .actions{display:flex;gap:6px;flex-wrap:wrap;align-items:center;}
        .empty-state{text-align:center;padding:80px 20px;background:#fff;border-radius:14px;color:#a0aec0;}
        .empty-state .icon{font-size:56px;margin-bottom:14px;}
        form{display:inline;}
        .user-info{font-size:14px;color:#4a5568;font-weight:600;}
        .badge-role{display:inline-block;padding:2px 9px;border-radius:12px;font-size:11px;font-weight:700;background:#ebf8ff;color:#2b6cb0;text-transform:uppercase;margin-left:6px;}
    </style>
</head>
<body>
<% User currentUser = (User) session.getAttribute("currentUser"); %>
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/" class="logo">🎓 LMS System</a>
    <div class="nav-links">
        <span class="user-info"><%=currentUser != null ? currentUser.getFullName() : ""%><span class="badge-role">instructor</span></span>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">Đăng xuất</a>
    </div>
</nav>

<div class="page-header">
    <div class="page-header-inner">
        <h1>📋 Khóa học của tôi</h1>
        <a href="${pageContext.request.contextPath}/instructor/courses/new" class="btn btn-primary">➕ Tạo khóa học mới</a>
    </div>
</div>

<div class="main">
    <c:if test="${not empty successMessage}">
        <div style="background:#c6f6d5;color:#22543d;border:1px solid #9ae6b4;padding:12px 18px;border-radius:10px;font-size:14px;margin-bottom:18px;">✅ ${successMessage}</div>
    </c:if>
    <c:if test="${not empty error}">
        <div style="background:#fed7d7;color:#822727;border:1px solid #fc8181;padding:12px 18px;border-radius:10px;font-size:14px;margin-bottom:18px;">⚠️ ${error}</div>
    </c:if>

    <c:choose>
        <c:when test="${not empty courses}">
            <table>
                <thead>
                    <tr>
                        <th>Tên khóa học</th>
                        <th>Danh mục</th>
                        <th>Giá</th>
                        <th>Trạng thái</th>
                        <th>Học viên</th>
                        <th>Ngày tạo</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="course" items="${courses}">
                        <tr>
                            <td>
                                <div class="course-name"><c:out value="${course.title}"/></div>
                                <c:if test="${course.status == 'rejected' && not empty course.rejectReason}">
                                    <div class="reject-reason">⚠ Lý do từ chối: <c:out value="${course.rejectReason}"/></div>
                                </c:if>
                                <c:if test="${course.status == 'warning' && not empty course.rejectReason}">
                                    <div class="reject-reason" style="color:#c05621;">⚠️ Admin cảnh cáo: <c:out value="${course.rejectReason}"/></div>
                                </c:if>
                                <c:if test="${course.status == 'appealed' && not empty course.appealMessage}">
                                    <div style="font-size:12px;color:#2a4365;margin-top:4px;">📩 Đã gửi kháng cáo: <c:out value="${course.appealMessage}"/></div>
                                </c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty course.categoryName}"><c:out value="${course.categoryName}"/></c:when>
                                    <c:otherwise><span style="color:#a0aec0;">—</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${course.price == 0}"><span style="color:#38a169;font-weight:700;">Miễn phí</span></c:when>
                                    <c:otherwise>${course.price} đ</c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${course.status == 'draft'}"><span class="badge badge-draft">Draft</span></c:when>
                                    <c:when test="${course.status == 'published'}"><span class="badge badge-published">✅ Published</span></c:when>
                                    <c:when test="${course.status == 'warning'}"><span class="badge badge-rejected" style="background:#fed7d7; color:#9b2c2c;">⚠️ Warning</span></c:when>
                                    <c:when test="${course.status == 'appealed'}"><span class="badge badge-published" style="background:#bee3f8; color:#2a4365;">📩 Đang kháng cáo</span></c:when>
                                    <c:when test="${course.status == 'rejected'}"><span class="badge badge-rejected">❌ Từ chối</span></c:when>
                                </c:choose>
                            </td>
                            <td>${course.totalStudents}</td>
                            <td>${course.createdAt}</td>
                            <td>
                                <div class="actions">
                                    <a href="${pageContext.request.contextPath}/instructor/courses/edit?id=${course.id}" class="btn btn-sm btn-secondary">✏️ Sửa</a>
                                    <a href="${pageContext.request.contextPath}/instructor/courses/manage?id=${course.id}" class="btn btn-sm btn-info">📂 Nội dung</a>
                                    
                                    <c:if test="${course.status == 'draft'}">
                                        <form action="${pageContext.request.contextPath}/instructor/courses/submit" method="post">
                                            <input type="hidden" name="id" value="${course.id}">
                                            <button type="submit" class="btn btn-sm btn-warning">🚀 Đăng</button>
                                        </form>
                                    </c:if>
                                    
                                    <%-- Nút kháng cáo: chỉ hiện khi status = warning --%>
                                    <c:if test="${course.status == 'warning'}">
                                        <form action="${pageContext.request.contextPath}/instructor/courses/appeal" method="post"
                                              style="display:flex; gap:6px; align-items:center;">
                                            <input type="hidden" name="id" value="${course.id}">
                                            <input type="text" name="appealMessage" placeholder="Nhập nội dung kháng cáo..."
                                                   required maxlength="500" style="padding:5px 10px; border:1px solid #e2e8f0; border-radius:6px; font-size:12px; width:200px;">
                                            <button type="submit" class="btn btn-sm btn-info" style="background:#3182ce;">📩 Kháng cáo</button>
                                        </form>
                                    </c:if>
                                    
                                    <c:if test="${course.status == 'draft'}">
                                        <form action="${pageContext.request.contextPath}/instructor/courses/delete" method="post"
                                              onsubmit="return confirm('Bạn chắc chắn muốn xóa khóa học này? Hành động này không thể hoàn tác!')">
                                            <input type="hidden" name="id" value="${course.id}">
                                            <button type="submit" class="btn btn-sm btn-error">🗑 Xóa</button>
                                        </form>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <div class="icon">📭</div>
                <p style="font-size:16px;margin-bottom:16px;">Bạn chưa có khóa học nào.</p>
                <a href="${pageContext.request.contextPath}/instructor/courses/new" class="btn btn-primary">➕ Tạo khóa học đầu tiên</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>
</body>
</html>