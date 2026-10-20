// SOLZA – meni, animacije, galerija, obrazec
(function () {
  var header = document.querySelector('.site-header');
  var burger = document.querySelector('.burger');

  // Glava ob drsenju
  function onScroll() { header.classList.toggle('scrolled', window.scrollY > 20); }
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  // Mobilni meni
  if (burger) {
    burger.addEventListener('click', function () {
      var open = header.classList.toggle('open');
      burger.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
  }

  // Podmeni "Storitve"
  document.querySelectorAll('.sub-toggle').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var li = btn.parentElement;
      var open = li.classList.toggle('open');
      btn.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
  });
  document.addEventListener('click', function (e) {
    document.querySelectorAll('.has-sub.open').forEach(function (li) {
      if (!li.contains(e.target) && window.innerWidth > 960) {
        li.classList.remove('open');
        li.querySelector('.sub-toggle').setAttribute('aria-expanded', 'false');
      }
    });
  });

  // Iskrice na vrhu strani (kot v logotipu)
  var hero = document.querySelector('.hero');
  if (hero) {
    var star = '<svg viewBox="0 0 40 40" aria-hidden="true"><path d="M20 0C21.6 11 25 17.6 40 20 26 22.6 21.4 29 20 40 18.6 29 14 22.6 0 20 15 17.6 18.4 11 20 0Z"/></svg>';
    // [vodoravno, navpično, velikost v px, zamik animacije v s, dodatni razred]
    var spots = [
      [{ right: '6%' }, { top: '84px' }, 32, 0, ''],
      [{ right: '17%' }, { top: '96px' }, 16, 1.1, 'soft'],
      [{ left: '5%' }, { top: '45%' }, 22, 2.3, 'soft wide'],
      [{ left: '6%' }, { bottom: '26px' }, 22, .6, ''],
      [{ right: '9%' }, { bottom: '40px' }, 14, 1.7, 'soft']
    ];
    spots.forEach(function (s) {
      var el = document.createElement('span');
      el.className = ('spark ' + s[4]).trim();
      el.setAttribute('aria-hidden', 'true');
      Object.assign(el.style, s[0], s[1]);
      el.style.width = el.style.height = s[2] + 'px';
      el.style.animationDelay = s[3] + 's';
      el.innerHTML = star;
      hero.insertBefore(el, hero.firstChild);
    });
  }

  // Postopen prikaz vsebine
  var items = document.querySelectorAll('.reveal');
  if ('IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (en.isIntersecting) { en.target.classList.add('visible'); io.unobserve(en.target); }
      });
    }, { threshold: 0.1 });
    items.forEach(function (el) { io.observe(el); });
  } else {
    items.forEach(function (el) { el.classList.add('visible'); });
  }

  // Galerija (povečava slike)
  var links = document.querySelectorAll('[data-full]');
  if (links.length) {
    var box = document.createElement('div');
    box.className = 'lightbox';
    box.setAttribute('role', 'dialog');
    box.setAttribute('aria-modal', 'true');
    box.innerHTML = '<button type="button" aria-label="Zapri">&times;</button><img alt="">';
    document.body.appendChild(box);
    var big = box.querySelector('img');
    var close = function () { box.classList.remove('active'); document.body.style.overflow = ''; };
    links.forEach(function (a) {
      a.addEventListener('click', function (e) {
        e.preventDefault();
        big.src = a.getAttribute('data-full');
        big.alt = a.querySelector('img') ? a.querySelector('img').alt : '';
        box.classList.add('active');
        document.body.style.overflow = 'hidden';
        box.querySelector('button').focus();
      });
    });
    box.addEventListener('click', function (e) { if (e.target !== big) close(); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') close(); });
  }

  // Obrazec: zapiše, s katere strani je prišlo povpraševanje
  document.querySelectorAll('input[name="stran"]').forEach(function (inp) {
    inp.value = document.title + ' (' + location.pathname + ')';
  });
})();
