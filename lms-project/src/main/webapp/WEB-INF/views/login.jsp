<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - LMS</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',Roboto,Arial,sans-serif;}
        body{background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px;}
        .card{background:#fff;border-radius:18px;box-shadow:0 20px 50px rgba(0,0,0,.18);width:100%;max-width:440px;padding:44px 38px;}
        .header{text-align:center;margin-bottom:30px;}
        .header .logo{font-size:28px;font-weight:800;color:#667eea;text-decoration:none;display:block;margin-bottom:10px;}
        .header h1{color:#1a202c;font-size:24px;font-weight:700;margin-bottom:6px;}
        .header p{color:#718096;font-size:14px;}
        .alert{padding:12px 16px;border-radius:9px;font-size:14px;margin-bottom:20px;display:flex;align-items:flex-start;gap:8px;}
        .alert-danger{background:#fff5f5;color:#c53030;border:1px solid #feb2b2;}
        .alert-success{background:#f0fff4;color:#276749;border:1px solid #9ae6b4;}
        .form-group{margin-bottom:20px;}
        .form-group label{display:block;margin-bottom:7px;color:#4a5568;font-size:14px;font-weight:600;}
        .form-control{width:100%;padding:12px 15px;border:1.5px solid #e2e8f0;border-radius:9px;font-size:15px;color:#2d3748;outline:none;transition:border-color .2s,box-shadow .2s;}
        .form-control:focus{border-color:#667eea;box-shadow:0 0 0 3px rgba(102,126,234,.15);}
        .btn-submit{width:100%;padding:13px;background:linear-gradient(135deg,#667eea,#764ba2);border:none;border-radius:9px;color:#fff;font-size:16px;font-weight:700;cursor:pointer;transition:opacity .2s,transform .1s;margin-top:8px;}
        .btn-submit:hover{opacity:.93;transform:translateY(-1px);}
        .footer-links{margin-top:22px;text-align:center;font-size:14px;color:#718096;line-height:2;}
        .footer-links a{color:#667eea;text-decoration:none;font-weight:600;}
        .footer-links a:hover{text-decoration:underline;}
    </style>
</head>
<body>
<div class="card">
    <div class="header">
        <a href="${pageContext.request.contextPath}/" class="logo">🎓 LMS System</a>
        <h1>Đăng nhập</h1>
        <p>Chào mừng bạn trở lại!</p>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">⚠️ <span>${error}</span></div>
    </c:if>
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success">✅ <span>${successMessage}</span></div>
    </c:if>

    <form action="${pageContext.request.contextPath}/login" method="post">
        <div class="form-group">
            <label for="email">Địa chỉ Email</label>
            <input type="email" id="email" name="email" class="form-control"
                   placeholder="name@example.com"
                   value="<c:out value='${email}' default=''/>" required autofocus>
        </div>
        <div class="form-group">
            <label for="password">Mật khẩu</label>
            <input type="password" id="password" name="password" class="form-control"
                   placeholder="Nhập mật khẩu của bạn" required>
        </div>
        <button type="submit" class="btn-submit">Đăng nhập</button>
    </form>

    <div class="footer-links">
        <div>Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký ngay</a></div>
        <div><a href="${pageContext.request.contextPath}/" style="color:#a0aec0;font-size:13px;">← Quay về trang chủ</a></div>
    </div>
</div>
</body>
</html>
