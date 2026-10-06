<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bài nộp - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-assignments.css?v=1">
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">
<%
    String navBackUrl = "/instructor/courses/manage?id=" + ((com.lms.model.Course) request.getAttribute("course")).getId();
    String navBackLabel = "← Quay lại khóa học";
%>
<%@ include file="/WEB-INF/views/partials/navbar.jspf" %>

<div class="asg-main wide">
    <div class="asg-title">📥 Bài nộp: <c:out value="${assignment.title}"/></div>
    <div class="asg-subtitle">Khóa học: <b><c:out value="${course.title}"/></b></div>

    <div class="asg-card">
        <div class="asg-info-row">
            <span><i class="fa-regular fa-clock"></i> Hạn nộp:
                <b><c:choose><c:when test="${not empty assignment.dueAt}">${assignment.dueAtDisplay}</c:when><c:otherwise>Không giới hạn</c:otherwise></c:choose></b>
                <c:if test="${assignment.overdue}"><span class="asg-badge late">Đã hết hạn</span></c:if>
            </span>
            <c:if test="${assignment.hasAttachment}">
                <span><i class="fa-solid fa-paperclip"></i>
                    <a href="${pageContext.request.contextPath}/instructor/assignments/download?id=${assignment.id}">
                        <c:out value="${assignment.attachName}"/>
                    </a>
                </span>
            </c:if>
        </div>

        <div class="asg-stat">
            <div><div class="num">${submissions.size()}</div><div class="lbl">Học viên đã nộp</div></div>
            <div><div class="num">${enrolledCount}</div><div class="lbl">Tổng học viên trong khóa</div></div>
            <div><div class="num">${enrolledCount - submissions.size() < 0 ? 0 : enrolledCount - submissions.size()}</div><div class="lbl">Chưa nộp</div></div>
        </div>

        <c:choose>
            <c:when test="${not empty submissions}">
                <div class="asg-table-wrap">
                    <table class="asg-table">
                        <thead>
                            <tr><th>#</th><th>Học viên</th><th>File nộp</th><th>Thời gian nộp</th><th>Ghi chú</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="s" items="${submissions}" varStatus="st">
                                <tr>
                                    <td>${st.index + 1}</td>
                                    <td>
                                        <b><c:out value="${s.studentName}"/></b>
                                        <div class="sub"><c:out value="${s.studentEmail}"/></div>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/instructor/assignments/submissions/download?id=${s.id}">
                                            <i class="fa-solid fa-download"></i> <c:out value="${s.fileName}"/>
                                        </a>
                                        <div class="sub">${s.fileSizeDisplay}</div>
                                    </td>
                                    <td>
                                        ${s.submittedAtDisplay}
                                        <c:if test="${s.late}"><br><span class="asg-badge late">Nộp trễ</span></c:if>
                                    </td>
                                    <td><c:out value="${s.note}"/></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <div class="asg-empty">Chưa có học viên nào nộp bài.</div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

</body>
</html>
