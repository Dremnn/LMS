<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.lms.model.User, com.lms.controller.ExploreServlet.InstructorItem" %>
<%
    List<InstructorItem> instructors = (List<InstructorItem>) request.getAttribute("instructors");
    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đội ngũ Giảng viên Tiêu biểu - UTEdu LMS</title>
    
    <!-- Fonts & Icons -->
    <link rel="preconnect" href="https://cdnjs.cloudflare.com">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Stylesheets -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=50">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=39">

    <style>
        .page-hero {
            padding: 60px 0 40px;
            background: linear-gradient(180deg, rgba(7, 111, 164, 0.08) 0%, rgba(9, 60, 98, 0.02) 100%);
            border-bottom: 1px solid var(--border);
            text-align: center;
            position: relative;
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
            margin: 0 auto 32px;
            line-height: 1.6;
        }

        /* Stats Strip */
        .instructor-stats-strip {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            max-width: 960px;
            margin: 0 auto;
            padding: 0 16px;
        }
        .stat-strip-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 18px;
            box-shadow: var(--shadow-sm);
        }
        .stat-strip-card .num {
            font-size: 28px;
            font-weight: 800;
            color: var(--primary);
            margin-bottom: 4px;
        }
        .stat-strip-card .lbl {
            font-size: 13px;
            color: var(--text-muted);
            font-weight: 600;
        }

        /* Filter Pills */
        .filter-bar {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 10px;
            margin: 36px 0 28px;
        }
        .filter-pill {
            padding: 9px 20px;
            border-radius: 999px;
            font-size: 14px;
            font-weight: 600;
            border: 1px solid var(--border);
            background: var(--surface);
            color: var(--text-muted);
            cursor: pointer;
            transition: all var(--t-fast);
        }
        .filter-pill:hover,
        .filter-pill.active {
            background: var(--primary);
            color: #fff;
            border-color: var(--primary);
            box-shadow: 0 4px 12px rgba(7, 111, 164, 0.25);
        }

        /* Instructors Grid */
        .instructors-section {
            padding: 40px 0 80px;
        }
        .instructors-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
            gap: 32px;
        }
        .instructor-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            overflow: hidden;
            box-shadow: var(--shadow-md);
            display: flex;
            flex-direction: column;
            transition: all var(--t-smooth);
            position: relative;
        }
        .instructor-card:hover {
            transform: translateY(-8px);
            box-shadow: var(--shadow-lg);
            border-color: rgba(7, 111, 164, 0.4);
        }
        .card-top-accent {
            height: 6px;
            background: linear-gradient(90deg, var(--primary), #38BDF8);
        }
        .card-body {
            padding: 32px 28px 24px;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        .inst-header {
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 20px;
        }
        .inst-avatar-wrap {
            position: relative;
            flex-shrink: 0;
        }
        .inst-avatar {
            width: 76px;
            height: 76px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
            font-weight: 800;
            color: #FFFFFF;
            box-shadow: 0 6px 18px rgba(9, 60, 98, 0.2);
            border: 3px solid var(--surface);
        }
        .verified-badge {
            position: absolute;
            bottom: 0;
            right: 0;
            background: #F59E0B;
            color: white;
            width: 22px;
            height: 22px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            border: 2px solid var(--surface);
        }
        .inst-names h3 {
            font-size: 20px;
            font-weight: 800;
            color: var(--text);
            margin-bottom: 4px;
        }
        .inst-role-badge {
            display: inline-block;
            font-size: 12px;
            font-weight: 700;
            padding: 3px 10px;
            border-radius: 6px;
            background: rgba(7, 111, 164, 0.1);
            color: var(--primary);
        }
        .inst-org {
            font-size: 12px;
            color: var(--text-muted);
            margin-top: 4px;
            font-weight: 500;
        }

        .rating-box {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 16px;
            font-size: 13px;
        }
        .stars { color: #F59E0B; font-size: 13px; }
        .rating-score { font-weight: 700; color: var(--text); }
        .rating-count { color: var(--text-muted); font-size: 12px; }

        .metrics-row {
            display: flex;
            gap: 16px;
            padding: 12px 16px;
            background: rgba(9, 60, 98, 0.03);
            border-radius: var(--radius-sm);
            margin-bottom: 16px;
        }
        .metric-item {
            flex: 1;
            text-align: center;
        }
        .metric-val {
            font-size: 16px;
            font-weight: 800;
            color: var(--primary);
        }
        .metric-lbl {
            font-size: 11px;
            color: var(--text-muted);
            font-weight: 600;
            text-transform: uppercase;
        }

        .inst-bio {
            font-size: 14px;
            color: var(--text-muted);
            line-height: 1.6;
            margin-bottom: 20px;
            flex: 1;
        }

        .skills-wrap {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-bottom: 24px;
        }
        .skill-tag {
            font-size: 11px;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 999px;
            background: rgba(7, 111, 164, 0.08);
            color: var(--primary-dark);
            border: 1px solid rgba(7, 111, 164, 0.14);
        }

        .card-actions {
            display: flex;
            gap: 12px;
            padding-top: 16px;
            border-top: 1px solid var(--border);
        }
        .btn-course-action {
            flex: 1;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 12px;
            background: var(--primary);
            color: #fff;
            border-radius: var(--radius-sm);
            font-size: 13px;
            font-weight: 700;
            text-decoration: none;
            transition: all var(--t-fast);
        }
        .btn-course-action:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 4px 14px rgba(7, 111, 164, 0.3);
        }
        .btn-chat-action {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 44px;
            height: 44px;
            border-radius: var(--radius-sm);
            border: 1px solid var(--border);
            color: var(--primary);
            background: var(--surface);
            font-size: 15px;
            transition: all var(--t-fast);
        }
        .btn-chat-action:hover {
            background: rgba(7, 111, 164, 0.1);
            border-color: var(--primary);
            transform: translateY(-2px);
        }

        /* Banner CTA */
        .instructor-join-banner {
            margin: 60px 0 20px;
            background: linear-gradient(135deg, var(--primary-dark), var(--primary));
            border-radius: var(--radius-lg);
            padding: 48px;
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 32px;
            box-shadow: var(--shadow-lg);
        }
        .join-text h3 { color: white; font-size: 26px; font-weight: 800; margin-bottom: 8px; }
        .join-text p { color: rgba(255, 255, 255, 0.85); font-size: 15px; max-width: 580px; margin: 0; }
        .join-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 14px 28px;
            background: #fff;
            color: var(--primary-dark);
            border-radius: 999px;
            font-size: 15px;
            font-weight: 700;
            text-decoration: none;
            white-space: nowrap;
            transition: all var(--t-fast);
            box-shadow: 0 4px 15px rgba(0,0,0,0.15);
        }
        .join-btn:hover {
            transform: scale(1.04);
            box-shadow: 0 8px 24px rgba(0,0,0,0.25);
            background: #f8fafc;
        }

        @media (max-width: 768px) {
            .instructors-grid { grid-template-columns: 1fr; }
            .instructor-join-banner { flex-direction: column; text-align: center; padding: 32px 24px; }
            .join-btn { width: 100%; justify-content: center; }
        }
    </style>
</head>
<body class="mesh-bg">

<!-- DYNAMIC ISLAND NAVBAR -->
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
        <% if (currentUser != null) { %>

            <%@ include file="/WEB-INF/views/partials/user-dropdown-style.jspf" %>
                        <a href="<%= "student".equals(role) ? (request.getContextPath() + "/wallet/topup") : (request.getContextPath() + "/profile") %>" class="wallet-badge" title="Số dư ví - Bấm để nạp tiền/quản lý ví">
                <i class="fa-solid fa-wallet"></i>
                <span><%= (currentUser.getBalance() != null ? String.format(java.util.Locale.US, "%,dđ", currentUser.getBalance().longValue()) : "0đ") %></span>
            </a>
            <div class="user-dropdown">
                <div class="user-badge">
                    <% if (currentUser.getAvatarUrl() != null && !currentUser.getAvatarUrl().trim().isEmpty()) { %>
                        <img src="<%=currentUser.getAvatarUrl()%>" alt="Avatar" class="user-avatar" style="object-fit: cover;">
                    <% } else { %>
                        <div class="user-avatar"><%=currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName().substring(0,1).toUpperCase() : "U"%></div>
                    <% } %>
                    <span><%=currentUser.getFullName()%></span>
                    <span class="role-tag"><%=role%></span>
                    <i class="fa-solid fa-chevron-down user-dropdown-chevron"></i>
                </div>
                <div class="user-dropdown-menu" style="display: none;">
                    <a href="<%= "student".equals(role) ? (request.getContextPath() + "/wallet/topup") : (request.getContextPath() + "/profile") %>" class="user-dropdown-item wallet-dropdown-item">
                        <i class="fa-solid fa-wallet"></i>
                        <span>Ví cá nhân</span>
                        <strong class="wallet-dropdown-balance"><%= (currentUser.getBalance() != null ? String.format(java.util.Locale.US, "%,dđ", currentUser.getBalance().longValue()) : "0đ") %></strong>
                    </a>
                    <% if ("student".equals(role)) { %>
                        <a href="<%=request.getContextPath()%>/dashboard" class="user-dropdown-item">
                            <i class="fa-solid fa-table-columns"></i> Bảng điều khiển
                        </a>
                        <a href="<%=request.getContextPath()%>/student/my-courses" class="user-dropdown-item">
                            <i class="fa-solid fa-book-open"></i> Khóa học của tôi
                        </a>
                    <% } %>
                    <a href="<%=request.getContextPath()%>/courses" class="user-dropdown-item">
                        <i class="fa-solid fa-graduation-cap"></i> Khóa học
                    </a>
                    <a href="<%=request.getContextPath()%>/profile" class="user-dropdown-item">
                        <i class="fa-solid fa-id-badge"></i> Hồ sơ
                    </a>
                    <% if (!"admin".equals(role)) { %>
                        <a href="<%=request.getContextPath()%>/report-issue.jsp" class="user-dropdown-item">
                            <i class="fa-solid fa-triangle-exclamation"></i> Báo cáo
                        </a>
                    <% } %>
                </div>
            </div>
            <% if ("instructor".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/instructor/courses" class="btn btn-outline">Quản lý</a>
            <% } else if ("admin".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/admin" class="btn btn-outline">Quản trị</a>
            <% } %>
            <a href="<%=request.getContextPath()%>/logout" class="btn btn-danger">Đăng xuất</a>
        <% } else { %>
            <a href="<%=request.getContextPath()%>/courses" class="nav-link">Khóa học</a>
            <a href="<%=request.getContextPath()%>/login" class="btn btn-outline">Đăng nhập</a>
            <a href="<%=request.getContextPath()%>/register" class="btn btn-primary">Đăng ký</a>
        <% } %>
    </div>
</nav>

<!-- PAGE HERO -->
<header class="page-hero">
    <div class="container">
        <div class="hero-badge">
            <i class="fa-solid fa-chalkboard-user"></i> Đội ngũ Chuyên gia Hàng đầu
        </div>
        <h1 class="page-title">Gặp gỡ <span>Giảng viên Tiêu biểu</span></h1>
        <p class="page-subtitle">
            Học tập và đồng hành trực tiếp cùng đội ngũ kiến trúc sư trưởng, kỹ sư phần mềm cao cấp và các nhà nghiên cứu AI giàu kinh nghiệm thực chiến từ các tập đoàn công nghệ lớn.
        </p>

        <div class="instructor-stats-strip">
            <div class="stat-strip-card">
                <div class="num">50+</div>
                <div class="lbl">Chuyên gia & Giảng viên</div>
            </div>
            <div class="stat-strip-card">
                <div class="num">98.5%</div>
                <div class="lbl">Đánh giá 5 sao từ học viên</div>
            </div>
            <div class="stat-strip-card">
                <div class="num">25,000+</div>
                <div class="lbl">Học viên đã hoàn thành</div>
            </div>
            <div class="stat-strip-card">
                <div class="num">100%</div>
                <div class="lbl">Kinh nghiệm thực chiến</div>
            </div>
        </div>
    </div>
</header>

<!-- MAIN CONTENT -->
<main class="instructors-section">
    <div class="container">

        <!-- Category Filters -->
        <div class="filter-bar">
            <button class="filter-pill active" onclick="filterInstructors('all', this)">Tất cả lĩnh vực</button>
            <button class="filter-pill" onclick="filterInstructors('java', this)">Java & Hệ thống Phân tán</button>
            <button class="filter-pill" onclick="filterInstructors('ai', this)">Trí tuệ Nhân tạo & LLMs</button>
            <button class="filter-pill" onclick="filterInstructors('cloud', this)">Cloud AWS & Kubernetes</button>
            <button class="filter-pill" onclick="filterInstructors('data', this)">Big Data & SQL Tuning</button>
        </div>

        <!-- Instructors Cards Grid -->
        <div class="instructors-grid" id="instructorsGrid">
            <% if (instructors != null) {
                for (InstructorItem inst : instructors) {
                    String categoryClass = "";
                    if (inst.getName().contains("Tú")) categoryClass = "cat-java";
                    else if (inst.getName().contains("Trung")) categoryClass = "cat-ai";
                    else if (inst.getName().contains("Tín")) categoryClass = "cat-cloud";
                    else if (inst.getName().contains("Thành")) categoryClass = "cat-data";
            %>
            <article class="instructor-card <%=categoryClass%>" data-category="<%=categoryClass%>">
                <div class="card-top-accent"></div>
                <div class="card-body">
                    <div class="inst-header">
                        <div class="inst-avatar-wrap">
                            <div class="inst-avatar" style="background: <%=inst.getAvatarBg()%>;"><%=inst.getInitials()%></div>
                            <div class="verified-badge" title="Giảng viên đã xác minh uy tín"><i class="fa-solid fa-check"></i></div>
                        </div>
                        <div class="inst-names">
                            <h3>Thầy <%=inst.getName()%></h3>
                            <span class="inst-role-badge"><%=inst.getTitle()%></span>
                            <div class="inst-org"><i class="fa-solid fa-building-columns"></i> <%=inst.getOrg()%></div>
                        </div>
                    </div>

                    <div class="rating-box">
                        <span class="stars"><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i></span>
                        <span class="rating-score"><%=inst.getRating()%></span>
                        <span class="rating-count">(<%=inst.getReviews()%>)</span>
                    </div>

                    <div class="metrics-row">
                        <div class="metric-item">
                            <div class="metric-val"><%=inst.getCoursesCount()%></div>
                            <div class="metric-lbl">Khóa học</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-val"><%=inst.getStudents()%></div>
                            <div class="metric-lbl">Học viên</div>
                        </div>
                        <div class="metric-item">
                            <div class="metric-val">100%</div>
                            <div class="metric-lbl">Hài lòng</div>
                        </div>
                    </div>

                    <p class="inst-bio"><%=inst.getBio()%></p>

                    <div class="skills-wrap">
                        <% for (String skill : inst.getSkills()) { %>
                            <span class="skill-tag"><i class="fa-solid fa-bolt"></i> <%=skill%></span>
                        <% } %>
                    </div>

                    <div class="card-actions">
                        <a href="<%=request.getContextPath()%>/<%=inst.getCourseUrl()%>" class="btn-course-action">
                            <i class="fa-solid fa-book-open"></i> Xem khóa học giảng dạy
                        </a>
                        <a href="<%=request.getContextPath()%>/chat" class="btn-chat-action" title="Nhắn tin trao đổi học tập">
                            <i class="fa-solid fa-paper-plane"></i>
                        </a>
                    </div>
                </div>
            </article>
            <%   }
               } %>
        </div>

        <!-- Join Faculty Banner -->
        <section class="instructor-join-banner">
            <div class="join-text">
                <h3>Bạn muốn gia nhập đội ngũ Giảng viên UTEdu?</h3>
                <p>Lan tỏa tri thức, chia sẻ kinh nghiệm thực chiến và cùng chúng tôi đào tạo thế hệ kỹ sư công nghệ tương lai với chế độ đãi ngộ hàng đầu.</p>
            </div>
            <a href="<%=request.getContextPath()%>/register" class="join-btn">
                <i class="fa-solid fa-handshake"></i> Đăng ký Giảng dạy
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
    function filterInstructors(category, btn) {
        document.querySelectorAll('.filter-pill').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        const cards = document.querySelectorAll('.instructor-card');
        cards.forEach(card => {
            if (category === 'all') {
                card.style.display = 'flex';
            } else {
                const match = card.getAttribute('data-category') === ('cat-' + category);
                card.style.display = match ? 'flex' : 'none';
            }
        });
    }
</script>
</body>
</html>
