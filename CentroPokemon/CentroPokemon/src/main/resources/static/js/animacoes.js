/**
 * @file        animacoes.js
 * @summary     Animações e interações leves do Centro Pokémon
 * @description Timer de oferta, efeitos nos botões, navegação ativa,
 *              partículas decorativas e transições entre seções da landing.
 * @selectors   .timer-display, .quick-btn, nav a, .pagina, .pagina-content
 * @nav         Links sem hash fazem navegação real (pathname). Com hash
 *              alternam seções (#inicio, #centro, #sobre) sem recarregar.
 * @active      Determina link ativo e seção pela URL atual (pathname/hash).
 */

document.addEventListener('DOMContentLoaded', function() {
    // Timer functionality - Countdown display
    var timerEl = document.querySelector('.timer-display');
    if (timerEl) {
        var parts = timerEl.textContent.trim().split(':');
        var secs = (+parts[0])*3600 + (+parts[1])*60 + (+parts[2]);
        
        /** Atualiza o visor do timer de oferta a cada segundo */
        function tick() {
            if (secs > 0) secs--;
            var h = Math.floor(secs/3600);
            var m = Math.floor((secs%3600)/60);
            var s = secs%60;
            timerEl.textContent = String(h).padStart(2,'0')+':'+String(m).padStart(2,'0')+':'+String(s).padStart(2,'0');
        }
        setInterval(tick, 1000);
    }

    // Button click animations - Quick buttons
    document.querySelectorAll('.quick-btn').forEach(function(btn) {
        btn.addEventListener('click', function() {
            btn.style.transform = 'translateY(2px) scale(0.98)';
            setTimeout(function(){ btn.style.transform = ''; }, 150);
        });
    });

    // Navigation active state
    var navLinks = document.querySelectorAll('nav a');
    navLinks.forEach(function(link) {
        link.addEventListener('click', function(e) {
            var href = link.getAttribute('href') || '';
            var isHashOnly = href.startsWith('#');
            var hasHash = href.indexOf('#') > -1;
            if (isHashOnly || hasHash) {
                e.preventDefault();
                navLinks.forEach(function(l){ l.classList.remove('active'); });
                link.classList.add('active');
                var targetId = isHashOnly ? href.substring(1) : href.split('#')[1];
                if (targetId) {
                    var targetEl = document.getElementById(targetId);
                    if (targetEl) {
                        pages.forEach(function(page) { page.classList.remove('ativa'); });
                        targetEl.classList.add('ativa');
                        try { window.location.hash = '#' + targetId; } catch (e) {}
                    }
                }
            } else {
                window.location.assign(href);
            }
        });
    });

    // Particle animation system
    var content = document.querySelector('.pagina-content');
    if (content) {
        var particles = document.createElement('div');
        particles.className = 'particles';
        content.appendChild(particles);
        
        for (var i = 0; i < 20; i++) {
            var p = document.createElement('span');
            p.className = 'particle';
            p.style.left = Math.random()*100 + '%';
            p.style.top = Math.random()*100 + '%';
            p.style.animationDelay = (Math.random()*3)+'s';
            particles.appendChild(p);
        }
    }

    // Page transition animations
    var pages = document.querySelectorAll('.pagina');
    if (pages.length > 1) {
        // Simple page switching logic
        /**
         * Alterna página ativa pela id de âncora
         * @param {string} pageId
         */
        var showPage = function(pageId) {
            pages.forEach(function(page) {
                page.classList.remove('ativa');
            });
            document.getElementById(pageId).classList.add('ativa');
        };

        // Connect navigation to page switching
        navLinks.forEach(function(link) {
            link.addEventListener('click', function() {
                var href = this.getAttribute('href') || '';
                if (href.startsWith('#')) {
                    var targetPage = href.substring(1);
                    if (targetPage) {
                        showPage(targetPage);
                    }
                } else if (href.indexOf('#') > -1) {
                    var targetPage2 = href.split('#')[1];
                    if (targetPage2) {
                        showPage(targetPage2);
                    }
                }
            });
        });

        var initialTarget = null;
        if (window.location.hash && window.location.hash.length > 1) {
            initialTarget = window.location.hash.substring(1);
        } else {
            var path = window.location.pathname || '';
            if (path.endsWith('/centro')) initialTarget = 'centro';
            else if (path.endsWith('/sobre')) initialTarget = 'sobre';
            else initialTarget = 'inicio';
        }
        var initialEl = initialTarget && document.getElementById(initialTarget);
        if (initialEl) {
            pages.forEach(function(page) { page.classList.remove('ativa'); });
            initialEl.classList.add('ativa');
        }

        var path = window.location.pathname || '';
        navLinks.forEach(function(l){ l.classList.remove('active'); });
        var targetHref = '/Pokemon.html';
        if (path.endsWith('/pokedex')) targetHref = '/pokedex';
        else if (path.endsWith('/centro')) targetHref = '/centro';
        else if (path.endsWith('/sobre')) targetHref = '/sobre';
        var activeLink = Array.from(navLinks).find(function(a){
            var href = (a.getAttribute('href')||'');
            return href === targetHref || href.split('#')[0] === targetHref;
        });
        if (activeLink) activeLink.classList.add('active');
    }
});