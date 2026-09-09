<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EduViet LMS - Nền tảng học trực tuyến</title>
    
    <!-- Fonts & Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Google Model Viewer Script for .glb files -->
    <script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/3.4.0/model-viewer.min.js"></script>
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=14">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=14">
    
    <style>
        /* Specific Index Styles */
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
            position: relative; z-index: 10; overflow: hidden;
            padding: 40px 24px; text-align: center; 
            border-radius: 24px; border: 1px solid rgba(255,255,255,0.8); 
            background: rgba(255, 255, 255, 0.6); backdrop-filter: blur(16px); 
            transition: all 0.4s cubic-bezier(0.2, 1, 0.3, 1); 
            box-shadow: 0 10px 30px rgba(0,0,0,0.02);
        }
        /* Spotlight Effect inside card */
        .feature-card::before {
            content: ""; position: absolute; top: 0; left: 0; right: 0; bottom: 0;
            background: radial-gradient(600px circle at var(--mouse-x, 50%) var(--mouse-y, 50%), rgba(255, 255, 255, 0.8), transparent 40%);
            z-index: 0; opacity: 0; transition: opacity 0.5s; pointer-events: none;
        }
        .feature-card:hover::before { opacity: 1; }
        .feature-card:hover { transform: translateY(-12px); border-color: white; box-shadow: 0 20px 40px rgba(79, 70, 229, 0.1); background: rgba(255, 255, 255, 0.85); }
        
        .feature-card h3 { position: relative; z-index: 2; font-size: 22px; margin-bottom: 16px; font-weight: 800; }
        /* Colorful Gradient Text for each card */
        .feature-card:nth-child(1) h3 { background: linear-gradient(135deg, #4f46e5, #ec4899); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .feature-card:nth-child(2) h3 { background: linear-gradient(135deg, #06b6d4, #3b82f6); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .feature-card:nth-child(3) h3 { background: linear-gradient(135deg, #f59e0b, #ef4444); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .feature-card:nth-child(4) h3 { background: linear-gradient(135deg, #10b981, #0ea5e9); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        
        .feature-card p { position: relative; z-index: 2; color: #4b5563; font-size: 15px; line-height: 1.6; font-weight: 500; }
        
        /* 3D Stats Counter Section */
        .stats-section { padding: 100px 0; background: radial-gradient(circle at top center, #312E81 0%, #0B0F19 100%); color: white; text-align: center; position: relative; overflow: hidden; }
        /* 3D Cyberpunk Grid Background */
        .stats-section::before {
            content: ""; position: absolute; top: 0; left: -50%; right: -50%; bottom: -50%;
            background-image: linear-gradient(rgba(255,255,255,0.05) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.05) 1px, transparent 1px);
            background-size: 40px 40px;
            transform: perspective(600px) rotateX(60deg) translateY(-100px) translateZ(-200px);
            opacity: 0.8; pointer-events: none;
        }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 40px; position: relative; z-index: 10; }
        
        .stat-card {
            padding: 40px 20px; background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 24px; backdrop-filter: blur(12px);
            position: relative; overflow: hidden;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3); transition: all 0.4s ease;
        }
        .stat-card::before {
            content: ""; position: absolute; top: 0; left: 0; right: 0; bottom: 0;
            background: radial-gradient(400px circle at var(--mouse-x, 50%) var(--mouse-y, 50%), rgba(56, 189, 248, 0.3), transparent 40%);
            z-index: 0; opacity: 0; transition: opacity 0.5s; pointer-events: none;
        }
        .stat-card:hover::before { opacity: 1; }
        .stat-card:hover { border-color: rgba(56, 189, 248, 0.4); }
        
        .stat-card h2 { position: relative; z-index: 2; font-size: 64px; background: linear-gradient(135deg, #38bdf8, #818cf8); -webkit-background-clip: text; -webkit-text-fill-color: transparent; margin-bottom: 8px; font-weight: 900; filter: drop-shadow(0 0 15px rgba(56,189,248,0.2)); }
        .stat-card p { position: relative; z-index: 2; font-size: 16px; color: #94A3B8; font-weight: 600; letter-spacing: 2px; text-transform: uppercase; }
        
        /* Floating Library Widgets (Digital Elements) */
        .widget-pos { position: absolute; z-index: 5; pointer-events: auto; cursor: pointer; }
        .widget-1 { top: 15%; right: 5%; }
        .widget-2 { bottom: 15%; right: 32%; }
        .widget-3 { top: 11%; left: 5%; }
        
        .floating-widget {
            display: flex; align-items: center; gap: 12px;
            background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(16px);
            padding: 12px 24px 12px 12px; border-radius: 100px;
            border: 1px solid rgba(255,255,255,0.9);
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            animation: floatOrganic 6s ease-in-out infinite;
            transition: transform 0.3s cubic-bezier(0.2, 1, 0.3, 1), box-shadow 0.3s, background 0.3s;
        }
        .widget-1 .floating-widget { animation-delay: 0s; }
        .widget-2 .floating-widget { animation-delay: -2s; }
        .widget-3 .floating-widget { animation-delay: -4s; }
        
        /* Interactive Hover on Widgets */
        .floating-widget:hover {
            transform: scale(1.08) translateY(-5px) !important;
            box-shadow: 0 25px 45px rgba(0,0,0,0.15);
            background: rgba(255, 255, 255, 0.95);
        }
        
        @keyframes pulseGlow { 0% { box-shadow: 0 0 0 0 rgba(255,255,255,0.6); } 70% { box-shadow: 0 0 0 15px rgba(255,255,255,0); } 100% { box-shadow: 0 0 0 0 rgba(255,255,255,0); } }
        .widget-icon { width: 44px; height: 44px; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 18px; box-shadow: 0 4px 10px rgba(0,0,0,0.2); animation: pulseGlow 2s infinite; }
        .widget-text h4 { font-size: 15px; font-weight: 800; color: #1E293B; margin: 0 0 2px 0; }
        .widget-text p { font-size: 13px; color: #64748B; margin: 0; font-weight: 500; }
        @keyframes floatOrganic { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-20px); } }
        
        @media (max-width: 992px) {
            .widget-pos { display: none; /* Hide on mobile to prevent clutter */ }
            .hero-section { flex-direction: column; text-align: center; padding-top: 40px; }
            .hero-content { margin-bottom: 40px; }
            .hero-cta { justify-content: center; }
            .hero-visual { height: 350px; }
        }
    </style>
</head>
<body class="mesh-bg">

<!-- Cursor Blob Follower -->
<div id="cursor-blob"></div>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";
%>

<!-- Navbar -->
<nav class="lms-navbar">
    <a href="<%=request.getContextPath()%>/" class="lms-logo">
        <span class="logo-icon">🎓</span>
        <span class="logo-text">EduViet <span class="logo-tag">LMS</span></span>
    </a>
    <div class="nav-links">
        <a href="<%=request.getContextPath()%>/courses" class="nav-link">Khóa học</a>
        
        <% if (currentUser != null) { %>
            <!-- ĐÂY LÀ ĐOẠN CODE MỚI ĐƯỢC THÊM VÀO -->
            <a href="<%=request.getContextPath()%>/student/dashboard" class="nav-link">Bảng điều khiển</a>
            
            <div class="user-badge">
                <div class="user-avatar"><%=currentUser.getFullName().substring(0,1).toUpperCase()%></div>
                <span><%=currentUser.getFullName()%></span>
                <span class="role-tag"><%=role%></span>
            </div>
            <% if ("instructor".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/instructor/courses" class="btn btn-outline">Quản lý</a>
            <% } else if ("admin".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/admin" class="btn btn-outline">Quản trị</a>
            <% } else { %>
                <!-- Bạn cũng có thể đổi chữ "Của tôi" ở dưới đây thành "Bảng điều khiển" nếu muốn thay thế hoàn toàn -->
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
    <!-- Parallax Shapes Background -->
    <div class="parallax-shape shape-1 parallax" data-speed="0.8"></div>
    <div class="parallax-shape shape-2 parallax" data-speed="-0.5"></div>
    <div class="parallax-shape shape-3 parallax" data-speed="0.4"></div>

    <!-- Floating UI Widgets (Thư viện số) -->
    <!-- Widget 1: Thư viện số (Top Right) -->
    <div class="widget-pos widget-1">
        <div class="parallax" data-speed="0.6">
            <div class="floating-widget">
                <div class="widget-icon" style="background: linear-gradient(135deg, #f59e0b, #ef4444);"><i class="fa-solid fa-book-open-reader"></i></div>
                <div class="widget-text"><h4>Thư viện số</h4><p>15,000+ tài liệu</p></div>
            </div>
        </div>
    </div>
    
    <!-- Widget 2: Tiến độ (Bottom Right, under the 3D model) -->
    <div class="widget-pos widget-2">
        <div class="parallax" data-speed="-0.4">
            <div class="floating-widget">
                <div class="widget-icon" style="background: linear-gradient(135deg, #10b981, #0ea5e9);"><i class="fa-solid fa-chart-pie"></i></div>
                <div class="widget-text"><h4>Tiến độ</h4><p>Tăng trưởng 45%</p></div>
            </div>
        </div>
    </div>
    
    <!-- Widget 3: Chứng chỉ (Top Left, out of the text area) -->
    <div class="widget-pos widget-3">
        <div class="parallax" data-speed="0.3">
            <div class="floating-widget">
                <div class="widget-icon" style="background: linear-gradient(135deg, #8b5cf6, #d946ef);"><i class="fa-solid fa-graduation-cap"></i></div>
                <div class="widget-text"><h4>Chứng chỉ</h4><p>Quốc tế & Uy tín</p></div>
            </div>
        </div>
    </div>

    <div class="hero-content reveal-up parallax" data-speed="0.25">
        <h1>Nền tảng Học trực tuyến <br><span>Hàng đầu Việt Nam</span></h1>
        <p>Tương tác với các mô hình học tập 3D sinh động. Trải nghiệm môi trường học tập hiện đại, kéo thả xoay vòng trực quan.</p>
        <div class="hero-cta">
            <% if (currentUser == null) { %>
                <a href="<%=request.getContextPath()%>/courses" class="btn btn-primary animate-pulse"><i class="fa-solid fa-rocket"></i> Khám phá ngay</a>
                <a href="<%=request.getContextPath()%>/register" class="btn btn-outline"><i class="fa-solid fa-user-plus"></i> Tạo tài khoản miễn phí</a>
            <% } else if ("student".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/student/my-courses" class="btn btn-primary"><i class="fa-solid fa-book-open"></i> Vào học tiếp</a>
            <% } else if ("instructor".equals(role)) { %>
                <a href="<%=request.getContextPath()%>/instructor/courses/new" class="btn btn-primary"><i class="fa-solid fa-circle-plus"></i> Tạo khóa mới</a>
            <% } %>
        </div>
    </div>
    
    <!-- 3D GLB Interactive Element -->
    <div class="hero-visual reveal-up reveal-delay-2 parallax" data-speed="-0.3">
        <model-viewer alt="Mô hình 3D" 
                      src="<%=request.getContextPath()%>/assets/models/3d.glb" 
                      camera-controls 
                      auto-rotate 
                      style="width: 100%; height: 100%; background-color: transparent;">
        </model-viewer>
    </div>
</section>

<!-- Features -->
<section class="features-section">
    <div class="container">
        <h2 class="section-title reveal-up">Vì sao chọn EduViet LMS?</h2>
        <p class="section-subtitle reveal-up">Chúng tôi mang đến trải nghiệm học thuật chuyên nghiệp kết hợp sự sáng tạo, chuẩn giáo dục Việt Nam.</p>
        
        <div class="features-grid">
            <div class="feature-card reveal-up">
                <model-viewer alt="Icon 3D" src="<%=request.getContextPath()%>/assets/models/icon1.gltf" auto-rotate rotation-per-second="120deg" camera-controls style="width: 100px; height: 100px; margin: 0 auto 20px auto; background-color: transparent;"></model-viewer>
                <h3>Lộ trình chuẩn</h3>
                <p>Giáo trình được thiết kế bài bản từ các chuyên gia hàng đầu trong ngành công nghệ.</p>
            </div>
            <div class="feature-card reveal-up reveal-delay-1">
                <model-viewer alt="Icon 3D" src="<%=request.getContextPath()%>/assets/models/icon1.gltf" auto-rotate rotation-per-second="120deg" camera-controls style="width: 100px; height: 100px; margin: 0 auto 20px auto; background-color: transparent;"></model-viewer>
                <h3>Chứng chỉ uy tín</h3>
                <p>Nhận chứng chỉ hoàn thành khóa học được công nhận bởi hàng trăm doanh nghiệp.</p>
            </div>
            <div class="feature-card reveal-up reveal-delay-2">
                <model-viewer alt="Icon 3D" src="<%=request.getContextPath()%>/assets/models/icon1.gltf" auto-rotate rotation-per-second="120deg" camera-controls style="width: 100px; height: 100px; margin: 0 auto 20px auto; background-color: transparent;"></model-viewer>
                <h3>Thống kê trực quan</h3>
                <p>Theo dõi tiến độ học tập với biểu đồ thông minh, tạo động lực học tập mỗi ngày.</p>
            </div>
            <div class="feature-card reveal-up reveal-delay-3">
                <model-viewer alt="Icon 3D" src="<%=request.getContextPath()%>/assets/models/icon1.gltf" auto-rotate rotation-per-second="120deg" camera-controls style="width: 100px; height: 100px; margin: 0 auto 20px auto; background-color: transparent;"></model-viewer>
                <h3>Tốc độ cực nhanh</h3>
                <p>Hệ thống mượt mà, chuyển trang không độ trễ, tối ưu hóa cho mọi thiết bị.</p>
            </div>
        </div>
    </div>
</section>

<!-- Stats Counter -->
<section class="stats-section">
    <div class="container stats-grid">
        <div class="stat-card reveal-up">
            <h2><span class="counter-val" data-target="1200">0</span>+</h2>
            <p>Học viên tham gia</p>
        </div>
        <div class="stat-card reveal-up reveal-delay-1">
            <h2><span class="counter-val" data-target="50">0</span>+</h2>
            <p>Khóa học chất lượng</p>
        </div>
        <div class="stat-card reveal-up reveal-delay-2">
            <h2><span class="counter-val" data-target="4">0</span>.8★</h2>
            <p>Đánh giá trung bình</p>
        </div>
    </div>
</section>

<!-- Modern Footer -->
<footer class="lms-footer modern-footer">
    <div class="container">
        <div class="footer-grid" style="align-items: flex-start;">
            <div class="footer-col brand-col">
                <a href="<%=request.getContextPath()%>/" class="lms-logo footer-logo" style="margin-bottom: 16px;">
                    <span class="logo-icon">🎓</span><span class="logo-text">EduViet LMS</span>
                </a>
                <p class="footer-desc">Nền tảng học trực tuyến hàng đầu Việt Nam. Nâng tầm tri thức, kiến tạo tương lai thế hệ trẻ.</p>
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
                    <li><a href="#">Khoá học nổi bật</a></li>
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
                    <li><i class="fa-solid fa-envelope"></i> hotro@eduviet.vn</li>
                </ul>
            </div>
            
            <div class="footer-col newsletter-col">
                <h4 class="footer-title">Nhận bản tin</h4>
                <p style="margin-bottom: 12px;">Đăng ký để nhận thông tin khoá học mới và mã giảm giá hàng tuần.</p>
                <form class="newsletter-form">
                    <input type="email" placeholder="Email của bạn..." required>
                    <button type="submit"><i class="fa-solid fa-paper-plane"></i></button>
                </form>
                <div class="app-badges" style="margin-top: 24px;">
                    <a href="#" class="app-badge"><i class="fa-brands fa-apple"></i> App Store</a>
                    <a href="#" class="app-badge"><i class="fa-brands fa-google-play"></i> Google Play</a>
                </div>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; 2026 EduViet LMS. Đã đăng ký bản quyền.</p>
            <div class="footer-bottom-links">
                <a href="#">Bảo mật</a>
                <a href="#">Điều khoản</a>
            </div>
        </div>
    </div>
</footer>

<!-- Dynamic Island Theme Toggle -->
<div class="theme-toggle-island" id="themeToggle">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<!-- App Scripts -->
<script src="<%=request.getContextPath()%>/assets/js/lms-app.js?v=14"></script>
</body>
</html>
