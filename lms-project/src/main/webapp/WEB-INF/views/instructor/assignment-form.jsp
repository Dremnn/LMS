<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${editMode ? 'Sửa bài tập' : 'Tạo bài tập'} - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=30">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-assignments.css?v=1">
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">
<%
    String navBackUrl = "/instructor/courses/manage?id=" + ((com.lms.model.Course) request.getAttribute("course")).getId();
    String navBackLabel = "Quay lại khóa học";
%>
<%@ include file="/WEB-INF/views/partials/navbar.jspf" %>

<div class="asg-main">
    <div class="asg-title">${editMode ? 'Sửa bài tập' : 'Tạo bài tập mới'}</div>
    <div class="asg-subtitle">Khóa học: <b><c:out value="${course.title}"/></b></div>

    <div class="asg-card">
        <c:if test="${not empty error}">
            <div class="asg-alert error"><i class="fa-solid fa-triangle-exclamation"></i> <c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/instructor/assignments/${editMode ? 'edit' : 'new'}"
              method="post" enctype="multipart/form-data">
            <c:choose>
                <c:when test="${editMode}"><input type="hidden" name="assignmentId" value="${assignment.id}"></c:when>
                <c:otherwise><input type="hidden" name="courseId" value="${course.id}"></c:otherwise>
            </c:choose>

            <div class="asg-group">
                <label for="title">Tiêu đề bài tập *</label>
                <input type="text" id="title" name="title" maxlength="200" required
                       placeholder="VD: Bài tập tuần 1 - Cấu trúc dữ liệu"
                       value="<c:out value='${formTitle}'/>">
            </div>

            <div class="asg-group">
                <label for="description">Nội dung / yêu cầu bài tập</label>
                <textarea id="description" name="description"
                          placeholder="Viết chi tiết yêu cầu bài tập... (có thể để trống nếu đã đính kèm file đề)"><c:out value="${formDescription}"/></textarea>
                <div class="asg-hint">💡 Phần này là tùy chọn - bạn có thể để trống, chỉ đính kèm file hoặc chỉ viết nội dung.</div>
            </div>

            <div class="asg-group">
                <label for="file">File đề bài đính kèm</label>
                <c:if test="${editMode && assignment.hasAttachment}">
                    <div class="asg-current-file">
                        <i class="fa-solid fa-paperclip"></i>
                        <span>File hiện tại: <b><c:out value="${assignment.attachName}"/></b> (${assignment.attachSizeDisplay})</span>
                        <a class="asg-btn-ghost" style="padding:4px 12px;font-size:12px;"
                           href="${pageContext.request.contextPath}/instructor/assignments/download?id=${assignment.id}">
                            <i class="fa-solid fa-download"></i> Tải
                        </a>
                    </div>
                </c:if>
                <input type="file" id="file" name="file"
                       accept=".pdf,.doc,.docx,.txt,.rtf,.odt,.xls,.xlsx,.csv,.ppt,.pptx,.zip,.rar,.7z,.png,.jpg,.jpeg">
                <div class="asg-hint">
                    💡 Tùy chọn. Tối đa 10 MB.
                    <c:if test="${editMode && assignment.hasAttachment}">Chọn file mới để thay thế file hiện tại.</c:if>
                </div>
                <c:if test="${editMode && assignment.hasAttachment}">
                    <label class="asg-check"><input type="checkbox" name="removeAttachment" value="1"> Xóa file đính kèm hiện tại</label>
                </c:if>
            </div>

            <div class="asg-group">
                <label for="dueAt">Hạn nộp bài (ngày và giờ)</label>
                <input type="datetime-local" id="dueAt" name="dueAt" value="<c:out value='${formDueAt}'/>">
                <div class="asg-hint">💡 Để trống nếu không đặt hạn. Học viên sẽ nhận thông báo trên web trước hạn 24 giờ và không thể nộp sau hạn.</div>
            </div>

            <div class="asg-actions">
                <button type="submit" class="asg-btn">
                    <i class="fa-solid fa-floppy-disk"></i> ${editMode ? 'Lưu thay đổi' : 'Tạo bài tập'}
                </button>
                <a class="asg-btn-ghost" href="${pageContext.request.contextPath}/instructor/courses/manage?id=${course.id}">Hủy</a>
            </div>
        </form>
    </div>
</div>

</body>
</html>
