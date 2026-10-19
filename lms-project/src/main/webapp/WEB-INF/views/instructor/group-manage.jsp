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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Nhóm học tập - ${course.title}</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=32">
    <style>
        body { background: #f0f4f8; font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, sans-serif; color: #1e293b; margin: 0; }
        .page-header { padding: 36px 40px; background: linear-gradient(135deg, #093C62, #076FA4); color: #fff; box-shadow: 0 4px 20px rgba(9,60,98,0.15); }
        .page-header h1 { margin: 0 0 8px 0; font-size: 26px; font-weight: 700; display: flex; align-items: center; gap: 12px; }
        .page-header p { margin: 0 0 16px 0; font-size: 15px; opacity: 0.9; }
        .header-nav { display: flex; gap: 14px; flex-wrap: wrap; }
        .header-nav a { color: #bae6fd; text-decoration: none; font-size: 13px; font-weight: 500; display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; background: rgba(255,255,255,0.12); border-radius: 8px; transition: 0.2s; }
        .header-nav a:hover { background: rgba(255,255,255,0.22); color: #fff; }

        .main { max-width: 1200px; margin: 32px auto; padding: 0 24px; }
        
        /* Stats strip */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 18px; margin-bottom: 24px; }
        .stat-card { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.04); border: 1px solid #e2e8f0; display: flex; align-items: center; gap: 16px; }
        .stat-icon { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 20px; flex-shrink: 0; }
        .stat-val { font-size: 24px; font-weight: 700; color: #0f172a; line-height: 1.2; }
        .stat-label { font-size: 13px; color: #64748b; margin-top: 2px; }

        /* Actions grid */
        .actions-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(360px, 1fr)); gap: 20px; margin-bottom: 28px; }
        .card { background: #fff; border-radius: 14px; padding: 24px; box-shadow: 0 2px 12px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; }
        .card h3 { margin: 0 0 8px 0; font-size: 17px; font-weight: 700; color: #093C62; display: flex; align-items: center; gap: 10px; }
        .card p.desc { margin: 0 0 18px 0; font-size: 13px; color: #64748b; line-height: 1.5; }

        .form-row { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .form-control { padding: 9px 12px; border: 1.5px solid #cbd5e1; border-radius: 8px; font-size: 14px; outline: none; transition: 0.2s; }
        .form-control:focus { border-color: #0284c7; box-shadow: 0 0 0 3px rgba(2,132,199,0.15); }
        .form-label { font-size: 13px; font-weight: 600; color: #334155; }

        .btn { padding: 9px 18px; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; border: none; display: inline-flex; align-items: center; gap: 8px; text-decoration: none; transition: 0.2s; }
        .btn-primary { background: #0284c7; color: #fff; }
        .btn-primary:hover { background: #0369a1; }
        .btn-primary:disabled { background: #94a3b8; cursor: not-allowed; }
        .btn-secondary { background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
        .btn-secondary:hover { background: #e2e8f0; color: #1e293b; }
        .btn-danger { background: #ef4444; color: #fff; }
        .btn-danger:hover { background: #dc2626; }
        .btn-danger-sm { background: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; padding: 4px 8px; font-size: 12px; border-radius: 6px; cursor: pointer; }
        .btn-danger-sm:hover { background: #ef4444; color: #fff; }

        /* Groups list */
        .group-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: 22px; margin-top: 18px; }
        .group-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.04); display: flex; flex-direction: column; }
        .group-header { background: #f8fafc; padding: 14px 18px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
        .group-title { font-size: 16px; font-weight: 700; color: #093C62; display: flex; align-items: center; gap: 8px; }
        .group-badge { font-size: 12px; font-weight: 600; padding: 3px 10px; border-radius: 20px; background: #e0f2fe; color: #0369a1; }
        .group-body { padding: 18px; flex: 1; display: flex; flex-direction: column; }

        .member-list { list-style: none; padding: 0; margin: 0 0 16px 0; border: 1px solid #f1f5f9; border-radius: 8px; overflow: hidden; }
        .member-item { display: flex; align-items: center; padding: 10px 14px; border-bottom: 1px solid #f1f5f9; font-size: 13px; background: #fff; gap: 10px; }
        .member-item:last-child { border-bottom: none; }
        .member-avatar { width: 32px; height: 32px; border-radius: 50%; background: #0284c7; color: #fff; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 13px; flex-shrink: 0; }
        .member-details { flex: 1; min-width: 0; }
        .member-name { font-weight: 600; color: #1e293b; display: block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .member-email { font-size: 11px; color: #64748b; display: block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .role-tag { font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 12px; flex-shrink: 0; }
        .role-leader { background: #fef08a; color: #854d0e; }
        .role-member { background: #f1f5f9; color: #64748b; }

        .btn-remove-mem { background: none; border: none; color: #94a3b8; cursor: pointer; padding: 4px; font-size: 13px; border-radius: 4px; }
        .btn-remove-mem:hover { color: #ef4444; background: #fee2e2; }

        .add-member-form { display: flex; gap: 8px; margin-bottom: 16px; padding: 8px; background: #f8fafc; border-radius: 8px; border: 1px dashed #cbd5e1; }
        .add-member-form select { flex: 1; padding: 6px 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 12px; }

        /* Grading box */
        .grading-box { margin-top: auto; padding-top: 14px; border-top: 1px dashed #e2e8f0; }
        .submission-info { background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 12px; margin-bottom: 12px; font-size: 13px; }
        .no-submission { background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 8px; padding: 14px; text-align: center; font-size: 12px; color: #64748b; }

        /* Unassigned list */
        .unassigned-card { background: #fffbeb; border: 1px solid #fde68a; border-radius: 12px; padding: 18px 24px; margin-bottom: 24px; }
        .unassigned-badge { display: inline-flex; align-items: center; gap: 6px; background: #fff; border: 1px solid #fcd34d; padding: 6px 12px; border-radius: 20px; font-size: 12px; margin: 4px; font-weight: 500; }

        .alert-success { background: #dcfce7; color: #166534; padding: 14px 20px; border-radius: 10px; margin-bottom: 20px; border: 1px solid #bbf7d0; font-size: 14px; font-weight: 500; display: flex; align-items: center; gap: 10px; }
        .alert-danger { background: #fee2e2; color: #991b1b; padding: 14px 20px; border-radius: 10px; margin-bottom: 20px; border: 1px solid #fecaca; font-size: 14px; font-weight: 500; display: flex; align-items: center; gap: 10px; }

        [data-theme="dark"] body { background: #0f172a; color: #f8fafc; }
        [data-theme="dark"] .card, [data-theme="dark"] .stat-card, [data-theme="dark"] .group-card { background: #1e293b; border-color: #334155; color: #f8fafc; }
        [data-theme="dark"] .card h3, [data-theme="dark"] .group-title { color: #38bdf8; }
        [data-theme="dark"] .group-header { background: #182234; border-color: #334155; }
        [data-theme="dark"] .member-item { background: #1e293b; border-color: #334155; }
        [data-theme="dark"] .member-name { color: #f8fafc; }
        [data-theme="dark"] .form-control { background: #0f172a; border-color: #475569; color: #f8fafc; }
        [data-theme="dark"] .add-member-form { background: #0f172a; border-color: #475569; }
        [data-theme="dark"] .add-member-form select { background: #1e293b; color: #f8fafc; border-color: #475569; }
        [data-theme="dark"] .no-submission { background: #0f172a; border-color: #475569; color: #94a3b8; }
        [data-theme="dark"] .unassigned-card { background: rgba(245, 158, 11, 0.1); border-color: rgba(245, 158, 11, 0.3); }
        [data-theme="dark"] .unassigned-badge { background: #1e293b; border-color: #475569; color: #f8fafc; }
    </style>
</head>
<body class="${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">

<header class="page-header">
    <div style="max-width: 1200px; margin: 0 auto;">
        <h1><i class="fa-solid fa-people-group"></i> Quản lý &amp; Chia nhóm học tập</h1>
        <p>Khóa học: <strong><c:out value="${course.title}" /></strong></p>
        <div class="header-nav">
            <a href="${pageContext.request.contextPath}/instructor/courses/manage?id=${course.id}">
                <i class="fa-solid fa-arrow-left"></i> Quản lý nội dung khóa học
            </a>
            <a href="${pageContext.request.contextPath}/instructor/courses">
                <i class="fa-solid fa-list-check"></i> Danh sách khóa học
            </a>
            <a href="${pageContext.request.contextPath}/courses/detail?id=${course.id}" target="_blank">
                <i class="fa-solid fa-eye"></i> Trang xem khóa học
            </a>
        </div>
    </div>
</header>

<div class="main">
    <c:if test="${not empty flashSuccess}">
        <div class="alert-success"><i class="fa-solid fa-circle-check"></i> ${flashSuccess}</div>
    </c:if>
    <c:if test="${not empty flashError}">
        <div class="alert-danger"><i class="fa-solid fa-triangle-exclamation"></i> ${flashError}</div>
    </c:if>

    <!-- STATS STRIP -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon" style="background:#e0f2fe; color:#0284c7;">
                <i class="fa-solid fa-user-graduate"></i>
            </div>
            <div>
                <div class="stat-val">${totalStudentsCount}</div>
                <div class="stat-label">Tổng học viên ghi danh</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#dcfce7; color:#16a34a;">
                <i class="fa-solid fa-users-viewfinder"></i>
            </div>
            <div>
                <div class="stat-val">${groupedStudentsCount}</div>
                <div class="stat-label">Học viên đã vào nhóm</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#fef3c7; color:#d97706;">
                <i class="fa-solid fa-user-clock"></i>
            </div>
            <div>
                <div class="stat-val">${unassignedStudentsCount}</div>
                <div class="stat-label">Học viên chưa có nhóm</div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#ede9fe; color:#7c3aed;">
                <i class="fa-solid fa-diagram-project"></i>
            </div>
            <div>
                <div class="stat-val">${groups.size()}</div>
                <div class="stat-label">Nhóm hiện tại</div>
            </div>
        </div>
    </div>

    <!-- ACTIONS GRID -->
    <div class="actions-grid">
        <!-- CARD 1: AUTO DIVIDE -->
        <div class="card">
            <h3><i class="fa-solid fa-wand-magic-sparkles" style="color:#0284c7;"></i> Chia nhóm Tự động</h3>
            <p class="desc">Hệ thống sẽ lấy ngẫu nhiên các học viên chưa có nhóm và tự động phân chia vào các nhóm với số lượng học viên chỉ định.</p>
            
            <form action="${pageContext.request.contextPath}/instructor/groups" method="post">
                <input type="hidden" name="action" value="auto_divide">
                <input type="hidden" name="courseId" value="${course.id}">
                
                <div class="form-row" style="margin-bottom: 16px;">
                    <div>
                        <label class="form-label">Số thành viên mỗi nhóm:</label>
                        <input type="number" name="membersPerGroup" value="5" min="2" max="30" class="form-control" style="width: 100px; margin-left: 8px;">
                    </div>
                </div>

                <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                    <button type="submit" class="btn btn-primary" ${unassignedStudentsCount == 0 ? 'disabled' : ''} onclick="return confirm('Bạn có chắc chắn muốn chia ngẫu nhiên ${unassignedStudentsCount} học viên vào các nhóm?');">
                        <i class="fa-solid fa-bolt"></i> Chạy chia nhóm tự động
                    </button>
                    
                    <c:if test="${not empty groups}">
                        <button type="button" class="btn btn-secondary" style="color: #b91c1c;" onclick="if(confirm('CẢNH BÁO: Hành động này sẽ xóa TOÀN BỘ ${groups.size()} nhóm hiện tại để bạn có thể chia lại từ đầu. Tiếp tục?')) { document.getElementById('deleteAllForm').submit(); }">
                            <i class="fa-solid fa-trash-can"></i> Xóa tất cả nhóm để chia lại
                        </button>
                    </c:if>
                </div>

                <c:if test="${unassignedStudentsCount == 0 && totalStudentsCount > 0}">
                    <p style="font-size: 12px; color: #16a34a; margin-top: 10px; margin-bottom: 0;">
                        <i class="fa-solid fa-check"></i> Tất cả ${totalStudentsCount} học viên đều đã có nhóm!
                    </p>
                </c:if>
                <c:if test="${totalStudentsCount == 0}">
                    <p style="font-size: 12px; color: #d97706; margin-top: 10px; margin-bottom: 0;">
                        <i class="fa-solid fa-circle-info"></i> Khóa học chưa có học viên đăng ký tham gia.
                    </p>
                </c:if>
            </form>

            <form id="deleteAllForm" action="${pageContext.request.contextPath}/instructor/groups" method="post" style="display:none;">
                <input type="hidden" name="action" value="delete_all">
                <input type="hidden" name="courseId" value="${course.id}">
            </form>
        </div>

        <!-- CARD 2: CREATE MANUAL GROUP -->
        <div class="card">
            <h3><i class="fa-solid fa-plus-circle" style="color:#10b981;"></i> Tạo nhóm Thủ công</h3>
            <p class="desc">Tự tạo thêm một nhóm học tập mới theo tên tùy chọn và số lượng thành viên tối đa mong muốn.</p>

            <form action="${pageContext.request.contextPath}/instructor/groups" method="post">
                <input type="hidden" name="action" value="create_group">
                <input type="hidden" name="courseId" value="${course.id}">

                <div class="form-row" style="margin-bottom: 16px;">
                    <div style="flex: 2; min-width: 160px;">
                        <label class="form-label">Tên nhóm:</label>
                        <input type="text" name="groupName" class="form-control" style="width: 100%; box-sizing: border-box;" placeholder="VD: Nhóm ${groups.size() + 1}" required>
                    </div>
                    <div style="flex: 1; min-width: 100px;">
                        <label class="form-label">Số TV tối đa:</label>
                        <input type="number" name="maxMembers" class="form-control" style="width: 100%; box-sizing: border-box;" value="5" min="2" max="50" required>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary" style="background:#10b981;">
                    <i class="fa-solid fa-plus"></i> Tạo nhóm mới
                </button>
            </form>
        </div>
    </div>

    <!-- UNASSIGNED STUDENTS SECTION -->
    <c:if test="${unassignedStudentsCount > 0}">
        <div class="unassigned-card">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                <h4 style="margin:0; font-size:15px; color:#92400e; display:flex; align-items:center; gap:8px;">
                    <i class="fa-solid fa-triangle-exclamation"></i> Danh sách học viên chưa vào nhóm (${unassignedStudentsCount})
                </h4>
            </div>
            <div style="display:flex; flex-wrap:wrap; gap:8px;">
                <c:forEach var="u" items="${unassignedUsers}">
                    <div class="unassigned-badge">
                        <i class="fa-solid fa-user" style="color:#d97706;"></i>
                        <strong><c:out value="${u.fullName}" /></strong>
                        <span style="color:#64748b; font-size:11px;">(<c:out value="${u.email}" />)</span>
                    </div>
                </c:forEach>
            </div>
        </div>
    </c:if>

    <!-- LIST OF GROUPS -->
    <div style="display:flex; justify-content:space-between; align-items:center; margin-top:32px;">
        <h2 style="font-size:20px; font-weight:700; color:#093C62; margin:0;">
            Danh sách Nhóm học tập (${groups.size()})
        </h2>
    </div>

    <c:if test="${empty groups}">
        <div class="card" style="text-align:center; padding: 48px 24px; margin-top:16px;">
            <i class="fa-solid fa-people-arrows" style="font-size:48px; color:#cbd5e1; margin-bottom:16px;"></i>
            <h3 style="justify-content:center; color:#64748b;">Chưa có nhóm học tập nào</h3>
            <p style="color:#94a3b8; font-size:14px; max-width:460px; margin:0 auto 16px;">Hãy sử dụng chức năng <strong>Chia nhóm Tự động</strong> ở phía trên hoặc tạo nhóm thủ công để phân chia học viên.</p>
        </div>
    </c:if>

    <div class="group-grid">
        <c:forEach var="group" items="${groups}">
            <div class="group-card">
                <div class="group-header">
                    <span class="group-title">
                        <i class="fa-solid fa-people-group" style="color:#0284c7;"></i>
                        <c:out value="${group.name}"/>
                    </span>
                    <div style="display:flex; align-items:center; gap:8px;">
                        <span class="group-badge">
                            ${groupMembersMap[group.id].size()} / ${group.maxMembers} TV
                        </span>
                        <form action="${pageContext.request.contextPath}/instructor/groups" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa nhóm ${group.name}?');">
                            <input type="hidden" name="action" value="delete_group">
                            <input type="hidden" name="courseId" value="${course.id}">
                            <input type="hidden" name="groupId" value="${group.id}">
                            <button type="submit" class="btn-danger-sm" title="Xóa nhóm này">
                                <i class="fa-solid fa-trash"></i>
                            </button>
                        </form>
                    </div>
                </div>

                <div class="group-body">
                    <!-- MEMBERS LIST -->
                    <ul class="member-list">
                        <c:forEach var="member" items="${groupMembersMap[group.id]}">
                            <li class="member-item">
                                <div class="member-avatar">
                                    <c:choose>
                                        <c:when test="${not empty member.student.fullName}">
                                            ${member.student.fullName.substring(0,1).toUpperCase()}
                                        </c:when>
                                        <c:otherwise>U</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="member-details">
                                    <span class="member-name"><c:out value="${member.student.fullName}"/></span>
                                    <span class="member-email"><c:out value="${member.student.email}"/></span>
                                </div>
                                <c:choose>
                                    <c:when test="${member.role == 'LEADER'}">
                                        <span class="role-tag role-leader"><i class="fa-solid fa-crown"></i> TRƯỞNG NHÓM</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="role-tag role-member">THÀNH VIÊN</span>
                                    </c:otherwise>
                                </c:choose>
                                
                                <form action="${pageContext.request.contextPath}/instructor/groups" method="post" style="display:inline;" onsubmit="return confirm('Xóa thành viên này khỏi nhóm?');">
                                    <input type="hidden" name="action" value="remove_member">
                                    <input type="hidden" name="courseId" value="${course.id}">
                                    <input type="hidden" name="groupId" value="${group.id}">
                                    <input type="hidden" name="studentId" value="${member.student.id}">
                                    <button type="submit" class="btn-remove-mem" title="Xóa khỏi nhóm">
                                        <i class="fa-solid fa-xmark"></i>
                                    </button>
                                </form>
                            </li>
                        </c:forEach>

                        <c:if test="${empty groupMembersMap[group.id]}">
                            <li style="padding:14px; text-align:center; color:#94a3b8; font-size:12px; font-style:italic;">
                                Nhóm chưa có thành viên nào
                            </li>
                        </c:if>
                    </ul>

                    <!-- ADD MEMBER FORM (IF UNASSIGNED STUDENTS EXIST) -->
                    <c:if test="${not empty unassignedUsers}">
                        <form action="${pageContext.request.contextPath}/instructor/groups" method="post" class="add-member-form">
                            <input type="hidden" name="action" value="add_member">
                            <input type="hidden" name="courseId" value="${course.id}">
                            <input type="hidden" name="groupId" value="${group.id}">
                            <select name="studentId" required>
                                <option value="">-- Thêm học viên vào nhóm này --</option>
                                <c:forEach var="u" items="${unassignedUsers}">
                                    <option value="${u.id}"><c:out value="${u.fullName}"/> (${u.email})</option>
                                </c:forEach>
                            </select>
                            <button type="submit" class="btn btn-primary" style="padding:5px 12px; font-size:12px;">
                                <i class="fa-solid fa-user-plus"></i> Thêm
                            </button>
                        </form>
                    </c:if>

                    <!-- GRADING BOX -->
                    <div class="grading-box">
                        <c:set var="submission" value="${groupSubmissionsMap[group.id]}" />
                        <c:choose>
                            <c:when test="${submission != null}">
                                <div class="submission-info">
                                    <p style="font-weight:700; color:#166534; margin:0 0 6px 0; display:flex; align-items:center; gap:6px;">
                                        <i class="fa-solid fa-circle-check"></i> Đã nộp bài tập nhóm
                                    </p>
                                    <div style="margin-bottom:4px;">
                                        <strong>Link bài:</strong> 
                                        <a href="${submission.fileUrl}" target="_blank" style="color:#0284c7; word-break:break-all;">
                                            ${submission.fileUrl} <i class="fa-solid fa-arrow-up-right-from-square" style="font-size:11px;"></i>
                                        </a>
                                    </div>
                                    <div style="font-size:11px; color:#475569;">
                                        Người nộp: <strong><c:out value="${submission.submitter != null && not empty submission.submitter.fullName ? submission.submitter.fullName : 'Học viên'}"/></strong>
                                    </div>
                                </div>

                                <form action="${pageContext.request.contextPath}/instructor/groups" method="post" style="display:flex; flex-direction:column; gap:8px;">
                                    <input type="hidden" name="action" value="grade_submission">
                                    <input type="hidden" name="courseId" value="${course.id}">
                                    <input type="hidden" name="groupId" value="${group.id}">
                                    
                                    <div style="display:flex; gap:8px; align-items:center;">
                                        <input type="number" name="score" step="0.25" min="0" max="10" placeholder="Điểm (0-10)" required value="${submission.score}" class="form-control" style="width:110px; padding:6px 10px; font-size:13px;">
                                        <button type="submit" class="btn btn-primary" style="padding:6px 14px; font-size:13px;">
                                            <i class="fa-solid fa-floppy-disk"></i> Lưu điểm
                                        </button>
                                    </div>
                                    <textarea name="feedback" placeholder="Nhận xét cho nhóm..." class="form-control" style="resize:vertical; min-height:48px; font-size:12px;">${submission.feedback}</textarea>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <div class="no-submission">
                                    <i class="fa-solid fa-clock" style="margin-right:4px;"></i> Nhóm chưa nộp bài tập cuối khóa
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
</div>

</body>
</html>
