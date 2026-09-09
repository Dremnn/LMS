<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin Quiz - LMS</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',Roboto,Arial,sans-serif;}
        body{background:#f0f4f8;color:#2d3748;}
        .navbar{background:#fff;box-shadow:0 2px 8px rgba(0,0,0,.07);padding:14px 36px;display:flex;justify-content:space-between;align-items:center;}
        .navbar .logo{font-size:20px;font-weight:800;color:#667eea;text-decoration:none;}
        .nav-links{display:flex;align-items:center;gap:12px;}
        .btn{padding:8px 18px;border-radius:8px;font-size:13px;font-weight:600;text-decoration:none;cursor:pointer;border:none;transition:all .2s;display:inline-block;}
        .btn-outline{border:1.5px solid #667eea;color:#667eea;background:transparent;}
        .btn-outline:hover{background:#667eea;color:#fff;}
        .btn-primary{background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;}
        .btn-danger{background:#fc8181;color:#742a2a;}
        .badge{display:inline-block;padding:2px 9px;border-radius:12px;font-size:11px;font-weight:700;background:#ebf8ff;color:#2b6cb0;text-transform:uppercase;margin-left:6px;}
        .main{max-width:680px;margin:60px auto;padding:0 24px;}
        .intro-card{background:#fff;border-radius:16px;box-shadow:0 8px 30px rgba(0,0,0,.08);overflow:hidden;}
        .intro-header{background:linear-gradient(135deg,#2d3748,#1a202c);color:#fff;padding:40px 36px 36px;text-align:center;}
        .intro-course{font-size:13px;color:#a0aec0;text-transform:uppercase;letter-spacing:1px;font-weight:700;margin-bottom:12px;}
        .intro-title{font-size:28px;font-weight:800;margin-bottom:20px;}
        .intro-body{padding:36px;}
        .info-grid{display:grid;grid-template-columns:repeat(2, 1fr);gap:24px;margin-bottom:32px;}
        .info-box{background:#f7f8ff;border:1px solid #e2e8f0;padding:20px;border-radius:12px;}
        .info-label{font-size:13px;color:#718096;font-weight:600;margin-bottom:6px;display:flex;align-items:center;gap:6px;}
        .info-value{font-size:20px;font-weight:800;color:#2d3748;}
        .info-value.highlight{color:#667eea;}
        .status-box{background:#fffff0;border:1px solid #f6e05e;padding:16px 20px;border-radius:12px;margin-bottom:32px;display:flex;align-items:center;gap:12px;}
        .status-icon{font-size:24px;}
        .status-text{font-size:14px;color:#744210;}
        .actions{display:flex;gap:16px;justify-content:center;}
        .btn-start{padding:14px 40px;background:linear-gradient(135deg,#68d391,#38a169);color:#fff;border:none;border-radius:10px;font-size:16px;font-weight:800;text-decoration:none;transition:transform .2s,box-shadow .2s;}
        .btn-start:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(56,161,105,.3);}
        .btn-start.disabled{background:#cbd5e0;color:#718096;pointer-events:none;box-shadow:none;}
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<% User currentUser = (User) session.getAttribute("currentUser");
   String role = currentUser != null ? currentUser.getRole() : ""; %>
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/" class="logo"><i class="fa-solid fa-graduation-cap"></i> EduViet LMS</a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/courses/detail?id=${course.id}" class="btn btn-outline">← Chi tiết khóa học</a>
        <% if (currentUser != null) { %>
            <span style="font-size:14px;color:#4a5568;font-weight:600;"><%=currentUser.getFullName()%><span class="badge"><%=role%></span></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">Đăng xuất</a>
        <% } %>
    </div>
</nav>

<div class="main">
    <div class="intro-card">
        <div class="intro-header">
            <div class="intro-course"><c:out value="${course.title}"/></div>
            <div class="intro-title">📝 <c:out value="${quiz.title}"/></div>
        </div>
        
        <div class="intro-body">
            <div class="info-grid">
                <div class="info-box">
                    <div class="info-label"><i class="fa-solid fa-bullseye"></i> Điểm đạt yêu cầu</div>
                    <div class="info-value highlight">${quiz.passScore} / 100</div>
                </div>
                <div class="info-box">
                    <div class="info-label">🔄 Số lần làm bài</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${quiz.maxAttempts != null}">
                                ${attemptsUsed} / ${quiz.maxAttempts}
                            </c:when>
                            <c:otherwise>
                                ${attemptsUsed} / Không giới hạn
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div class="info-box">
                    <div class="info-label">⏱️ Thời gian làm bài</div>
                    <div class="info-value">
                        <c:choose>
                            <c:when test="${quiz.timeLimitMinutes != null}">${quiz.timeLimitMinutes} phút</c:when>
                            <c:otherwise>Không giới hạn</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <c:if test="${quiz.openAt != null || quiz.closeAt != null}">
                    <div class="info-box">
                        <div class="info-label">🗓️ Thời gian mở/đóng</div>
                        <div class="info-value" style="font-size:15px;">
                            <c:if test="${quiz.openAt != null}">Mở: ${quiz.openAtFormatted}<br/></c:if>
                            <c:if test="${quiz.closeAt != null}">Đóng: ${quiz.closeAtFormatted}</c:if>
                        </div>
                    </div>
                </c:if>
            </div>

            <c:if test="${!quiz.openNow}">
                <div class="status-box" style="background:#fff5f5;border-color:#fc8181;">
                    <div class="status-icon">🚫</div>
                    <div class="status-text">
                        <c:choose>
                            <c:when test="${quiz.notYetOpen}">
                                <strong>Quiz chưa mở.</strong><br>Quiz sẽ mở lúc ${quiz.openAtFormatted}.
                            </c:when>
                            <c:otherwise>
                                <strong>Quiz đã đóng.</strong><br>Quiz đã đóng lúc ${quiz.closeAtFormatted}, không thể làm bài nữa.
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>

            <div class="status-box">
                <c:choose>
                    <c:when test="${attemptsUsed == 0}">
                        <div class="status-icon">🆕</div>
                        <div class="status-text">
                            <strong>Chưa làm bài.</strong><br>
                            Hãy sẵn sàng trước khi bắt đầu. Bạn phải đạt ít nhất ${quiz.passScore} điểm để qua bài kiểm tra này.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="status-icon"><i class="fa-solid fa-chart-line"></i></div>
                        <div class="status-text">
                            <strong>Đã làm bài (${attemptsUsed} lần).</strong><br>
                            Điểm cao nhất của bạn hiện tại là: <strong style="font-size:16px;">${highestScore != null ? highestScore : 0}</strong> / 100.
                            <c:if test="${highestScore >= quiz.passScore}">
                                <span style="color:#276749;font-weight:bold;"> (Đã Đạt <i class="fa-solid fa-circle-check"></i>)</span>
                            </c:if>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="actions">
                <c:choose>
                    <c:when test="${!quiz.openNow}">
                        <a href="#" class="btn-start disabled">🚫 Quiz không khả dụng lúc này</a>
                    </c:when>
                    <c:when test="${quiz.maxAttempts != null && attemptsUsed >= quiz.maxAttempts}">
                        <a href="#" class="btn-start disabled"><i class="fa-solid fa-xmark"></i> Đã hết lượt làm bài</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/student/quizzes/attempt?id=${quiz.id}${not empty param.lessonId ? '&lessonId=' : ''}${param.lessonId}" class="btn-start">
                            ${attemptsUsed == 0 ? '<i class="fa-solid fa-rocket"></i> Bắt đầu làm bài' : '🔄 Làm lại Quiz'}
                        </a>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${not empty param.lessonId}">
                        <a href="${pageContext.request.contextPath}/student/lessons/view?lessonId=${param.lessonId}" class="btn btn-outline" style="padding:14px 24px;font-size:15px;">Quay lại bài học</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/student/my-courses" class="btn btn-outline" style="padding:14px 24px;font-size:15px;">Quay lại khóa học</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>
</body>
</html>
