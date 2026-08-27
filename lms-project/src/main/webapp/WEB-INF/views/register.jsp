<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký - LMS</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',Roboto,Arial,sans-serif;}
        body{background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:30px 20px;}
        .card{background:#fff;border-radius:18px;box-shadow:0 20px 50px rgba(0,0,0,.18);width:100%;max-width:480px;padding:44px 38px;}
        .header{text-align:center;margin-bottom:28px;}
        .header .logo{font-size:26px;font-weight:800;color:#667eea;text-decoration:none;display:block;margin-bottom:10px;}
        .header h1{color:#1a202c;font-size:22px;font-weight:700;margin-bottom:6px;}
        .header p{color:#718096;font-size:14px;}
        .alert-danger{background:#fff5f5;color:#c53030;border:1px solid #feb2b2;padding:12px 16px;border-radius:9px;font-size:14px;margin-bottom:20px;}
        .form-group{margin-bottom:18px;}
        .form-group label{display:block;margin-bottom:6px;color:#4a5568;font-size:14px;font-weight:600;}
        .form-control{width:100%;padding:11px 14px;border:1.5px solid #e2e8f0;border-radius:9px;font-size:14px;color:#2d3748;outline:none;transition:border-color .2s,box-shadow .2s;}
        .form-control:focus{border-color:#667eea;box-shadow:0 0 0 3px rgba(102,126,234,.15);}
        .role-wrap{display:flex;gap:14px;}
        .role-opt{flex:1;display:flex;align-items:center;gap:9px;padding:11px 14px;border:1.5px solid #e2e8f0;border-radius:9px;cursor:pointer;transition:border-color .2s,background .2s;}
        .role-opt:hover{border-color:#667eea;background:#f7f8ff;}
        .role-opt input{cursor:pointer;accent-color:#667eea;}
        .role-opt span{font-size:14px;color:#4a5568;font-weight:500;}
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
        <h1>Tạo tài khoản</h1>
        <p>Tham gia cộng đồng học tập ngay hôm nay</p>
    </div>

    <c:if test="${not empty error}">
        <div class="alert-danger">⚠️ ${error}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/register" method="post">
        <div class="form-group">
            <label for="fullName">Họ và tên</label>
            <input type="text" id="fullName" name="fullName" class="form-control"
                   placeholder="Ví dụ: Nguyễn Văn A"
                   value="<c:out value='${fullName}' default=''/>" required autofocus>
        </div>
        <div class="form-group">
            <label for="email">Địa chỉ Email</label>
            <input type="email" id="email" name="email" class="form-control"
                   placeholder="name@example.com"
                   value="<c:out value='${email}' default=''/>" required>
        </div>
        <div class="form-group">
            <label for="password">Mật khẩu <small style="color:#a0aec0;font-weight:400;">(tối thiểu 6 ký tự)</small></label>
            <input type="password" id="password" name="password" class="form-control"
                   placeholder="Tạo mật khẩu an toàn" minlength="6" required>
        </div>
        <div class="form-group">
            <label for="confirmPassword">Xác nhận mật khẩu</label>
            <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                   placeholder="Nhập lại mật khẩu" minlength="6" required>
        </div>
        <div class="form-group">
            <label>Vai trò của bạn</label>
            <div class="role-wrap">
                <label class="role-opt">
                    <input type="radio" name="role" value="student"
                           <c:if test="${empty role || role == 'student'}">checked</c:if>>
                    <span>🎓 Học viên</span>
                </label>
                <label class="role-opt">
                    <input type="radio" name="role" value="instructor"
                           <c:if test="${role == 'instructor'}">checked</c:if>>
                    <span>👨‍🏫 Giảng viên</span>
                </label>
            </div>
        </div>
        <button type="submit" class="btn-submit">Đăng ký tài khoản</button>
    </form>

    <div class="footer-links">
        <div>Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập</a></div>
        <div><a href="${pageContext.request.contextPath}/" style="color:#a0aec0;font-size:13px;">← Quay về trang chủ</a></div>
    </div>
</div>
</body>
</html>
