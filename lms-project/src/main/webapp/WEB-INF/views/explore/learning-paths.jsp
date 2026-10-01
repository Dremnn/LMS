<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.lms.model.User, com.lms.controller.ExploreServlet.PathwayItem, com.lms.controller.ExploreServlet.PhaseItem" %>
<%
    List<PathwayItem> pathways = (List<PathwayItem>) request.getAttribute("pathways");
    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lộ trình Học tập Nghề nghiệp - UTEdu LMS</title>
    
    <!-- Fonts & Icons -->
    <link rel="preconnect" href="https://cdnjs.cloudflare.com">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Stylesheets -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=39">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=39">

    <style>
        .page-hero {
            padding: 60px 0 40px;
            background: linear-gradient(180deg, rgba(7, 111, 164, 0.08) 0%, rgba(9, 60, 98, 0.02) 100%);
            border-bottom: 1px solid var(--border);
            text-align: center;
        }
        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 16px;
            background: rgba(7, 111, 164, 0.12);
            color: var(--primary);
            border-radius: 999px;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 16px;
            border: 1px solid rgba(7, 111, 164, 0.2);
        }
        .page-title {
            font-size: clamp(32px, 4vw, 44px);
            font-weight: 800;
            color: var(--text);
            margin-bottom: 16px;
            line-height: 1.2;
        }
        .page-title span {
            background: linear-gradient(135deg, var(--primary), #0284C7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .page-subtitle {
            font-size: 16px;
            color: var(--text-muted);
            max-width: 680px;
            margin: 0 auto;
            line-height: 1.6;
        }

        /* Tab Switcher */
        .pathways-nav-tabs {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 12px;
            margin: 36px 0 40px;
        }
        .pathway-tab-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 14px 24px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            font-size: 15px;
            font-weight: 700;
            color: var(--text-muted);
            cursor: pointer;
            box-shadow: var(--shadow-sm);
            transition: all var(--t-fast);
        }
        .pathway-tab-btn:hover {
            color: var(--primary);
            border-color: var(--primary);
            transform: translateY(-2px);
        }
        .pathway-tab-btn.active {
            background: var(--primary);
            color: #FFFFFF;
            border-color: var(--primary);
            box-shadow: 0 6px 20px rgba(7, 111, 164, 0.3);
        }

        /* Pathway Content Container */
        .pathway-view {
            display: none;
            animation: fadeIn 0.4s ease;
        }
        .pathway-view.active {
            display: block;
        }

        /* Pathway Header Card */
        .pathway-header-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 40px;
            box-shadow: var(--shadow-md);
            margin-bottom: 40px;
            position: relative;
            overflow: hidden;
        }
        .pathway-top-meta {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 24px;
        }
        .pathway-title-box h2 {
            font-size: 28px;
            font-weight: 800;
            color: var(--text);
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .pathway-title-box p {
            font-size: 15px;
            color: var(--text-muted);
            max-width: 700px;
            line-height: 1.6;
            margin: 0;
        }
        .pathway-meta-badges {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }
        .meta-pill {
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 700;
            background: rgba(7, 111, 164, 0.08);
            color: var(--primary);
            border: 1px solid rgba(7, 111, 164, 0.15);
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .meta-pill.salary {
            background: rgba(16, 185, 129, 0.1);
            color: #059669;
            border-color: rgba(16, 185, 129, 0.2);
        }

        .roles-strip {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            padding-top: 20px;
            border-top: 1px solid var(--border);
        }
        .roles-label {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-muted);
            text-transform: uppercase;
        }
        .role-tag {
            font-size: 13px;
            font-weight: 600;
            padding: 4px 12px;
            background: rgba(9, 60, 98, 0.05);
            border-radius: 999px;
            color: var(--text);
        }

        /* Timeline Phases */
        .timeline-section-title {
            font-size: 22px;
            font-weight: 800;
            color: var(--text);
            margin-bottom: 28px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .timeline-container {
            position: relative;
            padding-left: 36px;
            margin-bottom: 40px;
        }
        .timeline-container::before {
            content: '';
            position: absolute;
            left: 14px;
            top: 20px;
            bottom: 20px;
            width: 3px;
            background: linear-gradient(180deg, var(--primary) 0%, rgba(7, 111, 164, 0.2) 100%);
            border-radius: 2px;
        }
        .phase-card {
            position: relative;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 28px;
            margin-bottom: 24px;
            box-shadow: var(--shadow-sm);
            transition: all var(--t-smooth);
        }
        .phase-card:hover {
            border-color: var(--primary);
            box-shadow: var(--shadow-md);
            transform: translateX(4px);
        }
        .phase-node {
            position: absolute;
            left: -37px;
            top: 28px;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: var(--primary);
            border: 4px solid var(--surface);
            box-shadow: 0 0 0 2px var(--primary);
        }
        .phase-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 12px;
        }
        .phase-title {
            font-size: 18px;
            font-weight: 800;
            color: var(--text);
            margin: 0;
        }
        .phase-time {
            font-size: 12px;
            font-weight: 700;
            color: var(--primary);
            background: rgba(7, 111, 164, 0.1);
            padding: 4px 10px;
            border-radius: 6px;
        }
        .phase-desc {
            font-size: 14px;
            color: var(--text-muted);
            line-height: 1.6;
            margin-bottom: 16px;
        }
        .phase-skills {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }
        .phase-skill-pill {
            font-size: 12px;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 6px;
            background: rgba(7, 111, 164, 0.06);
            color: var(--primary-dark);
            border: 1px solid rgba(7, 111, 164, 0.12);
        }

        /* Action Footer */
        .pathway-action-banner {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 24px;
            background: linear-gradient(135deg, rgba(7, 111, 164, 0.06), rgba(9, 60, 98, 0.02));
            border: 1px dashed var(--primary);
            border-radius: var(--radius);
            padding: 24px 32px;
            margin-top: 32px;
        }
        .action-text h4 { font-size: 17px; font-weight: 800; color: var(--text); margin-bottom: 4px; }
        .action-text p { font-size: 14px; color: var(--text-muted); margin: 0; }
        .btn-start-pathway {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 14px 28px;
            background: var(--primary);
            color: #FFFFFF;
            border-radius: var(--radius-sm);
            font-size: 14px;
            font-weight: 700;
            text-decoration: none;
            transition: all var(--t-fast);
            box-shadow: var(--shadow-sm);
        }
        .btn-start-pathway:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 6px 18px rgba(7, 111, 164, 0.3);
        }

        /* Advisor Consultation Box */
        .advisor-box {
            margin: 60px 0 20px;
            background: linear-gradient(135deg, var(--primary-dark), #0A426E);
            border-radius: var(--radius-lg);
            padding: 40px;
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 32px;
            box-shadow: var(--shadow-lg);
        }
        .advisor-content h3 { font-size: 24px; font-weight: 800; color: white; margin-bottom: 8px; }
        .advisor-content p { font-size: 15px; color: rgba(255, 255, 255, 0.85); margin: 0; max-width: 620px; }
        .advisor-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 14px 26px;
            background: #FFFFFF;
            color: var(--primary-dark);
            border-radius: 999px;
            font-size: 14px;
            font-weight: 700;
            text-decoration: none;
            white-space: nowrap;
            transition: all var(--t-fast);
        }
        .advisor-btn:hover {
            transform: scale(1.04);
            box-shadow: 0 6px 20px rgba(0,0,0,0.25);
            background: #F8FAFC;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @media (max-width: 768px) {
            .pathway-header-card { padding: 24px; }
            .advisor-box { flex-direction: column; text-align: center; padding: 32px 24px; }
            .advisor-btn { width: 100%; justify-content: center; }
            .pathway-action-banner { flex-direction: column; text-align: center; }
            .btn-start-pathway { width: 100%; justify-content: center; }
        }
    </style>
