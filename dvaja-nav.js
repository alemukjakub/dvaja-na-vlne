/* Mobilné menu (hamburger) — zdieľané na verejných stránkach.
   Prepína triedu .open na .nav-links a nastavuje aria-expanded. */
(function () {
  var b = document.querySelector('.burger');
  var n = document.querySelector('.nav-links');
  if (!b || !n) return;
  if (!n.id) n.id = 'nav-links';
  b.setAttribute('aria-expanded', 'false');
  b.setAttribute('aria-controls', n.id);
  b.addEventListener('click', function () {
    var open = n.classList.toggle('open');
    b.setAttribute('aria-expanded', open ? 'true' : 'false');
  });
  n.addEventListener('click', function (e) {
    if (e.target.closest('a')) { n.classList.remove('open'); b.setAttribute('aria-expanded', 'false'); }
  });
})();
