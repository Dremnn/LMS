<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.model.User" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${course.title} - UTEdu LMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-design.css?v=26">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/lms-animations.css?v=26">
    <style>
        .hero-section{background:rgba(255,255,255,0.75);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);border-bottom:1px solid rgba(226,232,240,0.8);padding:50px 40px 60px;}
        .hero-inner{max-width:1160px;margin:0 auto;display:grid;grid-template-columns:1fr 420px;gap:56px;align-items:start;}
        .hero-info h1{font-size:34px;font-weight:800;line-height:1.25;margin-bottom:16px;color:#0F172A;}
        .hero-info .desc{font-size:15px;color:#475569;line-height:1.7;margin-bottom:24px;max-height:120px;overflow-y:auto;padding-right:8px;}
        .hero-info .desc::-webkit-scrollbar{width:5px;}
        .hero-info .desc::-webkit-scrollbar-track{background:#F1F5F9;border-radius:4px;}
        .hero-info .desc::-webkit-scrollbar-thumb{background:#CBD5E1;border-radius:4px;}
        .hero-info .desc::-webkit-scrollbar-thumb:hover{background:#94A3B8;}
        .hero-meta{display:flex;flex-wrap:wrap;gap:12px;font-size:13px;margin-bottom:28px;}
        .hero-meta span{display:inline-flex;align-items:center;gap:6px;background:#F1F5F9;color:#475569;padding:6px 14px;border-radius:30px;font-weight:600;}
        .hero-meta span.instructor-tag{background:rgba(157, 185, 203, 0.25);color:#093C62;}
        .hero-meta span.rating-tag{background:#FEF3C7;color:#D97706;}
        .hero-price{font-size:32px;font-weight:800;margin-bottom:24px;}
        .price-free{color:#10B981;}
        .price-paid{color:#076FA4;}
        .btn-enroll{padding:14px 36px;background:linear-gradient(135deg,#076FA4,#093C62);color:#fff;border-radius:12px;font-size:16px;font-weight:700;text-decoration:none;transition:all .2s;display:inline-flex;align-items:center;gap:8px;border:none;cursor:pointer;box-shadow:0 8px 24px rgba(7,111,164,.28);}
        .btn-enroll:hover{transform:translateY(-2px);box-shadow:0 12px 32px rgba(7,111,164,.38);color:#fff;}
        .hero-img{border-radius:20px;overflow:hidden;box-shadow:0 16px 40px rgba(0,0,0,.08);border:1px solid #E2E8F0;background:#fff;}
        .hero-img img{width:100%;height:260px;object-fit:cover;display:block;}
        .back-link{display:inline-flex;align-items:center;gap:8px;color:#64748B;text-decoration:none;font-size:14px;font-weight:600;margin-bottom:20px;transition:color .2s;}
        .back-link:hover{color:#076FA4;}
        .main{max-width:1160px;margin:48px auto;padding:0 24px;}
        .curriculum-title{font-size:24px;font-weight:800;color:#093C62;margin-bottom:24px;display:flex;align-items:center;gap:12px;}
        .section-card{background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,.04);margin-bottom:20px;border:1px solid #E2E8F0;}
        .section-header{padding:18px 24px;background:#F8FAFC;display:flex;justify-content:space-between;align-items:center;border-left:4px solid #076FA4;border-bottom:1px solid #F1F5F9;}
        .section-header h3{font-size:16px;font-weight:700;color:#093C62;}
        .section-body{padding:0;}
        .lesson-item{display:flex;align-items:center;justify-content:space-between;padding:14px 24px;border-top:1px solid #F1F5F9;transition:background .15s;}
        .lesson-item:hover{background:#F0F6FA;}
        .lesson-name{font-size:14px;color:#1E293B;display:flex;align-items:center;gap:10px;font-weight:500;}
        .lesson-name a{color:#1E293B;text-decoration:none;font-weight:600;display:inline-flex;align-items:center;gap:8px;transition:color .15s;}
        .lesson-name a:hover{color:#076FA4;}
        .lesson-duration{font-size:13px;color:#94A3B8;white-space:nowrap;font-weight:500;}
        .empty-lessons{padding:18px 24px;color:#94A3B8;font-size:14px;font-style:italic;}
        .empty-state{text-align:center;padding:70px 20px;color:#94A3B8;background:#fff;border-radius:16px;border:1px solid #E2E8F0;}
        .progress-box{background:#F8FAFC;border:1px solid #E2E8F0;border-radius:12px;padding:16px 20px;margin-bottom:20px;}
        .progress-bar-bg{background:#E2E8F0;border-radius:10px;height:8px;overflow:hidden;margin-top:10px;}
        .progress-bar-fill{height:100%;border-radius:10px;background:linear-gradient(90deg,#093C62,#076FA4);}

        /* Reviews & Ratings Section */
        .reviews-section{margin-top:56px;}
        .reviews-summary{background:#fff;border-radius:16px;border:1px solid #E2E8F0;padding:28px 32px;display:flex;align-items:center;gap:36px;margin-bottom:24px;box-shadow:0 4px 20px rgba(0,0,0,.03);}
        .reviews-summary-score{text-align:center;min-width:140px;border-right:1px solid #E2E8F0;padding-right:36px;}
        .score-big{font-size:48px;font-weight:800;color:#093C62;line-height:1;margin-bottom:8px;}
        .score-stars{color:#F59E0B;font-size:18px;margin-bottom:6px;display:flex;justify-content:center;gap:3px;}
        .score-count{font-size:13px;color:#64748B;font-weight:600;}
        .reviews-summary-info{flex:1;}
        .reviews-summary-info h4{font-size:17px;font-weight:700;color:#093C62;margin-bottom:6px;}
        .reviews-summary-info p{font-size:14px;color:#64748B;line-height:1.5;margin:0;}

        .review-form-card{background:#fff;border-radius:16px;border:1px solid #E2E8F0;padding:24px 28px;margin-bottom:28px;box-shadow:0 4px 20px rgba(0,0,0,.03);}
        .review-form-card h4{font-size:16px;font-weight:700;color:#093C62;margin-bottom:14px;display:flex;align-items:center;gap:8px;}
        
        .star-rating-select{display:flex;flex-direction:row-reverse;justify-content:flex-end;gap:8px;margin-bottom:16px;}
        .star-rating-select input[type="radio"]{display:none;}
        .star-rating-select label{font-size:28px;color:#CBD5E1;cursor:pointer;transition:color .15s, transform .15s;}
        .star-rating-select label:hover,
        .star-rating-select label:hover ~ label,
        .star-rating-select input[type="radio"]:checked ~ label{color:#F59E0B;}
        .star-rating-select label:hover{transform:scale(1.2);}

        .review-textarea{width:100%;min-height:90px;border:1px solid #CBD5E1;border-radius:12px;padding:12px 16px;font-family:inherit;font-size:14px;color:#1E293B;resize:vertical;box-sizing:border-box;transition:border-color .15s;outline:none;}
        .review-textarea:focus{border-color:#076FA4;box-shadow:0 0 0 3px rgba(7,111,164,.15);}
        .review-form-actions{display:flex;justify-content:space-between;align-items:center;margin-top:14px;}
        .btn-submit-review{background:linear-gradient(135deg,#076FA4,#093C62);color:#fff;border:none;padding:11px 24px;border-radius:10px;font-size:14px;font-weight:700;cursor:pointer;transition:transform .15s, box-shadow .15s;display:inline-flex;align-items:center;gap:8px;box-shadow:0 4px 12px rgba(7,111,164,.25);}
        .btn-submit-review:hover{transform:translateY(-1px);box-shadow:0 6px 18px rgba(7,111,164,.35);}
        .btn-delete-review{background:#FEE2E2;color:#991B1B;border:none;padding:10px 18px;border-radius:10px;font-size:13px;font-weight:600;cursor:pointer;transition:background .15s;display:inline-flex;align-items:center;gap:6px;}
        .btn-delete-review:hover{background:#FECACA;}

        .review-item{background:#fff;border-radius:16px;border:1px solid #E2E8F0;padding:22px 26px;margin-bottom:14px;box-shadow:0 2px 8px rgba(0,0,0,.02);transition:box-shadow .15s;}
        .review-item:hover{box-shadow:0 6px 20px rgba(0,0,0,.06);}
        .review-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;}
        .review-user-info{display:flex;align-items:center;gap:12px;}
        .review-avatar{width:42px;height:42px;border-radius:50%;object-fit:cover;border:2px solid #E2EEF5;background:#E2EEF5;}
        .review-avatar-placeholder{width:42px;height:42px;border-radius:50%;background:linear-gradient(135deg,#076FA4,#093C62);color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:16px;}
        .review-name{font-size:15px;font-weight:700;color:#093C62;}
        .review-date{font-size:12px;color:#94A3B8;font-weight:500;margin-top:2px;}
        .review-stars{color:#F59E0B;font-size:14px;display:flex;gap:3px;}
        .review-comment{font-size:14px;color:#334155;line-height:1.65;white-space:pre-wrap;word-break:break-word;margin:0;}

        /* Dark Theme overrides for Course Detail */
        body.dark-theme .hero-section { background: transparent !important; border: none !important; }
        body.dark-theme .hero-info h1 { color: #FFFFFF !important; }
        body.dark-theme .hero-info .desc { color: #9DB9CB !important; }
        body.dark-theme .hero-meta span {
            background: #182535 !important;
            border: 1px solid #093C62 !important;
            color: #FFFFFF !important;
        }
        body.dark-theme .hero-meta span.instructor-tag {
            background: #182535 !important;
            border: 1px solid #093C62 !important;
            color: #FFFFFF !important;
        }
        body.dark-theme .hero-meta span i,
        body.dark-theme .hero-meta span.instructor-tag i {
            color: #38BDF8 !important;
        }
        body.dark-theme .hero-meta span.rating-tag {
            background: rgba(245, 158, 11, 0.15) !important;
            border: 1px solid rgba(245, 158, 11, 0.3) !important;
            color: #F59E0B !important;
        }
        body.dark-theme .hero-meta span.rating-tag i {
            color: #F59E0B !important;
        }
        body.dark-theme .hero-img { background: #182535 !important; border-color: #093C62 !important; }
        body.dark-theme .curriculum-title { color: #FFFFFF !important; }
        body.dark-theme .section-card { background: #182535 !important; border-color: #093C62 !important; }
        body.dark-theme .section-header { background: #151F2E !important; border-bottom: 1px solid #093C62 !important; border-left: 4px solid #076FA4 !important; }
        body.dark-theme .section-header h3 { color: #FFFFFF !important; }
        body.dark-theme .lesson-item { border-top: 1px solid #093C62 !important; }
        body.dark-theme .lesson-item:hover { background: rgba(9, 60, 98, 0.25) !important; }
        body.dark-theme .lesson-name, body.dark-theme .lesson-name a { color: #FFFFFF !important; }
        body.dark-theme .lesson-duration { color: #9DB9CB !important; }
        body.dark-theme .empty-lessons, body.dark-theme .empty-state { background: #182535 !important; border-color: #093C62 !important; color: #9DB9CB !important; }
        body.dark-theme .progress-box { background: #182535 !important; border-color: #093C62 !important; color: #FFFFFF !important; }
        body.dark-theme .progress-box div { color: #FFFFFF !important; }
        body.dark-theme .progress-bar-bg { background: #111312 !important; }
        body.dark-theme .reviews-summary, body.dark-theme .review-form-card, body.dark-theme .review-item { background: #182535 !important; border-color: #093C62 !important; }
        body.dark-theme .reviews-summary-score { border-right-color: #093C62 !important; }
        body.dark-theme .score-big, body.dark-theme .reviews-summary-info h4, body.dark-theme .review-form-card h4, body.dark-theme .review-name { color: #FFFFFF !important; }
        body.dark-theme .score-count, body.dark-theme .reviews-summary-info p, body.dark-theme .review-date, body.dark-theme .review-comment { color: #9DB9CB !important; }
        body.dark-theme .review-textarea { background: #111312 !important; border-color: #093C62 !important; color: #FFFFFF !important; }
    </style>
</head>
<body class="mesh-bg ${cookie.app_theme.value == 'dark' ? 'dark-theme' : ''}">
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String role = currentUser != null ? currentUser.getRole() : "";
%>
<!-- NAVBAR -->
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

<div class="hero-section">
    <div class="hero-inner">
        <div class="hero-info">
            <a href="${pageContext.request.contextPath}/courses" class="back-link"><i class="fa-solid fa-arrow-left"></i> Quay lại danh sách</a>
            <c:if test="${not empty course.categoryName}">
                <span style="font-size:13px;color:#076FA4;background:rgba(157, 185, 203, 0.25);padding:4px 12px;border-radius:20px;font-weight:700;display:inline-block;margin-bottom:12px;">
                    <i class="fa-solid fa-folder-open"></i> <c:out value="${course.categoryName}"/>
                </span>
            </c:if>
            <h1><c:out value="${course.title}"/></h1>
            <c:if test="${not empty success}">
                <div style="background:#ecfdf5;color:#065f46;border:1px solid #a7f3d0;padding:12px 18px;border-radius:10px;font-size:14px;margin-bottom:16px;">
                    <i class="fa-solid fa-circle-check"></i> ${success}
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div style="background:#fef2f2;color:#991b1b;border:1px solid #fecaca;padding:12px 18px;border-radius:10px;font-size:14px;margin-bottom:16px;">
                    <i class="fa-solid fa-triangle-exclamation"></i> ${error}
                </div>
            </c:if>
            <c:if test="${course.status == 'warning' || course.status == 'appealed'}">
                <div style="background:#fffbeb;border:1px solid #fde68a;padding:14px 18px;border-radius:10px;font-size:14px;margin-bottom:16px;color:#92400e;">
                    <i class="fa-solid fa-triangle-exclamation"></i> <strong>Khóa học này đang bị cảnh cáo</strong> — Nội dung đang được xem xét bởi quản trị viên.
                </div>
            </c:if>
            <p class="desc"><c:out value="${course.description}"/></p>
            <div class="hero-meta">
                <span class="instructor-tag"><i class="fa-solid fa-chalkboard-user"></i> <c:out value="${course.instructorName}"/></span>
                <span class="rating-tag"><a href="#reviews-section" style="color:inherit;text-decoration:none;"><i class="fa-solid fa-star"></i> ${course.avgRating} / 5 (${reviews != null ? reviews.size() : 0} đánh giá)</a></span>
                <span><i class="fa-solid fa-users"></i> ${course.totalStudents} học viên</span>
                <span><i class="fa-solid fa-book-open"></i> ${course.totalLessons} bài học</span>
            </div>
            <div class="hero-price">
                <c:choose>
                    <c:when test="${course.price == 0 || course.price == null}">
                        <span class="price-free">Miễn phí</span>
                    </c:when>
                    <c:otherwise>
                        <span class="price-paid">${course.price} đ</span>
                    </c:otherwise>
                </c:choose>
            </div>
            <c:choose>
                <c:when test="${not empty enrollment}">
                    <%-- Đã đăng ký: hiện tiến độ + nút vào học --%>
                    <div class="progress-box">
                        <div style="font-size:14px;color:#1E293B;display:flex;justify-content:space-between;font-weight:600;">
                            <span><i class="fa-solid fa-circle-check" style="color:#10B981;"></i> Đã đăng ký khóa học</span>
                            <span>Tiến độ: <strong>${enrollment.progressPercent}%</strong></span>
                        </div>
                        <div class="progress-bar-bg">
                            <div class="progress-bar-fill" style="width:${enrollment.progressPercent}%;"></div>
                        </div>
                    </div>
                    <div style="display:flex; gap:12px; align-items:center; flex-wrap:wrap;">
                        <a href="${pageContext.request.contextPath}/student/lessons/view?lessonId=${course.sectionsCache[0].lessons[0].id}" class="btn-enroll">
                            <i class="fa-solid fa-play"></i> Tiếp tục học
                        </a>
                        <form action="${pageContext.request.contextPath}/enrollments/cancel" method="post" style="display:inline;"
                              onsubmit="return confirm('Bạn có chắc chắn muốn hủy khóa học này không? Mọi tiến độ học tập sẽ bị xóa.')">
                            <input type="hidden" name="courseId" value="${course.id}" />
                            <button type="submit" class="btn" style="background:#FEE2E2;color:#991B1B;padding:12px 20px;border-radius:12px;font-weight:600;border:none;cursor:pointer;">
                                <i class="fa-solid fa-xmark"></i> Hủy khóa học
                            </button>
                        </form>
                    </div>
                </c:when>
                <c:otherwise>
                    <%-- Chưa đăng ký: hiện form đăng ký --%>
                    <form action="${pageContext.request.contextPath}/enrollments/new" method="post" style="display:inline;">
                        <input type="hidden" name="courseId" value="${course.id}" />
                        <button type="submit" class="btn-enroll"><i class="fa-solid fa-rocket"></i> Đăng ký học ngay</button>
                    </form>
                </c:otherwise>
            </c:choose>
        </div>
        <div class="hero-img">
            <c:choose>
                <c:when test="${not empty course.thumbnailUrl}">
                    <img src="${course.thumbnailUrl}" alt="<c:out value='${course.title}'/>"
                         onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/default-course.svg';">
                </c:when>
                <c:otherwise>
                    <img src="${pageContext.request.contextPath}/assets/images/default-course.svg" alt="Course Thumbnail">
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<div class="main">
    <div class="curriculum-title"><i class="fa-solid fa-list-check"></i> Chương trình học</div>
    <c:choose>
        <c:when test="${not empty course.sectionsCache}">
            <c:forEach var="section" items="${course.sectionsCache}" varStatus="st">
                <div class="section-card">
                    <div class="section-header">
                        <h3>Chương ${st.index + 1}: <c:out value="${section.title}"/></h3>
                        <span style="font-size:12px;color:#64748B;font-weight:500;">${section.lessons.size()} bài học</span>
                    </div>
                    <div class="section-body">
                        <c:choose>
                            <c:when test="${not empty section.lessons}">
                                <c:forEach var="lesson" items="${section.lessons}">
                                    <div class="lesson-item">
                                        <span class="lesson-name">
                                            <c:choose>
                                                <c:when test="${not empty enrollment}">
                                                    <%-- Đã đăng ký: tên bài là link dẫn vào xem nội dung --%>
                                                    <a href="${pageContext.request.contextPath}/student/lessons/view?lessonId=${lesson.id}"
                                                       style="color:#076FA4;text-decoration:none;font-weight:600;"
                                                       onmouseover="this.style.textDecoration='underline'"
                                                       onmouseout="this.style.textDecoration='none'">
                                                        <i class="fa-solid fa-circle-play" style="color:#076FA4;"></i> <c:out value="${lesson.title}"/>
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <%-- Chưa đăng ký: text tĩnh + icon khóa --%>
                                                    <span style="color:#94A3B8;"><i class="fa-solid fa-lock" style="color:#CBD5E1;"></i> <c:out value="${lesson.title}"/></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                        <span class="lesson-duration">
                                            <c:choose>
                                                <c:when test="${lesson.durationMinutes != null}">${lesson.durationMinutes} phút</c:when>
                                                <c:otherwise>N/A</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <p class="empty-lessons">Chương này chưa có bài học nào.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <div style="font-size:48px;margin-bottom:12px;"><i class="fa-solid fa-inbox"></i></div>
                <p>Khóa học này chưa có nội dung. Vui lòng quay lại sau!</p>
            </div>
        </c:otherwise>
    </c:choose>

    <!-- ============================================================ -->
    <!-- PHẦN ĐÁNH GIÁ & NHẬN XÉT (COURSE REVIEWS & RATINGS) -->
    <!-- ============================================================ -->
    <div id="reviews-section" class="reviews-section">
        <div class="curriculum-title">
            <i class="fa-solid fa-star" style="color:#F59E0B;"></i> Đánh giá & Nhận xét
            <span style="font-size:16px;color:#64748B;font-weight:600;">(${reviews != null ? reviews.size() : 0})</span>
        </div>

        <!-- Khối tổng quan đánh giá -->
        <div class="reviews-summary">
            <div class="reviews-summary-score">
                <div class="score-big">${course.avgRating}</div>
                <div class="score-stars">
                    <c:forEach var="i" begin="1" end="5">
                        <c:choose>
                            <c:when test="${course.avgRating >= i}">
                                <i class="fa-solid fa-star"></i>
                            </c:when>
                            <c:when test="${course.avgRating >= (i - 0.5)}">
                                <i class="fa-solid fa-star-half-stroke"></i>
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-star" style="color:#E2E8F0;"></i>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                </div>
                <div class="score-count">${reviews != null ? reviews.size() : 0} lượt đánh giá</div>
            </div>
            <div class="reviews-summary-info">
                <h4>Trải nghiệm từ học viên</h4>
                <p>Tất cả đánh giá đến từ các học viên đã thực tế tham gia học tập khóa học này tại UTEdu LMS. Mọi ý kiến đóng góp giúp nâng cao chất lượng nội dung và giảng dạy.</p>
            </div>
        </div>

        <!-- Form gửi / cập nhật đánh giá (chỉ dành cho học viên đã đăng ký) -->
        <c:choose>
            <c:when test="${not empty enrollment}">
                <div class="review-form-card">
                    <h4>
                        <i class="fa-solid fa-pen-to-square" style="color:#076FA4;"></i>
                        <c:choose>
                            <c:when test="${not empty myReview}">
                                Chỉnh sửa đánh giá của bạn
                            </c:when>
                            <c:otherwise>
                                Viết đánh giá của bạn về khóa học
                            </c:otherwise>
                        </c:choose>
                    </h4>

                    <form action="${pageContext.request.contextPath}/courses/reviews" method="post">
                        <input type="hidden" name="courseId" value="${course.id}" />

                        <div style="font-size:13px;font-weight:600;color:#475569;margin-bottom:8px;">
                            Chọn điểm đánh giá:
                        </div>
                        <div class="star-rating-select">
                            <input type="radio" id="star5" name="rating" value="5" ${myReview != null && myReview.rating == 5 ? 'checked' : ''} required />
                            <label for="star5" title="5 sao - Xuất sắc"><i class="fa-solid fa-star"></i></label>
                            
                            <input type="radio" id="star4" name="rating" value="4" ${myReview != null && myReview.rating == 4 ? 'checked' : ''} />
                            <label for="star4" title="4 sao - Rất tốt"><i class="fa-solid fa-star"></i></label>
                            
                            <input type="radio" id="star3" name="rating" value="3" ${myReview != null && myReview.rating == 3 ? 'checked' : ''} />
                            <label for="star3" title="3 sao - Bình thường"><i class="fa-solid fa-star"></i></label>
                            
                            <input type="radio" id="star2" name="rating" value="2" ${myReview != null && myReview.rating == 2 ? 'checked' : ''} />
                            <label for="star2" title="2 sao - Tạm được"><i class="fa-solid fa-star"></i></label>
                            
                            <input type="radio" id="star1" name="rating" value="1" ${myReview != null && myReview.rating == 1 ? 'checked' : ''} />
                            <label for="star1" title="1 sao - Kém"><i class="fa-solid fa-star"></i></label>
                        </div>

                        <div style="font-size:13px;font-weight:600;color:#475569;margin-bottom:8px;">
                            Nhận xét chi tiết (tùy chọn):
                        </div>
                        <textarea name="comment" class="review-textarea" placeholder="Hãy chia sẻ những điều bạn thích hoặc cần cải thiện về khóa học này..."><c:out value="${myReview != null ? myReview.comment : ''}"/></textarea>

                        <div class="review-form-actions">
                            <button type="submit" class="btn-submit-review">
                                <i class="fa-solid fa-paper-plane"></i>
                                <c:choose>
                                    <c:when test="${not empty myReview}">Cập nhật đánh giá</c:when>
                                    <c:otherwise>Gửi đánh giá</c:otherwise>
                                </c:choose>
                            </button>
                        </div>
                    </form>

                    <c:if test="${not empty myReview}">
                        <form action="${pageContext.request.contextPath}/courses/reviews/delete" method="post"
                              onsubmit="return confirm('Bạn có chắc chắn muốn xóa đánh giá của mình không?')"
                              style="margin-top:-38px; display:flex; justify-content:flex-end;">
                            <input type="hidden" name="courseId" value="${course.id}" />
                            <button type="submit" class="btn-delete-review">
                                <i class="fa-solid fa-trash-can"></i> Xóa đánh giá
                            </button>
                        </form>
                    </c:if>
                </div>
            </c:when>
            <c:otherwise>
                <%-- Chưa đăng ký khóa học --%>
                <div style="padding:18px 24px; background:#F8FAFC; border:1px dashed #CBD5E1; border-radius:14px; font-size:14px; color:#64748B; margin-bottom:28px; display:flex; align-items:center; gap:12px;">
                    <i class="fa-solid fa-circle-info" style="color:#076FA4;font-size:18px;"></i>
                    <c:choose>
                        <c:when test="${empty currentUser}">
                            <span>Vui lòng <a href="${pageContext.request.contextPath}/login" style="color:#076FA4;font-weight:700;text-decoration:none;">Đăng nhập</a> và đăng ký khóa học để có thể gửi đánh giá.</span>
                        </c:when>
                        <c:otherwise>
                            <span>Bạn cần đăng ký khóa học này trước khi có thể gửi nhận xét & đánh giá.</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:otherwise>
        </c:choose>

        <!-- Danh sách các đánh giá từ học viên -->
        <c:choose>
            <c:when test="${not empty reviews}">
                <div class="reviews-list">
                    <c:forEach var="review" items="${reviews}">
                        <div class="review-item">
                            <div class="review-header">
                                <div class="review-user-info">
                                    <c:choose>
                                        <c:when test="${not empty review.studentAvatar}">
                                            <img src="${pageContext.request.contextPath}${review.studentAvatar}"
                                                 alt="<c:out value='${review.studentName}'/>"
                                                 class="review-avatar"
                                                 onerror="this.onerror=null;this.style.display='none';this.nextElementSibling.style.display='flex';">
                                            <div class="review-avatar-placeholder" style="display:none;">
                                                <c:out value="${not empty review.studentName ? review.studentName.substring(0, 1).toUpperCase() : 'U'}"/>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="review-avatar-placeholder">
                                                <c:out value="${not empty review.studentName ? review.studentName.substring(0, 1).toUpperCase() : 'U'}"/>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div>
                                        <div class="review-name"><c:out value="${review.studentName}"/></div>
                                        <div class="review-date">${review.formattedCreatedAt}</div>
                                    </div>
                                </div>
                                <div class="review-stars">
                                    <c:forEach var="i" begin="1" end="5">
                                        <c:choose>
                                            <c:when test="${i <= review.rating}">
                                                <i class="fa-solid fa-star"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fa-solid fa-star" style="color:#E2E8F0;"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </div>
                            </div>
                            <c:if test="${not empty review.comment}">
                                <p class="review-comment"><c:out value="${review.comment}"/></p>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div style="text-align:center;padding:48px 20px;background:#fff;border-radius:16px;border:1px solid #E2E8F0;color:#94A3B8;">
                    <div style="font-size:36px;margin-bottom:10px;color:#CBD5E1;"><i class="fa-regular fa-comment-dots"></i></div>
                    <p style="margin:0;font-size:15px;color:#64748B;font-weight:500;">Chưa có đánh giá nào cho khóa học này.</p>
                    <p style="margin-top:6px;font-size:13px;color:#94A3B8;">Hãy là học viên đầu tiên trải nghiệm và chia sẻ nhận xét nhé!</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- Dynamic Island Theme Toggle (Lưu tùy chọn vào Cookie 365 ngày) -->
<div class="theme-toggle-island" id="themeToggle" title="Chuyển chế độ giao diện">
    <div class="toggle-icon sun-icon"><i class="fa-solid fa-sun"></i></div>
    <div class="toggle-icon moon-icon"><i class="fa-solid fa-moon"></i></div>
    <span class="toggle-text">Chế độ Tối</span>
</div>

<script src="${pageContext.request.contextPath}/assets/js/lms-app.js?v=26"></script>
</body>
</html>