<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo Quiz - LMS</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',Roboto,Arial,sans-serif;}
        body{background:#f0f4f8;color:#2d3748;}
        .navbar{background:#fff;box-shadow:0 2px 8px rgba(0,0,0,.07);padding:14px 36px;display:flex;justify-content:space-between;align-items:center;position:sticky;top:0;z-index:100;}
        .navbar .logo{font-size:20px;font-weight:800;color:#667eea;text-decoration:none;}
        .nav-links{display:flex;align-items:center;gap:12px;}
        .btn{padding:8px 18px;border-radius:8px;font-size:13px;font-weight:600;text-decoration:none;cursor:pointer;border:none;transition:all .2s;display:inline-block;}
        .btn-outline{border:1.5px solid #667eea;color:#667eea;background:transparent;}
        .btn-outline:hover{background:#667eea;color:#fff;}
        .btn-primary{background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;}
        .btn-primary:hover{opacity:.9;}
        .btn-danger{background:#fc8181;color:#742a2a;}
        .badge{display:inline-block;padding:2px 9px;border-radius:12px;font-size:11px;font-weight:700;background:#ebf8ff;color:#2b6cb0;text-transform:uppercase;margin-left:6px;}
        .main{max-width:680px;margin:40px auto;padding:0 24px;}
        .page-title{font-size:24px;font-weight:800;color:#1a202c;margin-bottom:24px;}
        .card{background:#fff;border-radius:14px;box-shadow:0 4px 16px rgba(0,0,0,.07);padding:32px;}
        .alert-danger{background:#fed7d7;color:#822727;border:1px solid #fc8181;padding:12px 16px;border-radius:9px;font-size:14px;margin-bottom:20px;}
        .form-group{margin-bottom:20px;}
        .form-group label{display:block;font-size:14px;font-weight:600;color:#2d3748;margin-bottom:7px;}
        .form-group input[type=text],
        .form-group input[type=number]{width:100%;padding:10px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;color:#2d3748;outline:none;transition:border-color .2s;}
        .form-group input:focus{border-color:#667eea;}
        .form-group .hint{font-size:12px;color:#a0aec0;margin-top:5px;}
        .radio-group{display:flex;flex-direction:column;gap:10px;margin-top:4px;}
        .radio-option{display:flex;align-items:flex-start;gap:10px;padding:12px 14px;border:1.5px solid #e2e8f0;border-radius:8px;cursor:pointer;transition:border-color .2s;}
        .radio-option:hover{border-color:#667eea;}
        .radio-option input[type=radio]{margin-top:2px;accent-color:#667eea;flex-shrink:0;}
        .radio-option-label{font-size:14px;font-weight:600;color:#2d3748;}
        .radio-option-sub{font-size:13px;color:#718096;margin-top:3px;}
        #sectionIdWrap{margin-top:10px;padding:12px 14px;background:#f7f8ff;border-radius:8px;border:1px solid #e2e8f0;display:none;}
        #sectionIdWrap label{font-size:13px;font-weight:600;color:#4a5568;margin-bottom:6px;display:block;}
        #sectionIdWrap input{width:100%;padding:8px 12px;border:1.5px solid #e2e8f0;border-radius:7px;font-size:14px;outline:none;}
        #sectionIdWrap input:focus{border-color:#667eea;}
        .form-actions{display:flex;gap:12px;margin-top:28px;}
        .btn-submit{padding:11px 28px;background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;border:none;border-radius:9px;font-size:15px;font-weight:700;cursor:pointer;transition:opacity .2s;}
        .btn-submit:hover{opacity:.9;}
    </style>
</head>
<body>
<% User currentUser = (User) session.getAttribute("currentUser");
   String role = currentUser != null ? currentUser.getRole() : ""; %>
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/" class="logo">🎓 LMS System</a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-outline">← Danh sách khóa học</a>
        <% if (currentUser != null) { %>
            <span style="font-size:14px;color:#4a5568;font-weight:600;"><%=currentUser.getFullName()%><span class="badge"><%=role%></span></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">Đăng xuất</a>
        <% } %>
    </div>
</nav>

<div class="main">
    <div class="page-title">📝 Tạo Quiz mới</div>

    <div class="card">
        <c:if test="${not empty error}">
            <div class="alert-danger">⚠️ <c:out value="${error}"/></div>
        </c:if>

        <form action="${pageContext.request.contextPath}/instructor/quizzes/new" method="post">
            <input type="hidden" name="courseId" value="${courseId}" />

            <div class="form-group">
                <label for="title">Tiêu đề Quiz *</label>
                <input type="text" id="title" name="title" required placeholder="VD: Quiz tổng kết chương 1" />
            </div>

            <div class="form-group">
                <label for="passScore">Điểm đạt (thang 100) *</label>
                <input type="number" id="passScore" name="passScore" min="0" max="100" step="0.01" required placeholder="VD: 70" />
            </div>

            <div class="form-group">
                <label for="maxAttempts">Số lần làm bài tối đa</label>
                <input type="number" id="maxAttempts" name="maxAttempts" min="1" placeholder="Để trống = không giới hạn" />
                <div class="hint">💡 Để trống nếu muốn cho phép làm lại không giới hạn số lần.</div>
            </div>

            <div class="form-group">
                <label for="timeLimitMinutes">Thời gian làm bài (phút)</label>
                <input type="number" id="timeLimitMinutes" name="timeLimitMinutes" min="1" placeholder="Để trống = không giới hạn thời gian" />
                <div class="hint">💡 Học viên sẽ thấy đồng hồ đếm ngược và bài tự động nộp khi hết giờ.</div>
            </div>

            <div class="form-group">
                <label for="openAt">Mở quiz lúc</label>
                <input type="datetime-local" id="openAt" name="openAt" style="width:100%;padding:10px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;color:#2d3748;outline:none;" />
                <div class="hint">💡 Để trống nếu muốn mở ngay khi tạo quiz.</div>
            </div>

            <div class="form-group">
                <label for="closeAt">Đóng quiz lúc</label>
                <input type="datetime-local" id="closeAt" name="closeAt" style="width:100%;padding:10px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;color:#2d3748;outline:none;" />
                <div class="hint">💡 Để trống nếu không muốn tự động đóng quiz.</div>
            </div>

            <div class="form-group">
                <label>Gắn Quiz vào *</label>
                <div class="radio-group">
                    <label class="radio-option">
                        <input type="radio" name="attachType" value="course" checked onchange="toggleSectionInput(this.value)" />
                        <div>
                            <div class="radio-option-label">📚 Toàn bộ khóa học</div>
                            <div class="radio-option-sub">Quiz tổng kết — xuất hiện sau khi học xong tất cả các chương</div>
                        </div>
                    </label>
                    <label class="radio-option">
                        <input type="radio" name="attachType" value="section" onchange="toggleSectionInput(this.value)" />
                        <div>
                            <div class="radio-option-label">📂 Một chương cụ thể</div>
                            <div class="radio-option-sub">Quiz cuối chương — gắn với 1 section nhất định</div>
                        </div>
                    </label>
                </div>
                <div id="sectionIdWrap">
                    <label for="sectionId">Chọn chương muốn gắn</label>
                    <select id="sectionId" name="sectionId" style="width:100%;padding:10px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;color:#2d3748;outline:none;background:#fff;">
                        <option value="">-- Chọn một chương --</option>
                        <c:forEach var="section" items="${course.sectionsCache}">
                            <option value="${section.id}"><c:out value="${section.title}"/></option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn-submit">💾 Tạo Quiz</button>
                <a href="${pageContext.request.contextPath}/instructor/courses/manage?id=${courseId}" class="btn btn-outline">Hủy</a>
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
