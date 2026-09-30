<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gửi thông báo - LMS Instructor</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <style>
        .page-header { background: linear-gradient(135deg, #093C62, #076FA4); color: #fff; padding: 24px; border-radius: 16px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 4px 16px rgba(9, 60, 98, .15); }
        .page-title { font-size: 20px; font-weight: 700; margin: 0; }
        .main { max-width: 800px; margin: 36px auto; padding: 0 24px; }
        .card { background: #fff; border-radius: 14px; padding: 24px; box-shadow: 0 4px 16px rgba(9, 60, 98, .06); border: 1px solid #C6D8E3; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #093C62; font-size: 14px; }
        .form-control { width: 100%; padding: 12px 16px; border: 1px solid #C6D8E3; border-radius: 10px; font-size: 14px; color: #093C62; background: #fff; transition: all 0.2s; box-sizing: border-box; }
        .form-control:focus { outline: none; border-color: #076FA4; box-shadow: 0 0 0 3px rgba(7, 111, 164, 0.1); }
        .btn { display: inline-block; padding: 12px 24px; border-radius: 10px; font-size: 14px; font-weight: 600; text-align: center; cursor: pointer; transition: all 0.2s; border: none; }
        .btn-primary { background: linear-gradient(135deg, #076FA4, #093C62); color: #fff; }
        .btn-primary:hover { box-shadow: 0 4px 12px rgba(7, 111, 164, 0.3); transform: translateY(-1px); }
        .alert { padding: 12px 16px; border-radius: 10px; font-size: 14px; margin-bottom: 20px; font-weight: 500; }
        .alert-success { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
        .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

        body.dark-theme .page-header { background: linear-gradient(135deg, #182535, #093C62); }
        body.dark-theme .card { background: #182535; border-color: #093C62; box-shadow: 0 4px 16px rgba(0,0,0,.3); }
        body.dark-theme .form-group label { color: #9DB9CB; }
        body.dark-theme .form-control { background: #111312; border-color: #093C62; color: #F4F8FA; }
        body.dark-theme .form-control:focus { border-color: #5C7688; }
        body.dark-theme .btn-primary { background: #093C62; }
    </style>
</head>
<body class="mesh-bg \">
<% 
    User currentUser = (User) session.getAttribute("currentUser"); 
    String role = currentUser != null ? currentUser.getRole() : "";
%>

<!-- DÙNG CHUNG NAVBAR -->
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

<div class="main slide-up">
    <div class="page-header">
        <div>
            <h1 class="page-title"><i class="fas fa-bullhorn mr-2"></i> Gửi thông báo</h1>
            <p style="margin:4px 0 0 0;font-size:13px;opacity:0.9;">Gửi thông báo đến học viên</p>
        </div>
        <a href="\/instructor/courses" class="btn" style="background:rgba(255,255,255,0.2);color:#fff;border-radius:8px;padding:8px 16px;text-decoration:none;font-size:13px;">
            <i class="fas fa-arrow-left"></i> Quay lại
        </a>
    </div>

    <div class="card">
        <c:if test="\">
            <div class="alert alert-error">\</div>
        </c:if>
        <c:if test="\">
            <div class="alert alert-success">\</div>
        </c:if>

        <form action="\/instructor/notifications/send" method="post">
            <div class="form-group">
                <label for="target">Gửi tới ai?</label>
                <select name="target" id="target" class="form-control">
                    <option value="my_students">Học viên đang học các khóa của tôi</option>
                    <c:if test="\">
                        <option value="all_students">Toàn bộ hệ thống</option>
                    </c:if>
                </select>
            </div>
            
            <div class="form-group">
                <label for="title">Tiêu đề thông báo</label>
                <input type="text" name="title" id="title" class="form-control" required placeholder="Nhập tiêu đề...">
            </div>
            
            <div class="form-group">
                <label for="message">Nội dung chi tiết</label>
                <textarea name="message" id="message" rows="5" class="form-control" required placeholder="Nhập nội dung thông báo..."></textarea>
            </div>
            
            <div style="text-align: right; margin-top: 24px;">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-paper-plane mr-2"></i> Gửi thông báo
                </button>
            </div>
        </form>
    </div>
</div>

<script src="\/assets/js/lms-app.js?v=34"></script>
</body>
</html>






