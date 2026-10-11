(() => {
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const secs = [...document.querySelectorAll('main section[id]')];
  const dots = document.getElementById('dots');
  const count = document.getElementById('count');
  const crumb = document.getElementById('crumb');
  const pbar = document.getElementById('pbar');

  // Dots (origen: trigger, no centro)
  secs.forEach((s, i) => {
    const a = document.createElement('a');
    a.href = '#' + s.id;
    a.title = s.dataset.name || s.id;
    a.setAttribute('aria-label', s.dataset.name || s.id);
    dots.appendChild(a);
    s._dot = a;
  });

  // Reveal: opacity + transform, 220ms, stagger vía --d
  const io = new IntersectionObserver((es) => {
    es.forEach((e) => { if (e.isIntersecting) e.target.classList.add('in'); });
  }, { threshold: 0.12, rootMargin: '0px 0px -8% 0px' });
  document.querySelectorAll('.rv').forEach((el) => io.observe(el));
  if (reduce) document.querySelectorAll('.rv').forEach((el) => el.classList.add('in'));

  // Progreso + sección activa (solo transform en barra)
  const onScroll = () => {
    const max = document.body.scrollHeight - innerHeight;
    const p = max > 0 ? scrollY / max : 0;
    if (pbar) pbar.style.transform = 'scaleX(' + p.toFixed(4) + ')';
    let act = secs[0];
    secs.forEach((s) => { if (s.getBoundingClientRect().top < innerHeight * 0.45) act = s; });
    if (act) {
      const n = secs.indexOf(act) + 1;
      if (count) count.textContent = String(n).padStart(2, '0') + ' / ' + String(secs.length).padStart(2, '0');
      if (crumb) crumb.textContent = act.dataset.name || '';
      secs.forEach((s) => s._dot.classList.toggle('on', s === act));
    }
  };
  addEventListener('scroll', onScroll, { passive: true });
  addEventListener('resize', onScroll);
  onScroll();

  // Resaltado IDE: corre una vez sobre texto plano, sin dependencias
  const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  const HL = /(\/\/[^\n]*|#[^\n]*)|('(?:[^'\\\n]|\\.)*')|\b(\d[\d._]*)\b|\b(import|export|return|if|else|for|in|while|async|await|late|final|const|var|try|catch|throw|new|class|extends|void|true|false|null|switch|case|break|continue|sdk)\b|\b([A-Za-z_]\w*)(?=\s*\()|\b([A-Z][A-Za-z0-9_]*)\b/g;
  document.querySelectorAll('figure.code pre code').forEach((el) => {
    const src = el.textContent;
    if (!src || src.includes('tk-')) return;
    let out = '', last = 0, m;
    HL.lastIndex = 0;
    while ((m = HL.exec(src))) {
      out += esc(src.slice(last, m.index));
      const [full, com, str, num, kw, fn, tp] = m;
      const cls = com ? 'tk-com' : str ? 'tk-str' : num ? 'tk-num' : kw ? 'tk-kw' : fn ? 'tk-fn' : 'tk-tp';
      out += '<span class="' + cls + '">' + esc(full) + '</span>';
      last = m.index + full.length;
    }
    out += esc(src.slice(last));
    el.innerHTML = out;
  });

  // Teclado: flechas / PageUp-Down (sin animar nada con JS)
  addEventListener('keydown', (e) => {
    if (!['ArrowDown', 'ArrowRight', 'PageDown', 'ArrowUp', 'ArrowLeft', 'PageUp', 'Home', 'End'].includes(e.key)) return;
    const y = scrollY, h = innerHeight;
    const cur = secs.findIndex((s) => { const b = s.getBoundingClientRect(); return b.top <= h * 0.5 && b.bottom > h * 0.5; });
    let next = cur;
    if (['ArrowDown', 'ArrowRight', 'PageDown'].includes(e.key)) next = Math.min(secs.length - 1, cur + 1);
    if (['ArrowUp', 'ArrowLeft', 'PageUp'].includes(e.key)) next = Math.max(0, cur - 1);
    if (e.key === 'Home') next = 0;
    if (e.key === 'End') next = secs.length - 1;
    if (next !== cur && next >= 0) { e.preventDefault(); secs[next].scrollIntoView({ behavior: reduce ? 'auto' : 'smooth' }); }
    else if (e.key === 'ArrowDown' && cur === -1) { secs[0].scrollIntoView({ behavior: reduce ? 'auto' : 'smooth' }); }
    void y;
  });
})();
