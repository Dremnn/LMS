<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',Roboto,Arial,sans-serif;}
        body{background:#f0f4f8;color:#2d3748;}
        .navbar{background:#fff;box-shadow:0 2px 8px rgba(0,0,0,.07);padding:14px 40px;display:flex;justify-content:space-between;align-items:center;}
        .navbar .logo{font-size:20px;font-weight:800;color:#667eea;text-decoration:none;}
        .nav-links{display:flex;align-items:center;gap:12px;}
        .btn{padding:8px 18px;border-radius:8px;font-size:14px;font-weight:600;text-decoration:none;cursor:pointer;border:none;transition:all .2s;display:inline-block;}
        .btn-outline{border:1.5px solid #667eea;color:#667eea;background:transparent;}
        .btn-outline:hover{background:#667eea;color:#fff;}
        .btn-danger{background:#fc8181;color:#742a2a;}
        .btn-danger:hover{background:#f56565;color:#fff;}
        .page-header{padding:36px 40px;background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;}
        .page-header h1{font-size:26px;font-weight:800;}
        .page-header p{opacity:.85;font-size:14px;margin-top:6px;}
        .main{max-width:720px;margin:40px auto;padding:0 24px;}
        .card{background:#fff;border-radius:16px;padding:40px;box-shadow:0 4px 20px rgba(0,0,0,.07);}
        .alert-danger{background:#fff5f5;color:#c53030;border:1px solid #feb2b2;padding:14px 18px;border-radius:9px;font-size:14px;margin-bottom:24px;}
        .form-group{margin-bottom:22px;}
        .form-group label{display:block;margin-bottom:8px;color:#374151;font-size:14px;font-weight:600;}
        .form-group label .required{color:#e53e3e;margin-left:2px;}
        .form-control{width:100%;padding:11px 14px;border:1.5px solid #e2e8f0;border-radius:9px;font-size:14px;color:#2d3748;outline:none;transition:border-color .2s,box-shadow .2s;}
        .form-control:focus{border-color:#667eea;box-shadow:0 0 0 3px rgba(102,126,234,.15);}
        textarea.form-control{min-height:130px;resize:vertical;line-height:1.6;}
        .form-hint{font-size:12px;color:#a0aec0;margin-top:5px;}
        .btn-submit{width:100%;padding:14px;background:linear-gradient(135deg,#667eea,#764ba2);border:none;border-radius:9px;color:#fff;font-size:16px;font-weight:700;cursor:pointer;transition:opacity .2s,transform .1s;margin-top:10px;}
        .btn-submit:hover{opacity:.92;transform:translateY(-1px);}
        .back-link{display:inline-flex;align-items:center;gap:6px;color:rgba(255,255,255,.8);text-decoration:none;font-size:14px;margin-bottom:18px;transition:color .2s;}
        .back-link:hover{color:#fff;}
        .divider{border:none;border-top:1px solid #f0f4f8;margin:24px 0;}
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/" class="logo"><i class="fa-solid fa-graduation-cap"></i> EduViet LMS</a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-outline">← Danh sách khóa học</a>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">Đăng xuất</a>
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
</body>
</html>
