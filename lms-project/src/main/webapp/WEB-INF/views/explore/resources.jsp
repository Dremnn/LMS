<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.lms.model.User, com.lms.controller.ExploreServlet.ResourceItem" %>
<%
    List<ResourceItem> resources = (List<ResourceItem>) request.getAttribute("resources");
    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thư viện Tài liệu & Mã nguồn Mẫu - UTEdu LMS</title>
    
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

        /* Search & Filter Bar */
        .search-filter-box {
            max-width: 760px;
            margin: 36px auto 0;
            padding: 0 16px;
        }
        .search-input-wrap {
            position: relative;
            margin-bottom: 20px;
        }
        .search-input-wrap i {
            position: absolute;
            left: 20px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
            font-size: 18px;
        }
        .search-resource-input {
            width: 100%;
            padding: 16px 20px 16px 52px;
            border-radius: 999px;
            border: 2px solid var(--border);
            background: var(--surface);
            font-size: 15px;
            color: var(--text);
            font-family: inherit;
            box-shadow: var(--shadow-sm);
            transition: all var(--t-fast);
        }
        .search-resource-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(7, 111, 164, 0.15);
        }

        .filter-tags {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 10px;
        }
        .filter-btn {
            padding: 8px 18px;
            border-radius: 999px;
            font-size: 13px;
            font-weight: 600;
            background: var(--surface);
            border: 1px solid var(--border);
            color: var(--text-muted);
            cursor: pointer;
            transition: all var(--t-fast);
        }
        .filter-btn:hover,
        .filter-btn.active {
            background: var(--primary);
            color: #fff;
            border-color: var(--primary);
            box-shadow: 0 4px 12px rgba(7, 111, 164, 0.25);
        }

        /* Resource Grid */
        .resources-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 28px;
            margin: 40px 0 60px;
        }
        .resource-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            padding: 28px;
            box-shadow: var(--shadow-sm);
            display: flex;
            flex-direction: column;
            transition: all var(--t-smooth);
            position: relative;
        }
        .resource-card:hover {
            transform: translateY(-6px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary);
        }
        .res-top-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
        }
        .res-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.5px;
            color: white;
        }
        .res-downloads {
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .res-title {
            font-size: 18px;
            font-weight: 800;
            color: var(--text);
            line-height: 1.4;
            margin-bottom: 8px;
        }
        .res-author {
            font-size: 12px;
            color: var(--primary);
            font-weight: 600;
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .res-desc {
            font-size: 14px;
            color: var(--text-muted);
            line-height: 1.6;
            margin-bottom: 20px;
            flex: 1;
        }

        .res-meta-row {
            display: flex;
            gap: 16px;
            padding: 10px 14px;
            background: rgba(9, 60, 98, 0.03);
            border-radius: var(--radius-sm);
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 600;
            margin-bottom: 20px;
        }
        .res-meta-item {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .res-card-actions {
            display: flex;
            gap: 12px;
        }
        .btn-download-res {
            flex: 1;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 12px 18px;
            background: var(--primary);
            color: #FFFFFF;
            border-radius: var(--radius-sm);
            font-size: 13px;
            font-weight: 700;
            border: none;
            cursor: pointer;
            transition: all var(--t-fast);
        }
        .btn-download-res:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 4px 14px rgba(7, 111, 164, 0.3);
        }
        .btn-preview-res {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 12px 16px;
            background: transparent;
            color: var(--text-muted);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all var(--t-fast);
        }
        .btn-preview-res:hover {
            background: rgba(7, 111, 164, 0.08);
            color: var(--primary);
            border-color: var(--primary);
        }

        /* Toast Download Notification */
        .download-toast {
            position: fixed;
            bottom: 30px;
            right: 30px;
            background: #093C62;
            color: #FFFFFF;
            padding: 16px 24px;
            border-radius: var(--radius);
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            display: flex;
            align-items: center;
            gap: 12px;
            z-index: 9999;
            transform: translateY(100px);
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s cubic-bezier(0.22, 1, 0.36, 1);
        }
        .download-toast.show {
            transform: translateY(0);
            opacity: 1;
            visibility: visible;
        }

        /* Contribution Box */
        .contribution-banner {
            background: linear-gradient(135deg, var(--primary-dark), #093C62);
            border-radius: var(--radius-lg);
            padding: 40px;
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 32px;
            box-shadow: var(--shadow-lg);
            margin-bottom: 20px;
        }
        .contribute-text h3 { font-size: 22px; font-weight: 800; color: white; margin-bottom: 8px; }
        .contribute-text p { font-size: 14px; color: rgba(255, 255, 255, 0.85); margin: 0; max-width: 600px; }
        .contribute-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 12px 24px;
            background: #FFFFFF;
            color: var(--primary-dark);
            border-radius: 999px;
            font-size: 14px;
            font-weight: 700;
            text-decoration: none;
            white-space: nowrap;
            transition: all var(--t-fast);
        }
        .contribute-btn:hover {
            transform: scale(1.04);
            box-shadow: 0 6px 20px rgba(0,0,0,0.2);
            background: #F8FAFC;
        }

        @media (max-width: 768px) {
            .resources-grid { grid-template-columns: 1fr; }
            .contribution-banner { flex-direction: column; text-align: center; padding: 28px; }
            .contribute-btn { width: 100%; justify-content: center; }
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
        <% if (currentUser != null) { %>

            <%@ include file="/WEB-INF/views/partials/user-dropdown-style.jspf" %>
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
            <i class="fa-solid fa-book-bookmark"></i> Kho Tài nguyên Học tập Số
        </div>
        <h1 class="page-title">Thư viện Tài liệu & <span>Mã nguồn Mẫu</span></h1>
        <p class="page-subtitle">
            Tải miễn phí các cẩm nang công nghệ chuyên sâu, cheat sheet tổng hợp, bộ đề ôn tập và starter kits mã nguồn đồ án hoàn chỉnh được ban chuyên môn UTEdu biên soạn.
        </p>

        <!-- Search Bar -->
        <div class="search-filter-box">
            <div class="search-input-wrap">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input type="text" id="resourceSearchInput" class="search-resource-input"
                       placeholder="Tìm kiếm tài liệu theo tên, công nghệ (Java, AI, SQL, Cloud...)"
                       oninput="filterResources()">
            </div>
            <div class="filter-tags">
                <button class="filter-btn active" onclick="setCategoryFilter('all', this)">Tất cả</button>
                <button class="filter-btn" onclick="setCategoryFilter('java', this)">Java & Spring Boot</button>
                <button class="filter-btn" onclick="setCategoryFilter('ai', this)">AI & LLMs</button>
                <button class="filter-btn" onclick="setCategoryFilter('database', this)">Cơ sở Dữ liệu & SQL</button>
                <button class="filter-btn" onclick="setCategoryFilter('cloud', this)">Cloud DevOps</button>
                <button class="filter-btn" onclick="setCategoryFilter('career', this)">Phỏng vấn Tuyển dụng</button>
            </div>
        </div>
    </div>
</header>

<!-- MAIN CONTENT -->
<main style="padding: 20px 0 60px;">
    <div class="container">

        <!-- Resources Grid -->
        <div class="resources-grid" id="resourcesGrid">
            <% if (resources != null) {
                for (ResourceItem res : resources) {
            %>
            <article class="resource-card" data-category="<%=res.getCategory()%>" data-title="<%=res.getTitle().toLowerCase()%>">
                <div class="res-top-row">
                    <span class="res-badge" style="background: <%=res.getFormatColor()%>;"><i class="fa-solid <%=res.getIcon()%>"></i> <%=res.getFormat()%></span>
                    <span class="res-downloads"><i class="fa-solid fa-download"></i> <%=res.getDownloads()%> lượt</span>
                </div>

                <h3 class="res-title"><%=res.getTitle()%></h3>
                <div class="res-author"><i class="fa-solid fa-user-pen"></i> <%=res.getAuthor()%></div>
                <p class="res-desc"><%=res.getDescription()%></p>

                <div class="res-meta-row">
                    <div class="res-meta-item"><i class="fa-regular fa-hard-drive"></i> <%=res.getSize()%></div>
                    <div class="res-meta-item"><i class="fa-regular fa-file"></i> <%=res.getPagesOrItems()%> <%=res.getPagesLabel()%></div>
                    <div class="res-meta-item"><i class="fa-solid fa-graduation-cap"></i> <%=res.getLevel()%></div>
                </div>

                <div class="res-card-actions">
                    <button class="btn-download-res" onclick="triggerDownload('<%=res.getTitle()%>')">
                        <i class="fa-solid fa-arrow-down-to-bracket"></i> Tải tài liệu
                    </button>
                    <button class="btn-preview-res" onclick="triggerPreview('<%=res.getTitle()%>', '<%=res.getAuthor()%>', '<%=res.getDescription()%>')">
                        <i class="fa-solid fa-eye"></i> Xem trước
                    </button>
                </div>
            </article>
            <%   }
               } %>
        </div>

        <!-- Contribution Banner -->
        <section class="contribution-banner">
            <div class="contribute-text">
                <h3>Bạn muốn đóng góp tài liệu cho Thư viện UTEdu?</h3>
                <p>Chia sẻ các bài viết, đồ án mẫu hoặc cheat sheet tự soạn. Tài liệu được hội đồng học thuật duyệt sẽ được trao thưởng học bổng khóa học.</p>
            </div>
            <a href="mailto:hotro@utedu.vn?subject=[UTEdu%20Resources]%20Đóng%20góp%20tài%20liệu" class="contribute-btn">
                <i class="fa-solid fa-cloud-arrow-up"></i> Gửi Tài liệu Đóng góp
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

<!-- Toast Notification -->
<div id="downloadToast" class="download-toast">
    <i class="fa-solid fa-circle-check" style="color: #10B981; font-size: 20px;"></i>
    <div>
        <div style="font-weight: 700; font-size: 14px;">Bắt đầu tải tài liệu!</div>
        <div id="toastMessage" style="font-size: 12px; color: #94A3B8;">Tài liệu đang được tải xuống thiết bị của bạn.</div>
    </div>
</div>

<!-- Dynamic Island Theme Toggle -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="<%=request.getContextPath()%>/assets/js/lms-app.js?v=39"></script>
<script>
    let currentCategory = 'all';

    function setCategoryFilter(category, btn) {
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        currentCategory = category;
        filterResources();
    }

    function filterResources() {
        const query = document.getElementById('resourceSearchInput').value.trim().toLowerCase();
        const cards = document.querySelectorAll('.resource-card');

        cards.forEach(card => {
            const cardCat = card.getAttribute('data-category');
            const cardTitle = card.getAttribute('data-title');
            
            const matchesCat = (currentCategory === 'all' || cardCat === currentCategory);
            const matchesQuery = (!query || cardTitle.includes(query));

            card.style.display = (matchesCat && matchesQuery) ? 'flex' : 'none';
        });
    }

    function triggerDownload(title) {
        const toast = document.getElementById('downloadToast');
        const msg = document.getElementById('toastMessage');
        msg.textContent = 'Đang tải: ' + title;
        toast.classList.add('show');
        setTimeout(() => {
            toast.classList.remove('show');
        }, 3500);
    }

    function triggerPreview(title, author, desc) {
        alert("Xem trước tóm tắt tài liệu:\n\n" + title + "\nTác giả: " + author + "\n\nNội dung: " + desc);
    }
</script>
</body>
</html>
