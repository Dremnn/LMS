<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.NotificationSettings" %>
<%
    NotificationSettings settings = (NotificationSettings) request.getAttribute("settings");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tùy chọn thông báo - LMS</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; background: #f5f6fa; }
        .header { background: #fff; padding: 24px; }
        .container { background: #fff; margin: 0 24px 24px; border-radius: 8px; padding: 24px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 14px 16px; border-bottom: 1px solid #eee; text-align: left; }
        th { font-weight: bold; }
        .switch { position: relative; display: inline-block; width: 40px; height: 22px; }
        .switch input { opacity: 0; width: 0; height: 0; }
        .slider { position: absolute; cursor: pointer; top:0; left:0; right:0; bottom:0;
                  background: #ccc; border-radius: 22px; transition: .2s; }
        .slider:before { position: absolute; content: ""; height: 16px; width: 16px; left: 3px; bottom: 3px;
                          background: white; border-radius: 50%; transition: .2s; }
        input:checked + .slider { background: #2563eb; }
        input:checked + .slider:before { transform: translateX(18px); }
        .btn { padding: 10px 20px; border: none; border-radius: 6px; background: #2563eb; color: #fff;
               cursor: pointer; font-size: 14px; margin-top: 16px; }
    </style>
</head>
<body>

    <div class="header"><h2>Tùy chọn thông báo</h2></div>

    <div class="container">
        <form method="post" action="${pageContext.request.contextPath}/notifications/settings">
            <table>
                <tr><th>Loại thông báo</th><th style="text-align:center;">Bật/Tắt</th></tr>
                <tr>
                    <td>Nhắc quiz sắp hết hạn</td>
                    <td style="text-align:center;">
                        <label class="switch">
                            <input type="checkbox" name="quizDeadlineEnabled"
                                   <%= settings.isQuizDeadlineEnabled() ? "checked" : "" %>>
                            <span class="slider"></span>
                        </label>
                    </td>
                </tr>
                <tr>
                    <td>Xác nhận ghi danh khóa học</td>
                    <td style="text-align:center;">
                        <label class="switch">
                            <input type="checkbox" name="enrollmentEnabled"
                                   <%= settings.isEnrollmentEnabled() ? "checked" : "" %>>
                            <span class="slider"></span>
                        </label>
                    </td>
                </tr>
                <tr>
                    <td>Nhắc sự kiện tự tạo</td>
                    <td style="text-align:center;">
                        <label class="switch">
                            <input type="checkbox" name="eventReminderEnabled"
                                   <%= settings.isEventReminderEnabled() ? "checked" : "" %>>
                            <span class="slider"></span>
                        </label>
                    </td>
                </tr>
            </table>
            <button type="submit" class="btn">Lưu thay đổi</button>
        </form>
    </div>


    <jsp:include page="/WEB-INF/views/components/drawer.jsp" />
</body>
</html>

