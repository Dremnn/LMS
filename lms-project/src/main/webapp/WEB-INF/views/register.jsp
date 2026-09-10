<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký - UTEdu LMS</title>
    
    <!-- Fonts & Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/lms-design.css?v=3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/lms-animations.css?v=3">
    
    <style>
        .auth-layout { display: flex; min-height: 100vh; background: var(--bg); }
        
        .auth-left {
            flex: 1; background: linear-gradient(135deg, #06B6D4, #3730A3);
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            color: white; padding: 40px; text-align: center; position: relative; overflow: hidden;
        }
        .auth-left::before { 
            content: ''; position: absolute; width: 700px; height: 700px; 
            background: rgba(255,255,255,0.03); border-radius: 50%; top: -150px; left: -150px; 
        }
        
        .auth-quote { z-index: 1; max-width: 440px; }
        .auth-quote h2 { font-size: 32px; margin-bottom: 16px; color: #FFFFFF; font-weight: 800; }
        .auth-quote p { font-size: 16px; color: #E0F2FE; line-height: 1.6; }
        
        .auth-right {
            flex: 1.2; display: flex; align-items: center; justify-content: center; padding: 40px; background: var(--bg);
        }
        .auth-form-wrapper { 
            width: 100%; max-width: 500px; background: var(--surface); 
            padding: 48px 40px; border-radius: var(--radius-lg); 
            box-shadow: var(--shadow-md); border: 1px solid var(--border);
        }
        
        .auth-header { margin-bottom: 32px; text-align: center; }
        .auth-header h1 { font-size: 28px; margin-bottom: 8px; font-weight: 800; }
        .auth-header p { color: var(--text-muted); font-size: 15px; }
        
        .form-row { display: flex; gap: 16px; }
        .form-row .form-group { flex: 1; }
        
        .role-wrap { display: flex; gap: 16px; }
        .role-opt {
            flex: 1; display: flex; align-items: center; gap: 10px;
            padding: 14px 16px; border: 1.5px solid var(--border);
            border-radius: var(--radius-sm); cursor: pointer;
            transition: all var(--t-fast); background: var(--surface);
        }
        .role-opt:hover { border-color: var(--primary-light); background: var(--bg); }
        .role-opt input { cursor: pointer; accent-color: var(--primary); width: 18px; height: 18px; }
        .role-opt span { font-size: 15px; color: var(--text); font-weight: 600; }
        
        .btn-submit { width: 100%; margin-top: 16px; padding: 14px; font-size: 16px; border-radius: var(--radius-sm); }
        
        .back-link { 
            display: inline-flex; align-items: center; gap: 6px; 
            color: var(--text-muted); font-weight: 500; font-size: 14px; 
            margin-top: 24px; transition: color var(--t-fast); 
        }
        .back-link:hover { color: var(--primary); }
        
        @media (max-width: 1024px) { .auth-left { display: none; } }
        @media (max-width: 600px) { .form-row { flex-direction: column; gap: 0; } }
    </style>
</head>
<body>

<div class="auth-layout">
    <!-- Left Panel with 3D Illustration Equivalent -->
    <div class="auth-left">
        <i class="fa-solid fa-seedling animate-float" style="font-size: 160px; color: #fff; filter: drop-shadow(0 20px 30px rgba(0,0,0,0.3)); margin-bottom: 40px;"></i>
        <div class="auth-quote reveal-up">
            <h2>Kiến tạo tương lai</h2>
            <p>Khám phá kho tàng tri thức khổng lồ và kết nối với các chuyên gia hàng đầu ngay hôm nay.</p>
        </div>
    </div>
    
    <!-- Right Panel with Form -->
    <div class="auth-right">
        <div class="auth-form-wrapper reveal-up reveal-delay-1">
            <div class="auth-header">
                <a href="${pageContext.request.contextPath}/" class="lms-logo" style="justify-content: center; margin-bottom: 24px;">
                    <span class="logo-icon"><i class="fa-solid fa-graduation-cap"></i></span><span class="logo-text">UTEdu LMS</span>
                </a>
                <h1>Tạo tài khoản mới</h1>
                <p>Chỉ mất vài phút để thiết lập hồ sơ học tập của bạn.</p>
            </div>

            <!-- Error Alerts -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger"><i class="fa-solid fa-triangle-exclamation" style="font-size: 20px;"></i> <span>${error}</span></div>
            </c:if>

            <form action="${pageContext.request.contextPath}/register" method="post">
                <div class="form-group">
                    <label for="fullName" class="form-label">Họ và tên</label>
                    <input type="text" id="fullName" name="fullName" class="form-control"
                           placeholder="Ví dụ: Nguyễn Văn A"
                           value="<c:out value='${fullName}' default=''/>" required autofocus>
                </div>
                
                <div class="form-group">
                    <label for="email" class="form-label">Địa chỉ Email</label>
                    <input type="email" id="email" name="email" class="form-control"
                           placeholder="name@example.com"
                           value="<c:out value='${email}' default=''/>" required>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="password" class="form-label">Mật khẩu</label>
                        <input type="password" id="password" name="password" class="form-control"
                               placeholder="Tối thiểu 6 ký tự" minlength="6" required>
                    </div>
                    <div class="form-group">
                        <label for="confirmPassword" class="form-label">Xác nhận mật khẩu</label>
                        <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                               placeholder="Nhập lại mật khẩu" minlength="6" required>
                    </div>
                </div>

                <div class="form-group" style="margin-top: 8px;">
                    <label class="form-label">Vai trò của bạn</label>
                    <div class="role-wrap">
                        <label class="role-opt">
                            <input type="radio" name="role" value="student"
                                   <c:if test="${empty role || role == 'student'}">checked</c:if>>
                            <span><i class="fa-solid fa-graduation-cap"></i> Học viên</span>
                        </label>
                        <label class="role-opt">
                            <input type="radio" name="role" value="instructor"
                                   <c:if test="${role == 'instructor'}">checked</c:if>>
                            <span><i class="fa-solid fa-chalkboard-user"></i> Giảng viên</span>
                        </label>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary btn-submit">
                    Đăng ký tài khoản <i class="fa-solid fa-user-plus"></i>
                </button>
            </form>

            <div style="text-align: center; margin-top: 24px;">
                <p style="color: var(--text-muted); font-size: 14px;">Đã có tài khoản? <a href="${pageContext.request.contextPath}/login" style="color: var(--primary); font-weight: 600;">Đăng nhập</a></p>
                <a href="${pageContext.request.contextPath}/" class="back-link"><i class="fa-solid fa-arrow-left"></i> Về trang chủ</a>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js"></script>
</body>
</html>
