<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${quiz.title} - LMS</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',Roboto,Arial,sans-serif;}
        body{background:#f0f4f8;color:#2d3748;}
        .navbar{background:#fff;box-shadow:0 2px 8px rgba(0,0,0,.07);padding:14px 36px;display:flex;justify-content:space-between;align-items:center;position:sticky;top:0;z-index:100;}
        .navbar .logo{font-size:20px;font-weight:800;color:#667eea;text-decoration:none;}
        .nav-links{display:flex;align-items:center;gap:12px;}
        .btn{padding:8px 18px;border-radius:8px;font-size:13px;font-weight:600;text-decoration:none;cursor:pointer;border:none;transition:all .2s;display:inline-block;}
        .btn-outline{border:1.5px solid #667eea;color:#667eea;background:transparent;}
        .btn-outline:hover{background:#667eea;color:#fff;}
        .btn-danger{background:#fc8181;color:#742a2a;}
        .badge{display:inline-block;padding:2px 9px;border-radius:12px;font-size:11px;font-weight:700;background:#ebf8ff;color:#2b6cb0;text-transform:uppercase;margin-left:6px;}
        .hero{background:linear-gradient(135deg,#1a202c,#2d3748);color:#fff;padding:40px 36px 48px;}
        .hero-inner{max-width:780px;margin:0 auto;}
        .quiz-title{font-size:26px;font-weight:800;margin-bottom:10px;}
        .quiz-meta{display:flex;gap:24px;font-size:14px;opacity:.85;}
        .main{max-width:780px;margin:-16px auto 48px;padding:0 24px;}
        .alert-danger{background:#fed7d7;color:#822727;border:1px solid #fc8181;padding:12px 16px;border-radius:9px;font-size:14px;margin-bottom:20px;}
        .question-card{background:#fff;border-radius:14px;box-shadow:0 4px 14px rgba(0,0,0,.07);margin-bottom:20px;overflow:hidden;}
        .question-header{padding:18px 24px 14px;border-bottom:1px solid #f0f4f8;}
        .question-num{font-size:11px;font-weight:700;color:#a0aec0;text-transform:uppercase;margin-bottom:6px;}
        .question-content{font-size:16px;font-weight:600;color:#1a202c;line-height:1.55;}
        .question-type-badge{display:inline-block;margin-top:8px;padding:2px 10px;border-radius:20px;font-size:11px;font-weight:700;background:#ebf8ff;color:#2b6cb0;}
        .options-list{padding:16px 24px;display:flex;flex-direction:column;gap:10px;}
        .option-label{display:flex;align-items:center;gap:12px;padding:11px 16px;border:1.5px solid #e2e8f0;border-radius:9px;cursor:pointer;transition:all .15s;font-size:14px;color:#2d3748;}
        .option-label:hover{border-color:#667eea;background:#f7f8ff;}
        .option-label input[type=radio]{accent-color:#667eea;width:16px;height:16px;flex-shrink:0;}
        .option-label input[type=checkbox]{accent-color:#667eea;width:16px;height:16px;flex-shrink:0;}
        .submit-bar{background:#fff;border-top:1px solid #e2e8f0;padding:20px 24px;display:flex;align-items:center;justify-content:space-between;border-radius:14px;box-shadow:0 4px 14px rgba(0,0,0,.07);margin-top:8px;}
        .submit-bar-info{font-size:14px;color:#718096;}
        .btn-submit{padding:13px 36px;background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;border:none;border-radius:10px;font-size:16px;font-weight:700;cursor:pointer;transition:opacity .2s;}
        .btn-submit:hover{opacity:.9;}
    </style>
</head>
<body>
<% User currentUser = (User) session.getAttribute("currentUser");
   String role = currentUser != null ? currentUser.getRole() : ""; %>
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/" class="logo">🎓 LMS System</a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/student/my-courses" class="btn btn-outline">← Khóa học của tôi</a>
        <% if (currentUser != null) { %>
            <span style="font-size:14px;color:#4a5568;font-weight:600;"><%=currentUser.getFullName()%><span class="badge"><%=role%></span></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">Đăng xuất</a>
        <% } %>
    </div>
</nav>

<div class="hero">
    <div class="hero-inner">
        <div class="quiz-title">📝 <c:out value="${quiz.title}"/></div>
        <div class="quiz-meta">
            <span>🎯 Điểm đạt yêu cầu: <strong>${quiz.passScore}/100</strong></span>
            <span>
                🔄 Số lần làm:
                <c:choose>
                    <c:when test="${quiz.maxAttempts != null}"><strong>${quiz.maxAttempts}</strong></c:when>
                    <c:otherwise><strong>Không giới hạn</strong></c:otherwise>
                </c:choose>
            </span>
            <span>📊 Số câu hỏi: <strong>${questions.size()}</strong></span>
        </div>
    </div>
</div>

<div class="main">
    <c:if test="${not empty error}">
        <div class="alert-danger">⚠️ <c:out value="${error}"/></div>
    </c:if>

    <form action="${pageContext.request.contextPath}/student/quizzes/submit" method="post"
          onsubmit="return confirm('Bạn chắc chắn muốn nộp bài? Sau khi nộp sẽ không thể thay đổi.')">
        <input type="hidden" name="quizId" value="${quiz.id}" />
        <c:if test="${not empty param.lessonId}">
            <input type="hidden" name="lessonId" value="${param.lessonId}" />
        </c:if>

        <c:forEach var="question" items="${questions}" varStatus="status">
            <div class="question-card">
                <div class="question-header">
                    <div class="question-num">Câu ${status.index + 1} / ${questions.size()}</div>
                    <div class="question-content"><c:out value="${question.content}"/></div>
                    <span class="question-type-badge">
                        <c:choose>
                            <c:when test="${question.questionType == 'single_choice'}">Chọn 1 đáp án</c:when>
                            <c:otherwise>Chọn nhiều đáp án</c:otherwise>
                        </c:choose>
                    </span>
                </div>
                <div class="options-list">
                    <c:forEach var="option" items="${question.options}">
                        <label class="option-label">
                            <c:choose>
                                <c:when test="${question.questionType == 'single_choice'}">
                                    <input type="radio" name="answer_${question.id}" value="${option.id}" />
                                </c:when>
                                <c:otherwise>
                                    <input type="checkbox" name="answer_${question.id}" value="${option.id}" />
                                </c:otherwise>
                            </c:choose>
                            <c:out value="${option.content}"/>
                        </label>
                    </c:forEach>
                </div>
            </div>
        </c:forEach>

        <div class="submit-bar">
            <div class="submit-bar-info">
                📋 Tổng <strong>${questions.size()}</strong> câu hỏi · Điểm đạt: <strong>${quiz.passScore}/100</strong>
            </div>
            <button type="submit" class="btn-submit">🚀 Nộp bài</button>
        </div>
    </form>
</div>
</body>
</html>
