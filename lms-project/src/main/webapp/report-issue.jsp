<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";
    String userEmail = currentUser != null && currentUser.getEmail() != null ? currentUser.getEmail() : "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Báo lỗi & Sự cố — UTEdu LMS</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=50">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=36">

  <style>
    .report-main-content {
      min-height: calc(100vh - 160px);
      padding: 40px 20px 60px;
      display: flex;
      justify-content: center;
      align-items: flex-start;
    }

    .report-card-wrapper {
      max-width: 820px;
      width: 100%;
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: var(--radius-lg, 24px);
      padding: 44px 48px;
      box-shadow: 0 12px 40px rgba(9, 60, 98, 0.08);
      position: relative;
      transition: background var(--t-smooth), border-color var(--t-smooth), box-shadow var(--t-smooth);
    }

    .form-header {
      margin-bottom: 36px;
      text-align: center;
    }

    .header-badge {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 6px 16px;
      background: rgba(7, 111, 164, 0.1);
      border: 1px solid rgba(7, 111, 164, 0.2);
      border-radius: 50px;
      font-size: 13px;
      font-weight: 700;
      color: var(--primary);
      margin-bottom: 14px;
    }

    .form-header h1 {
      font-size: 34px;
      font-weight: 800;
      color: var(--text);
      margin-bottom: 10px;
      letter-spacing: -0.5px;
    }

    .form-header p {
      color: var(--text-muted);
      font-size: 15px;
      max-width: 580px;
      margin: 0 auto;
    }

    .form-group {
      margin-bottom: 22px;
    }

    .form-label {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 8px;
      font-weight: 600;
      color: var(--text);
      font-size: 14px;
    }

    .form-label .required {
      color: var(--danger);
      font-weight: 700;
    }

    .form-label i {
      color: var(--primary);
      font-size: 14px;
    }

    .optional-tag {
      color: var(--text-muted);
      font-weight: 500;
      font-size: 12px;
      margin-left: 4px;
    }

    .form-control {
      width: 100%;
      padding: 13px 18px;
      border: 1.5px solid var(--border);
      border-radius: var(--radius-sm, 10px);
      font-size: 15px;
      font-family: inherit;
      transition: all var(--t-fast);
      background: var(--surface);
      color: var(--text);
    }

    .form-control:focus {
      border-color: var(--primary);
      outline: none;
      box-shadow: 0 0 0 4px rgba(7, 111, 164, 0.15);
    }

    .form-control.error {
      border-color: var(--danger);
      box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.15);
    }

    .form-control::placeholder {
      color: #9DB9CB;
    }

    textarea.form-control {
      resize: vertical;
      min-height: 130px;
      line-height: 1.65;
    }

    /* Role Selection Grid */
    .role-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;
    }

    .role-option {
      display: none;
    }

    .role-label {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 10px;
      padding: 18px 14px;
      border: 1.5px solid var(--border);
      border-radius: var(--radius-sm, 12px);
      cursor: pointer;
      transition: all var(--t-smooth);
      text-align: center;
      background: var(--surface);
    }

    .role-label:hover {
      border-color: var(--primary);
      background: rgba(7, 111, 164, 0.04);
      transform: translateY(-2px);
    }

    .role-option:checked + .role-label {
      border-color: var(--primary);
      background: rgba(7, 111, 164, 0.08);
      box-shadow: 0 0 0 3px rgba(7, 111, 164, 0.18);
    }

    .role-emoji {
      font-size: 30px;
    }

    .role-name {
      font-size: 15px;
      font-weight: 700;
      color: var(--text);
    }

    .role-hint {
      font-size: 12px;
      color: var(--text-muted);
    }

    /* Type Selection Chips */
    .type-grid {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }

    .type-option {
      display: none;
    }

    .type-chip {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 9px 18px;
      border: 1.5px solid var(--border);
      border-radius: 50px;
      cursor: pointer;
      font-size: 13px;
      font-weight: 600;
      color: var(--text-muted);
      transition: all var(--t-smooth);
      background: var(--surface);
      white-space: nowrap;
    }

    .type-chip:hover {
      border-color: var(--primary);
      color: var(--primary);
      background: rgba(7, 111, 164, 0.04);
    }

    .type-option:checked + .type-chip {
      border-color: var(--primary);
      background: var(--primary);
      color: #FFFFFF;
      box-shadow: 0 4px 12px rgba(7, 111, 164, 0.25);
    }

    /* Drag & Drop Upload */
    .upload-zone {
      border: 2px dashed var(--border);
      border-radius: var(--radius-sm, 14px);
      padding: 32px 20px;
      text-align: center;
      cursor: pointer;
      transition: all var(--t-smooth);
      background: rgba(198, 216, 227, 0.12);
      position: relative;
    }

    .upload-zone:hover, .upload-zone.dragover {
      border-color: var(--primary);
      background: rgba(7, 111, 164, 0.06);
    }

    .upload-zone input[type="file"] {
      position: absolute;
      inset: 0;
      opacity: 0;
      cursor: pointer;
      width: 100%;
      height: 100%;
    }

    .upload-icon {
      font-size: 36px;
      color: var(--primary);
      margin-bottom: 10px;
      display: block;
    }

    .upload-title {
      font-weight: 700;
      color: var(--text);
      margin-bottom: 4px;
      font-size: 15px;
    }

    .upload-hint {
      font-size: 13px;
      color: var(--text-muted);
    }

    .upload-hint span {
      color: var(--primary);
      font-weight: 600;
    }

    #preview-grid {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      margin-top: 16px;
    }

    .preview-item {
      position: relative;
      width: 96px;
      height: 96px;
      border-radius: 10px;
      overflow: hidden;
      border: 2px solid var(--border);
      animation: fadeIn 0.3s ease;
    }

    .preview-item img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .preview-remove {
      position: absolute;
      top: 4px;
      right: 4px;
      width: 24px;
      height: 24px;
      background: rgba(0, 0, 0, 0.65);
      color: white;
      border: none;
      border-radius: 50%;
      cursor: pointer;
      font-size: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: background var(--t-fast);
    }

    .preview-remove:hover {
      background: var(--danger);
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: scale(0.85); }
      to { opacity: 1; transform: scale(1); }
    }

    .char-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 6px;
    }

    .char-hint, .char-count {
      font-size: 12px;
      color: var(--text-muted);
    }

    .char-count.near { color: var(--warning); font-weight: 600; }
    .char-count.exceed { color: var(--danger); font-weight: 700; }

    .field-error {
      display: none;
      font-size: 12px;
      color: var(--danger);
      margin-top: 6px;
      align-items: center;
      gap: 6px;
      font-weight: 500;
    }

    .field-error.show {
      display: flex;
    }

    .form-divider {
      border: none;
      border-top: 1px solid var(--border);
      margin: 28px 0;
    }

    .submit-row {
      display: flex;
      align-items: center;
      gap: 16px;
      margin-top: 32px;
    }

    .btn-submit {
      flex: 1;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 10px;
      padding: 14px 28px;
      border-radius: var(--radius-sm, 10px);
      font-weight: 700;
      font-size: 15px;
      cursor: pointer;
      border: none;
      font-family: inherit;
      background: linear-gradient(135deg, var(--primary), var(--secondary));
      color: #FFFFFF;
      box-shadow: 0 4px 16px rgba(7, 111, 164, 0.3);
      transition: all var(--t-smooth);
    }

    .btn-submit:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 24px rgba(7, 111, 164, 0.4);
    }

    .btn-submit:active {
      transform: scale(0.98);
    }

    .btn-submit:disabled {
      opacity: 0.65;
      cursor: not-allowed;
      transform: none;
      box-shadow: none;
    }

    .btn-reset {
      padding: 14px 22px;
      border: 1.5px solid var(--border);
      border-radius: var(--radius-sm, 10px);
      font-weight: 600;
      font-size: 14px;
      cursor: pointer;
      font-family: inherit;
      background: transparent;
      color: var(--text-muted);
      transition: all var(--t-smooth);
    }

    .btn-reset:hover {
      border-color: var(--danger);
      color: var(--danger);
    }

    .spinner {
      display: none;
      width: 18px;
      height: 18px;
      border: 2.5px solid rgba(255, 255, 255, 0.35);
      border-top-color: white;
      border-radius: 50%;
      animation: spin 0.7s linear infinite;
    }

    @keyframes spin {
      to { transform: rotate(360deg); }
    }

    /* Success Panel */
    #success-panel {
      display: none;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      text-align: center;
      padding: 40px 20px;
    }

    .success-circle {
      width: 88px;
      height: 88px;
      background: linear-gradient(135deg, var(--success), #059669);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 40px;
      color: white;
      margin: 0 auto 24px;
      box-shadow: 0 12px 36px rgba(16, 185, 129, 0.35);
      animation: popIn 0.5s cubic-bezier(0.22, 1, 0.36, 1);
    }

    @keyframes popIn {
      from { opacity: 0; transform: scale(0.4); }
      to { opacity: 1; transform: scale(1); }
    }

    .success-title {
      font-size: 26px;
      font-weight: 800;
      margin-bottom: 12px;
      color: var(--text);
    }

    .success-desc {
      color: var(--text-muted);
      font-size: 15px;
      max-width: 460px;
      margin: 0 auto 32px;
    }

    .success-ref {
      background: rgba(7, 111, 164, 0.08);
      border: 1px solid rgba(7, 111, 164, 0.25);
      border-radius: var(--radius-sm, 10px);
      padding: 16px 28px;
      font-size: 14px;
      color: var(--primary);
      margin-bottom: 32px;
      display: inline-block;
    }

    .success-ref strong {
      font-size: 20px;
      letter-spacing: 1px;
      display: block;
      margin-top: 6px;
      color: var(--primary-dark);
    }

    .btn-back-home {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 13px 28px;
      border-radius: var(--radius-sm, 10px);
      background: linear-gradient(135deg, var(--primary), var(--secondary));
      color: white;
      font-weight: 700;
      font-size: 15px;
      text-decoration: none;
      box-shadow: 0 4px 16px rgba(7, 111, 164, 0.3);
      transition: all var(--t-smooth);
    }

    .btn-back-home:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 24px rgba(7, 111, 164, 0.4);
    }

    /* Dark Mode Overrides */
    body.dark-theme .report-card-wrapper {
      background: #182535 !important;
      border-color: #273e57 !important;
      box-shadow: 0 16px 48px rgba(0, 0, 0, 0.4) !important;
    }

    body.dark-theme .form-header h1 {
      color: #FFFFFF !important;
    }

    body.dark-theme .form-header p {
      color: #9DB9CB !important;
    }

    body.dark-theme .header-badge {
      background: rgba(56, 189, 248, 0.15) !important;
      border-color: rgba(56, 189, 248, 0.3) !important;
      color: #38BDF8 !important;
    }

    body.dark-theme .form-label {
      color: #F1F5F9 !important;
    }

    body.dark-theme .form-control {
      background: #101824 !important;
      border-color: #273e57 !important;
      color: #F8FAFC !important;
    }

    body.dark-theme .form-control:focus {
      border-color: #38BDF8 !important;
      box-shadow: 0 0 0 3px rgba(56, 189, 248, 0.25) !important;
    }

    body.dark-theme .form-control::placeholder {
      color: #64748B !important;
    }

    body.dark-theme .role-label {
      background: #101824 !important;
      border-color: #273e57 !important;
    }

    body.dark-theme .role-name {
      color: #F1F5F9 !important;
    }

    body.dark-theme .role-hint {
      color: #94A3B8 !important;
    }

    body.dark-theme .role-label:hover {
      border-color: #38BDF8 !important;
      background: rgba(7, 111, 164, 0.15) !important;
    }

    body.dark-theme .role-option:checked + .role-label {
      background: rgba(7, 111, 164, 0.25) !important;
      border-color: #38BDF8 !important;
      box-shadow: 0 0 0 3px rgba(56, 189, 248, 0.2) !important;
    }

    body.dark-theme .type-chip {
      background: #101824 !important;
      border-color: #273e57 !important;
      color: #94A3B8 !important;
    }

    body.dark-theme .type-chip:hover {
      border-color: #38BDF8 !important;
      color: #38BDF8 !important;
    }

    body.dark-theme .type-option:checked + .type-chip {
      background: #076FA4 !important;
      border-color: #38BDF8 !important;
      color: #FFFFFF !important;
    }

    body.dark-theme .upload-zone {
      background: #101824 !important;
      border-color: #273e57 !important;
    }

    body.dark-theme .upload-zone:hover,
    body.dark-theme .upload-zone.dragover {
      border-color: #38BDF8 !important;
      background: rgba(7, 111, 164, 0.12) !important;
    }

    body.dark-theme .upload-title {
      color: #F1F5F9 !important;
    }

    body.dark-theme .upload-hint {
      color: #94A3B8 !important;
    }

    body.dark-theme .form-divider {
      border-top-color: rgba(148, 163, 184, 0.15) !important;
    }

    body.dark-theme .btn-reset {
      border-color: #273e57 !important;
      color: #94A3B8 !important;
    }

    body.dark-theme .btn-reset:hover {
      border-color: var(--danger) !important;
      color: var(--danger) !important;
    }

    body.dark-theme .success-title {
      color: #FFFFFF !important;
    }

    body.dark-theme .success-desc {
      color: #9DB9CB !important;
    }

    body.dark-theme .success-ref {
      background: rgba(7, 111, 164, 0.2) !important;
      border-color: rgba(56, 189, 248, 0.3) !important;
      color: #38BDF8 !important;
    }

    body.dark-theme .success-ref strong {
      color: #38BDF8 !important;
    }

    @media (max-width: 860px) {
      .report-card-wrapper { padding: 32px 24px; }
      .form-header h1 { font-size: 28px; }
    }

    @media (max-width: 480px) {
      .role-grid { grid-template-columns: 1fr; }
      .submit-row { flex-direction: column; }
      .btn-reset { width: 100%; }
    }
  </style>
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">

