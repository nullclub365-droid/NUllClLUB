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

  // App preview clips: step through real screens like a short story reel
  var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  document.querySelectorAll('.clip').forEach(function (clip) {
    var screens = clip.querySelectorAll('.clip-phone img');
    var captions = (clip.getAttribute('data-captions') || '').split('|');
    var captionEl = clip.querySelector('.clip-caption');
    var bars = clip.querySelector('.clip-bars');
    var duration = 2800;
    var index = 0;
    var timer = null;
    var visible = false;
    var hovered = false;
    if (screens.length < 2) return;

    bars.innerHTML = '';
    screens.forEach(function () { bars.appendChild(document.createElement('i')); });
    clip.style.setProperty('--clip-dur', duration + 'ms');

    function show(i) {
      index = (i + screens.length) % screens.length;
      screens.forEach(function (img, n) { img.classList.toggle('is-on', n === index); });
      Array.prototype.forEach.call(bars.children, function (bar, n) {
        bar.classList.remove('is-active');
        bar.classList.toggle('is-done', n < index);
      });
      // Restart the fill animation on the current bar
      void bars.children[index].offsetWidth;
      if (!reduceMotion) bars.children[index].classList.add('is-active');
      else bars.children[index].classList.add('is-done');
      if (captionEl && captions[index]) captionEl.textContent = captions[index];
      // Warm the next screen so the swap never flashes
      var next = screens[(index + 1) % screens.length];
      if (next.loading === 'lazy') next.loading = 'eager';
    }

    function schedule() {
      clearTimeout(timer);
      if (reduceMotion || !visible || hovered) return;
      timer = setTimeout(function () { show(index + 1); schedule(); }, duration);
    }

    function setPaused(paused) {
      clip.classList.toggle('is-paused', paused);
    }

    clip.addEventListener('mouseenter', function () { hovered = true; setPaused(true); clearTimeout(timer); });
    clip.addEventListener('mouseleave', function () { hovered = false; setPaused(false); show(index); schedule(); });
    // Tapping the phone skips ahead instead of opening the app page
    clip.addEventListener('click', function (e) {
      e.stopPropagation();
      show(index + 1);
      schedule();
    });

    if ('IntersectionObserver' in window) {
      new IntersectionObserver(function (entries) {
        visible = entries[0].isIntersecting;
        setPaused(!visible);
        if (visible) { show(index); schedule(); } else { clearTimeout(timer); }
      }, { threshold: 0.4 }).observe(clip);
    } else {
      visible = true;
      schedule();
    }
    show(0);
  });

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
