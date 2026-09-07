/**
 * App Script - Modern Vietnam EDU LMS
 */

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


    // 8. Dynamic Island Theme Toggle
    const themeToggle = document.getElementById('themeToggle');
    if (themeToggle) {
        themeToggle.addEventListener('click', () => {
            document.body.classList.toggle('dark-theme');
            const isDark = document.body.classList.contains('dark-theme');
            const text = themeToggle.querySelector('.toggle-text');
            if (isDark) {
                text.textContent = 'Chế độ Sáng';
            } else {
                text.textContent = 'Chế độ Tối';
            }
        });
    }