<!-- NAVBAR ĐỒNG BỘ CHUẨN LMS -->
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
    <% if (currentUser != null) { %>

      <%@ include file="/WEB-INF/views/partials/user-dropdown-style.jspf" %>
                  <a href="<%= "student".equals(role) ? (request.getContextPath() + "/wallet/topup") : (request.getContextPath() + "/profile") %>" class="wallet-badge" title="Số dư ví - Bấm để nạp tiền/quản lý ví">
                <i class="fa-solid fa-wallet"></i>
                <span><%= (currentUser.getBalance() != null ? String.format(java.util.Locale.US, "%,dđ", currentUser.getBalance().longValue()) : "0đ") %></span>
            </a>
      <div class="user-dropdown">
        <div class="user-badge">
          <% if (currentUser.getAvatarUrl() != null && !currentUser.getAvatarUrl().trim().isEmpty()) { %>
            <img src="<%=currentUser.getAvatarUrl()%>" alt="Avatar" class="user-avatar" style="object-fit: cover;">
          <% } else { %>
            <div class="user-avatar"><%=currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName().substring(0,1).toUpperCase() : "U"%></div>
          <% } %>
          <span><%=currentUser.getFullName()%></span>
          <span class="role-tag"><%=role%></span>
          <i class="fa-solid fa-chevron-down user-dropdown-chevron"></i>
        </div>
        <div class="user-dropdown-menu" style="display: none;">
                    <a href="<%= "student".equals(role) ? (request.getContextPath() + "/wallet/topup") : (request.getContextPath() + "/profile") %>" class="user-dropdown-item wallet-dropdown-item">
                        <i class="fa-solid fa-wallet"></i>
                        <span>Ví cá nhân</span>
                        <strong class="wallet-dropdown-balance"><%= (currentUser.getBalance() != null ? String.format(java.util.Locale.US, "%,dđ", currentUser.getBalance().longValue()) : "0đ") %></strong>
                    </a>
                    <% if ("student".equals(role)) { %>
                        <a href="<%=request.getContextPath()%>/dashboard" class="user-dropdown-item">
                            <i class="fa-solid fa-table-columns"></i> Bảng điều khiển
                        </a>
                        <a href="<%=request.getContextPath()%>/student/my-courses" class="user-dropdown-item">
                            <i class="fa-solid fa-book-open"></i> Khóa học của tôi
                        </a>
                    <% } %>
          <a href="<%=request.getContextPath()%>/courses" class="user-dropdown-item">
            <i class="fa-solid fa-graduation-cap"></i> Khóa học
          </a>
          <a href="<%=request.getContextPath()%>/profile" class="user-dropdown-item">
            <i class="fa-solid fa-id-badge"></i> Hồ sơ
          </a>
          <% if (!"admin".equals(role)) { %>
            <a href="<%=request.getContextPath()%>/report-issue.jsp" class="user-dropdown-item">
              <i class="fa-solid fa-triangle-exclamation"></i> Báo cáo
            </a>
          <% } %>
        </div>
      </div>
      <% if ("instructor".equals(role)) { %>
        <a href="<%=request.getContextPath()%>/instructor/courses" class="btn btn-outline">Quản lý</a>
      <% } else if ("admin".equals(role)) { %>
        <a href="<%=request.getContextPath()%>/admin" class="btn btn-outline">Quản trị</a>
        <a href="<%=request.getContextPath()%>/admin/issues" class="btn btn-outline" style="border-color:#076FA4;background:rgba(7,111,164,.1);"><i class="fa-solid fa-triangle-exclamation"></i> Xử lý sự cố</a>
      <% } %>
      <a href="<%=request.getContextPath()%>/logout" class="btn btn-danger">Đăng xuất</a>
    <% } else { %>
      <a href="<%=request.getContextPath()%>/courses" class="nav-link">Khóa học</a>
      <a href="<%=request.getContextPath()%>/report-issue.jsp" class="nav-link active">Báo cáo</a>
      <a href="<%=request.getContextPath()%>/login" class="btn btn-outline">Đăng nhập</a>
      <a href="<%=request.getContextPath()%>/register" class="btn btn-primary">Đăng ký</a>
    <% } %>
  </div>
