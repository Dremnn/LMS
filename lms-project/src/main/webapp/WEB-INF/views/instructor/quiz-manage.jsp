<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Quiz - LMS</title>
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
        .btn-danger-sm{padding:6px 14px;background:#fed7d7;color:#9b2c2c;border:none;border-radius:7px;font-size:12px;font-weight:700;cursor:pointer;}
        .btn-danger-sm:hover{background:#fc8181;color:#fff;}
        .btn-danger{background:#fc8181;color:#742a2a;}
        .badge{display:inline-block;padding:2px 9px;border-radius:12px;font-size:11px;font-weight:700;background:#ebf8ff;color:#2b6cb0;text-transform:uppercase;margin-left:6px;}
        .main{max-width:900px;margin:36px auto;padding:0 24px;}
        .page-header{margin-bottom:28px;}
        .page-title{font-size:24px;font-weight:800;color:#1a202c;}
        .page-meta{font-size:14px;color:#718096;margin-top:6px;display:flex;gap:20px;}
        .page-meta span{display:flex;align-items:center;gap:4px;}
        .alert-danger{background:#fed7d7;color:#822727;border:1px solid #fc8181;padding:12px 16px;border-radius:9px;font-size:14px;margin-bottom:20px;}
        .section-label{font-size:13px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#a0aec0;margin-bottom:14px;}
        /* ---- CÂUU HỎI ---- */
        .question-card{background:#fff;border-radius:12px;box-shadow:0 3px 12px rgba(0,0,0,.06);margin-bottom:16px;overflow:hidden;border-left:4px solid #667eea;}
        .question-header{display:flex;justify-content:space-between;align-items:flex-start;padding:16px 20px 12px;}
        .question-num{font-size:11px;font-weight:700;color:#a0aec0;text-transform:uppercase;margin-bottom:4px;}
        .question-content{font-size:15px;font-weight:600;color:#1a202c;line-height:1.5;}
        .question-type{font-size:11px;padding:3px 9px;border-radius:20px;font-weight:700;background:#e9d8fd;color:#553c9a;}
        .options-list{padding:0 20px 16px;display:flex;flex-direction:column;gap:7px;}
        .option-item{display:flex;align-items:center;gap:9px;padding:8px 12px;border-radius:8px;font-size:14px;background:#f7f8ff;}
        .option-item.correct{background:#c6f6d5;color:#22543d;font-weight:600;}
        .option-item.correct .tick{color:#38a169;font-size:15px;}
        .option-item .dot{width:8px;height:8px;border-radius:50%;background:#cbd5e0;flex-shrink:0;}
        .question-footer{padding:0 20px 14px;display:flex;justify-content:flex-end;}
        .empty-questions{text-align:center;padding:40px;background:#fff;border-radius:12px;color:#a0aec0;}
        /* ---- FORM THÊM CÂU HỎI ---- */
        .add-form-card{background:#fff;border-radius:14px;box-shadow:0 4px 16px rgba(0,0,0,.07);padding:28px;margin-top:32px;}
        .add-form-title{font-size:18px;font-weight:700;color:#1a202c;margin-bottom:22px;padding-bottom:12px;border-bottom:2px solid #f0f4f8;}
        .form-group{margin-bottom:18px;}
        .form-group label{display:block;font-size:13px;font-weight:600;color:#4a5568;margin-bottom:6px;}
        .form-group textarea{width:100%;padding:10px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;resize:vertical;min-height:80px;outline:none;transition:border-color .2s;}
        .form-group textarea:focus{border-color:#667eea;}
        .form-group select{width:100%;padding:10px 14px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;outline:none;background:#fff;cursor:pointer;}
        .form-group select:focus{border-color:#667eea;}
        .options-container{display:flex;flex-direction:column;gap:10px;margin-bottom:12px;}
        .option-row{display:flex;align-items:center;gap:10px;padding:10px 14px;background:#f7f8ff;border-radius:8px;border:1px solid #e2e8f0;}
        .option-row input[type=text]{flex:1;padding:8px 12px;border:1.5px solid #e2e8f0;border-radius:7px;font-size:14px;outline:none;}
        .option-row input[type=text]:focus{border-color:#667eea;}
        .option-row label{display:flex;align-items:center;gap:6px;font-size:13px;font-weight:600;color:#4a5568;white-space:nowrap;cursor:pointer;}
        .option-row input[type=checkbox]{accent-color:#38a169;width:16px;height:16px;}
        .btn-add-option{padding:8px 16px;background:#edf2f7;color:#4a5568;border:1.5px dashed #cbd5e0;border-radius:8px;font-size:13px;font-weight:600;cursor:pointer;transition:all .2s;}
        .btn-add-option:hover{background:#e2e8f0;border-color:#a0aec0;}
        .hint{font-size:12px;color:#a0aec0;margin-top:8px;}
        .btn-submit{padding:11px 28px;background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;border:none;border-radius:9px;font-size:14px;font-weight:700;cursor:pointer;}
        .btn-submit:hover{opacity:.9;}
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<% User currentUser = (User) session.getAttribute("currentUser");
   String role = currentUser != null ? currentUser.getRole() : ""; %>
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/" class="logo"><i class="fa-solid fa-graduation-cap"></i> EduViet LMS</a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/instructor/courses" class="btn btn-outline">← Khóa học</a>
        <% if (currentUser != null) { %>
            <span style="font-size:14px;color:#4a5568;font-weight:600;"><%=currentUser.getFullName()%><span class="badge"><%=role%></span></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">Đăng xuất</a>
        <% } %>
    </div>
</nav>

<div class="main">
    <div class="page-header">
        <div class="page-title">📝 <c:out value="${quiz.title}"/></div>
        <div class="page-meta">
            <span><i class="fa-solid fa-bullseye"></i> Điểm đạt: <strong>${quiz.passScore}/100</strong></span>
            <span>🔄 Số lần làm:
                <c:choose>
                    <c:when test="${quiz.maxAttempts != null}"><strong>${quiz.maxAttempts}</strong></c:when>
                    <c:otherwise><strong>Không giới hạn</strong></c:otherwise>
                </c:choose>
            </span>
            <span><i class="fa-solid fa-chart-line"></i> Số câu hỏi: <strong>${quiz.totalQuestions}</strong></span>
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> <c:out value="${error}"/></div>
    </c:if>

    <%-- ===== DANH SÁCH CÂU HỎI ===== --%>
    <div class="section-label">Câu hỏi hiện có</div>
    <c:choose>
        <c:when test="${not empty questions}">
            <c:forEach var="question" items="${questions}" varStatus="st">
                <div class="question-card">
                    <div class="question-header">
                        <div>
                            <div class="question-num">Câu ${st.index + 1}</div>
                            <div class="question-content"><c:out value="${question.content}"/></div>
                        </div>
                        <span class="question-type">
                            <c:choose>
                                <c:when test="${question.questionType == 'single_choice'}">1 đáp án đúng</c:when>
                                <c:otherwise>Nhiều đáp án đúng</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="options-list">
                        <c:forEach var="opt" items="${question.options}">
                            <div class="option-item ${opt.correct ? 'correct' : ''}">
                                <c:choose>
                                    <c:when test="${opt.correct}">
                                        <span class="tick">✓</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="dot"></span>
                                    </c:otherwise>
                                </c:choose>
                                <span><c:out value="${opt.content}"/></span>
                            </div>
                        </c:forEach>
                    </div>
                    <div class="question-footer">
                        <form action="${pageContext.request.contextPath}/instructor/quizzes/questions/delete"
                              method="post"
                              onsubmit="return confirm('Xác nhận xóa câu hỏi này?')">
                            <input type="hidden" name="questionId" value="${question.id}" />
                            <input type="hidden" name="quizId" value="${quiz.id}" />
                            <button type="submit" class="btn-danger-sm">🗑 Xóa câu hỏi</button>
                        </form>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="empty-questions">
                <div style="font-size:40px;margin-bottom:10px;"><i class="fa-solid fa-inbox"></i></div>
                <p>Quiz chưa có câu hỏi nào. Thêm câu hỏi đầu tiên bên dưới!</p>
            </div>
        </c:otherwise>
    </c:choose>

    <%-- ===== FORM THÊM CÂU HỎI ===== --%>
    <div class="add-form-card">
        <div class="add-form-title">➕ Thêm câu hỏi mới</div>
        <form action="${pageContext.request.contextPath}/instructor/quizzes/questions/add" method="post">
            <input type="hidden" name="quizId" value="${quiz.id}" />

            <div class="form-group">
                <label for="content">Nội dung câu hỏi *</label>
                <textarea id="content" name="content" required placeholder="Nhập nội dung câu hỏi..."></textarea>
            </div>

            <div class="form-group">
                <label for="questionType">Loại câu hỏi *</label>
                <select id="questionType" name="questionType">
                    <option value="single_choice">1 đáp án đúng (Single choice)</option>
                    <option value="multi_choice">Nhiều đáp án đúng (Multi choice)</option>
                </select>
            </div>

            <div class="form-group">
                <label>Các đáp án *</label>
                <div class="options-container" id="optionsContainer">
                    <div class="option-row">
                        <input type="text" name="optionContent" placeholder="Nội dung đáp án A" required />
                        <label><input type="checkbox" name="correctOption" value="0" /> Đáp án đúng</label>
                    </div>
                    <div class="option-row">
                        <input type="text" name="optionContent" placeholder="Nội dung đáp án B" required />
                        <label><input type="checkbox" name="correctOption" value="1" /> Đáp án đúng</label>
                    </div>
                    <div class="option-row">
                        <input type="text" name="optionContent" placeholder="Nội dung đáp án C" required />
                        <label><input type="checkbox" name="correctOption" value="2" /> Đáp án đúng</label>
                    </div>
                    <div class="option-row">
                        <input type="text" name="optionContent" placeholder="Nội dung đáp án D" required />
                        <label><input type="checkbox" name="correctOption" value="3" /> Đáp án đúng</label>
                    </div>
                </div>
                <button type="button" class="btn-add-option" onclick="addOption()">+ Thêm đáp án</button>
                <div class="hint">💡 Với loại "1 đáp án đúng", chỉ được tick đúng 1 ô "Đáp án đúng".</div>
            </div>

            <button type="submit" class="btn-submit">💾 Lưu câu hỏi</button>
        </form>
    </div>
</div>

<script>
    function addOption() {
        var container = document.getElementById('optionsContainer');
        var idx = container.children.length;
        var letters = ['A','B','C','D','E','F','G','H'];
        var letter = idx < letters.length ? letters[idx] : (idx + 1);
        var div = document.createElement('div');
        div.className = 'option-row';
        div.innerHTML =
            '<input type="text" name="optionContent" placeholder="Nội dung đáp án ' + letter + '" required />' +
            '<label><input type="checkbox" name="correctOption" value="' + idx + '" /> Đáp án đúng</label>';
        container.appendChild(div);
    }
</script>
</body>
</html>
