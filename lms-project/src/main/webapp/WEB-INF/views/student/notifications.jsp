<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.lms.model.Notification" %>
<%
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    Notification selected = (Notification) request.getAttribute("selected");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Các thông báo - LMS</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; background: #f5f6fa; }
        .header { background: #fff; padding: 16px 24px; display: flex; align-items: center; gap: 12px; }
        .avatar { width: 48px; height: 48px; border-radius: 50%; background: #14b8a6; color: #fff;
                  display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 18px; }
        .container { display: flex; background: #fff; margin: 0 24px 24px; border-radius: 8px; overflow: hidden; min-height: 500px; }
        .list-col { width: 340px; border-right: 1px solid #eee; overflow-y: auto; }
        .list-col h2 { padding: 16px; margin: 0; font-size: 18px; border-bottom: 1px solid #eee; }
        .n-item { padding: 12px 16px; border-bottom: 1px solid #f0f0f0; cursor: pointer; }
        .n-item:hover { background: #f9fafb; }
        .n-item.active { background: #2563eb; color: #fff; }
        .n-item.active a, .n-item.active .n-time { color: #dbeafe; }
        .n-item .n-title { display: flex; align-items: flex-start; gap: 8px; font-size: 14px; }
        .n-item .n-time { font-size: 12px; color: #999; margin-top: 4px; margin-left: 24px; }
        .n-item.unread .n-title { font-weight: bold; }

        .detail-col { flex: 1; padding: 24px; }
        .detail-col .n-title-row { display: flex; align-items: flex-start; gap: 8px; }
        .detail-col .n-meta { font-size: 12px; color: #999; margin: 4px 0 16px 24px; }
        .detail-col .n-breadcrumb { margin: 16px 0; }
        .detail-col .n-breadcrumb a { color: #2563eb; text-decoration: none; }
        .detail-col hr { border: none; border-top: 1px solid #eee; margin: 16px 0; }
        .detail-col .n-message { line-height: 1.6; }
        .no-selection { color: #999; text-align: center; padding: 60px 20px; }
    </style>
</head>
<body>

    <div class="header">
        <div class="avatar"><%= currentUserInitial(request) %></div>
        <div>
            <strong><%= ((com.lms.model.User) request.getSession().getAttribute("currentUser")).getFullName() %></strong>
        </div>
    </div>

    <div class="container">
        <div class="list-col">
            <h2>Các thông báo</h2>
            <% if (notifications == null || notifications.isEmpty()) { %>
                <div class="no-selection">Chưa có thông báo nào.</div>
            <% } else {
                for (Notification n : notifications) {
                    boolean isActive = selected != null && selected.getId() == n.getId();
                    String itemClass = "n-item" + (isActive ? " active" : "") + (!n.isRead() ? " unread" : "");
            %>
                <div class="<%= itemClass %>"
                     onclick="location.href='<%= request.getContextPath() %>/student/notifications?id=<%= n.getId() %>'">
                    <div class="n-title">💡 <%= n.getTitle() %></div>
                    <div class="n-time"><%= timeAgo(n.getCreatedAt()) %></div>
                </div>
            <%  }
            } %>
        </div>

        <div class="detail-col">
            <% if (selected == null) { %>
                <div class="no-selection">Chọn 1 thông báo để xem chi tiết.</div>
            <% } else { %>
                <div class="n-title-row">💡 <strong><%= selected.getTitle() %></strong></div>
                <div class="n-meta"><%= timeAgo(selected.getCreatedAt()) %></div>

                <hr>
                <div class="n-message"><%= selected.getMessage() %></div>

                <% if (selected.getRelatedUrl() != null && !selected.getRelatedUrl().isEmpty()) { %>
                    <p style="margin-top:20px;">
                        <a href="<%= request.getContextPath() %><%= selected.getRelatedUrl() %>">Đi tới liên kết liên quan</a>
                    </p>
                <% } %>
            <% } %>
        </div>
    </div>

<%!
    // Hàm phụ trợ hiển thị "cách đây X phút/giờ/ngày" - đặt trong JSP declaration để tái sử dụng
    public String timeAgo(java.time.LocalDateTime dateTime) {
        if (dateTime == null) return "";
        long minutes = java.time.temporal.ChronoUnit.MINUTES.between(dateTime, java.time.LocalDateTime.now());
        if (minutes < 60) return "cách đây " + minutes + " phút";
        long hours = minutes / 60;
        if (hours < 24) return "cách đây " + hours + " giờ";
        long days = hours / 24;
        return "cách đây " + days + " ngày";
    }

    public String currentUserInitial(jakarta.servlet.http.HttpServletRequest request) {
        com.lms.model.User u = (com.lms.model.User) request.getSession().getAttribute("currentUser");
        if (u == null || u.getFullName() == null || u.getFullName().isEmpty()) return "?";
        return u.getFullName().substring(0, 1).toUpperCase();
    }
%>

</body>
</html>
