<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đăng nhập — EduViet LMS</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=3">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=3">
</head>
<body style="margin:0;padding:0;">
<div class="auth-wrapper">

  <!-- ── Left: Brand Panel ─────────────────────────────── -->
  <div class="auth-brand">
    <div class="auth-brand-inner">
      <span class="auth-brand-logo">🎓</span>
      <h1 class="auth-brand-title">Chào mừng trở lại!</h1>
      <p class="auth-brand-desc">
        Đăng nhập để tiếp tục hành trình học tập cùng hàng nghìn sinh viên Việt Nam đang phát triển mỗi ngày.
      </p>
      <div class="auth-features">
        <div class="auth-feature">
          <div class="auth-feature-icon">📚</div>
          <span>Truy cập 500+ bài học chất lượng cao</span>
        </div>
        <div class="auth-feature">
          <div class="auth-feature-icon">📊</div>
          <span>Theo dõi tiến độ học tập realtime</span>
        </div>
        <div class="auth-feature">
          <div class="auth-feature-icon">🏆</div>
          <span>Nhận chứng chỉ khi hoàn thành khoá</span>
        </div>
        <div class="auth-feature">
          <div class="auth-feature-icon">🎯</div>
          <span>Lộ trình học được cá nhân hoá</span>
        </div>
      </div>
    </div>
  </div>

  <!-- ── Right: Form ────────────────────────────────────── -->
  <div class="auth-form-side">
    <div class="auth-form-box">
      <a href="${pageContext.request.contextPath}/"
         style="color:var(--text-muted);font-size:13px;text-decoration:none;display:inline-flex;align-items:center;gap:4px;margin-bottom:24px;">
        ← Về trang chủ
      </a>

      <h2 class="auth-form-title">Đăng nhập</h2>
      <p class="auth-form-sub">Nhập thông tin tài khoản của bạn</p>

      <c:if test="${not empty error}">
        <div class="alert alert-danger">⚠️ <span>${error}</span></div>
      </c:if>
      <c:if test="${not empty successMessage}">
        <div class="alert alert-success">✅ <span>${successMessage}</span></div>
      </c:if>

      <form action="${pageContext.request.contextPath}/login" method="post">
        <div class="form-group">
          <label class="form-label" for="email">Địa chỉ Email</label>
          <input type="email" id="email" name="email" class="form-control"
                 placeholder="name@example.com"
                 value="<c:out value='${email}' default=''/>" required autofocus>
        </div>
        <div class="form-group">
          <label class="form-label" for="password">Mật khẩu</label>
          <input type="password" id="password" name="password" class="form-control"
                 placeholder="Nhập mật khẩu của bạn" required>
        </div>
        <button type="submit" class="btn btn-primary btn-lg" style="width:100%;margin-top:4px;">
          Đăng nhập →
        </button>
      </form>

      <div class="auth-form-footer">
        <div>Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký ngay</a></div>
      </div>
    </div>
  </div>

</div>
<script src="${pageContext.request.contextPath}/assets/js/lms-app.js"></script>
</body>
</html>
