<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Quiz - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=26">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=26">
    <style>
        .btn-danger-sm{padding:6px 14px;background:#fed7d7;color:#9b2c2c;border:none;border-radius:7px;font-size:12px;font-weight:700;cursor:pointer;}
        .btn-danger-sm:hover{background:#fc8181;color:#fff;}
        .btn-action-sm{background:#edf2f7;color:#4a5568;border:none;padding:6px 14px;border-radius:7px;font-size:12px;font-weight:700;cursor:pointer;display:inline-flex;align-items:center;gap:4px;transition:background .2s;}
        .btn-action-sm:hover{background:#e2e8f0;color:#1a202c;}
        .modal-overlay{display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(15,23,42,.6);backdrop-filter:blur(4px);z-index:9999;align-items:center;justify-content:center;}
        .modal-overlay.active{display:flex;}
        .modal-card{background:#fff;border-radius:16px;padding:24px 28px;width:90%;max-width:620px;max-height:90vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,.25);animation:modalSlide .25s ease;}
        @keyframes modalSlide{from{transform:translateY(-20px) scale(.96);opacity:0;}to{transform:translateY(0) scale(1);opacity:1;}}
        .modal-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;}
        .modal-header h3{font-size:17px;font-weight:700;color:#1e293b;}
        .btn-close{background:none;border:none;font-size:20px;color:#94a3b8;cursor:pointer;line-height:1;}
        .btn-close:hover{color:#0f172a;}
        .main{max-width:900px;margin:36px auto;padding:0 24px;}
        .page-header{margin-bottom:28px;}
        .page-title{font-size:24px;font-weight:800;color:#093C62;}
        .page-meta{font-size:14px;color:#5C7688;margin-top:6px;display:flex;gap:20px;}
        .page-meta span{display:flex;align-items:center;gap:4px;}
        .alert-danger{background:#fed7d7;color:#822727;border:1px solid #fc8181;padding:12px 16px;border-radius:9px;font-size:14px;margin-bottom:20px;}
        .section-label{font-size:13px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:#5C7688;margin-bottom:14px;}
        /* ---- CÂU HỎI ---- */
        .question-card{background:#fff;border-radius:12px;box-shadow:0 3px 12px rgba(9,60,98,.06);margin-bottom:16px;overflow:hidden;border:1px solid #C6D8E3;border-left:4px solid #076FA4;}
        .question-header{display:flex;justify-content:space-between;align-items:flex-start;padding:16px 20px 12px;}
        .question-num{font-size:11px;font-weight:700;color:#5C7688;text-transform:uppercase;margin-bottom:4px;}
        .question-content{font-size:15px;font-weight:600;color:#093C62;line-height:1.5;}
        .question-type{font-size:11px;padding:3px 9px;border-radius:20px;font-weight:700;background:#E2EEF5;color:#093C62;}
        .options-list{padding:0 20px 16px;display:flex;flex-direction:column;gap:7px;}
        .option-item{display:flex;align-items:center;gap:9px;padding:8px 12px;border-radius:8px;font-size:14px;background:#F0F6FA;color:#093C62;}
        .option-item.correct{background:#c6f6d5;color:#22543d;font-weight:600;}
        .option-item.correct .tick{color:#38a169;font-size:15px;}
        .option-item .dot{width:8px;height:8px;border-radius:50%;background:#9DB9CB;flex-shrink:0;}
        .question-footer{padding:0 20px 14px;display:flex;justify-content:flex-end;}
        .empty-questions{text-align:center;padding:40px;background:#fff;border-radius:12px;color:#5C7688;border:1px solid #C6D8E3;}
        /* ---- FORM THÊM CÂU HỎI ---- */
        .add-form-card{background:#fff;border-radius:14px;box-shadow:0 4px 16px rgba(9,60,98,.07);padding:28px;margin-top:32px;border:1px solid #C6D8E3;}
        .add-form-title{font-size:18px;font-weight:700;color:#093C62;margin-bottom:22px;padding-bottom:12px;border-bottom:2px solid #E2EEF5;}
        .form-group{margin-bottom:18px;}
        .form-group label{display:block;font-size:13px;font-weight:600;color:#093C62;margin-bottom:6px;}
        .form-group textarea{width:100%;padding:10px 14px;border:1.5px solid #C6D8E3;border-radius:8px;font-size:14px;resize:vertical;min-height:80px;outline:none;transition:border-color .2s;color:#093C62;}
        .form-group textarea:focus{border-color:#076FA4;}
        .form-group select{width:100%;padding:10px 14px;border:1.5px solid #C6D8E3;border-radius:8px;font-size:14px;outline:none;background:#fff;cursor:pointer;color:#093C62;}
        .form-group select:focus{border-color:#076FA4;}
        .options-container{display:flex;flex-direction:column;gap:10px;margin-bottom:12px;}
        .option-row{display:flex;align-items:center;gap:10px;padding:10px 14px;background:#F0F6FA;border-radius:8px;border:1px solid #C6D8E3;}
        .option-row input[type=text]{flex:1;padding:8px 12px;border:1.5px solid #C6D8E3;border-radius:7px;font-size:14px;outline:none;color:#093C62;}
        .option-row input[type=text]:focus{border-color:#076FA4;}
        .option-row label{display:flex;align-items:center;gap:6px;font-size:13px;font-weight:600;color:#093C62;white-space:nowrap;cursor:pointer;}
        .option-row input[type=checkbox]{accent-color:#38a169;width:16px;height:16px;}
        .btn-add-option{padding:8px 16px;background:#E2EEF5;color:#093C62;border:1.5px dashed #9DB9CB;border-radius:8px;font-size:13px;font-weight:600;cursor:pointer;transition:all .2s;}
        .btn-add-option:hover{background:#C6D8E3;color:#076FA4;}
        .hint{font-size:12px;color:#5C7688;margin-top:8px;}
        .btn-submit{padding:11px 28px;background:linear-gradient(135deg,#093C62,#076FA4);color:#fff;border:none;border-radius:9px;font-size:14px;font-weight:700;cursor:pointer;}
        .btn-submit:hover{opacity:.9;}

        /* Dark Theme (Ô 1: #111312, Ô 2: #182535, Ô 3: #093C62) */
        body.dark-theme .page-title{color:#F4F8FA;}
        body.dark-theme .page-meta{color:#9DB9CB;}
        body.dark-theme .question-card{background:#182535;border-color:#093C62;border-left-color:#076FA4;box-shadow:0 3px 12px rgba(0,0,0,.3);}
        body.dark-theme .question-content{color:#F4F8FA;}
        body.dark-theme .option-item{background:#111312;color:#9DB9CB;}
        body.dark-theme .add-form-card{background:#182535;border-color:#093C62;box-shadow:0 4px 16px rgba(0,0,0,.3);}
        body.dark-theme .add-form-title{color:#F4F8FA;border-bottom-color:#093C62;}
        body.dark-theme .form-group label{color:#F4F8FA;}
        body.dark-theme .form-group textarea, body.dark-theme .form-group select{background:#111312;border-color:#093C62;color:#F4F8FA;}
        body.dark-theme .option-row{background:#111312;border-color:#093C62;}
        body.dark-theme .option-row input[type=text]{background:#182535;border-color:#093C62;color:#F4F8FA;}
        body.dark-theme .option-row label{color:#F4F8FA;}
        body.dark-theme .modal-card{background:#182535;border:1px solid #093C62;color:#F4F8FA;}
        body.dark-theme .modal-header h3{color:#F4F8FA;}
    </style>
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">
<% User currentUser = (User) session.getAttribute("currentUser");
   String role = currentUser != null ? currentUser.getRole() : ""; %>

<!-- NAVBAR -->
<nav class="lms-navbar">
    <a href="<%=request.getContextPath()%>/" class="lms-logo">
        <img src="<%=request.getContextPath()%>/assets/images/utedu-logo.png" alt="UTEdu" class="lms-logo-img">
        <span class="logo-tag">LMS</span>
    </a>
    <div class="nav-links">
        <a href="<%=request.getContextPath()%>/instructor/courses" class="nav-link">← Khóa học</a>
        <a href="<%=request.getContextPath()%>/courses" class="nav-link">Khóa học</a>
        <% if (currentUser != null) { %>
            <% if ("student".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/student/dashboard" class="nav-link">Bảng điều khiển</a>
            <% } %>
            <div class="user-badge">
                <div class="user-avatar"><%=currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName().substring(0,1).toUpperCase() : "U"%></div>
                <span><%=currentUser.getFullName()%></span>
                <span class="role-tag"><%=role%></span>
            </div>
            <% if ("instructor".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/instructor/courses" class="btn btn-outline">Quản lý</a>
            <% } else if ("admin".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/admin" class="btn btn-outline">Quản trị</a>
            <% } else { %>
                <a href="<%=request.getContextPath()%>/student/my-courses" class="btn btn-outline">Của tôi</a>
            <% } %>
            <a href="<%=request.getContextPath()%>/logout" class="btn btn-danger">Đăng xuất</a>
        <% } else { %>
            <a href="<%=request.getContextPath()%>/login" class="btn btn-outline">Đăng nhập</a>
            <a href="<%=request.getContextPath()%>/register" class="btn btn-primary">Đăng ký</a>
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
                    <div id="qdata_${question.id}" style="display:none;"
                         data-id="${question.id}"
                         data-content="<c:out value="${question.content}" escapeXml="true"/>"
                         data-type="${question.questionType}">
                        <c:forEach var="opt" items="${question.options}">
                            <span class="opt-item" data-content="<c:out value="${opt.content}" escapeXml="true"/>" data-correct="${opt.correct}"></span>
                        </c:forEach>
                    </div>
                    <div class="question-footer" style="display:flex; justify-content:flex-end; gap:8px;">
                        <button type="button" class="btn-action-sm" onclick="openEditQuestionModal(${question.id})">
                            <i class="fa-solid fa-pen-to-square"></i> Sửa câu hỏi
                        </button>
                        <form action="${pageContext.request.contextPath}/instructor/quizzes/questions/delete"
                              method="post"
                              onsubmit="return confirm('Xác nhận xóa câu hỏi này?')">
                            <input type="hidden" name="questionId" value="${question.id}" />
                            <input type="hidden" name="quizId" value="${quiz.id}" />
                            <button type="submit" class="btn-danger-sm"><i class="fa-solid fa-trash"></i> Xóa câu hỏi</button>
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

<%-- MODAL CHỈNH SỬA CÂU HỎI --%>
<div class="modal-overlay" id="editQuestionModal" onclick="if(event.target===this)closeEditQuestionModal()">
    <div class="modal-card">
        <div class="modal-header">
            <h3>✏️ Chỉnh sửa câu hỏi</h3>
            <button type="button" class="btn-close" onclick="closeEditQuestionModal()">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/instructor/quizzes/questions/edit" method="post">
            <input type="hidden" name="quizId" value="${quiz.id}" />
            <input type="hidden" name="questionId" id="modalEditQuestionId" />

            <div class="form-group">
                <label for="editContent">Nội dung câu hỏi *</label>
                <textarea id="editContent" name="content" required placeholder="Nhập nội dung câu hỏi..."></textarea>
            </div>

            <div class="form-group">
                <label for="editQuestionType">Loại câu hỏi *</label>
                <select id="editQuestionType" name="questionType">
                    <option value="single_choice">1 đáp án đúng (Single choice)</option>
                    <option value="multi_choice">Nhiều đáp án đúng (Multi choice)</option>
                </select>
            </div>

            <div class="form-group">
                <label>Các đáp án *</label>
                <div class="options-container" id="editOptionsContainer">
                    <!-- Sẽ được điền động bằng JS -->
                </div>
                <button type="button" class="btn-add-option" onclick="addEditOption()">+ Thêm đáp án</button>
                <div class="hint">💡 Với loại "1 đáp án đúng", chỉ được tick đúng 1 ô "Đáp án đúng".</div>
            </div>

            <div style="display:flex;justify-content:flex-end;gap:10px;margin-top:20px;">
                <button type="button" class="btn btn-outline btn-sm" onclick="closeEditQuestionModal()">Hủy</button>
                <button type="submit" class="btn-submit" style="padding:8px 20px;">💾 Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<script>
    function addOption() {
        var container = document.getElementById('optionsContainer');
        var idx = container.children.length;
        var letters = ['A','B','C','D','E','F','G','H','I','J'];
        var letter = idx < letters.length ? letters[idx] : (idx + 1);
        var div = document.createElement('div');
        div.className = 'option-row';
        div.innerHTML =
            '<input type="text" name="optionContent" placeholder="Nội dung đáp án ' + letter + '" required />' +
            '<label><input type="checkbox" name="correctOption" value="' + idx + '" /> Đáp án đúng</label>';
        container.appendChild(div);
    }

    function openEditQuestionModal(questionId) {
        var dataEl = document.getElementById('qdata_' + questionId);
        if (!dataEl) return;

        document.getElementById('modalEditQuestionId').value = questionId;
        document.getElementById('editContent').value = dataEl.getAttribute('data-content');
        document.getElementById('editQuestionType').value = dataEl.getAttribute('data-type');

        var container = document.getElementById('editOptionsContainer');
        container.innerHTML = '';

        var optItems = dataEl.getElementsByClassName('opt-item');
        var letters = ['A','B','C','D','E','F','G','H','I','J'];

        for (var i = 0; i < optItems.length; i++) {
            var optContent = optItems[i].getAttribute('data-content');
            var isCorrect = optItems[i].getAttribute('data-correct') === 'true';
            var letter = i < letters.length ? letters[i] : (i + 1);

            var div = document.createElement('div');
            div.className = 'option-row';
            div.innerHTML =
                '<input type="text" name="optionContent" value="' + escapeHtml(optContent) + '" placeholder="Nội dung đáp án ' + letter + '" required />' +
                '<label><input type="checkbox" name="correctOption" value="' + i + '" ' + (isCorrect ? 'checked' : '') + ' /> Đáp án đúng</label>';
            container.appendChild(div);
        }

        document.getElementById('editQuestionModal').classList.add('active');
    }

    function closeEditQuestionModal() {
        document.getElementById('editQuestionModal').classList.remove('active');
    }

    function addEditOption() {
        var container = document.getElementById('editOptionsContainer');
        var idx = container.children.length;
        var letters = ['A','B','C','D','E','F','G','H','I','J'];
        var letter = idx < letters.length ? letters[idx] : (idx + 1);

        var div = document.createElement('div');
        div.className = 'option-row';
        div.innerHTML =
            '<input type="text" name="optionContent" placeholder="Nội dung đáp án ' + letter + '" required />' +
            '<label><input type="checkbox" name="correctOption" value="' + idx + '" /> Đáp án đúng</label>';
        container.appendChild(div);
    }

    function escapeHtml(str) {
        if (!str) return '';
        return str.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    }
</script>

<!-- Dynamic Island Theme Toggle -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=26"></script>
</body>
</html>
