<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đăng nhập — UTEdu LMS</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
</head>
<body class="${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}" style="margin:0;padding:0;">
<div class="auth-wrapper">

  <!-- Left: Brand Panel -->
  <div class="auth-brand">
    <div class="auth-brand-inner">
      <span class="auth-brand-logo"><i class="fa-solid fa-graduation-cap"></i></span>
      <h1 class="auth-brand-title">Chào mừng trở lại!</h1>
      <p class="auth-brand-desc">
        Đăng nhập để tiếp tục hành trình học tập cùng hàng nghìn sinh viên Việt Nam đang phát triển mỗi ngày.
      </p>
      <div class="auth-features">
        <div class="auth-feature">
          <div class="auth-feature-icon"><i class="fa-solid fa-book-open"></i></div>
          <span>Truy cập 500+ bài học chất lượng cao</span>
        </div>
        <div class="auth-feature">
          <div class="auth-feature-icon"><i class="fa-solid fa-chart-line"></i></div>
          <span>Theo dõi tiến độ học tập realtime</span>
        </div>
        <div class="auth-feature">
          <div class="auth-feature-icon"><i class="fa-solid fa-certificate"></i></div>
          <span>Nhận chứng chỉ khi hoàn thành khoá</span>
        </div>
        <div class="auth-feature">
          <div class="auth-feature-icon"><i class="fa-solid fa-bullseye"></i></div>
          <span>Lộ trình học được cá nhân hoá</span>
        </div>
      </div>
    </div>
  </div>

  <!-- Right: Form -->
  <div class="auth-form-side">
    <div class="auth-form-box">
      <a href="${pageContext.request.contextPath}/"
         style="color:var(--text-muted);font-size:13px;text-decoration:none;display:inline-flex;align-items:center;gap:4px;margin-bottom:24px;">
        <i class="fa-solid fa-arrow-left"></i> Về trang chủ
      </a>

      <h2 class="auth-form-title">Đăng nhập</h2>
      <p class="auth-form-sub">Nhập thông tin tài khoản của bạn</p>

      <c:if test="${not empty error}">
        <div class="alert alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> <span>${error}</span></div>
      </c:if>
      <c:if test="${not empty successMessage}">
        <div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> <span>${successMessage}</span></div>
      </c:if>

      <form action="${pageContext.request.contextPath}/login" method="post">
        <div class="form-group">
          <label class="form-label" for="email">Địa chỉ Email</label>
          <input type="email" id="email" name="email" class="form-control"
                 placeholder="name@example.com"
                 value="<c:out value='${not empty email ? email : rememberEmail}' default=''/>" required autofocus>
        </div>
        <div class="form-group" style="margin-bottom:12px;">
          <label class="form-label" for="password">Mật khẩu</label>
          <input type="password" id="password" name="password" class="form-control"
                 placeholder="Nhập mật khẩu của bạn" required>
        </div>

        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:16px;">
          <label style="display:inline-flex;align-items:center;gap:8px;cursor:pointer;font-size:13.5px;color:#475569;user-select:none;">
            <input type="checkbox" name="rememberMe" value="true" ${rememberMeChecked ? 'checked' : ''}
                   style="width:16px;height:16px;accent-color:#076FA4;cursor:pointer;border-radius:4px;">
            <span>Ghi nhớ đăng nhập</span>
          </label>
        </div>

        <button type="submit" class="btn btn-primary btn-lg" style="width:100%;margin-top:4px;">
          Đăng nhập <i class="fa-solid fa-arrow-right"></i>
        </button>
      </form>

      <div class="auth-form-footer">
        <div>Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký ngay</a></div>
      </div>
    </div>
  </div>

</div>

<!-- Dynamic Island Theme Toggle -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=30"></script>

    <jsp:include page="/WEB-INF/views/components/drawer.jsp" />
</body>
</html>