</nav>

<!-- MAIN FORM CONTENT -->
<main class="report-main-content">
  <div class="report-card-wrapper" id="form-section">
    <div class="form-header">
      <div class="header-badge">
        <i class="fa-solid fa-headset"></i> Trung tâm hỗ trợ kỹ thuật
      </div>
      <h1>Báo cáo sự cố hệ thống</h1>
      <p>Dành cho <strong>học viên</strong> và <strong>giảng viên</strong>. Vui lòng cung cấp chi tiết thông tin sự cố để đội ngũ kỹ thuật UTEdu LMS kiểm tra và xử lý kịp thời.</p>
    </div>

    <form id="report-form" novalidate>

      <!-- Email -->
      <div class="form-group">
        <label class="form-label" for="email">
          <i class="fa-solid fa-envelope"></i> Địa chỉ email của bạn <span class="required">*</span>
        </label>
        <input type="email" class="form-control" id="email" value="<%= userEmail %>" placeholder="ví dụ: yourname@example.com" autocomplete="email">
        <div class="field-error" id="email-err">
          <i class="fa-solid fa-circle-exclamation"></i><span>Vui lòng nhập địa chỉ email hợp lệ để nhận phản hồi</span>
        </div>
      </div>

      <!-- Role -->
      <div class="form-group">
        <label class="form-label">
          <i class="fa-solid fa-user-tag"></i> Vai trò của bạn <span class="required">*</span>
        </label>
        <div class="role-grid">
          <div>
            <input type="radio" name="role" id="role-student" value="student" class="role-option" <%= ("student".equalsIgnoreCase(role) || role.isEmpty()) ? "checked" : "" %>>
            <label class="role-label" for="role-student">
              <span class="role-emoji">🎓</span>
              <span class="role-name">Sinh viên / Học viên</span>
              <span class="role-hint">Đang theo học các khóa học</span>
            </label>
          </div>
          <div>
            <input type="radio" name="role" id="role-instructor" value="instructor" class="role-option" <%= "instructor".equalsIgnoreCase(role) ? "checked" : "" %>>
            <label class="role-label" for="role-instructor">
              <span class="role-emoji">👨‍🏫</span>
              <span class="role-name">Giảng viên</span>
              <span class="role-hint">Đang giảng dạy và quản lý lớp</span>
            </label>
          </div>
        </div>
        <div class="field-error" id="role-err">
          <i class="fa-solid fa-circle-exclamation"></i><span>Vui lòng chọn vai trò hiện tại của bạn</span>
        </div>
      </div>

      <hr class="form-divider">

      <!-- Issue Type -->
      <div class="form-group">
        <label class="form-label">
          <i class="fa-solid fa-tags"></i> Phân loại sự cố <span class="required">*</span>
        </label>
        <div class="type-grid">
          <div><input type="radio" name="issue_type" id="type-notification" value="notification" class="type-option"><label class="type-chip" for="type-notification"><i class="fa-solid fa-bell"></i> Thông báo</label></div>
          <div><input type="radio" name="issue_type" id="type-quiz" value="quiz" class="type-option"><label class="type-chip" for="type-quiz"><i class="fa-solid fa-circle-question"></i> Bài kiểm tra / Quiz</label></div>
          <div><input type="radio" name="issue_type" id="type-lesson" value="lesson" class="type-option"><label class="type-chip" for="type-lesson"><i class="fa-solid fa-play-circle"></i> Bài học / Video</label></div>
          <div><input type="radio" name="issue_type" id="type-payment" value="payment" class="type-option"><label class="type-chip" for="type-payment"><i class="fa-solid fa-wallet"></i> Thanh toán / Ví</label></div>
          <div><input type="radio" name="issue_type" id="type-account" value="account" class="type-option"><label class="type-chip" for="type-account"><i class="fa-solid fa-user-circle"></i> Tài khoản & Bảo mật</label></div>
          <div><input type="radio" name="issue_type" id="type-course" value="course" class="type-option"><label class="type-chip" for="type-course"><i class="fa-solid fa-book"></i> Nội dung khóa học</label></div>
          <div><input type="radio" name="issue_type" id="type-ui" value="ui" class="type-option"><label class="type-chip" for="type-ui"><i class="fa-solid fa-desktop"></i> Giao diện / Hiển thị</label></div>
          <div><input type="radio" name="issue_type" id="type-other" value="other" class="type-option"><label class="type-chip" for="type-other"><i class="fa-solid fa-ellipsis"></i> Sự cố khác</label></div>
        </div>
        <div class="field-error" id="type-err">
          <i class="fa-solid fa-circle-exclamation"></i><span>Vui lòng chọn loại sự cố đang gặp phải</span>
        </div>
      </div>

      <!-- Description -->
      <div class="form-group">
        <label class="form-label" for="description">
          <i class="fa-solid fa-pen-to-square"></i> Mô tả chi tiết sự cố <span class="required">*</span>
        </label>
        <textarea class="form-control" id="description" maxlength="2000"
          placeholder="Mô tả cụ thể sự cố bạn gặp: xảy ra ở chức năng nào, các thao tác dẫn đến lỗi, thông báo lỗi hiển thị (nếu có)..."></textarea>
        <div class="char-row">
          <span class="char-hint">Tối thiểu 10 ký tự</span>
          <span class="char-count" id="char-count">0 / 2000</span>
        </div>
        <div class="field-error" id="desc-err">
          <i class="fa-solid fa-circle-exclamation"></i><span id="desc-err-msg">Vui lòng mô tả sự cố (ít nhất 10 ký tự)</span>
        </div>
      </div>

      <!-- URL (optional) -->
      <div class="form-group">
        <label class="form-label" for="page-url">
          <i class="fa-solid fa-link"></i> Đường dẫn trang xảy ra lỗi <span class="optional-tag">(không bắt buộc)</span>
        </label>
        <input type="url" class="form-control" id="page-url" placeholder="ví dụ: http://localhost:8080/lms-project/student/lesson-view?id=...">
      </div>

      <hr class="form-divider">

      <!-- Screenshot upload -->
      <div class="form-group">
        <label class="form-label">
          <i class="fa-solid fa-image"></i> Ảnh chụp màn hình minh họa <span class="optional-tag">(tối đa 3 ảnh, mỗi ảnh ≤ 5 MB)</span>
        </label>
        <div class="upload-zone" id="upload-zone">
          <input type="file" id="screenshot-input" accept="image/*" multiple>
          <i class="fa-solid fa-cloud-arrow-up upload-icon"></i>
          <p class="upload-title">Kéo & thả ảnh chụp màn hình vào đây</p>
          <p class="upload-hint">hoặc <span>nhấn vào đây để tải ảnh từ máy tính</span> (hỗ trợ PNG, JPG, WEBP)</p>
        </div>
        <div id="preview-grid"></div>
        <div class="field-error" id="img-err">
          <i class="fa-solid fa-circle-exclamation"></i><span id="img-err-msg">Chỉ chấp nhận tối đa 3 ảnh, mỗi ảnh ≤ 5 MB</span>
        </div>
      </div>

      <!-- Submit buttons -->
      <div class="submit-row">
        <button type="submit" class="btn-submit" id="submit-btn">
          <span id="btn-text"><i class="fa-solid fa-paper-plane"></i> Gửi báo cáo sự cố</span>
          <span class="spinner" id="btn-spinner"></span>
        </button>
        <button type="button" class="btn-reset" id="reset-btn">
          <i class="fa-solid fa-rotate-left"></i> Làm mới biểu mẫu
        </button>
      </div>

    </form>
  </div>

  <!-- Success Panel (Hiện khi gửi thành công) -->
  <div class="report-card-wrapper" id="success-panel">
    <div class="success-circle"><i class="fa-solid fa-check"></i></div>
    <h2 class="success-title">Báo cáo đã được gửi thành công!</h2>
    <p class="success-desc">
      Hệ thống đã tiếp nhận sự cố của bạn. Đội ngũ quản trị viên UTEdu LMS sẽ kiểm tra và phản hồi qua email của bạn trong thời gian sớm nhất.
    </p>
    <div class="success-ref">
      Mã tham chiếu theo dõi sự cố của bạn:
      <strong id="ref-code">—</strong>
    </div>
    <div style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">
      <a href="<%=request.getContextPath()%>/" class="btn-back-home">
        <i class="fa-solid fa-house"></i> Về trang chủ
      </a>
      <a href="<%=request.getContextPath()%>/report-issue.jsp" class="btn btn-outline" style="border-radius: 10px; padding: 13px 24px; font-weight: 600;">
        <i class="fa-solid fa-plus"></i> Gửi thêm báo cáo khác
      </a>
    </div>
  </div>
