<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bài tập - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-assignments.css?v=1">
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">
<%
    String navBackUrl = "/student/my-courses";
    String navBackLabel = "← Khóa học của tôi";
%>
<%@ include file="/WEB-INF/views/partials/navbar.jspf" %>

<div class="asg-main">
    <div class="asg-title">📎 Bài tập khóa học</div>
    <div class="asg-subtitle"><c:out value="${course.title}"/></div>

    <c:if test="${not empty error}"><div class="asg-alert error"><c:out value="${error}"/></div></c:if>

    <div class="asg-card">
        <c:choose>
            <c:when test="${not empty assignments}">
                <c:forEach var="a" items="${assignments}">
                    <div class="asg-item">
                        <div>
                            <div class="asg-item-title"><c:out value="${a.title}"/></div>
                            <div class="asg-item-meta">
                                <span><i class="fa-regular fa-clock"></i>
                                    <c:choose>
                                        <c:when test="${not empty a.dueAt}">Hạn nộp: ${a.dueAtDisplay}</c:when>
                                        <c:otherwise>Không giới hạn thời gian</c:otherwise>
                                    </c:choose>
                                </span>
                                <c:choose>
                                    <c:when test="${a.submittedByMe}"><span class="asg-badge ok"><i class="fa-solid fa-check"></i> Đã nộp ${a.mySubmittedAtDisplay}</span></c:when>
                                    <c:when test="${a.overdue}"><span class="asg-badge late">Quá hạn - chưa nộp</span></c:when>
                                    <c:when test="${a.dueSoon}"><span class="asg-badge soon"><i class="fa-solid fa-bell"></i> Sắp đến hạn</span></c:when>
                                    <c:otherwise><span class="asg-badge pending">Chưa nộp</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="asg-item-actions">
                            <a class="asg-btn-ghost" href="${pageContext.request.contextPath}/student/assignments/view?id=${a.id}">
                                <c:choose><c:when test="${a.submittedByMe}">Xem bài nộp</c:when><c:otherwise>Xem &amp; nộp bài</c:otherwise></c:choose>
                            </a>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="asg-empty">Giảng viên chưa giao bài tập nào.</div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

</body>
</html>
