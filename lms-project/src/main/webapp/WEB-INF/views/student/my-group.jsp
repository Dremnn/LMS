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
    <title>Nhóm của tôi - LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=30">
    <style>
        body { background: #f8fafc; font-family: 'Segoe UI', Roboto, sans-serif; }
        .page-header { background: #093C62; color: #fff; padding: 40px 24px; text-align: center; }
        .page-header h1 { margin-bottom: 12px; font-size: 28px; }
        .container { max-width: 900px; margin: 40px auto; padding: 0 24px; }
        .card { background: #fff; padding: 24px; border-radius: 12px; box-shadow: 0 4px 16px rgba(0,0,0,0.06); margin-bottom: 24px; }
        .no-group { text-align: center; padding: 40px; color: #64748b; }
        
        .member-list { margin-top: 20px; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden; }
        .member-item { display: flex; align-items: center; padding: 12px 16px; border-bottom: 1px solid #e2e8f0; background: #fff; }
        .member-item:last-child { border-bottom: none; }
        .member-item.me { background: #f0fdf4; }
        .avatar-placeholder { width: 40px; height: 40px; background: #cbd5e1; color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; margin-right: 16px; }
        .role-badge { padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: bold; margin-left: auto; }
        .role-leader { background: #fef08a; color: #854d0e; }
        .role-member { background: #f1f5f9; color: #64748b; }

        .submit-section { background: #f8fafc; border: 2px dashed #cbd5e1; border-radius: 8px; padding: 24px; text-align: center; }
        .form-control { width: 100%; max-width: 400px; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; margin-bottom: 16px; }
        .btn-submit { background: #0ea5e9; color: #fff; border: none; padding: 10px 24px; border-radius: 6px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-submit:hover { background: #0284c7; }

        .status-box { padding: 16px; border-radius: 8px; margin-top: 16px; text-align: left; }
        .status-submitted { background: #ecfdf5; border-left: 4px solid #10b981; }
        .status-graded { background: #eff6ff; border-left: 4px solid #3b82f6; }
        
        .alert-success { background: #d1fae5; color: #065f46; padding: 12px; border-radius: 6px; margin-bottom: 24px; }
        .alert-danger { background: #fee2e2; color: #991b1b; padding: 12px; border-radius: 6px; margin-bottom: 24px; }
    </style>
</head>
<body>

<header class="page-header">
    <h1><i class="fa-solid fa-people-group"></i> Nhóm của tôi</h1>
    <p>Khóa học: ${course.title}</p>
</header>

<div class="container">
    <% if (flashSuccess != null) { %><div class="alert-success"><i class="fa-solid fa-check"></i> <%= flashSuccess %></div><% } %>
    <% if (flashError != null) { %><div class="alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> <%= flashError %></div><% } %>

    <c:choose>
        <c:when test="${empty myGroup}">
            <div class="card no-group">
                <i class="fa-solid fa-user-xmark" style="font-size: 48px; margin-bottom: 16px; color: #94a3b8;"></i>
                <h2>Bạn chưa có nhóm</h2>
                <p>Giảng viên hiện tại chưa phân nhóm cho bạn trong khóa học này. Vui lòng chờ thông báo mới nhất!</p>
            </div>
        </c:when>
        
        <c:otherwise>
            <div class="card">
                <h2 style="color: #0f172a;"><c:out value="${myGroup.name}" /></h2>
                <p style="color: #64748b; font-size: 14px;">Bạn có thể liên hệ với các thành viên dưới đây để cùng làm báo cáo.</p>
                
                <div class="member-list">
                    <c:forEach var="member" items="${members}">
                        <div class="member-item ${member.student.id == currentUser.id ? 'me' : ''}">
                            <div class="avatar-placeholder">
                                ${member.student.fullName.substring(0,1).toUpperCase()}
                            </div>
                            <div>
                                <strong style="display: block; color: #1e293b;">
                                    <c:out value="${member.student.fullName}"/>
                                    <c:if test="${member.student.id == currentUser.id}"> (Bạn)</c:if>
                                </strong>
                                <span style="font-size: 12px; color: #64748b;"><c:out value="${member.student.email}"/></span>
                            </div>
                            
                            <c:if test="${member.role == 'LEADER'}">
                                <span class="role-badge role-leader"><i class="fa-solid fa-crown"></i> TRƯỞNG NHÓM</span>
                            </c:if>
                            <c:if test="${member.role != 'LEADER'}">
                                <span class="role-badge role-member">THÀNH VIÊN</span>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <div class="card">
                <h2><i class="fa-solid fa-cloud-arrow-up"></i> Nộp bài tập nhóm</h2>
                <p style="color: #64748b; font-size: 14px; margin-bottom: 24px;">Bất kỳ thành viên nào cũng có quyền nộp hoặc cập nhật link bài tập (Link Google Drive, Github...). Lần nộp cuối cùng sẽ được ghi nhận cho cả nhóm.</p>

                <c:if test="${submission != null}">
                    <div class="status-box ${submission.score != null ? 'status-graded' : 'status-submitted'}">
                        <h4 style="margin-bottom: 8px;"><i class="fa-solid fa-circle-check"></i> Trạng thái: Đã nộp bài</h4>
                        <p style="font-size: 14px; margin-bottom: 4px;"><strong>Link bài làm:</strong> <a href="${submission.fileUrl}" target="_blank">${submission.fileUrl}</a></p>
                        <p style="font-size: 14px; margin-bottom: 4px;"><strong>Người nộp:</strong> ${submission.submitter.fullName}</p>
                        
                        <c:if test="${submission.score != null}">
                            <hr style="border: 0; border-top: 1px solid #cbd5e1; margin: 12px 0;">
                            <p style="font-size: 16px; color: #1d4ed8;"><strong>Điểm số chung: ${submission.score} / 10</strong></p>
                            <c:if test="${not empty submission.feedback}">
                                <p style="font-size: 14px; margin-top: 4px;"><strong>Nhận xét:</strong> ${submission.feedback}</p>
                            </c:if>
                        </c:if>
                    </div>
                </c:if>

                <c:if test="${submission == null || submission.score == null}">
                    <div class="submit-section" style="margin-top: 24px;">
                        <form action="${pageContext.request.contextPath}/student/my-group" method="post">
                            <input type="hidden" name="courseId" value="${course.id}">
                            <input type="url" name="fileUrl" class="form-control" placeholder="Nhập đường dẫn (URL) bài làm của nhóm..." required value="${submission != null ? submission.fileUrl : ''}">
                            <br>
                            <button type="submit" class="btn-submit">
                                ${submission != null ? 'Cập nhật bài nộp' : 'Gửi bài nộp'}
                            </button>
                        </form>
                    </div>
                </c:if>
            </div>
        </c:otherwise>
    </c:choose>
    
    <div style="text-align: center; margin-top: 20px;">
        <a href="${pageContext.request.contextPath}/student/courses" style="color: #64748b; text-decoration: none;"><i class="fa-solid fa-arrow-left"></i> Về danh sách khóa học</a>
    </div>
</div>

</body>
</html>
