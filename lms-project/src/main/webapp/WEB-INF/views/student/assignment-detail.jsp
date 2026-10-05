<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết bài tập - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-assignments.css?v=1">
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">
<%
    String navBackUrl = "/student/assignments?courseId=" + ((com.lms.model.Assignment) request.getAttribute("assignment")).getCourseId();
    String navBackLabel = "← Danh sách bài tập";
%>
<%@ include file="/WEB-INF/views/partials/navbar.jspf" %>

<div class="asg-main">
    <div class="asg-title">📎 <c:out value="${assignment.title}"/></div>
    <div class="asg-subtitle">Khóa học: <b><c:out value="${assignment.courseTitle}"/></b></div>

    <c:if test="${not empty error}"><div class="asg-alert error"><i class="fa-solid fa-triangle-exclamation"></i> <c:out value="${error}"/></div></c:if>
    <c:if test="${not empty success}"><div class="asg-alert success"><i class="fa-solid fa-circle-check"></i> <c:out value="${success}"/></div></c:if>

    <div class="asg-card">
        <div class="asg-info-row">
            <span><i class="fa-regular fa-clock"></i> Hạn nộp:
                <b><c:choose><c:when test="${not empty assignment.dueAt}">${assignment.dueAtDisplay}</c:when><c:otherwise>Không giới hạn</c:otherwise></c:choose></b>
                <c:if test="${assignment.overdue}"><span class="asg-badge late">Đã hết hạn</span></c:if>
                <c:if test="${assignment.dueSoon}"><span class="asg-badge soon">Sắp đến hạn</span></c:if>
            </span>
        </div>

        <h3>Yêu cầu bài tập</h3>
        <c:choose>
            <c:when test="${not empty assignment.description}">
                <div class="asg-desc"><c:out value="${assignment.description}"/></div>
            </c:when>
            <c:otherwise>
                <div class="asg-desc empty">Giảng viên không ghi nội dung chi tiết.<c:if test="${assignment.hasAttachment}"> Xem file đề bài đính kèm bên dưới.</c:if></div>
            </c:otherwise>
        </c:choose>

        <c:if test="${assignment.hasAttachment}">
            <div class="asg-current-file" style="margin-top:18px;">
                <i class="fa-solid fa-paperclip"></i>
                <span>File đề bài: <b><c:out value="${assignment.attachName}"/></b> (${assignment.attachSizeDisplay})</span>
                <a class="asg-btn-ghost" style="padding:4px 12px;font-size:12px;"
                   href="${pageContext.request.contextPath}/student/assignments/download?id=${assignment.id}">
                    <i class="fa-solid fa-download"></i> Tải đề
                </a>
            </div>
        </c:if>
    </div>

    <div class="asg-card">
        <h3>Bài nộp của bạn</h3>

        <c:if test="${not empty mySubmission}">
            <div class="asg-current-file">
                <i class="fa-solid fa-file-circle-check" style="color:#38A169;"></i>
                <span><b><c:out value="${mySubmission.fileName}"/></b> (${mySubmission.fileSizeDisplay}) - nộp lúc ${mySubmission.submittedAtDisplay}</span>
                <a class="asg-btn-ghost" style="padding:4px 12px;font-size:12px;"
                   href="${pageContext.request.contextPath}/student/assignments/mysubmission/download?id=${mySubmission.id}">
                    <i class="fa-solid fa-download"></i> Tải lại
                </a>
            </div>
            <c:if test="${not empty mySubmission.note}">
                <div class="asg-hint" style="margin-bottom:14px;">Ghi chú của bạn: <c:out value="${mySubmission.note}"/></div>
            </c:if>
        </c:if>

        <c:choose>
            <c:when test="${assignment.overdue}">
                <div class="asg-alert error" style="margin-bottom:0;">
                    <i class="fa-solid fa-lock"></i> Đã quá hạn nộp bài - không thể nộp hoặc thay đổi bài nộp.
                </div>
            </c:when>
            <c:otherwise>
                <form action="${pageContext.request.contextPath}/student/assignments/submit" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="assignmentId" value="${assignment.id}">
                    <div class="asg-group">
                        <label for="file">${empty mySubmission ? 'Chọn file bài làm *' : 'Nộp lại bằng file khác (sẽ thay thế bài cũ)'}</label>
                        <input type="file" id="file" name="file" required
                               accept=".pdf,.doc,.docx,.txt,.rtf,.odt,.xls,.xlsx,.csv,.ppt,.pptx,.zip,.rar,.7z,.png,.jpg,.jpeg">
                        <div class="asg-hint">Chấp nhận: pdf, doc, docx, txt, rtf, odt, xls, xlsx, csv, ppt, pptx, zip, rar, 7z, png, jpg. Tối đa 10 MB.</div>
                    </div>
                    <div class="asg-group">
                        <label for="note">Ghi chú cho giảng viên (tùy chọn)</label>
                        <textarea id="note" name="note" style="min-height:80px;" maxlength="1000"></textarea>
                    </div>
                    <div class="asg-actions" style="margin-top:8px;">
                        <button type="submit" class="asg-btn"><i class="fa-solid fa-paper-plane"></i> ${empty mySubmission ? 'Nộp bài' : 'Nộp lại'}</button>
                    </div>
                </form>
            </c:otherwise>
        </c:choose>
    </div>
</div>

</body>
</html>
