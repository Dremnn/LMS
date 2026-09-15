<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="com.lms.model.User, com.lms.model.WalletTransaction" %>
<%@ page import="java.time.format.DateTimeFormatter, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";
    String avatarInitial = (currentUser != null && currentUser.getFullName() != null && !currentUser.getFullName().isEmpty())
            ? currentUser.getFullName().substring(0, 1).toUpperCase() : "U";
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ cá nhân - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css?v=30">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/lms-design.css?v=26">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/lms-animations.css?v=26">
    <style>
        body { margin: 0; padding: 0; min-height: 100vh; }
        .profile-container { max-width: 960px; margin: 24px auto 40px; padding: 0 24px; display: grid; grid-template-columns: 320px 1fr; gap: 24px; }
        @media (max-width: 800px) { .profile-container { grid-template-columns: 1fr; } }

        .panel { background: var(--surface); border-radius: 14px; padding: 24px; margin-bottom: 24px; box-shadow: 0 4px 16px rgba(9,60,98,.06); border: 1px solid var(--border); }
        .panel h2 { margin-top: 0; color: var(--text); font-weight: 800; font-size: 18px; }

        .avatar-wrap { text-align: center; }
        .avatar-big {
            width: 120px; height: 120px; border-radius: 50%; margin: 0 auto 16px; object-fit: cover;
            border: 3px solid var(--primary); display: flex; align-items: center; justify-content: center;
            background: var(--primary); color: #fff; font-size: 42px; font-weight: 800;
        }
        .profile-name { font-size: 20px; font-weight: 800; color: var(--text); margin: 0 0 4px; }
        .role-badge {
            display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 700;
            text-transform: uppercase; letter-spacing: .5px; background: var(--primary-light, #E2EEF5); color: var(--primary);
        }

        .info-row { display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px solid var(--border); }
        .info-row:last-child { border-bottom: none; }
        .info-row .label { color: var(--text-muted); font-size: 14px; display: flex; align-items: center; gap: 8px; }
        .info-row .value { font-weight: 600; color: var(--text); font-size: 14px; text-align: right; }

        .balance-card {
            background: linear-gradient(135deg, #076FA4, #093C62); border-radius: 14px; padding: 24px;
            color: #fff; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center;
        }
        .balance-card .label { font-size: 13px; opacity: .85; margin-bottom: 6px; }
        .balance-card .amount { font-size: 30px; font-weight: 800; }
        .balance-card a { text-decoration: none; }

        table.history-table { width: 100%; border-collapse: collapse; font-size: 14px; }
        table.history-table th, table.history-table td { padding: 10px 8px; text-align: left; border-bottom: 1px solid var(--border); }
        table.history-table th { color: var(--text-muted); font-weight: 600; font-size: 12px; text-transform: uppercase; }
        .tx-amount.topup { color: #16A34A; font-weight: 700; }
        .tx-amount.payment { color: #DC2626; font-weight: 700; }
        .no-items { color: var(--text-muted); text-align: center; padding: 20px; }
    </style>
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">
    <!-- NAVBAR -->
    <nav class="lms-navbar">
        <div class="nav-left">
        <a href="${pageContext.request.contextPath}/" class="lms-logo">
            <img src="${pageContext.request.contextPath}/assets/images/utedu-logo.png" alt="UTEdu" class="lms-logo-img" style="height: 36px !important; width: auto; max-height: 36px;">
            <span class="logo-tag">LMS</span>
        </a>
        <% if (currentUser != null) { %>
        <div class="quick-actions">
                        <a href="<%=request.getContextPath()%>/student/chat" class="quick-action-btn" title="Tin nhắn">
                <i class="fa-solid fa-comment-dots"></i><span class="quick-action-text">Tin nhắn</span>
            </a>
            <a href="<%=request.getContextPath()%>/student/notifications" class="quick-action-btn" title="Thông báo">
                <i class="fa-solid fa-bell"></i><span class="quick-action-text">Thông báo</span>
            </a>
        </div>
        <% } %>
    </div>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/courses" class="nav-link">Khóa học</a>
            <% if (currentUser != null) { %>
                <div class="user-badge">
                    <div class="user-avatar"><%=currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName().substring(0,1).toUpperCase() : "U"%></div>
                    <span><%=currentUser.getFullName()%></span>
                    <span class="role-tag"><%=role%></span>
                </div>
                <a href="${pageContext.request.contextPath}/profile" class="btn btn-outline active">Hồ sơ</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">Đăng xuất</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/login" class="btn btn-outline">Đăng nhập</a>
                <a href="${pageContext.request.contextPath}/register" class="btn btn-primary">Đăng ký</a>
            <% } %>
        </div>
    </nav>

    <div class="profile-container">
        <c:if test="${not empty error}">
            <div class="alert alert-danger" style="grid-column: 1 / -1;"><i class="fa-solid fa-triangle-exclamation"></i> <span>${error}</span></div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="alert alert-success" style="grid-column: 1 / -1;"><i class="fa-solid fa-circle-check"></i> <span>${success}</span></div>
        </c:if>

        <!-- CỘT TRÁI: Thông tin hiển thị -->
        <div>
            <div class="panel avatar-wrap">
                <c:choose>
                    <c:when test="${not empty profileUser.avatarUrl}">
                        <img src="${profileUser.avatarUrl}" alt="avatar" class="avatar-big">
                    </c:when>
                    <c:otherwise>
                        <div class="avatar-big"><%=avatarInitial%></div>
                    </c:otherwise>
                </c:choose>
                <p class="profile-name">${profileUser.fullName}</p>
                <span class="role-badge">${profileUser.role}</span>
            </div>

            <c:if test="${profileUser.role == 'student'}">
                <div class="balance-card">
                    <div>
                        <div class="label">Số dư ví hiện tại</div>
                        <div class="amount"><fmt:formatNumber value="${profileUser.balance}" type="number" groupingUsed="true"/>đ</div>
                    </div>
                    <a href="${pageContext.request.contextPath}/wallet/topup" class="btn btn-primary"><i class="fa-solid fa-wallet"></i> Nạp tiền</a>
                </div>
            </c:if>
        </div>

        <!-- CỘT PHẢI: Chi tiết + form chỉnh sửa -->
        <div>
            <div class="panel">
                <h2>Thông tin tài khoản</h2>
                <div class="info-row">
                    <span class="label"><i class="fa-solid fa-id-badge"></i> Họ và tên</span>
                    <span class="value">${profileUser.fullName}</span>
                </div>
                <div class="info-row">
                    <span class="label"><i class="fa-solid fa-user"></i> Tên đăng nhập</span>
                    <span class="value">${profileUser.email}</span>
                </div>
                <div class="info-row">
                    <span class="label"><i class="fa-solid fa-envelope"></i> Email</span>
                    <span class="value">${profileUser.email}</span>
                </div>
                <div class="info-row">
                    <span class="label"><i class="fa-solid fa-phone"></i> Số điện thoại</span>
                    <span class="value">
                        <c:choose>
                            <c:when test="${not empty profileUser.phone}">${profileUser.phone}</c:when>
                            <c:otherwise><em style="color: var(--text-muted); font-weight: 400;">Chưa cập nhật</em></c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <c:if test="${profileUser.role == 'student'}">
                    <div class="info-row">
                        <span class="label"><i class="fa-solid fa-wallet"></i> Số dư ví</span>
                        <span class="value"><fmt:formatNumber value="${profileUser.balance}" type="number" groupingUsed="true"/>đ</span>
                    </div>
                </c:if>
            </div>

            <div class="panel">
                <h2>Cập nhật hồ sơ</h2>
                <form action="${pageContext.request.contextPath}/profile" method="post">


                    <div class="form-group">
                        <label for="fullName" class="form-label">Họ và tên</label>
                        <input type="text" id="fullName" name="fullName" class="form-control"
                            placeholder="Nhập họ và tên" value="${profileUser.fullName}" required>
                    </div>

                    <div class="form-group">
                        <label for="avatarUrl" class="form-label">Đường dẫn ảnh đại diện (URL)</label>
                        <input type="text" id="avatarUrl" name="avatarUrl" class="form-control"
                               placeholder="https://..." value="${profileUser.avatarUrl}">
                    </div>
                    <div class="form-group">
                        <label for="phone" class="form-label">Số điện thoại</label>
                        <input type="text" id="phone" name="phone" class="form-control"
                               placeholder="Ví dụ: 0912345678" value="${profileUser.phone}">
                    </div>
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi</button>
                </form>
            </div>

            <c:if test="${profileUser.role == 'student'}">
                <div class="panel">
                    <h2>Lịch sử giao dịch ví</h2>
                    <c:choose>
                        <c:when test="${empty walletHistory}">
                            <div class="no-items">Chưa có giao dịch nào.</div>
                        </c:when>
                        <c:otherwise>
                            <table class="history-table">
                                <thead>
                                    <tr><th>Thời gian</th><th>Loại</th><th>Nội dung</th><th>Số tiền</th><th>Số dư sau GD</th></tr>
                                </thead>
                                <tbody>
                                <%
                                    @SuppressWarnings("unchecked")
                                    List<WalletTransaction> historyList = (List<WalletTransaction>) request.getAttribute("walletHistory");
                                    if (historyList != null) {
                                        for (WalletTransaction tx : historyList) {
                                            boolean isTopup = "topup".equals(tx.getType());
                                %>
                                    <tr>
                                        <td><%= tx.getCreatedAt() != null ? tx.getCreatedAt().format(dtf) : "" %></td>
                                        <td><%= isTopup ? "Nạp tiền" : "Thanh toán" %></td>
                                        <td><%= isTopup
                                                ? "Mã GD: " + (tx.getReferenceCode() == null || tx.getReferenceCode().isEmpty() ? "—" : tx.getReferenceCode())
                                                : "Khóa học: " + (tx.getCourseName() != null ? tx.getCourseName() : "") %></td>
                                        <td class="tx-amount <%= tx.getType() %>">
                                            <%= isTopup ? "+" : "-" %><%= String.format("%,.0f", tx.getAmount()) %>đ
                                        </td>
                                        <td><%= String.format("%,.0f", tx.getBalanceAfter()) %>đ</td>
                                    </tr>
                                <%
                                        }
                                    }
                                %>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>
        </div>
    </div>

</body>
</html>
