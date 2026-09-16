<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="com.lms.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nạp tiền vào ví - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css?v=30">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/lms-design.css?v=26">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/lms-animations.css?v=26">
    <style>
        body { margin: 0; padding: 0; min-height: 100vh; }
        .topup-container { max-width: 720px; margin: 24px auto 40px; padding: 0 24px; }
        .panel { background: var(--surface); border-radius: 14px; padding: 24px; margin-bottom: 24px; box-shadow: 0 4px 16px rgba(9,60,98,.06); border: 1px solid var(--border); }
        .panel h2 { margin-top: 0; color: var(--text); font-weight: 800; }

        .topup-grid { display: grid; grid-template-columns: 240px 1fr; gap: 28px; }
        @media (max-width: 640px) { .topup-grid { grid-template-columns: 1fr; } }

        .qr-box {
            border: 2px dashed var(--border); border-radius: 12px; padding: 16px; text-align: center;
            display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 10px; min-height: 240px;
        }
        .qr-box img { max-width: 100%; border-radius: 8px; }
        .qr-box .placeholder { color: var(--text-muted); font-size: 13px; }
        .qr-box i { font-size: 48px; color: var(--border); }

        .amount-presets { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 16px; }
        .amount-presets button {
            padding: 8px 16px; border-radius: 8px; border: 1.5px solid var(--border); background: var(--bg);
            color: var(--text); font-weight: 600; cursor: pointer; transition: all .15s;
        }
        .amount-presets button:hover, .amount-presets button.active { border-color: var(--primary); color: var(--primary); background: var(--primary-light, #E2EEF5); }

        .bank-info { background: var(--bg); border-radius: 10px; padding: 14px 16px; font-size: 14px; margin-top: 14px; }
        .bank-info div { padding: 3px 0; }
        .bank-info b { color: var(--text); }
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
                <% if ("student".equals(role)) { %>
                    <a href="${pageContext.request.contextPath}/student/dashboard" class="nav-link">Bảng điều khiển</a>
                    <a href="${pageContext.request.contextPath}/student/my-courses" class="nav-link">Khóa học của tôi</a>
                <% } %>
                <a href="${pageContext.request.contextPath}/profile" class="nav-link">Hồ sơ</a>
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
                    <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-outline">Quản lý</a>
                <% } else if ("admin".equals(role)) { %>
                    <a href="${pageContext.request.contextPath}/admin" class="btn btn-outline">Quản trị</a>
                <% } %>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">Đăng xuất</a>
            <% } %>
        </div>
    </nav>

    <div class="topup-container">
        <a href="${pageContext.request.contextPath}/profile" style="color: var(--primary); text-decoration: none; font-weight: 600; display: inline-block; margin: 20px 0 0;">
            <i class="fa-solid fa-arrow-left"></i> Quay lại hồ sơ
        </a>

        <c:if test="${not empty error}">
            <div class="alert alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> <span>${error}</span></div>
        </c:if>

        <div class="panel">
            <h2><i class="fa-solid fa-wallet"></i> Nạp tiền vào ví</h2>
            <p style="color: var(--text-muted); font-size: 14px;">
                Số dư hiện tại: <b style="color: var(--text);"><fmt:formatNumber value="${currentUser.balance}" type="number" groupingUsed="true"/>đ</b>
            </p>

            <div class="topup-grid">
                <!-- QR code - ảnh thật sẽ được thay thế sau -->
                <div class="qr-box">
                    <img src="${pageContext.request.contextPath}/assets/images/qr-code.png" alt="QR chuyển khoản"
                        onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                    <div class="placeholder" style="display:none; flex-direction: column; align-items: center; gap: 10px;">
                        <i class="fa-solid fa-qrcode"></i>
                        <span>QR code sẽ được cập nhật sau<br></span>
                    </div>
                    <div class="bank-info">
                        <div><b>Ngân hàng:</b> Vietcombank</div>
                        <div><b>Số tài khoản:</b> 1234567890</div>
                        <div><b>Chủ TK:</b> UTEdu LMS</div>
                        <div><b>Nội dung CK:</b> NAPTIEN <%=currentUser != null ? currentUser.getId() : ""%></div>
                    </div>
                </div>

                <!-- Form nhập số tiền + xác nhận -->
                <form action="${pageContext.request.contextPath}/wallet/topup" method="post" id="topupForm">
                    <div class="form-group">
                        <label class="form-label">Chọn nhanh số tiền</label>
                        <div class="amount-presets">
                            <button type="button" onclick="setAmount(50000)">50,000đ</button>
                            <button type="button" onclick="setAmount(100000)">100,000đ</button>
                            <button type="button" onclick="setAmount(200000)">200,000đ</button>
                            <button type="button" onclick="setAmount(500000)">500,000đ</button>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="amount" class="form-label">Số tiền nạp (VNĐ)</label>
                        <input type="number" id="amount" name="amount" class="form-control"
                               min="10000" step="1000" placeholder="Tối thiểu 10,000đ" required>
                    </div>
                    <div class="form-group">
                        <label for="referenceCode" class="form-label">Mã giao dịch chuyển khoản (nếu có)</label>
                        <input type="text" id="referenceCode" name="referenceCode" class="form-control"
                               placeholder="Ví dụ: FT23091412345">
                    </div>
                    <p style="font-size: 13px; color: var(--text-muted);">
                        <i class="fa-solid fa-circle-info"></i>
                        Sau khi quét mã QR và chuyển khoản đúng nội dung, bấm nút bên dưới để xác nhận.
                        (Bản demo: số dư được cộng ngay, chưa xác thực tự động với ngân hàng.)
                    </p>
                    <button type="submit" class="btn btn-primary" style="width: 100%; padding: 14px;">
                        <i class="fa-solid fa-check"></i> Tôi đã chuyển khoản
                    </button>
                </form>
            </div>
        </div>
    </div>

    <script>
        function setAmount(value) {
            document.getElementById('amount').value = value;
            document.querySelectorAll('.amount-presets button').forEach(function (btn) {
                btn.classList.remove('active');
            });
            event.target.classList.add('active');
        }
    </script>

</body>
</html>
