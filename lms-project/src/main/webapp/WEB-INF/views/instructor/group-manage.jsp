<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String flashError = (String) session.getAttribute("flashError");
    if (flashError != null) session.removeAttribute("flashError");
    String flashSuccess = (String) session.getAttribute("flashSuccess");
    if (flashSuccess != null) session.removeAttribute("flashSuccess");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Nhóm học tập - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <style>
        body { background: #f0f4f8; }
        .page-header { padding: 32px 40px; background: linear-gradient(135deg, #093C62, #076FA4); color: #fff; }
        .main { max-width: 1000px; margin: 36px auto; padding: 0 24px; }
        .card { background: #fff; border-radius: 12px; padding: 24px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); margin-bottom: 24px; }
        .group-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; margin-top: 24px; }
        .group-card { border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden; }
        .group-header { background: #edf2f7; padding: 12px 16px; font-weight: bold; display: flex; justify-content: space-between; align-items: center; }
        .group-body { padding: 16px; }
        .member-list { list-style: none; padding: 0; margin: 0; }
        .member-item { display: flex; align-items: center; padding: 8px 0; border-bottom: 1px solid #edf2f7; font-size: 14px; }
        .member-item:last-child { border-bottom: none; }
        .member-role { font-size: 10px; padding: 2px 6px; border-radius: 12px; background: #e2e8f0; margin-left: auto; }
        .role-leader { background: #fefcbf; color: #744210; }
        .btn-primary { background: #3182ce; color: #fff; border: none; padding: 8px 16px; border-radius: 6px; cursor: pointer; }
        .btn-primary:hover { background: #2b6cb0; }
        .alert-success { background: #c6f6d5; color: #22543d; padding: 12px; border-radius: 6px; margin-bottom: 16px; }
        .alert-danger { background: #fed7d7; color: #822727; padding: 12px; border-radius: 6px; margin-bottom: 16px; }
    </style>
</head>
<body>

<header class="page-header">
    <h1><i class="fa-solid fa-users"></i> Quản lý Nhóm</h1>
    <p>Khóa học: <strong><c:out value="${course.title}" /></strong></p>
    <a href="${pageContext.request.contextPath}/instructor/dashboard" style="color:#a0aec0; text-decoration:none; font-size:14px; margin-top:8px; display:inline-block;"><i class="fa-solid fa-arrow-left"></i> Quay lại Dashboard</a>
</header>

<div class="main">
    <% if (flashSuccess != null) { %><div class="alert-success"><%= flashSuccess %></div><% } %>
    <% if (flashError != null) { %><div class="alert-danger"><%= flashError %></div><% } %>

    <div class="card">
        <h3><i class="fa-solid fa-wand-magic-sparkles"></i> Chia nhóm Tự động</h3>
        <p style="color:#718096; font-size:14px; margin-bottom:16px;">Hệ thống sẽ quét các học viên chưa có nhóm và chia đều vào các nhóm ngẫu nhiên.</p>
        
        <form action="${pageContext.request.contextPath}/instructor/groups" method="post" style="display:flex; align-items:center; gap:16px;">
            <input type="hidden" name="action" value="auto_divide">
            <input type="hidden" name="courseId" value="${course.id}">
            <div>
                <label style="font-size:14px; font-weight:bold;">Số thành viên mỗi nhóm:</label>
                <input type="number" name="membersPerGroup" value="5" min="2" max="20" style="padding:8px; border:1px solid #cbd5e0; border-radius:6px; width:80px; margin-left:8px;">
            </div>
            <button type="submit" class="btn-primary" onclick="return confirm('Bạn có chắc chắn muốn chia nhóm cho các học viên còn lại?');">
                Chạy tự động
            </button>
        </form>
    </div>

    <div class="card">
        <h3>Danh sách Nhóm học tập (${groups.size()})</h3>
        
        <c:if test="${empty groups}">
            <p style="color:#a0aec0; margin-top:16px;">Chưa có nhóm nào được tạo.</p>
        </c:if>

        <div class="group-grid">
            <c:forEach var="group" items="${groups}">
                <div class="group-card">
                    <div class="group-header">
                        <span><i class="fa-solid fa-people-group"></i> <c:out value="${group.name}"/></span>
                        <span style="font-size:12px; font-weight:normal; color:#718096;">
                            ${groupMembersMap[group.id].size()} / ${group.maxMembers} TV
                        </span>
                    </div>
                    <div class="group-body">
                        <ul class="member-list">
                            <c:forEach var="member" items="${groupMembersMap[group.id]}">
                                <li class="member-item">
                                    <i class="fa-solid fa-user" style="color:#cbd5e0; margin-right:8px;"></i>
                                    <c:out value="${member.student.fullName}"/>
                                    <c:if test="${member.role == 'LEADER'}">
                                        <span class="member-role role-leader">LEADER</span>
                                    </c:if>
                                    <c:if test="${member.role != 'LEADER'}">
                                        <span class="member-role">MEMBER</span>
                                    </c:if>
                                </li>
                            </c:forEach>
                            <c:if test="${empty groupMembersMap[group.id]}">
                                <li style="font-size:12px; color:#a0aec0; font-style:italic;">Chưa có thành viên</li>
                            </c:if>
                        </ul>
                        
                        <%-- CHẤM ĐIỂM (GRADING SECTION) --%>
                        <div style="margin-top: 16px; padding-top: 16px; border-top: 1px dashed #e2e8f0;">
                            <c:set var="submission" value="${groupSubmissionsMap[group.id]}" />
                            <c:choose>
                                <c:when test="${submission != null}">
                                    <div style="background: #f0fdf4; padding: 12px; border-radius: 6px; border: 1px solid #bbf7d0; margin-bottom: 12px;">
                                        <p style="font-size: 12px; font-weight: bold; color: #166534; margin-bottom: 4px;"><i class="fa-solid fa-check-circle"></i> Đã nộp bài</p>
                                        <a href="${submission.fileUrl}" target="_blank" style="font-size: 13px; color: #2563eb; text-decoration: none; word-break: break-all;">Mở bài làm <i class="fa-solid fa-arrow-up-right-from-square" style="font-size: 10px;"></i></a>
                                        <p style="font-size: 11px; color: #475569; margin-top: 4px;">Bởi: ${submission.submitter.fullName}</p>
                                    </div>
                                    
                                    <form action="${pageContext.request.contextPath}/instructor/groups" method="post" style="display: flex; flex-direction: column; gap: 8px;">
                                        <input type="hidden" name="action" value="grade_submission">
                                        <input type="hidden" name="courseId" value="${course.id}">
                                        <input type="hidden" name="groupId" value="${group.id}">
                                        
                                        <div style="display: flex; gap: 8px; align-items: center;">
                                            <input type="number" name="score" step="0.5" min="0" max="10" placeholder="Điểm (0-10)" required value="${submission.score}" style="padding: 6px; border: 1px solid #cbd5e1; border-radius: 4px; width: 100px; font-size: 13px;">
                                            <button type="submit" class="btn-primary" style="padding: 6px 12px; font-size: 13px;">Lưu Điểm</button>
                                        </div>
                                        <textarea name="feedback" placeholder="Nhận xét cho nhóm..." style="padding: 6px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 13px; resize: vertical; min-height: 50px;">${submission.feedback}</textarea>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <div style="background: #f8fafc; padding: 12px; border-radius: 6px; text-align: center; border: 1px dashed #cbd5e1;">
                                        <p style="font-size: 12px; color: #64748b;">Nhóm chưa nộp bài</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</div>

</body>
</html>
