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
    <style>
        .radio-group{display:flex;flex-direction:column;gap:10px;margin-top:6px;}
        .radio-option{display:flex;align-items:flex-start;gap:10px;padding:12px 14px;border:1.5px solid #C6D8E3;border-radius:8px;cursor:pointer;transition:border-color .2s;background:#fff;}
        .radio-option:hover{border-color:#076FA4;}
        .radio-option input[type=radio]{margin-top:2px;accent-color:#076FA4;flex-shrink:0;}
        .radio-option-label{font-size:14px;font-weight:600;color:#093C62;}
        .radio-option-sub{font-size:13px;color:#5C7688;margin-top:3px;}
        #sectionIdWrap{margin-top:10px;padding:12px 14px;background:#F0F6FA;border-radius:8px;border:1px solid #C6D8E3;}
        #sectionIdWrap label{font-size:13px;font-weight:600;color:#093C62;margin-bottom:6px;display:block;}
        #sectionIdWrap select{width:100%;padding:10px 14px;border:1.5px solid #C6D8E3;border-radius:8px;font-size:14px;outline:none;color:#093C62;background:#fff;}
        #sectionIdWrap select:focus{border-color:#076FA4;}

        body.dark-theme .radio-option{background:#182535;border-color:#093C62;}
        body.dark-theme .radio-option:hover{border-color:#076FA4;}
        body.dark-theme .radio-option-label{color:#F4F8FA;}
        body.dark-theme .radio-option-sub{color:#9DB9CB;}
        body.dark-theme #sectionIdWrap{background:#111312;border-color:#093C62;}
        body.dark-theme #sectionIdWrap label{color:#F4F8FA;}
        body.dark-theme #sectionIdWrap select{background:#182535;border-color:#093C62;color:#F4F8FA;}
    </style>
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

            <div class="asg-group">
                <label>Gắn Bài tập vào *</label>
                <div class="radio-group">
                    <label class="radio-option">
                        <input type="radio" name="attachType" value="course" ${empty formAttachType || formAttachType == 'course' ? 'checked' : ''} onchange="toggleSectionInput(this.value)" />
                        <div>
                            <div class="radio-option-label"><i class="fa-solid fa-book-open"></i> Toàn bộ khóa học</div>
                            <div class="radio-option-sub">Bài tập chung — hiển thị trong mục bài tập toàn khóa của học viên</div>
                        </div>
                    </label>
                    <label class="radio-option">
                        <input type="radio" name="attachType" value="section" ${formAttachType == 'section' ? 'checked' : ''} onchange="toggleSectionInput(this.value)" />
                        <div>
                            <div class="radio-option-label"><i class="fa-solid fa-folder-open"></i> Một chương cụ thể</div>
                            <div class="radio-option-sub">Bài tập theo chương — gắn liền với 1 chương học cụ thể giống như Quiz</div>
                        </div>
                    </label>
                </div>
                <div id="sectionIdWrap" style="${formAttachType == 'section' ? 'display:block;' : 'display:none;'}">
                    <label for="sectionId">Chọn chương muốn gắn *</label>
                    <select id="sectionId" name="sectionId" ${formAttachType == 'section' ? 'required' : ''}>
                        <option value="">-- Chọn một chương --</option>
                        <c:forEach var="section" items="${course.sectionsCache}">
                            <option value="${section.id}" ${formSectionId == section.id ? 'selected' : ''}>
                                <c:out value="${section.title}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>
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

<script>
    function toggleSectionInput(val) {
        var wrap = document.getElementById('sectionIdWrap');
        var input = document.getElementById('sectionId');
        if (val === 'section') {
            wrap.style.display = 'block';
            input.required = true;
        } else {
            wrap.style.display = 'none';
            input.required = false;
            input.value = '';
        }
    }
</script>

</body>
</html>
