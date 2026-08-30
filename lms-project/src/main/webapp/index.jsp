F<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LMS - Học trực tuyến</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; font-family:'Segoe UI',Roboto,Arial,sans-serif; }
        body { background:#f7fafc; color:#2d3748; }
        .navbar { background:#fff; box-shadow:0 2px 10px rgba(0,0,0,.07); padding:14px 48px; display:flex; justify-content:space-between; align-items:center; position:sticky; top:0; z-index:100; }
        .navbar .logo { font-size:22px; font-weight:700; color:#667eea; text-decoration:none; }
        .nav-links { display:flex; align-items:center; gap:12px; }
        .btn { padding:9px 20px; border-radius:8px; text-decoration:none; font-weight:600; font-size:14px; transition:all .2s; display:inline-block; cursor:pointer; border:none; }
        .btn-outline { border:1.5px solid #667eea; color:#667eea; background:transparent; }
        .btn-outline:hover { background:#667eea; color:#fff; }
        .btn-primary { background:linear-gradient(135deg,#667eea,#764ba2); color:#fff; }
        .btn-primary:hover { opacity:.92; transform:translateY(-1px); }
        .btn-danger { background:#fc8181; color:#742a2a; }
        .btn-danger:hover { background:#f56565; color:#fff; }
        .btn-secondary { background:#e2e8f0; color:#4a5568; }
        .btn-secondary:hover { background:#cbd5e0; }
        .hero { background:linear-gradient(135deg,#667eea 0%,#764ba2 100%); color:#fff; padding:100px 48px; text-align:center; }
        .hero h1 { font-size:48px; font-weight:800; margin-bottom:20px; line-height:1.15; }
        .hero p { font-size:20px; opacity:.9; max-width:640px; margin:0 auto 40px; line-height:1.6; }
        .hero-cta { display:flex; gap:15px; justify-content:center; flex-wrap:wrap; }
        .btn-hero { padding:14px 32px; border-radius:10px; font-size:17px; font-weight:700; text-decoration:none; transition:all .2s; display:inline-block; }
        .btn-hero-white { background:#fff; color:#667eea; }
        .btn-hero-white:hover { transform:translateY(-2px); box-shadow:0 8px 24px rgba(0,0,0,.15); }
        .btn-hero-outline { border:2px solid #fff; color:#fff; }
        .btn-hero-outline:hover { background:#fff; color:#667eea; }
        .features { display:grid; grid-template-columns:repeat(auto-fit,minmax(260px,1fr)); gap:24px; max-width:1100px; margin:80px auto; padding:0 24px; }
        .feature-card { background:#fff; border-radius:14px; padding:32px 28px; box-shadow:0 4px 18px rgba(0,0,0,.06); border-top:4px solid #667eea; }
        .feature-card .icon { font-size:36px; margin-bottom:14px; }
        .feature-card h3 { font-size:18px; font-weight:700; margin-bottom:10px; color:#1a202c; }
        .feature-card p { font-size:14px; color:#718096; line-height:1.6; }
        .user-info { font-size:14px; color:#4a5568; font-weight:600; }
        .badge { display:inline-block; padding:2px 10px; border-radius:12px; font-size:11px; font-weight:700; background:#ebf8ff; color:#2b6cb0; text-transform:uppercase; margin-left:6px; }
        footer { background:#1a202c; color:#a0aec0; text-align:center; padding:28px; margin-top:60px; font-size:14px; }
    </style>
</head>
<body>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";
%>

<nav class="navbar">
    <a href="<%=request.getContextPath()%>/" class="logo">🎓 LMS System</a>
    <div class="nav-links">
        <a href="<%=request.getContextPath()%>/courses" class="btn btn-secondary">Khóa học</a>
        <% if (currentUser != null) { %>
            <span class="user-info">
                <%=currentUser.getFullName()%>
                <span class="badge"><%=role%></span>
            </span>
            <% if ("instructor".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/instructor/courses" class="btn btn-outline">Quản lý khóa học</a>
            <% } else if ("admin".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/admin" class="btn btn-outline">Trang quản trị</a>
            <% } %>
            <a href="<%=request.getContextPath()%>/logout" class="btn btn-danger">Đăng xuất</a>
        <% } else { %>
            <a href="<%=request.getContextPath()%>/login" class="btn btn-outline">Đăng nhập</a>
            <a href="<%=request.getContextPath()%>/register" class="btn btn-primary">Đăng ký</a>
        <% } %>
    </div>
</nav>

<section class="hero">
    <h1>Nền tảng Học trực tuyến<br>#2 Việt Nam</h1>
    <p>Học lập trình, thiết kế và công nghệ từ những giảng viên hàng đầu. Học mọi lúc, mọi nơi theo tốc độ của bạn.</p>
    <div class="hero-cta">
        <% if (currentUser == null) { %>
            <a href="<%=request.getContextPath()%>/courses" class="btn-hero btn-hero-white">🚀 Khám phá khóa học</a>
            <a href="<%=request.getContextPath()%>/register" class="btn-hero btn-hero-outline">✨ Đăng ký miễn phí</a>
        <% } else if ("student".equals(role)) { %>
            <a href="<%=request.getContextPath()%>/student/my-courses" class="btn-hero btn-hero-white">📚 Khóa học của tôi</a>
            <a href="<%=request.getContextPath()%>/courses" class="btn-hero btn-hero-outline">🔍 Khám phá khóa học</a>
        <% } else if ("instructor".equals(role)) { %>
            <a href="<%=request.getContextPath()%>/instructor/courses" class="btn-hero btn-hero-white">📋 Quản lý khóa học</a>
            <a href="<%=request.getContextPath()%>/instructor/courses/new" class="btn-hero btn-hero-outline">➕ Tạo khóa học mới</a>
        <% } else if ("admin".equals(role)) { %>
            <a href="<%=request.getContextPath()%>/admin" class="btn-hero btn-hero-white">⚙️ Trang quản trị</a>
        <% } %>
    </div>
</section>

<footer>
    <p>© 2026 LMS System — Nền tảng học trực tuyến hàng đầu Việt Nam</p>
</footer>
</body>
</html>
