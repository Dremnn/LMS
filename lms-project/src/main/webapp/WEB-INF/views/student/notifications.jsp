<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.lms.model.Notification" %>
<%
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    Notification selected = (Notification) request.getAttribute("selected");
    com.lms.model.User currentUser = (com.lms.model.User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông báo - EduViet LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <style>
        .notifications-wrapper {
            max-width: 1100px;
            margin: -40px auto 40px;
            position: relative;
            z-index: 10;
        }
        .notif-layout {
            display: flex;
            gap: 24px;
            background: transparent;
        }
        
        /* Sidebar Danh sách */
        .notif-sidebar {
            width: 380px;
            background: var(--surface);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            border: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            overflow: hidden;
            height: calc(100vh - 200px);
            min-height: 500px;
        }
        .sidebar-header {
            padding: 20px 24px;
            border-bottom: 1px solid var(--border);
            background: var(--surface);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .sidebar-header h2 { margin: 0; font-size: 18px; color: var(--text); }
        .sidebar-header a { font-size: 13px; color: var(--primary); text-decoration: none; font-weight: 600; }
        .sidebar-header a:hover { text-decoration: underline; }
        
        .notif-list {
            flex: 1;
            overflow-y: auto;
            background: var(--surface);
        }
        .n-item {
            padding: 16px 24px;
            border-bottom: 1px solid var(--border);
            cursor: pointer;
            transition: all var(--t-fast);
            position: relative;
        }
        .n-item:hover { background: rgba(79, 70, 229, 0.03); }
        .n-item.active { background: rgba(79, 70, 229, 0.08); border-left: 4px solid var(--primary); padding-left: 20px; }
        .n-item.unread { background: #F0F9FF; }
        .n-item.unread.active { background: rgba(79, 70, 229, 0.08); }
        
        .n-item .n-title { font-size: 15px; color: var(--text); margin-bottom: 6px; display: flex; align-items: flex-start; gap: 8px; }
        .n-item.unread .n-title { font-weight: 700; color: var(--primary-dark); }
        .n-item .n-time { font-size: 12px; color: var(--text-muted); margin-left: 28px; display: flex; align-items: center; gap: 4px; }
        
        /* Cột Chi tiết */
        .notif-detail {
            flex: 1;
            background: var(--surface);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            border: 1px solid var(--border);
            padding: 40px;
            display: flex;
            flex-direction: column;
            height: calc(100vh - 200px);
            min-height: 500px;
            overflow-y: auto;
        }
        
        .detail-header { border-bottom: 2px solid var(--border); padding-bottom: 20px; margin-bottom: 24px; }
        .detail-title { font-size: 22px; color: var(--text); font-weight: 700; display: flex; align-items: flex-start; gap: 12px; line-height: 1.4; margin: 0 0 10px 0; }
        .detail-meta { display: flex; align-items: center; gap: 16px; color: var(--text-muted); font-size: 13px; }
        .detail-body { font-size: 15px; color: var(--text); line-height: 1.8; flex: 1; }
        
        .no-selection {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: var(--text-muted);
            text-align: center;
        }
        .no-selection i { font-size: 64px; color: var(--border); margin-bottom: 16px; }
        
        .link-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: var(--primary-light);
            color: var(--primary);
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            margin-top: 24px;
            transition: all var(--t-fast);
        }
        .link-btn:hover { background: var(--primary); color: white; transform: translateY(-1px); }
        
    </style>
</head>
<body class="mesh-bg">

<!-- DYNAMIC ISLAND NAVBAR -->
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
            <a href="<%=request.getContextPath()%>/student/notifications" class="quick-action-btn" title="Thông báo">
                <i class="fa-solid fa-bell"></i><span class="quick-action-text">Thông báo</span>
            </a>
        </div>
        <% } %>
    </div>
    <div class="nav-links">
        <a href="<%=request.getContextPath()%>/courses" class="nav-link">Khóa học</a>
        <% if (currentUser != null) { %>
            <% if ("student".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/student/dashboard" class="nav-link">Bảng điều khiển</a>
                <a href="<%=request.getContextPath()%>/student/my-courses" class="nav-link">Khóa học của tôi</a>
            <% } %>
            <a href="<%=request.getContextPath()%>/profile" class="nav-link">Hồ sơ</a>
            <div class="user-badge">
                <% if (currentUser.getAvatarUrl() != null && !currentUser.getAvatarUrl().trim().isEmpty()) { %>
                    <img src="<%=currentUser.getAvatarUrl()%>" alt="Avatar" class="user-avatar" style="object-fit: cover;">
                <% } else { %>
                    <div class="user-avatar"><%=currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName().substring(0,1).toUpperCase() : "U"%></div>
                <% } %>
                <span><%=currentUser.getFullName()%></span>
                <span class="role-tag"><%=role%></span>
            </div>
            <% if ("instructor".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/instructor/courses" class="btn btn-outline">Quản lý</a>
            <% } else if ("admin".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/admin" class="btn btn-outline">Quản trị</a>
            <% } %>
            <a href="<%=request.getContextPath()%>/logout" class="btn btn-danger">Đăng xuất</a>
        <% } %>
    </div>
</nav>

<!-- PAGE HEADER -->
<div class="page-header" style="padding-bottom: 80px; text-align: left;">
    <div class="container" style="max-width: 1100px;">
        <h1><i class="fa-solid fa-envelope-open-text"></i> Hộp thư thông báo</h1>
        <p>Quản lý các tin nhắn và cập nhật quan trọng từ hệ thống.</p>
    </div>
</div>

<div class="notifications-wrapper reveal reveal-d1">
    <div class="notif-layout">
        
        <!-- SIDEBAR -->
        <div class="notif-sidebar">
            <div class="sidebar-header">
                <h2><i class="fa-solid fa-inbox"></i> Tất cả thông báo</h2>
                <a href="<%= request.getContextPath() %>/student/notifications/mark-all-read"><i class="fa-solid fa-check-double"></i> Đánh dấu đã đọc</a>
            </div>
            <div class="notif-list">
                <% if (notifications == null || notifications.isEmpty()) { %>
                    <div style="padding: 40px 20px; text-align: center; color: var(--text-muted);">
                        <i class="fa-solid fa-box-open" style="font-size: 32px; color: var(--border); margin-bottom: 12px;"></i>
                        <p>Chưa có thông báo nào.</p>
                    </div>
                <% } else {
                    for (Notification n : notifications) {
                        boolean isActive = selected != null && selected.getId() == n.getId();
                        String itemClass = "n-item" + (isActive ? " active" : "") + (!n.isRead() ? " unread" : "");
                %>
                    <div class="<%= itemClass %>" onclick="location.href='<%= request.getContextPath() %>/student/notifications?id=<%= n.getId() %>'">
                        <div class="n-title">
                            <% if (!n.isRead()) { %>
                                <i class="fa-solid fa-circle" style="color: var(--primary); font-size: 8px; margin-top: 6px;"></i>
                            <% } else { %>
                                <i class="fa-regular fa-bell" style="color: var(--text-muted); font-size: 14px; margin-top: 2px;"></i>
                            <% } %>
                            <span><%= n.getTitle() %></span>
                        </div>
                        <div class="n-time"><i class="fa-regular fa-clock"></i> <%= timeAgo(n.getCreatedAt()) %></div>
                    </div>
                <%  }
                } %>
            </div>
        </div>

        <!-- DETAIL COLUMN -->
        <div class="notif-detail">
            <% if (selected == null) { %>
                <div class="no-selection">
                    <i class="fa-regular fa-comments"></i>
                    <h3>Chưa chọn thông báo</h3>
                    <p>Hãy chọn một thông báo từ danh sách bên trái để xem chi tiết.</p>
                </div>
            <% } else { %>
                <div class="detail-header">
                    <h2 class="detail-title">
                        <i class="fa-solid fa-envelope-open" style="color: var(--primary); margin-top: 4px; font-size: 20px;"></i>
                        <%= selected.getTitle() %>
                    </h2>
                    <div class="detail-meta">
                        <span><i class="fa-solid fa-calendar-day"></i> <%= selected.getCreatedAt().toString().replace("T", " ") %></span>
                        <span><i class="fa-regular fa-clock"></i> <%= timeAgo(selected.getCreatedAt()) %></span>
                    </div>
                </div>

                <div class="detail-body">
                    <%= selected.getMessage().replace("\n", "<br>") %>
                    
                    <% if (selected.getRelatedUrl() != null && !selected.getRelatedUrl().isEmpty()) { %>
                        <div>
                            <a href="<%= request.getContextPath() %><%= selected.getRelatedUrl() %>" class="link-btn">
                                Truy cập liên kết <i class="fa-solid fa-arrow-right"></i>
                            </a>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>

    </div>
</div>

<script src="<%=request.getContextPath()%>/assets/js/lms-app.js?v=30"></script>

</body>
</html>

<%!
    public String timeAgo(java.time.LocalDateTime dateTime) {
        if (dateTime == null) return "";
        long minutes = java.time.temporal.ChronoUnit.MINUTES.between(dateTime, java.time.LocalDateTime.now());
        if (minutes < 1) return "Vừa xong";
        if (minutes < 60) return minutes + " phút trước";
        long hours = minutes / 60;
        if (hours < 24) return hours + " giờ trước";
        long days = hours / 24;
        return days + " ngày trước";
    }
%>
