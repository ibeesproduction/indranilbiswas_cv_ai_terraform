/**
 * Main JavaScript for Indranil Biswas CV Website
 * Handles navigation, animations, and interactivity
 */

// ============================================
// Smooth Scroll Navigation
// ============================================
document.addEventListener('DOMContentLoaded', function() {
    
    // Smooth scroll for all anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                // Close mobile menu if open
                const navLinks = document.querySelector('.nav-links');
                if (navLinks.classList.contains('active')) {
                    navLinks.classList.remove('active');
                    toggleMobileMenuIcon(false);
                }
                
                // Smooth scroll to target
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // ============================================
    // Mobile Menu Toggle
    // ============================================
    const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
    const navLinks = document.querySelector('.nav-links');
    
    if (mobileMenuToggle) {
        mobileMenuToggle.addEventListener('click', function() {
            navLinks.classList.toggle('active');
            toggleMobileMenuIcon(navLinks.classList.contains('active'));
        });
    }

    function toggleMobileMenuIcon(isOpen) {
        const spans = mobileMenuToggle.querySelectorAll('span');
        if (isOpen) {
            spans[0].style.transform = 'rotate(45deg) translateY(10px)';
            spans[1].style.opacity = '0';
            spans[2].style.transform = 'rotate(-45deg) translateY(-10px)';
        } else {
            spans[0].style.transform = 'none';
            spans[1].style.opacity = '1';
            spans[2].style.transform = 'none';
        }
    }

    // Close mobile menu when clicking outside
    document.addEventListener('click', function(event) {
        const isClickInsideNav = event.target.closest('nav');
        if (!isClickInsideNav && navLinks.classList.contains('active')) {
            navLinks.classList.remove('active');
            toggleMobileMenuIcon(false);
        }
    });

    // ============================================
    // Scroll Animations
    // ============================================
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in-up');
                // Only animate once
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // Observe all cards, timeline items, and cert badges
    document.querySelectorAll('.card, .timeline-item, .cert-badge').forEach(el => {
        observer.observe(el);
    });

    // ============================================
    // Active Navigation Link on Scroll
    // ============================================
    const sections = document.querySelectorAll('section[id]');
    const navItems = document.querySelectorAll('.nav-links a');

    function highlightNavigation() {
        let scrollY = window.pageYOffset;

        sections.forEach(section => {
            const sectionHeight = section.offsetHeight;
            const sectionTop = section.offsetTop - 100;
            const sectionId = section.getAttribute('id');

            if (scrollY > sectionTop && scrollY <= sectionTop + sectionHeight) {
                navItems.forEach(item => {
                    item.classList.remove('active');
                    if (item.getAttribute('href') === `#${sectionId}`) {
                        item.classList.add('active');
                    }
                });
            }
        });
    }

    window.addEventListener('scroll', highlightNavigation);

    // ============================================
    // Navbar Background on Scroll
    // ============================================
    const nav = document.querySelector('nav');
    let lastScroll = 0;

    window.addEventListener('scroll', () => {
        const currentScroll = window.pageYOffset;

        if (currentScroll > 100) {
            nav.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.3)';
        } else {
            nav.style.boxShadow = 'none';
        }

        lastScroll = currentScroll;
    });

    // ============================================
    // Profile Image Error Handling
    // ============================================
    const profileImg = document.querySelector('.profile-image');
    const logoImg = document.querySelector('.logo-img');
    
    // Fallback if image doesn't load
    if (profileImg) {
        profileImg.addEventListener('error', function() {
            this.style.display = 'none';
            const parent = this.parentElement;
            parent.innerHTML = `
                <div style="width: 100%; height: 100%; border-radius: 50%; background: linear-gradient(135deg, var(--primary), var(--secondary)); display: flex; align-items: center; justify-content: center; font-size: 4rem; border: 5px solid var(--primary);">
                    IB
                </div>
            `;
        });
    }

    if (logoImg) {
        logoImg.addEventListener('error', function() {
            this.style.display = 'none';
            const parent = this.parentElement;
            const span = document.createElement('span');
            span.style.cssText = 'width: 40px; height: 40px; border-radius: 50%; background: linear-gradient(135deg, var(--primary), var(--secondary)); display: flex; align-items: center; justify-content: center; font-size: 1rem; font-weight: bold; border: 2px solid var(--primary);';
            span.textContent = 'IB';
            parent.insertBefore(span, parent.firstChild);
        });
    }

    // ============================================
    // Parallax Effect for Hero Background
    // ============================================
    const hero = document.querySelector('.hero');
    
    window.addEventListener('scroll', () => {
        if (hero) {
            const scrolled = window.pageYOffset;
            const parallax = scrolled * 0.5;
            hero.style.backgroundPositionY = `${parallax}px`;
        }
    });

    // ============================================
    // Skills Cards Hover Effect
    // ============================================
    const skillCards = document.querySelectorAll('.skill-category');
    
    skillCards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-10px) scale(1.02)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
        });
    });

    // ============================================
    // Timeline Item Progressive Display
    // ============================================
    const timelineItems = document.querySelectorAll('.timeline-item');
    
    timelineItems.forEach((item, index) => {
        item.style.opacity = '0';
        item.style.transform = 'translateX(-20px)';
        
        setTimeout(() => {
            item.style.transition = 'all 0.6s ease';
            item.style.opacity = '1';
            item.style.transform = 'translateX(0)';
        }, index * 100);
    });

    // ============================================
    // Certification Badge Click to Copy
    // ============================================
    const certBadges = document.querySelectorAll('.cert-badge');
    
    certBadges.forEach(badge => {
        badge.addEventListener('click', function() {
            const certName = this.querySelector('.cert-name').textContent;
            
            // Create temporary tooltip
            const tooltip = document.createElement('div');
            tooltip.textContent = 'Certification name copied!';
            tooltip.style.cssText = `
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                background: var(--primary);
                color: var(--bg-dark);
                padding: 0.5rem 1rem;
                border-radius: 4px;
                font-size: 0.8rem;
                pointer-events: none;
                z-index: 1000;
            `;
            
            this.style.position = 'relative';
            this.appendChild(tooltip);
            
            // Copy to clipboard
            navigator.clipboard.writeText(certName).catch(err => {
                console.error('Failed to copy:', err);
            });
            
            // Remove tooltip after 2 seconds
            setTimeout(() => {
                tooltip.remove();
            }, 2000);
        });
    });

    // ============================================
    // Dynamic Year in Footer
    // ============================================
    const yearElement = document.querySelector('.footer-content p');
    if (yearElement) {
        const currentYear = new Date().getFullYear();
        yearElement.innerHTML = yearElement.innerHTML.replace('2026', currentYear);
    }

    // ============================================
    // Keyboard Navigation
    // ============================================
    document.addEventListener('keydown', function(e) {
        // Press 'H' to go to home
        if (e.key === 'h' || e.key === 'H') {
            if (!e.target.matches('input, textarea')) {
                window.scrollTo({ top: 0, behavior: 'smooth' });
            }
        }
        
        // Press 'Escape' to close mobile menu
        if (e.key === 'Escape') {
            if (navLinks.classList.contains('active')) {
                navLinks.classList.remove('active');
                toggleMobileMenuIcon(false);
            }
        }
    });

    // ============================================
    // Console Welcome Message
    // ============================================
    console.log('%c👋 Hi there!', 'font-size: 20px; font-weight: bold; color: #00d4ff;');
    console.log('%cThanks for checking out my CV website!', 'font-size: 14px; color: #94a3b8;');
    console.log('%cBuilt with HTML, CSS, and JavaScript', 'font-size: 12px; color: #64748b;');
    console.log('%cHosted on AWS S3 + CloudFront', 'font-size: 12px; color: #64748b;');

    // ============================================
    // Performance Logging (Development Only)
    // ============================================
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        window.addEventListener('load', () => {
            console.log('%c⚡ Performance Metrics', 'font-size: 14px; font-weight: bold; color: #10b981;');
            
            if (window.performance) {
                const perfData = window.performance.timing;
                const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;
                const connectTime = perfData.responseEnd - perfData.requestStart;
                const renderTime = perfData.domComplete - perfData.domLoading;
                
                console.log(`📊 Page Load Time: ${pageLoadTime}ms`);
                console.log(`🔌 Connection Time: ${connectTime}ms`);
                console.log(`🎨 Render Time: ${renderTime}ms`);
            }
        });
    }

    // ============================================
    // Lazy Load Images (if needed in future)
    // ============================================
    if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    if (img.dataset.src) {
                        img.src = img.dataset.src;
                        img.removeAttribute('data-src');
                        observer.unobserve(img);
                    }
                }
            });
        });

        // Observe all images with data-src attribute
        document.querySelectorAll('img[data-src]').forEach(img => {
            imageObserver.observe(img);
        });
    }

});

// ============================================
// Utility Functions
// ============================================

/**
 * Debounce function to limit function calls
 */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

/**
 * Check if element is in viewport
 */
function isInViewport(element) {
    const rect = element.getBoundingClientRect();
    return (
        rect.top >= 0 &&
        rect.left >= 0 &&
        rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
        rect.right <= (window.innerWidth || document.documentElement.clientWidth)
    );
}

/**
 * Get scroll percentage
 */
function getScrollPercentage() {
    const windowHeight = window.innerHeight;
    const documentHeight = document.documentElement.scrollHeight;
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    return (scrollTop / (documentHeight - windowHeight)) * 100;
}