</head>
<body class="mesh-bg">

<!-- NAVBAR -->
<nav class="lms-navbar">
    <div class="nav-left">
        <a href="<%=request.getContextPath()%>/" class="lms-logo">
            <img src="<%=request.getContextPath()%>/assets/images/utedu-logo.png" alt="UTEdu" class="lms-logo-img" style="height: 36px !important; width: auto; max-height: 36px;">
            <span class="logo-tag">LMS</span>
        </a>
        <% if (currentUser != null) { %>
        <div class="quick-actions">
            <a href="<%=request.getContextPath()%>/chat" class="quick-action-btn" title="Tin nhắn">
                <i class="fa-solid fa-comment-dots"></i><span class="quick-action-text">Tin nhắn</span>
            </a>
            <a href="<%=request.getContextPath()%>/notifications" class="quick-action-btn" title="Thông báo">
                <i class="fa-solid fa-bell"></i><span class="quick-action-text">Thông báo</span>
            </a>
        </div>
        <% } %>
    </div>
    <div class="nav-links">
        <a href="<%=request.getContextPath()%>/courses" class="nav-link">Khóa học</a>
        <a href="<%=request.getContextPath()%>/instructors" class="nav-link">Giảng viên</a>
        <a href="<%=request.getContextPath()%>/learning-paths" class="nav-link active">Lộ trình</a>
        <a href="<%=request.getContextPath()%>/resources" class="nav-link">Tài liệu</a>
        <% if (currentUser != null) { %>
            <% if ("student".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/dashboard" class="nav-link">Bảng điều khiển</a>
                <a href="<%=request.getContextPath()%>/student/my-courses" class="nav-link">Khóa học của tôi</a>
            <% } %>
            <a href="<%=request.getContextPath()%>/profile" class="nav-link">Hồ sơ</a>
            <div class="user-badge">
                <% if (currentUser.getAvatarUrl() != null && !currentUser.getAvatarUrl().trim().isEmpty()) { %>
                    <img src="<%=currentUser.getAvatarUrl()%>" alt="Avatar" class="user-avatar" style="object-fit: cover;">
                <% } else { %>
                    <div class="user-avatar"><%=currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName().substring(0,1).toUpperCase() : "U"%></div>
                <% } %>
                <span><%=currentUser.getFullName()%></span>
                <span class="role-tag"><%=role%></span>
            </div>
            <% if ("instructor".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/instructor/courses" class="btn btn-outline">Quản lý</a>
            <% } else if ("admin".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/admin" class="btn btn-outline">Quản trị</a>
            <% } %>
            <a href="<%=request.getContextPath()%>/logout" class="btn btn-danger">Đăng xuất</a>
        <% } else { %>
            <a href="<%=request.getContextPath()%>/login" class="btn btn-outline">Đăng nhập</a>
            <a href="<%=request.getContextPath()%>/register" class="btn btn-primary">Đăng ký</a>
        <% } %>
    </div>
