<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        <c:choose>
            <c:when test="${empty course}">Tạo khóa học mới</c:when>
            <c:otherwise>Sửa khóa học</c:otherwise>
        </c:choose>
        - LMS Instructor
    </title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <style>
        .page-header{padding:36px 40px;background:linear-gradient(135deg,#093C62,#076FA4);color:#fff;}
        .page-header h1{font-size:26px;font-weight:800;}
        .page-header p{opacity:.85;font-size:14px;margin-top:6px;}
        .main{max-width:720px;margin:40px auto;padding:0 24px;}
        .card{background:#fff;border-radius:16px;padding:40px;box-shadow:0 4px 20px rgba(9,60,98,.07);border:1px solid #C6D8E3;}
        .alert-danger{background:#fff5f5;color:#c53030;border:1px solid #feb2b2;padding:14px 18px;border-radius:9px;font-size:14px;margin-bottom:24px;}
        .form-group{margin-bottom:22px;}
        .form-group label{display:block;margin-bottom:8px;color:#093C62;font-size:14px;font-weight:600;}
        .form-group label .required{color:#e53e3e;margin-left:2px;}
        .form-control{width:100%;padding:11px 14px;border:1.5px solid #C6D8E3;border-radius:9px;font-size:14px;color:#093C62;outline:none;transition:border-color .2s,box-shadow .2s;}
        .form-control:focus{border-color:#076FA4;box-shadow:0 0 0 3px rgba(7,111,164,.15);}
        textarea.form-control{min-height:130px;resize:vertical;line-height:1.6;}
        .form-hint{font-size:12px;color:#5C7688;margin-top:5px;}
        .btn-submit{width:100%;padding:14px;background:linear-gradient(135deg,#093C62,#076FA4);border:none;border-radius:9px;color:#fff;font-size:16px;font-weight:700;cursor:pointer;transition:opacity .2s,transform .1s;margin-top:10px;}
        .btn-submit:hover{opacity:.92;transform:translateY(-1px);}
        .back-link{display:inline-flex;align-items:center;gap:6px;color:rgba(255,255,255,.8);text-decoration:none;font-size:14px;margin-bottom:18px;transition:color .2s;}
        .back-link:hover{color:#fff;}
        .divider{border:none;border-top:1px solid #C6D8E3;margin:24px 0;}

        /* Dark Theme (Ô 1: #111312, Ô 2: #182535, Ô 3: #093C62) */
        body.dark-theme .page-header{background:linear-gradient(135deg,#182535,#093C62);}
        body.dark-theme .card{background:#182535;border-color:#093C62;box-shadow:0 4px 20px rgba(0,0,0,.3);}
        body.dark-theme .form-group label{color:#F4F8FA;}
        body.dark-theme .form-control{background:#111312;border-color:#093C62;color:#F4F8FA;}
        body.dark-theme .form-control:focus{border-color:#076FA4;}
        body.dark-theme .form-hint{color:#9DB9CB;}
        body.dark-theme #thumbnailPreviewContainer{background:#111312 !important;border-color:#093C62 !important;}
        body.dark-theme .divider{border-top-color:#093C62;}
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
        <a href="<%=request.getContextPath()%>/instructor/courses" class="nav-link">← Danh sách khóa học</a>
        <a href="<%=request.getContextPath()%>/courses" class="nav-link">Khóa học</a>
        <% if (currentUser != null) { %>
            <% if ("student".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/dashboard" class="nav-link">Bảng điều khiển</a>
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
    <a href="${pageContext.request.contextPath}/instructor/courses" class="back-link">← Quay lại danh sách</a>
    <h1>
        <c:choose>
            <c:when test="${empty course}">➕ Tạo khóa học mới</c:when>
            <c:otherwise>✏️ Sửa khóa học</c:otherwise>
        </c:choose>
    </h1>
    <p>
        <c:choose>
            <c:when test="${empty course}">Điền thông tin để tạo khóa học mới. Bạn có thể thêm chương và bài học sau khi tạo xong.</c:when>
            <c:otherwise>Cập nhật thông tin cơ bản của khóa học.</c:otherwise>
        </c:choose>
    </p>
</div>

<div class="main">
    <div class="card">
        <c:if test="${not empty error}">
            <div class="alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> ${error}</div>
        </c:if>

        <c:choose>
            <c:when test="${empty course}">
                <form action="${pageContext.request.contextPath}/instructor/courses/new" method="post">
            </c:when>
            <c:otherwise>
                <form action="${pageContext.request.contextPath}/instructor/courses/edit" method="post">
                    <input type="hidden" name="id" value="${course.id}">
            </c:otherwise>
        </c:choose>

            <div class="form-group">
                <label for="title">Tên khóa học <span class="required">*</span></label>
                <input type="text" id="title" name="title" class="form-control"
                       placeholder="Ví dụ: Lập trình Java từ cơ bản đến nâng cao"
                       value="<c:out value='${course.title}' default=''/>" required>
            </div>

            <div class="form-group">
                <label for="description">Mô tả khóa học</label>
                <textarea id="description" name="description" class="form-control"
                          placeholder="Giới thiệu ngắn gọn về khóa học, nội dung sẽ học và đối tượng phù hợp..."><c:out value="${course.description}" default=""/></textarea>
            </div>

            <div class="form-group">
                <label for="categoryId">Danh mục</label>
                <select id="categoryId" name="categoryId" class="form-control">
                    <option value="">— Chọn danh mục —</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.id}" <c:if test="${cat.id == course.categoryId}">selected</c:if>>
                            <c:out value="${cat.name}"/>
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group">
                <label for="price">Giá khóa học (đ)</label>
                <input type="number" id="price" name="price" class="form-control"
                       placeholder="0" min="0" step="0.01"
                       value="<c:out value='${course.price}' default='0'/>">
                <p class="form-hint">Nhập 0 nếu muốn khóa học miễn phí.</p>
            </div>

            <div class="form-group">
                <label for="thumbnailUrl"><i class="fa-solid fa-image" style="color:#076FA4;"></i> Ảnh thu nhỏ khóa học (Thumbnail URL)</label>
                <input type="text" id="thumbnailUrl" name="thumbnailUrl" class="form-control"
                       placeholder="https://images.unsplash.com/... hoặc đường dẫn ảnh..."
                       value="<c:out value='${course.thumbnailUrl}' default=''/>"
                       oninput="previewThumbnail(this.value)">
                <p class="form-hint">Dán link hình ảnh minh họa cho khóa học (khuyến nghị tỷ lệ 16:9). Xem trước hiển thị bên dưới:</p>
                
                <div id="thumbnailPreviewContainer" style="margin-top:12px; max-width:380px; border-radius:12px; overflow:hidden; border:1.5px dashed #CBD5E1; background:#F8FAFC; padding:10px; text-align:center;">
                    <img id="thumbnailPreviewImg" src="${not empty course.thumbnailUrl ? course.thumbnailUrl : ''}" 
                         alt="Thumbnail Preview" 
                         style="max-width:100%; height:180px; width:100%; object-fit:cover; border-radius:8px; display:${not empty course.thumbnailUrl ? 'block' : 'none'};"
                         onerror="handleImageError()">
                    <div id="thumbnailPlaceholder" style="padding:28px 12px; color:#94A3B8; font-size:13px; display:${not empty course.thumbnailUrl ? 'none' : 'block'};">
                        <i class="fa-solid fa-cloud-arrow-up" style="font-size:32px; margin-bottom:8px; display:block; color:#CBD5E1;"></i>
                        <span>Chưa có ảnh thu nhỏ. Nhập URL ở trên để xem trước.</span>
                    </div>
                </div>
            </div>

            <hr class="divider">

            <button type="submit" class="btn-submit">
                <c:choose>
                    <c:when test="${empty course}"><i class="fa-solid fa-rocket"></i> Tạo khóa học</c:when>
                    <c:otherwise>💾 Cập nhật khóa học</c:otherwise>
                </c:choose>
            </button>
        </form>
    </div>
</div>

<script>
function previewThumbnail(url) {
    var img = document.getElementById('thumbnailPreviewImg');
    var placeholder = document.getElementById('thumbnailPlaceholder');
    url = url ? url.trim() : '';
    if (url) {
        img.src = url;
        img.style.display = 'block';
        placeholder.style.display = 'none';
    } else {
        img.style.display = 'none';
        img.src = '';
        placeholder.style.display = 'block';
        placeholder.innerHTML = '<i class="fa-solid fa-cloud-arrow-up" style="font-size:32px; margin-bottom:8px; display:block; color:#CBD5E1;"></i><span>Chưa có ảnh thu nhỏ. Nhập URL ở trên để xem trước.</span>';
    }
}
function handleImageError() {
    var img = document.getElementById('thumbnailPreviewImg');
    var placeholder = document.getElementById('thumbnailPlaceholder');
    img.style.display = 'none';
    placeholder.style.display = 'block';
    placeholder.innerHTML = '<i class="fa-solid fa-triangle-exclamation" style="font-size:28px; color:#EF4444; margin-bottom:8px; display:block;"></i><span style="color:#EF4444; font-weight:600;">Link ảnh không tải được hoặc không đúng định dạng</span>';
}
</script>

<!-- Dynamic Island Theme Toggle -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=30"></script>

</body>
</html>
