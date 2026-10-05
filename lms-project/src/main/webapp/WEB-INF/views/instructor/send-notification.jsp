<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User, com.lms.model.Course, java.util.List" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gửi thông báo - UTEdu LMS Giảng viên</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/lms-design.css?v=38">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/lms-animations.css?v=38">
    <style>
        .page-header { background: linear-gradient(135deg, #093C62, #076FA4); color: #fff; padding: 24px 28px; border-radius: 16px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 4px 20px rgba(9, 60, 98, .15); }
        .page-title { font-size: 22px; font-weight: 700; margin: 0; display: flex; align-items: center; gap: 12px; }
        .main { max-width: 860px; margin: 36px auto; padding: 0 24px; }
        .card { background: #fff; border-radius: 16px; padding: 32px; box-shadow: 0 4px 20px rgba(0, 0, 0, .06); border: 1px solid var(--border, #E2E8F0); }
        .form-group { margin-bottom: 24px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #093C62; font-size: 14px; }
        .form-control { width: 100%; padding: 12px 16px; border: 1px solid #C6D8E3; border-radius: 10px; font-size: 14px; color: #1E293B; background: #fff; transition: all 0.2s; box-sizing: border-box; }
        .form-control:focus { outline: none; border-color: #076FA4; box-shadow: 0 0 0 3px rgba(7, 111, 164, 0.15); }
        .btn { display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 12px 28px; border-radius: 10px; font-size: 14px; font-weight: 600; text-align: center; cursor: pointer; transition: all 0.2s; border: none; }
        .btn-primary { background: linear-gradient(135deg, #076FA4, #093C62); color: #fff; box-shadow: 0 2px 8px rgba(7, 111, 164, 0.25); }
        .btn-primary:hover { box-shadow: 0 4px 16px rgba(7, 111, 164, 0.4); transform: translateY(-1px); }
        .btn-back { background: rgba(255, 255, 255, 0.2); color: #fff; text-decoration: none; padding: 10px 18px; border-radius: 10px; font-size: 13px; font-weight: 600; transition: background 0.2s; display: inline-flex; align-items: center; gap: 6px; }
        .btn-back:hover { background: rgba(255, 255, 255, 0.3); color: #fff; }
        .alert { padding: 14px 18px; border-radius: 10px; font-size: 14px; margin-bottom: 24px; font-weight: 500; display: flex; align-items: center; gap: 10px; }
        .alert-success { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
        .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

        /* Dark Theme Support Chuẩn UTEdu */
        body.dark-theme .page-header { background: linear-gradient(135deg, #182535, #093C62); }
        body.dark-theme .card { background: #182535; border-color: #093C62; box-shadow: 0 4px 20px rgba(0,0,0,.4); }
        body.dark-theme .form-group label { color: #9DB9CB; }
        body.dark-theme .form-control { background: #111312; border-color: #093C62; color: #F4F8FA; }
        body.dark-theme .form-control:focus { border-color: #076FA4; }
        body.dark-theme .btn-primary { background: linear-gradient(135deg, #076FA4, #093C62); }
    </style>
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">

    <!-- NAVBAR CHUẨN UTEDU LMS -->
    <nav class="lms-navbar">
        <div class="nav-left">
            <a href="${pageContext.request.contextPath}/" class="lms-logo">
                <img src="${pageContext.request.contextPath}/assets/images/utedu-logo.png" alt="UTEdu" class="lms-logo-img" style="height: 36px !important; width: auto; max-height: 36px;">
                <span class="logo-tag">LMS</span>
            </a>
            <% if (currentUser != null) { %>
            <div class="quick-actions">
                <a href="${pageContext.request.contextPath}/chat" class="quick-action-btn" title="Tin nhắn">
                    <i class="fa-solid fa-comment-dots"></i><span class="quick-action-text">Tin nhắn</span>
                </a>
                <a href="${pageContext.request.contextPath}/notifications" class="quick-action-btn" title="Thông báo">
                    <i class="fa-solid fa-bell"></i><span class="quick-action-text">Thông báo</span>
                </a>
            </div>
            <% } %>
        </div>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/courses" class="nav-link">Khóa học</a>
            <% if (currentUser != null) { %>
                <% if ("student".equals(role)) { %>
                    <a href="${pageContext.request.contextPath}/dashboard" class="nav-link">Bảng điều khiển</a>
                <% } %>
                <div class="user-badge">
                    <div class="user-avatar"><%=currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName().substring(0,1).toUpperCase() : "U"%></div>
                    <span><%=currentUser.getFullName()%></span>
                    <span class="role-tag"><%=role%></span>
                </div>
                <% if ("instructor".equals(role)) { %>
                    <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-outline" style="border-color:#076FA4; color:#076FA4;">Quản lý khóa học</a>
                <% } else if ("admin".equals(role)) { %>
                    <a href="${pageContext.request.contextPath}/admin" class="btn btn-outline">Quản trị</a>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/student/my-courses" class="btn btn-outline">Của tôi</a>
                <% } %>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger" style="margin-left: 8px;">Đăng xuất</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/login" class="btn btn-outline">Đăng nhập</a>
                <a href="${pageContext.request.contextPath}/register" class="btn btn-primary">Đăng ký</a>
            <% } %>
        </div>
    </nav>

    <div class="main slide-up">
        <div class="page-header">
            <div>
                <h1 class="page-title"><i class="fas fa-bullhorn"></i> Gửi thông báo đến học viên</h1>
                <p style="margin:6px 0 0 0;font-size:13px;opacity:0.9;">Gửi thông báo nhanh đến các học viên tham gia khóa học của bạn</p>
            </div>
            <a href="${pageContext.request.contextPath}/instructor/courses" class="btn-back">
                <i class="fas fa-arrow-left"></i> Quay lại
            </a>
        </div>

        <div class="card">
            <!-- Thông báo Lỗi nếu có -->
            <c:if test="${not empty error}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle" style="font-size: 18px;"></i>
                    <span>${error}</span>
                </div>
            </c:if>

            <!-- Thông báo Thành công nếu có -->
            <c:if test="${not empty success}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle" style="font-size: 18px;"></i>
                    <span>${success}</span>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/instructor/notifications/send" method="post">
                <div class="form-group">
                    <label for="target"><i class="fas fa-users mr-1"></i> Đối tượng nhận thông báo</label>
                    <select name="target" id="target" class="form-control">
                        <option value="my_students">Tất cả học viên đang học các khóa của tôi</option>
                        <c:if test="${not empty instructorCourses}">
                            <optgroup label="Gửi theo từng khóa học cụ thể:">
                                <c:forEach var="c" items="${instructorCourses}">
                                    <option value="course_${c.id}">Khóa học: ${c.title}</option>
                                </c:forEach>
                            </optgroup>
                        </c:if>
                        <c:if test="${sessionScope.currentUser.role == 'admin'}">
                            <option value="all_students">Toàn bộ học viên trong hệ thống (Quyền Admin)</option>
                        </c:if>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="title"><i class="fas fa-heading mr-1"></i> Tiêu đề thông báo <span style="color: #ef4444;">*</span></label>
                    <input type="text" name="title" id="title" class="form-control" value="${title}" required placeholder="Ví dụ: Cập nhật tài liệu buổi 5, Nhắc nộp bài tập...">
                </div>
                
                <div class="form-group">
                    <label for="message"><i class="fas fa-align-left mr-1"></i> Nội dung chi tiết <span style="color: #ef4444;">*</span></label>
                    <textarea name="message" id="message" rows="6" class="form-control" required placeholder="Nhập chi tiết nội dung thông báo gửi đến học viên...">${message}</textarea>
                </div>
                
                <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 28px;">
                    <a href="${pageContext.request.contextPath}/instructor/courses" class="btn" style="background:#e2e8f0; color:#475569; text-decoration:none;">
                        Hủy
                    </a>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-paper-plane"></i> Gửi thông báo ngay
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Dynamic Island Theme Toggle -->
    <div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
        <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
        <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
        <span class="toggle-text">Chế độ Tối</span>
    </div>

    <script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=38"></script>
</body>
</html>