</main>

<!-- FOOTER ĐỒNG BỘ CHUẨN LMS -->
<footer class="lms-footer modern-footer">
  <div class="container">
    <div class="footer-grid" style="align-items: flex-start;">
      <div class="footer-col brand-col">
        <a href="<%=request.getContextPath()%>/" class="lms-logo footer-logo" style="margin-bottom: 16px;">
          <span class="logo-icon">🎓</span><span class="logo-text">UTEdu LMS</span>
        </a>
        <p class="footer-desc">Nền tảng học trực tuyến thế hệ mới. Nâng tầm tri thức, kiến tạo tương lai thế hệ trẻ.</p>
        <div class="social-links">
          <a href="https://www.youtube.com/@MixiGaming3con" target="_blank" rel="noopener noreferrer" class="social-icon" title="Facebook" aria-label="Facebook"><i class="fa-brands fa-facebook-f"></i></a>
          <a href="https://www.youtube.com/@MixiGaming3con" target="_blank" rel="noopener noreferrer" class="social-icon" title="YouTube" aria-label="YouTube"><i class="fa-brands fa-youtube"></i></a>
          <a href="https://www.youtube.com/@MixiGaming3con" target="_blank" rel="noopener noreferrer" class="social-icon" title="TikTok" aria-label="TikTok"><i class="fa-brands fa-tiktok"></i></a>
          <a href="https://www.youtube.com/@MixiGaming3con" target="_blank" rel="noopener noreferrer" class="social-icon" title="LinkedIn" aria-label="LinkedIn"><i class="fa-brands fa-linkedin-in"></i></a>
        </div>
      </div>

      <div class="footer-col">
        <h4 class="footer-title">Khám phá</h4>
        <ul class="footer-links">
          <li><a href="<%=request.getContextPath()%>/courses?sortBy=popular">Khoá học nổi bật</a></li>
          <li><a href="<%=request.getContextPath()%>/instructors">Giảng viên tiêu biểu</a></li>
          <li><a href="<%=request.getContextPath()%>/learning-paths">Lộ trình học tập</a></li>
          <li><a href="<%=request.getContextPath()%>/resources">Thư viện tài liệu</a></li>
        </ul>
      </div>

      <div class="footer-col">
        <h4 class="footer-title">Hỗ trợ & Trợ giúp</h4>
        <ul class="footer-links">
          <li><a href="<%=request.getContextPath()%>/report-issue.jsp">Báo cáo sự cố</a></li>
          <li><a href="<%=request.getContextPath()%>/courses">Tất cả khóa học</a></li>
          <li><a href="<%=request.getContextPath()%>/login">Đăng nhập tài khoản</a></li>
          <li><a href="<%=request.getContextPath()%>/register">Đăng ký thành viên</a></li>
        </ul>
      </div>

      <div class="footer-col">
        <h4 class="footer-title">Liên hệ</h4>
        <ul class="footer-contact">
          <li><i class="fa-solid fa-location-dot"></i> Tầng 15, Tòa nhà công nghệ, Thành phố Hồ Chí Minh</li>
          <li><i class="fa-solid fa-phone"></i> 1900 1036</li>
          <li><i class="fa-solid fa-envelope"></i> hotro@utedu.vn</li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      <p>&copy; 2026 UTEdu LMS. Đã đăng ký bản quyền.</p>
      <div class="footer-bottom-links">
        <a href="#">Bảo mật</a>
        <a href="#">Điều khoản sử dụng</a>
      </div>
    </div>
  </div>
