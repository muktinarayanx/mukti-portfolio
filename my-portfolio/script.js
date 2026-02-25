/* ============================================================
   script.js — Mukti Narayan's Portfolio
   Particles · Scroll Reveal · Nav · Form Validation · Loader
   ============================================================ */

(function () {
    'use strict';

    /* --------------------------------------------------
       1. LOADING SCREEN
       -------------------------------------------------- */
    window.addEventListener('load', () => {
        const loader = document.getElementById('loader');
        // small delay so the animation is visible
        setTimeout(() => loader.classList.add('hidden'), 900);
    });

    /* --------------------------------------------------
       2. PARTICLE STAR FIELD
       -------------------------------------------------- */
    const canvas = document.getElementById('particles-canvas');
    const ctx = canvas.getContext('2d');
    let stars = [];
    const STAR_COUNT = 180;

    function resizeCanvas() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    }

    function createStars() {
        stars = [];
        for (let i = 0; i < STAR_COUNT; i++) {
            stars.push({
                x: Math.random() * canvas.width,
                y: Math.random() * canvas.height,
                radius: Math.random() * 1.6 + 0.4,
                alpha: Math.random() * 0.8 + 0.2,
                dx: (Math.random() - 0.5) * 0.15,
                dy: (Math.random() - 0.5) * 0.15,
                twinkleSpeed: Math.random() * 0.02 + 0.005,
                twinkleDir: 1,
            });
        }
    }

    function drawStars() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        stars.forEach(s => {
            // twinkle
            s.alpha += s.twinkleSpeed * s.twinkleDir;
            if (s.alpha >= 1) s.twinkleDir = -1;
            if (s.alpha <= 0.2) s.twinkleDir = 1;

            // drift
            s.x += s.dx;
            s.y += s.dy;

            // wrap around screen
            if (s.x < 0) s.x = canvas.width;
            if (s.x > canvas.width) s.x = 0;
            if (s.y < 0) s.y = canvas.height;
            if (s.y > canvas.height) s.y = 0;

            ctx.beginPath();
            ctx.arc(s.x, s.y, s.radius, 0, Math.PI * 2);
            ctx.fillStyle = `rgba(200,220,255,${s.alpha})`;
            ctx.fill();
        });
        requestAnimationFrame(drawStars);
    }

    resizeCanvas();
    createStars();
    drawStars();
    window.addEventListener('resize', () => { resizeCanvas(); createStars(); });

    /* --------------------------------------------------
       3. NAVBAR — scroll class + active link highlight
       -------------------------------------------------- */
    const navbar = document.getElementById('navbar');
    const navLinks = document.querySelectorAll('.nav-links a');
    const sections = document.querySelectorAll('section[id]');

    function onScroll() {
        const scrollY = window.scrollY;

        // add scrolled class
        navbar.classList.toggle('scrolled', scrollY > 60);

        // back to top button
        backToTop.classList.toggle('visible', scrollY > 500);

        // highlight active section link
        sections.forEach(sec => {
            const top = sec.offsetTop - 120;
            const bottom = top + sec.offsetHeight;
            const id = sec.getAttribute('id');
            if (scrollY >= top && scrollY < bottom) {
                navLinks.forEach(a => {
                    a.classList.toggle('active', a.getAttribute('href') === '#' + id);
                });
            }
        });
    }

    window.addEventListener('scroll', onScroll, { passive: true });

    /* --------------------------------------------------
       4. HAMBURGER TOGGLE (mobile)
       -------------------------------------------------- */
    const hamburger = document.getElementById('hamburger');
    const navMenu = document.getElementById('navLinks');

    hamburger.addEventListener('click', () => {
        hamburger.classList.toggle('active');
        navMenu.classList.toggle('open');
    });

    // close menu on link click
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            hamburger.classList.remove('active');
            navMenu.classList.remove('open');
        });
    });

    /* --------------------------------------------------
       5. SCROLL REVEAL
       -------------------------------------------------- */
    const revealEls = document.querySelectorAll('.reveal');

    const revealObserver = new IntersectionObserver(
        (entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');
                    revealObserver.unobserve(entry.target); // only once
                }
            });
        },
        { threshold: 0.15 }
    );

    revealEls.forEach(el => revealObserver.observe(el));

    /* --------------------------------------------------
       6. SKILL BAR ANIMATION
       -------------------------------------------------- */
    const skillFills = document.querySelectorAll('.skill-fill');

    const skillObserver = new IntersectionObserver(
        (entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const bar = entry.target;
                    bar.style.width = bar.dataset.width + '%';
                    skillObserver.unobserve(bar);
                }
            });
        },
        { threshold: 0.3 }
    );

    skillFills.forEach(bar => skillObserver.observe(bar));

    /* --------------------------------------------------
       7. CONTACT FORM VALIDATION
       -------------------------------------------------- */
    const form = document.getElementById('contactForm');
    const formStatus = document.getElementById('formStatus');
    const nameInput = document.getElementById('formName');
    const emailInput = document.getElementById('formEmail');
    const msgInput = document.getElementById('formMessage');

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    function setInvalid(input) {
        input.closest('.form-group').classList.add('invalid');
    }
    function clearInvalid(input) {
        input.closest('.form-group').classList.remove('invalid');
    }

    // live clearing
    [nameInput, emailInput, msgInput].forEach(inp => {
        inp.addEventListener('input', () => clearInvalid(inp));
    });

    form.addEventListener('submit', (e) => {
        e.preventDefault();
        let valid = true;

        // name
        if (nameInput.value.trim() === '') { setInvalid(nameInput); valid = false; }
        else clearInvalid(nameInput);

        // email
        if (!emailRegex.test(emailInput.value.trim())) { setInvalid(emailInput); valid = false; }
        else clearInvalid(emailInput);

        // message
        if (msgInput.value.trim() === '') { setInvalid(msgInput); valid = false; }
        else clearInvalid(msgInput);

        if (valid) {
            formStatus.textContent = '🚀 Message sent successfully! (demo)';
            form.reset();
            setTimeout(() => { formStatus.textContent = ''; }, 4000);
        }
    });

    /* --------------------------------------------------
       8. BACK TO TOP BUTTON
       -------------------------------------------------- */
    const backToTop = document.getElementById('backToTop');
    backToTop.addEventListener('click', () => {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    });

    /* --------------------------------------------------
       9. INITIAL SCROLL-CHECK (in case user refreshes mid-page)
       -------------------------------------------------- */
    onScroll();

})();
