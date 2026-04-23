(function () {
  'use strict';

  // Mark current navigation link for clearer orientation.
  var currentPage = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.nav a, .footer-nav a').forEach(function (link) {
    var href = link.getAttribute('href') || '';
    if (!href || href.startsWith('#')) return;
    var targetPage = href.split('#')[0];
    if (targetPage === currentPage || (currentPage === '' && targetPage === 'index.html')) {
      link.setAttribute('aria-current', 'page');
    }
  });

  // Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(function (anchor) {
    anchor.addEventListener('click', function (e) {
      var targetId = this.getAttribute('href');
      if (targetId === '#') return;
      var target = document.querySelector(targetId);
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  });

  // Whole card click goes to app detail page (except when clicking "Get the app")
  document.querySelectorAll('.product-card--clickable').forEach(function (card) {
    card.addEventListener('click', function (e) {
      // If user clicked the "Get the app" link, let it work normally
      if (e.target.closest('.product-link') && !e.target.closest('.product-link--disabled')) {
        return;
      }
      var url = card.getAttribute('data-detail-url');
      if (url) {
        window.location.href = url;
      }
    });
  });

  // Optional: subtle parallax on hero content
  var hero = document.getElementById('hero');
  if (hero) {
    window.addEventListener('scroll', function () {
      var scrolled = window.scrollY;
      var rate = scrolled * 0.15;
      var content = hero.querySelector('.hero-content');
      if (content && scrolled < window.innerHeight) {
        content.style.transform = 'translateY(' + rate + 'px)';
      }
    });
  }

  // GymFlow: attach exercise thumbnails based on slugified names
  var librarySection = document.querySelector('.library-section');
  if (librarySection) {
    var exerciseItems = librarySection.querySelectorAll('.exercise-list li');
    exerciseItems.forEach(function (item) {
      var name = item.textContent.trim();
      if (!name) return;
      var slug = name
        .toLowerCase()
        .replace(/&/g, 'and')
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-+|-+$/g, '');
      var thumb = document.createElement('img');
      thumb.src = 'assets/gymflow/' + slug + '.jpg';
      thumb.alt = name + ' exercise';
      thumb.loading = 'lazy';
      thumb.decoding = 'async';
      thumb.className = 'exercise-thumb';
      thumb.dataset.fullSrc = thumb.src;
      item.insertBefore(thumb, item.firstChild);

      thumb.addEventListener('click', function (e) {
        e.stopPropagation();
        openExerciseLightbox(thumb.dataset.fullSrc, name);
      });

      // Also open the lightbox when clicking anywhere on the row (except links)
      item.addEventListener('click', function (e) {
        if (e.target.tagName.toLowerCase() === 'a') return;
        openExerciseLightbox(thumb.dataset.fullSrc, name);
      });
    });
  }
})();

function openExerciseLightbox(src, title) {
  var existing = document.querySelector('.exercise-lightbox-backdrop');
  if (existing) existing.remove();

  var backdrop = document.createElement('div');
  backdrop.className = 'exercise-lightbox-backdrop';

  var inner = document.createElement('div');
  inner.className = 'exercise-lightbox-inner';

  var img = document.createElement('img');
  img.src = src;
  img.alt = title + ' exercise preview';

  inner.appendChild(img);
  backdrop.appendChild(inner);
  document.body.appendChild(backdrop);

  function close() {
    backdrop.remove();
    document.removeEventListener('keydown', onKey);
  }

  function onKey(e) {
    if (e.key === 'Escape') close();
  }

  backdrop.addEventListener('click', function (e) {
    if (e.target === backdrop) close();
  });
  document.addEventListener('keydown', onKey);
}
