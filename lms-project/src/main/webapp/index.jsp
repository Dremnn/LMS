<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UTEdu LMS - Nền tảng học trực tuyến</title>

    <!-- Preconnect để trình duyệt kết nối sớm tới các CDN, giảm độ trễ tải -->
    <link rel="preconnect" href="https://cdnjs.cloudflare.com">
    <link rel="preconnect" href="https://ajax.googleapis.com">

    <!-- Fonts & Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Google Model Viewer - chỉ dùng cho 1 model Hero duy nhất -->
    <script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/3.4.0/model-viewer.min.js"></script>

    <!-- Custom CSS -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=15">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=15">

    <style>
        .hero-section { display: flex; align-items: center; justify-content: space-between; padding: 60px 0; min-height: 80vh; gap: 40px; }
        .hero-content { flex: 1; max-width: 600px; }
        .hero-content h1 { font-size: 52px; font-weight: 800; line-height: 1.15; margin-bottom: 24px; color: var(--text); }
        .hero-content h1 span { background: linear-gradient(135deg, var(--primary), var(--secondary)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .hero-content p { font-size: 18px; color: var(--text-muted); margin-bottom: 32px; line-height: 1.6; }
        .hero-cta { display: flex; gap: 16px; flex-wrap: wrap; }
        .hero-visual { flex: 1; display: flex; justify-content: center; align-items: center; position: relative; height: 500px; width: 100%; border-radius: 20px; overflow: hidden; }

        .features-section { padding: 80px 0; background: rgba(255, 255, 255, 0.4); border-top: 1px solid var(--border); position: relative; z-index: 5; }
        .section-title { text-align: center; font-size: 38px; margin-bottom: 16px; font-weight: 800; background: linear-gradient(135deg, #1E1B4B, var(--primary)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .section-subtitle { text-align: center; color: var(--text-muted); margin-bottom: 56px; font-size: 18px; max-width: 600px; margin-left: auto; margin-right: auto; font-weight: 500; }

        .features-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 32px; }
        .feature-card {
            position: relative; overflow: hidden;
            padding: 40px 24px; text-align: center;
            border-radius: 24px; border: 1px solid rgba(255,255,255,0.8);
            background: rgba(255, 255, 255, 0.6); backdrop-filter: blur(12px);
            transition: transform 0.3s ease, box-shadow 0.3s ease, border-color 0.3s ease;
            box-shadow: 0 10px 30px rgba(0,0,0,0.02);
        }
        .feature-card:hover { transform: translateY(-8px); border-color: white; box-shadow: 0 20px 40px rgba(79, 70, 229, 0.1); background: rgba(255, 255, 255, 0.85); }

        .feature-icon { width: 90px; height: 90px; margin: 0 auto 20px auto; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 36px; color: #fff; }
        .feature-card:nth-child(1) .feature-icon { background: linear-gradient(135deg, #4f46e5, #ec4899); }
        .feature-card:nth-child(2) .feature-icon { background: linear-gradient(135deg, #8b5cf6, #d946ef); }
        .feature-card:nth-child(3) .feature-icon { background: linear-gradient(135deg, #10b981, #0ea5e9); }
        .feature-card:nth-child(4) .feature-icon { background: linear-gradient(135deg, #f59e0b, #ef4444); }

        .feature-card h3 { font-size: 22px; margin-bottom: 16px; font-weight: 800; }
        .feature-card:nth-child(1) h3 { background: linear-gradient(135deg, #4f46e5, #ec4899); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .feature-card:nth-child(2) h3 { background: linear-gradient(135deg, #8b5cf6, #d946ef); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .feature-card:nth-child(3) h3 { background: linear-gradient(135deg, #10b981, #0ea5e9); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .feature-card:nth-child(4) h3 { background: linear-gradient(135deg, #f59e0b, #ef4444); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }

        .feature-card p { color: #4b5563; font-size: 15px; line-height: 1.6; font-weight: 500; }

        .stats-section { padding: 100px 0; background: radial-gradient(circle at top center, #312E81 0%, #0B0F19 100%); color: white; text-align: center; position: relative; overflow: hidden; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 40px; position: relative; z-index: 10; }

        .stat-card {
            padding: 40px 20px; background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 24px; backdrop-filter: blur(8px);
            box-shadow: 0 10px 40px rgba(0,0,0,0.3); transition: border-color 0.3s ease;
        }
        .stat-card:hover { border-color: rgba(56, 189, 248, 0.4); }

        .stat-card h2 { font-size: 64px; background: linear-gradient(135deg, #38bdf8, #818cf8); -webkit-background-clip: text; -webkit-text-fill-color: transparent; margin-bottom: 8px; font-weight: 900; }
        .stat-card p { font-size: 16px; color: #94A3B8; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; }

        .widget-pos { position: absolute; z-index: 5; pointer-events: auto; }
        .widget-1 { top: 15%; right: 5%; }
        .widget-2 { bottom: 15%; right: 32%; }
        .widget-3 { top: 11%; left: 5%; }

        .floating-widget {
            display: flex; align-items: center; gap: 12px;
            background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(10px);
            padding: 12px 24px 12px 12px; border-radius: 100px;
            border: 1px solid rgba(255,255,255,0.9);
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .floating-widget:hover { box-shadow: 0 20px 40px rgba(0,0,0,0.15); }

        .widget-icon { width: 44px; height: 44px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 18px; }
        .widget-text h4 { font-size: 15px; font-weight: 800; color: #1E293B; margin: 0 0 2px 0; }
        .widget-text p { font-size: 13px; color: #64748B; margin: 0; font-weight: 500; }

        @keyframes floatOrganic { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-16px); } }

        @media (max-width: 992px) {
            .widget-pos { display: none; }
            .hero-section { flex-direction: column; text-align: center; padding-top: 40px; }
            .hero-content { margin-bottom: 40px; }
            .hero-cta { justify-content: center; }
            .hero-visual { height: 350px; }
        }
    </style>
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">

<%
    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";
%>

<!-- Navbar -->
<nav class="lms-navbar">
    <a href="<%=request.getContextPath()%>/" class="lms-logo">
        <img src="<%=request.getContextPath()%>/assets/images/utedu-logo.png" alt="UTEdu" class="lms-logo-img">
        <span class="logo-tag">LMS</span>
    </a>
    <div class="nav-links">
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

<!-- Hero Section -->
<section class="container hero-section" style="position: relative; z-index: 1;">

    <div class="widget-pos widget-1">
        <div class="floating-widget">
            <div class="widget-icon" style="background: linear-gradient(135deg, #f59e0b, #ef4444);"><i class="fa-solid fa-book-open-reader"></i></div>
            <div class="widget-text"><h4>Thư viện số</h4><p>15,000+ tài liệu</p></div>
        </div>
    </div>

    <div class="widget-pos widget-2">
        <div class="floating-widget">
            <div class="widget-icon" style="background: linear-gradient(135deg, #10b981, #0ea5e9);"><i class="fa-solid fa-chart-pie"></i></div>
            <div class="widget-text"><h4>Tiến độ</h4><p>Tăng trưởng 45%</p></div>
        </div>
    </div>

    <div class="widget-pos widget-3">
        <div class="floating-widget">
            <div class="widget-icon" style="background: linear-gradient(135deg, #8b5cf6, #d946ef);"><i class="fa-solid fa-graduation-cap"></i></div>
            <div class="widget-text"><h4>Chứng chỉ</h4><p>Quốc tế & Uy tín</p></div>
        </div>
    </div>

    <div class="hero-content">
        <h1>Nền tảng Học trực tuyến <br><span>Thứ hai Việt Nam</span></h1>
        <p>Trải nghiệm môi trường học tập hiện đại, lộ trình rõ ràng, theo dõi tiến độ trực quan mỗi ngày.</p>
        <div class="hero-cta">
            <% if (currentUser == null) { %>
                <a href="<%=request.getContextPath()%>/courses" class="btn btn-primary"><i class="fa-solid fa-rocket"></i> Khám phá ngay</a>
                <a href="<%=request.getContextPath()%>/register" class="btn btn-outline"><i class="fa-solid fa-user-plus"></i> Tạo tài khoản miễn phí</a>
            <% } else if ("student".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/student/my-courses" class="btn btn-primary"><i class="fa-solid fa-book-open"></i> Vào học tiếp</a>
            <% } else if ("instructor".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/instructor/courses/new" class="btn btn-primary"><i class="fa-solid fa-circle-plus"></i> Tạo khóa mới</a>
            <% } %>
        </div>
    </div>

    <!-- Model 3D Hero - đã bỏ auto-rotate, thêm loading=lazy để không tốn tài nguyên ngay từ đầu -->
    <div class="hero-visual">
        <model-viewer alt="Mô hình 3D"
                      src="<%=request.getContextPath()%>/assets/models/3d.glb"
                      camera-controls
                      loading="lazy"
                      style="width: 100%; height: 100%; background-color: transparent;">
        </model-viewer>
    </div>
</section>

<!-- Features -->
<section class="features-section">
    <div class="container">
        <h2 class="section-title">Vì sao chọn UTEdu LMS?</h2>
        <p class="section-subtitle">Chúng tôi mang đến trải nghiệm học thuật chuyên nghiệp kết hợp sự sáng tạo, chuẩn giáo dục Việt Nam.</p>

        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon"><i class="fa-solid fa-route"></i></div>
                <h3>Lộ trình chuẩn</h3>
                <p>Giáo trình được thiết kế bài bản từ các chuyên gia hàng đầu trong ngành công nghệ.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon"><i class="fa-solid fa-certificate"></i></div>
                <h3>Chứng chỉ uy tín</h3>
                <p>Nhận chứng chỉ hoàn thành khóa học được công nhận bởi hàng trăm doanh nghiệp.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon"><i class="fa-solid fa-chart-line"></i></div>
                <h3>Thống kê trực quan</h3>
                <p>Theo dõi tiến độ học tập với biểu đồ thông minh, tạo động lực học tập mỗi ngày.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon"><i class="fa-solid fa-bolt"></i></div>
                <h3>Tốc độ cực nhanh</h3>
                <p>Hệ thống mượt mà, chuyển trang không độ trễ, tối ưu hóa cho mọi thiết bị.</p>
            </div>
        </div>
    </div>
</section>

<!-- Stats Counter -->
<section class="stats-section">
    <div class="container stats-grid">
        <div class="stat-card">
            <h2><span class="counter-val" data-target="1200">0</span>+</h2>
            <p>Học viên tham gia</p>
        </div>
        <div class="stat-card">
            <h2><span class="counter-val" data-target="50">0</span>+</h2>
            <p>Khóa học chất lượng</p>
        </div>
        <div class="stat-card">
            <h2><span class="counter-val" data-target="4">0</span>.8★</h2>
            <p>Đánh giá trung bình</p>
        </div>
    </div>
</section>

<!-- Footer -->
<footer class="lms-footer modern-footer">
    <div class="container">
        <div class="footer-grid" style="align-items: flex-start;">
            <div class="footer-col brand-col">
                <a href="<%=request.getContextPath()%>/" class="lms-logo footer-logo" style="margin-bottom: 16px;">
                    <span class="logo-icon">🎓</span><span class="logo-text">UTEdu LMS</span>
                </a>
                <p class="footer-desc">Nền tảng học trực tuyến. Nâng tầm tri thức, kiến tạo tương lai thế hệ trẻ.</p>
                <div class="social-links">
                    <a href="#" class="social-icon"><i class="fa-brands fa-facebook-f"></i></a>
                    <a href="#" class="social-icon"><i class="fa-brands fa-youtube"></i></a>
                    <a href="#" class="social-icon"><i class="fa-brands fa-tiktok"></i></a>
                    <a href="#" class="social-icon"><i class="fa-brands fa-linkedin-in"></i></a>
                </div>
            </div>

            <div class="footer-col">
                <h4 class="footer-title">Khám phá</h4>
                <ul class="footer-links">
                    <li><a href="<%=request.getContextPath()%>/courses">Khoá học nổi bật</a></li>
                    <li><a href="#">Giảng viên tiêu biểu</a></li>
                    <li><a href="#">Lộ trình học tập</a></li>
                    <li><a href="#">Thư viện tài liệu</a></li>
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

<!-- Tạm dừng animation của widget khi cuộn ra khỏi màn hình, tiết kiệm tài nguyên -->
<script>
    if ('IntersectionObserver' in window) {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                entry.target.style.animationPlayState = entry.isIntersecting ? 'running' : 'paused';
            });
        });
        document.querySelectorAll('.floating-widget').forEach(el => observer.observe(el));
    }
</script>

<!-- Dynamic Island Theme Toggle (Lưu tùy chọn vào Cookie 365 ngày) -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<!-- App Scripts -->
<script src="<%=request.getContextPath()%>/assets/js/lms-app.js?v=16"></script>
</body>
</html>