</footer>

<!-- DYNAMIC ISLAND THEME TOGGLE (LƯU VÀO COOKIE 365 NGÀY) -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
  <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
  <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
  <span class="toggle-text">Chế độ Tối</span>
</div>

<!-- SCRIPTS -->
<script src="<%=request.getContextPath()%>/assets/js/lms-app.js"></script>
<script>
  const $ = id => document.getElementById(id);
  const showErr = (id, show) => {
    const el = $(id);
    if (el) el.classList.toggle('show', show);
  };

  const desc = $('description');
  const counter = $('char-count');
  if (desc && counter) {
    desc.addEventListener('input', () => {
      const len = desc.value.length;
      counter.textContent = len + ' / 2000';
      counter.className = 'char-count' + (len >= 1900 ? ' exceed' : len >= 1600 ? ' near' : '');
    });
  }

  const uploadZone  = $('upload-zone');
  const fileInput   = $('screenshot-input');
  const previewGrid = $('preview-grid');
  let attachedFiles = [];
  let attachedDataUrls = [];

  if (uploadZone && fileInput) {
    uploadZone.addEventListener('dragover', e => { e.preventDefault(); uploadZone.classList.add('dragover'); });
    uploadZone.addEventListener('dragleave', () => uploadZone.classList.remove('dragover'));
    uploadZone.addEventListener('drop', e => {
      e.preventDefault();
      uploadZone.classList.remove('dragover');
      handleFiles(Array.from(e.dataTransfer.files));
    });
    fileInput.addEventListener('change', () => handleFiles(Array.from(fileInput.files)));
  }

  function handleFiles(files) {
    showErr('img-err', false);
    const imgs = files.filter(f => f.type.startsWith('image/'));
    if (imgs.some(f => f.size > 5 * 1024 * 1024)) {
      $('img-err-msg').textContent = 'Mỗi ảnh không được vượt quá 5 MB.';
      showErr('img-err', true);
      return;
    }
    if (attachedFiles.length + imgs.length > 3) {
      $('img-err-msg').textContent = 'Chỉ được đính kèm tối đa 3 ảnh chụp màn hình.';
      showErr('img-err', true);
      return;
    }
    imgs.forEach(f => {
      attachedFiles.push(f);
      const reader = new FileReader();
      reader.onload = e => {
        const dataUrl = e.target.result;
        const idx = attachedDataUrls.push(dataUrl) - 1;
        addPreview(dataUrl, idx);
      };
      reader.readAsDataURL(f);
    });
    fileInput.value = '';
  }

  function addPreview(src, idx) {
    const item = document.createElement('div');
    item.className = 'preview-item';
    item.dataset.idx = idx;
    item.innerHTML = `<img src="${src}" alt="preview"><button type="button" class="preview-remove" title="Xóa ảnh"><i class="fa-solid fa-xmark"></i></button>`;
    item.querySelector('.preview-remove').addEventListener('click', () => {
      const targetIdx = Number(item.dataset.idx);
      attachedFiles.splice(targetIdx, 1);
      attachedDataUrls.splice(targetIdx, 1);
      item.remove();
      Array.from(previewGrid.children).forEach((el, i) => el.dataset.idx = i);
      showErr('img-err', false);
    });
    previewGrid.appendChild(item);
  }

  function validate() {
    let ok = true;
    const emailVal = $('email').value.trim();
    const emailOk  = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailVal);
    $('email').classList.toggle('error', !emailOk);
    showErr('email-err', !emailOk);
    if (!emailOk) ok = false;

    const roleOk = document.querySelector('input[name="role"]:checked');
    showErr('role-err', !roleOk);
    if (!roleOk) ok = false;

    const typeOk = document.querySelector('input[name="issue_type"]:checked');
    showErr('type-err', !typeOk);
    if (!typeOk) ok = false;

    const descVal = desc.value.trim();
    const descOk  = descVal.length >= 10;
    desc.classList.toggle('error', !descOk);
    if (!descOk) {
      $('desc-err-msg').textContent = descVal.length === 0
        ? 'Vui lòng mô tả chi tiết sự cố bạn gặp phải'
        : 'Cần thêm ít nhất ' + (10 - descVal.length) + ' ký tự nữa';
    }
    showErr('desc-err', !descOk);
    if (!descOk) ok = false;

    return ok;
  }

  $('email').addEventListener('input', () => {
    $('email').classList.remove('error');
    showErr('email-err', false);
  });
  desc.addEventListener('input', () => {
    desc.classList.remove('error');
    showErr('desc-err', false);
  });

  $('report-form').addEventListener('submit', async e => {
    e.preventDefault();
    if (!validate()) return;

    const btn = $('submit-btn');
    const btnText = $('btn-text');
    const spinner = $('btn-spinner');

    btn.disabled = true;
    btnText.style.display = 'none';
    spinner.style.display = 'block';

    const payload = {
      email: $('email').value.trim(),
      role: document.querySelector('input[name="role"]:checked').value,
      issue_type: document.querySelector('input[name="issue_type"]:checked').value,
      description: $('description').value.trim(),
      page_url: $('page-url').value.trim() || '',
      screenshots: attachedDataUrls.length > 0 ? JSON.stringify(attachedDataUrls) : ''
    };

    try {
      const response = await fetch('<%=request.getContextPath()%>/api/report-issue', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(payload)
      });

      const data = await response.json();

      if (response.ok && data.success) {
        $('ref-code').textContent = data.referenceCode;
        $('form-section').style.display = 'none';
        const sp = $('success-panel');
        sp.style.display = 'flex';
        window.scrollTo({ top: 0, behavior: 'smooth' });
      } else {
        alert(data.message || 'Không thể gửi báo cáo. Vui lòng thử lại!');
        btn.disabled = false;
        btnText.style.display = 'inline-flex';
        spinner.style.display = 'none';
      }
    } catch (err) {
      console.error(err);
      alert('Đã xảy ra lỗi khi kết nối tới máy chủ. Vui lòng thử lại!');
      btn.disabled = false;
      btnText.style.display = 'inline-flex';
      spinner.style.display = 'none';
    }
  });

  $('reset-btn').addEventListener('click', () => {
    $('report-form').reset();
    attachedFiles = [];
    attachedDataUrls = [];
    previewGrid.innerHTML = '';
    counter.textContent = '0 / 2000';
    counter.className = 'char-count';
    document.querySelectorAll('.form-control.error').forEach(el => el.classList.remove('error'));
    document.querySelectorAll('.field-error.show').forEach(el => el.classList.remove('show'));
    $('email').focus();
  });
</script>
</body>
</html>
