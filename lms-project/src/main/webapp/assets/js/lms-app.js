/**
 * App Script - Modern Vietnam EDU LMS
 */

// 0. Đọc Cookie app_theme và kích hoạt Dark Theme ngay lập tức để tránh giật giao diện
(function() {
    const value = '; ' + document.cookie;
    const parts = value.split('; app_theme=');
    if (parts.length === 2 && parts.pop().split(';').shift() === 'dark') {
        if (document.body) {
            document.body.classList.add('dark-theme');
        } else {
            document.addEventListener('DOMContentLoaded', () => {
                document.body.classList.add('dark-theme');
            });
        }
    }
})();

document.addEventListener("DOMContentLoaded", () => {
    
    // 1. Scroll Reveal Logic (Intersection Observer)
    const revealElements = document.querySelectorAll('.reveal-up');
    
    if (revealElements.length > 0 && 'IntersectionObserver' in window) {
        const revealObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('active');
                } else {
                    // Khi cuộn ra khỏi màn hình, gỡ bỏ active để lần sau cuộn lại sẽ có hiệu ứng
                    entry.target.classList.remove('active');
                }
            });
        }, {
            root: null,
            threshold: 0.1,
            rootMargin: "0px 0px -50px 0px"
        });

        revealElements.forEach(el => revealObserver.observe(el));
    } else {
        // Fallback for browsers without IntersectionObserver
        revealElements.forEach(el => el.classList.add('active'));
    }

    // 2. Counter Animation Logic
    const counters = document.querySelectorAll('.counter-val');
    
    if (counters.length > 0 && 'IntersectionObserver' in window) {
        const counterObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const target = entry.target;
                    const finalValue = parseInt(target.getAttribute('data-target'), 10);
                    const duration = 1500; // 1.5s
                    const frameRate = 1000 / 60; // 60fps
                    const totalFrames = duration / frameRate;
                    const step = finalValue / totalFrames;
                    let current = 0;

                    const updateCounter = () => {
                        current += step;
                        if (current < finalValue) {
                            target.innerText = Math.ceil(current);
                            requestAnimationFrame(updateCounter);
                        } else {
                            target.innerText = finalValue;
                        }
                    };

                    updateCounter();
                    observer.unobserve(target);
                }
            });
        }, { threshold: 0.2 });

        counters.forEach(c => counterObserver.observe(c));
    }

    // 3. Navbar Scroll Effect
    const navbar = document.querySelector('.lms-navbar');
    if (navbar) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 20) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        });
    }
});


    // 4. Parallax Scrolling Effects
    const parallaxElements = document.querySelectorAll('.parallax');
    if (parallaxElements.length > 0) {
        window.addEventListener('scroll', () => {
            const scrollY = window.scrollY;
            window.requestAnimationFrame(() => {
                parallaxElements.forEach(el => {
                    const speed = el.getAttribute('data-speed') || 0.3;
                    // Tạo hiệu ứng trượt khác tốc độ với cuộn chuột
                    el.style.transform = `translateY(${scrollY * speed}px)`;
                });
            });
        });
    }


    // 5. 3D Card Hover Tilt Effect (Hiệu ứng thẻ bài 3D tương tác chuột)
    const cards = document.querySelectorAll('.feature-card, .stat-card');
    cards.forEach(card => {
        card.addEventListener('mousemove', e => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;
            // Xoay thẻ bài theo hướng chuột
            const rotateX = ((y - centerY) / centerY) * -12; // Xoay tối đa 12 độ
            const rotateY = ((x - centerX) / centerX) * 12;
            
            card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-10px) scale(1.02)`;
            card.style.boxShadow = `${-rotateY}px ${rotateX}px 30px rgba(79, 70, 229, 0.2)`;
        });
        
        card.addEventListener('mouseleave', () => {
            card.style.transform = 'perspective(1000px) rotateX(0deg) rotateY(0deg) translateY(0px) scale(1)';
            card.style.boxShadow = 'var(--shadow-md)';
            card.style.transition = 'transform 0.6s cubic-bezier(0.2, 1, 0.3, 1), box-shadow 0.6s ease';
        });
        
        card.addEventListener('mouseenter', () => {
            card.style.transition = 'none'; // Bỏ transition để chuột tracking mượt hơn
        });
    });

    // 6. Glowing Cursor Blob (Quả cầu ánh sáng chạy theo chuột)
    const blob = document.getElementById('cursor-blob');
    if (blob) {
        window.addEventListener('mousemove', (e) => {
            // Chạy theo chuột
            blob.style.left = e.clientX + 'px';
            blob.style.top = e.clientY + 'px';
        });
    }


    // 7. Mouse Parallax Effect (Tương tác bồng bềnh khi di chuột mượt mà)
    document.addEventListener('mousemove', (e) => {
        requestAnimationFrame(() => {
            const x = (window.innerWidth / 2 - e.clientX) / 50;
            const y = (window.innerHeight / 2 - e.clientY) / 50;
            
            // Di chuyển các hình nền (parallax-shape)
            document.querySelectorAll('.parallax-shape').forEach(shape => {
                const speed = shape.getAttribute('data-speed') || 1;
                shape.style.transform = `translate3d(${x * speed * 2}px, ${y * speed * 2}px, 0)`;
            });
            
        });
    });


    // Helper functions để thao tác Cookie phía Client
    function getLmsCookie(name) {
        const value = '; ' + document.cookie;
        const parts = value.split('; ' + name + '=');
        if (parts.length === 2) return parts.pop().split(';').shift();
        return null;
    }

    function setLmsCookie(name, value, days) {
        let expires = '';
        if (days) {
            const date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            expires = '; expires=' + date.toUTCString();
        }
        document.cookie = name + '=' + (value || '') + expires + '; path=/; SameSite=Lax';
    }

    // 8. Dynamic Island Theme Toggle với Cookie lưu trữ 365 ngày
    const themeToggle = document.getElementById('themeToggle');
    if (themeToggle) {
        const text = themeToggle.querySelector('.toggle-text');

        // Đồng bộ nhãn nút theo trạng thái dark-theme hiện tại
        const updateToggleLabel = () => {
            const isDark = document.body.classList.contains('dark-theme');
            if (text) {
                text.textContent = isDark ? 'Chế độ Sáng' : 'Chế độ Tối';
            }
        };

        updateToggleLabel();

        themeToggle.addEventListener('click', () => {
            document.body.classList.toggle('dark-theme');
            const isDark = document.body.classList.contains('dark-theme');
            updateToggleLabel();
            // Lưu tùy chọn vào Cookie với thời hạn 365 ngày
            setLmsCookie('app_theme', isDark ? 'dark' : 'light', 365);
        });
    }

            // ---------- Unread Chat Badge & Notification Dropdown ----------
    const chatBtn = document.querySelector('a.quick-action-btn[href$="/chat"]');
    const notifBtn = document.querySelector('a.quick-action-btn[href$="/notifications"]');
    let basePath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
    if (basePath === "" || basePath === "/") basePath = "/LMS"; // Default context

    if (chatBtn || notifBtn) {
        fetch(window.location.origin + basePath + '/api/chat/unread')
            .then(res => res.json())
            .then(data => {
                if (chatBtn && data.unread > 0) {
                    let badge = document.createElement('span');
                    badge.style.position = 'absolute';
                    badge.style.top = '4px';
                    badge.style.right = '4px';
                    badge.style.background = '#ef4444';
                    badge.style.color = 'white';
                    badge.style.fontSize = '10px';
                    badge.style.fontWeight = 'bold';
                    badge.style.padding = '2px 6px';
                    badge.style.borderRadius = '10px';
                    badge.innerText = data.unread;
                    chatBtn.style.position = 'relative';
                    chatBtn.appendChild(badge);
                }
                if (notifBtn && data.unreadNotif > 0) {
                    let badge = document.createElement('span');
                    badge.style.position = 'absolute';
                    badge.style.top = '4px';
                    badge.style.right = '4px';
                    badge.style.background = '#ef4444';
                    badge.style.color = 'white';
                    badge.style.fontSize = '10px';
                    badge.style.fontWeight = 'bold';
                    badge.style.padding = '2px 6px';
                    badge.style.borderRadius = '10px';
                    badge.innerText = data.unreadNotif;
                    notifBtn.style.position = 'relative';
                    notifBtn.appendChild(badge);
                }
            })
            .catch(e => console.error('Error fetching unread counts', e));
    }

    // Handle Notification Dropdown
    if (notifBtn) {
        notifBtn.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Check if dropdown already exists
            let dropdown = document.getElementById('notif-dropdown');
            if (dropdown) {
                dropdown.remove();
                return;
            }
            
            dropdown = document.createElement('div');
            dropdown.id = 'notif-dropdown';
            dropdown.style.position = 'absolute';
            dropdown.style.top = '120%';
            dropdown.style.right = '-20px';
            dropdown.style.width = '320px';
            dropdown.style.background = document.body.classList.contains('dark-theme') ? '#182535' : '#ffffff';
            dropdown.style.border = document.body.classList.contains('dark-theme') ? '1px solid #093C62' : '1px solid #e2e8f0';
            dropdown.style.borderRadius = '12px';
            dropdown.style.boxShadow = '0 10px 25px rgba(0,0,0,0.15)';
            dropdown.style.zIndex = '1000';
            dropdown.style.overflow = 'hidden';
            dropdown.style.textAlign = 'left';
            
            notifBtn.style.position = 'relative';
            notifBtn.appendChild(dropdown);
            
            dropdown.innerHTML = '<div style="padding: 15px; text-align: center; color: #718096;"><i class="fa-solid fa-spinner fa-spin"></i> Đang tải...</div>';
            
            fetch(window.location.origin + basePath + '/api/notifications/recent')
                .then(res => res.json())
                .then(data => {
                    const textColor = document.body.classList.contains('dark-theme') ? '#F4F8FA' : '#2d3748';
                    const mutedColor = document.body.classList.contains('dark-theme') ? '#9DB9CB' : '#718096';
                    const borderColor = document.body.classList.contains('dark-theme') ? '#093C62' : '#edf2f7';
                    const hoverBg = document.body.classList.contains('dark-theme') ? '#111312' : '#f7fafc';
                    const primaryColor = '#3182ce';

                    if (data.length === 0) {
                        dropdown.innerHTML = '<div style="padding: 15px; text-align: center; color: ' + mutedColor + '; font-size: 13px;">Chưa có thông báo nào.</div>';
                    } else {
                        let html = '<div style="max-height: 350px; overflow-y: auto;">';
                        data.forEach(n => {
                            let dot = n.isRead ? '<div style="width:8px;height:8px;margin-right:8px;"></div>' : '<i class="fa-solid fa-circle" style="color: ' + primaryColor + '; font-size: 8px; margin-right: 8px;"></i>';
                            let url = n.relatedUrl ? (basePath + n.relatedUrl) : (basePath + '/notifications?id=' + n.id);
                            html += <a href=" + url + " style="display: block; padding: 12px 15px; border-bottom: 1px solid  + borderColor + ; text-decoration: none; color:  + textColor + ; transition: background 0.2s;" onmouseover="this.style.background=' + hoverBg + '" onmouseout="this.style.background='transparent'">
                                        <div style="font-size: 13px; font-weight:  + (n.isRead ? 'normal' : 'bold') + ; display: flex; align-items: baseline;">
                                             + dot + 
                                            <span style="flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"> + n.title + </span>
                                        </div>
                                        <div style="font-size: 11px; color:  + mutedColor + ; margin-top: 4px; padding-left: 16px;"> + new Date(n.createdAt).toLocaleString('vi-VN') + </div>
                                    </a>;
                        });
                        html += '</div>';
                        html += <a href=" + basePath + /notifications" style="display: block; padding: 12px; text-align: center; background:  + hoverBg + ; color:  + primaryColor + ; font-size: 13px; font-weight: bold; text-decoration: none; border-top: 1px solid  + borderColor + ;">
                                    Xem tất cả thông báo <i class="fa-solid fa-arrow-right" style="margin-left: 5px;"></i>
                                </a>;
                        dropdown.innerHTML = html;
                    }
                })
                .catch(err => {
                    dropdown.innerHTML = '<div style="padding: 15px; text-align: center; color: #e53e3e; font-size: 13px;">Lỗi tải thông báo.</div>';
                });
                
            // Close dropdown when clicking outside
            setTimeout(() => {
                document.addEventListener('click', function closeDropdown(e) {
                    if (!notifBtn.contains(e.target)) {
                        dropdown.remove();
                        document.removeEventListener('click', closeDropdown);
                    }
                });
            }, 0);
        });
    }