</nav>

<!-- PAGE HERO -->
<header class="page-hero">
    <div class="container">
        <div class="hero-badge">
            <i class="fa-solid fa-route"></i> Career Pathways 2026
        </div>
        <h1 class="page-title">Lộ trình <span>Học tập Toàn diện</span></h1>
        <p class="page-subtitle">
            Học tập có định hướng rõ ràng. Các lộ trình được thiết kế chuẩn mực từ nền tảng đến cấp độ kỹ sư cao cấp, tập trung vào kỹ năng thực chiến và công nghệ doanh nghiệp đang săn đón.
        </p>
    </div>
</header>

<!-- MAIN CONTENT -->
<main style="padding: 20px 0 80px;">
    <div class="container">

        <!-- Tabs -->
        <div class="pathways-nav-tabs">
            <% if (pathways != null) {
                for (int i = 0; i < pathways.size(); i++) {
                    PathwayItem p = pathways.get(i);
            %>
            <button class="pathway-tab-btn <%=i == 0 ? "active" : ""%>" onclick="switchPathway('<%=p.getId()%>', this)">
                <i class="fa-solid <%=p.getIcon()%>"></i> <%=p.getTitle()%>
            </button>
            <%   }
               } %>
        </div>

        <!-- Pathway Details Views -->
        <% if (pathways != null) {
            for (int i = 0; i < pathways.size(); i++) {
                PathwayItem p = pathways.get(i);
        %>
        <div id="pathway-<%=p.getId()%>" class="pathway-view <%=i == 0 ? "active" : ""%>">
            
            <!-- Header Card -->
            <div class="pathway-header-card">
                <div class="pathway-top-meta">
                    <div class="pathway-title-box">
                        <h2><i class="fa-solid <%=p.getIcon()%>" style="color: <%=p.getColor()%>; font-size: 24px;"></i> <%=p.getTitle()%></h2>
                        <p><%=p.getDescription()%></p>
                    </div>
                    <div class="pathway-meta-badges">
                        <span class="meta-pill"><i class="fa-regular fa-clock"></i> <%=p.getDuration()%></span>
                        <span class="meta-pill"><i class="fa-solid fa-layer-group"></i> <%=p.getLevel()%></span>
                        <span class="meta-pill salary"><i class="fa-solid fa-money-bill-wave"></i> Thu nhập: <%=p.getSalaryRange()%></span>
                    </div>
                </div>

                <div class="roles-strip">
                    <span class="roles-label"><i class="fa-solid fa-briefcase"></i> Vị trí việc làm mục tiêu:</span>
                    <% for (String roleName : p.getTargetRoles()) { %>
                        <span class="role-tag"><%=roleName%></span>
                    <% } %>
                </div>
            </div>

            <!-- Milestones Timeline -->
            <div class="timeline-section-title">
                <i class="fa-solid fa-bars-progress"></i> Các giai đoạn đào tạo chi tiết
            </div>

            <div class="timeline-container">
                <% for (PhaseItem phase : p.getPhases()) { %>
                <div class="phase-card">
                    <div class="phase-node"></div>
                    <div class="phase-head">
                        <h4 class="phase-title"><%=phase.getPhaseName()%></h4>
                        <span class="phase-time"><i class="fa-regular fa-calendar-check"></i> <%=phase.getTimeEstimate()%></span>
                    </div>
                    <p class="phase-desc"><%=phase.getSummary()%></p>
                    <div class="phase-skills">
                        <% for (String skill : phase.getSkills()) { %>
                            <span class="phase-skill-pill"><i class="fa-solid fa-check"></i> <%=skill%></span>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- Pathway Call to Action -->
            <div class="pathway-action-banner">
                <div class="action-text">
                    <h4>Sẵn sàng chinh phục lộ trình này?</h4>
                    <p>Khám phá các khóa học thực hành trong hệ thống để bắt đầu tích lũy kiến thức ngay hôm nay.</p>
                </div>
                <a href="<%=request.getContextPath()%>/<%=p.getCourseQuery()%>" class="btn-start-pathway">
                    <i class="fa-solid fa-compass"></i> Bắt đầu Lộ trình
                </a>
            </div>

        </div>
        <%   }
           } %>

        <!-- Advisor Consultation Box -->
        <section class="advisor-box">
            <div class="advisor-content">
                <h3>Cần tư vấn lộ trình học tập cá nhân hóa?</h3>
                <p>Đội ngũ cố vấn chuyên môn của UTEdu LMS sẽ đánh giá nền tảng hiện tại của bạn và tư vấn lộ trình học tập tối ưu nhất cho mục tiêu công việc.</p>
            </div>
            <a href="<%=request.getContextPath()%>/chat" class="advisor-btn">
                <i class="fa-solid fa-comments"></i> Trò chuyện với Cố vấn
            </a>
        </section>

    </div>
</main>

<!-- FOOTER -->
<footer class="lms-footer modern-footer">
    <div class="container">
        <div class="footer-grid" style="align-items: flex-start;">
            <div class="footer-col brand-col">
                <a href="<%=request.getContextPath()%>/" class="lms-logo footer-logo" style="margin-bottom: 16px;">
                    <img src="<%=request.getContextPath()%>/assets/images/utedu-logo.png" alt="UTEdu" class="lms-logo-img" style="height: 36px !important; width: auto; max-height: 36px;">
                    <span class="logo-tag">LMS</span>
                </a>
                <p class="footer-desc">Nền tảng học trực tuyến thế hệ mới. Nâng tầm tri thức, kiến tạo tương lai thế hệ trẻ.</p>
                <div class="social-links" style="margin-top: 16px; display: flex; gap: 12px;">
                    <a href="#" class="social-icon" title="Facebook"><i class="fa-brands fa-facebook-f"></i></a>
                    <a href="#" class="social-icon" title="YouTube"><i class="fa-brands fa-youtube"></i></a>
                    <a href="#" class="social-icon" title="GitHub"><i class="fa-brands fa-github"></i></a>
                    <a href="#" class="social-icon" title="LinkedIn"><i class="fa-brands fa-linkedin-in"></i></a>
                </div>
            </div>

            <div class="footer-col">
                <h4 class="footer-title">Khám phá</h4>
                <ul class="footer-links">
                    <li><a href="<%=request.getContextPath()%>/courses?sortBy=popular">Khoá học nổi bật</a></li>
                    <li><a href="<%=request.getContextPath()%>/instructors">Giảng viên tiêu biểu</a></li>
                    <li><a href="<%=request.getContextPath()%>/learning-paths">Lộ trình học tập</a></li>
                    <li><a href="<%=request.getContextPath()%>/resources">Thư viện tài liệu</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h4 class="footer-title">Liên kết nhanh</h4>
                <ul class="footer-links">
                    <li><a href="<%=request.getContextPath()%>/courses">Tất cả khóa học</a></li>
                    <li><a href="<%=request.getContextPath()%>/login">Đăng nhập</a></li>
                    <li><a href="<%=request.getContextPath()%>/register">Đăng ký thành viên</a></li>
                    <li><a href="<%=request.getContextPath()%>/dashboard">Bảng điều khiển</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h4 class="footer-title">Liên hệ</h4>
                <ul class="footer-contact">
                    <li><i class="fa-solid fa-location-dot"></i> Tầng 15, Tòa nhà công nghệ, Thành phố Hồ Chí Minh</li>
                    <li><i class="fa-solid fa-phone"></i> 1900 1036</li>
                    <li><i class="fa-solid fa-envelope"></i> hotro@utedu.vn</li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; 2026 UTEdu LMS. Đã đăng ký bản quyền.</p>
            <div class="footer-bottom-links">
                <a href="#">Bảo mật</a>
                <a href="#">Điều khoản</a>
            </div>
        </div>
    </div>
</footer>

<!-- Dynamic Island Theme Toggle -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="<%=request.getContextPath()%>/assets/js/lms-app.js?v=39"></script>
<script>
    function switchPathway(pathwayId, btn) {
        document.querySelectorAll('.pathway-tab-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        document.querySelectorAll('.pathway-view').forEach(view => {
            view.classList.remove('active');
        });
        const targetView = document.getElementById('pathway-' + pathwayId);
        if (targetView) {
            targetView.classList.add('active');
        }
    }
</script>
</body>
</html>
