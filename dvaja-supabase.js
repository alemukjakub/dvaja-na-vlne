/* ============================================================
   Dvaja na vlne — spoločná dátová vrstva (Supabase)
   ------------------------------------------------------------
   Po vytvorení Supabase projektu sem doplň dve hodnoty:
     SB_URL  = API URL projektu   (napr. https://xxxx.supabase.co)
     SB_KEY  = publishable / anon key (verejný, len na čítanie)
   Kým sú tu placeholdery "__...__", stránky používajú vstavaný
   (seed) obsah a všetko funguje aj bez pripojenia.
   ============================================================ */
window.SB_URL = "https://sxttzfxxkmdudnkffbtb.supabase.co";
window.SB_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4dHR6Znh4a21kdWRua2ZmYnRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMxMDU5MDUsImV4cCI6MjA5ODY4MTkwNX0.R962U44wAh-oZhJIhsdNWF2N360XILjB_5wfxsgZLyo";

/* paleta gradientov pre obrázky (rovnaká ako inde na webe) */
window.GRADIENTS = [
  'linear-gradient(150deg,#3FA9DB,#0B4D74)',
  'linear-gradient(150deg,#7FD0E8,#1391CE)',
  'linear-gradient(150deg,#1391CE,#0B3A5C)',
  'linear-gradient(150deg,#5FB8DE,#0B4D74)',
  'linear-gradient(150deg,#9BD9EC,#2E9BD6)',
  'linear-gradient(150deg,#2E9BD6,#0B3A5C)'
];

window.SB = {
  /* je backend nakonfigurovaný? */
  ready: function () {
    return String(window.SB_URL).indexOf("__") !== 0 &&
           String(window.SB_KEY).indexOf("__") !== 0;
  },
  _headers: function () {
    return { apikey: window.SB_KEY, Authorization: "Bearer " + window.SB_KEY };
  },

  /* všetky články, najnovšie prvé */
  list: async function () {
    var r = await fetch(window.SB_URL + "/rest/v1/articles?select=*&order=published_at.desc",
      { headers: this._headers() });
    if (!r.ok) throw new Error("Supabase " + r.status);
    return r.json();
  },

  /* jeden článok podľa slugu */
  bySlug: async function (slug) {
    var r = await fetch(window.SB_URL + "/rest/v1/articles?slug=eq." +
      encodeURIComponent(slug) + "&select=*&limit=1", { headers: this._headers() });
    if (!r.ok) throw new Error("Supabase " + r.status);
    var a = await r.json();
    return a[0] || null;
  },

  /* prihlásenie (e-mail + heslo) -> vráti access_token */
  login: async function (email, password) {
    var r = await fetch(window.SB_URL + "/auth/v1/token?grant_type=password", {
      method: "POST",
      headers: { apikey: window.SB_KEY, "Content-Type": "application/json" },
      body: JSON.stringify({ email: email, password: password })
    });
    var j = await r.json().catch(function () { return {}; });
    if (!r.ok) throw new Error(j.error_description || j.msg || j.error || ("Prihlásenie zlyhalo (" + r.status + ")"));
    return j;
  },

  /* zápis do DB s prihláseným tokenom (POST/PATCH/DELETE na PostgREST) */
  write: async function (method, path, token, body) {
    var r = await fetch(window.SB_URL + "/rest/v1/" + path, {
      method: method,
      headers: {
        apikey: window.SB_KEY,
        Authorization: "Bearer " + token,
        "Content-Type": "application/json",
        Prefer: "return=representation"
      },
      body: body ? JSON.stringify(body) : undefined
    });
    var txt = await r.text(), j = null;
    try { j = txt ? JSON.parse(txt) : null; } catch (_) { j = txt; }
    if (!r.ok) {
      var msg = (j && (j.message || j.error || j.hint)) || ("HTTP " + r.status);
      var e = new Error(msg); e.status = r.status; throw e;
    }
    return j;
  },

  /* nahratie obrázka do Storage (prihlásený) -> verejná URL */
  upload: async function (bucket, path, file, token) {
    var enc = path.split("/").map(encodeURIComponent).join("/");
    var r = await fetch(window.SB_URL + "/storage/v1/object/" + bucket + "/" + enc, {
      method: "POST",
      headers: { apikey: window.SB_KEY, Authorization: "Bearer " + token, "Content-Type": file.type || "application/octet-stream", "x-upsert": "true" },
      body: file
    });
    if (!r.ok) { var t = await r.text().catch(function () { return ""; }); var e = new Error("Nahratie obrázka zlyhalo (" + r.status + "): " + t.slice(0, 200)); e.status = r.status; throw e; }
    return window.SB_URL + "/storage/v1/object/public/" + bucket + "/" + enc;
  }
};

/* CSS pozadie karty/pinu/hero: ak má článok obrázok, použi ho (cover), inak gradient */
window.bgCss = function (a) {
  if (a && a.image_url) return "url('" + String(a.image_url).replace(/'/g, "%27") + "') center/cover no-repeat";
  return (a && a.gradient) || window.GRADIENTS[0];
};

/* mapovanie riadku z DB na tvar, aký očakáva mapa (D.pts) */
window.toPin = function (a) {
  return {
    name: a.place,
    title: a.title,
    cat: a.category,
    slug: a.slug,
    x: Number(a.map_x),
    y: Number(a.map_y),
    img: window.bgCss(a)
  };
};

/* Chytrý dátum: nové články relatívne ("pred 3 dňami"), staršie ako plný
   slovenský dátum v genitíve ("28. júna 2026"). TZ-safe (berie Y-M-D priamo). */
window.fmtDate = function (iso) {
  if (!iso) return "";
  var months = ["januára","februára","marca","apríla","mája","júna","júla",
                "augusta","septembra","októbra","novembra","decembra"];
  var s = String(iso), mt = s.match(/^(\d{4})-(\d{2})-(\d{2})/), y, mo, da, full;
  if (mt) { y = +mt[1]; mo = +mt[2]; da = +mt[3]; }
  else { var d0 = new Date(s); if (isNaN(d0)) return ""; y = d0.getFullYear(); mo = d0.getMonth() + 1; da = d0.getDate(); }
  full = da + ". " + months[mo - 1] + " " + y;

  // relatívny výpočet konzistentne v lokálnom čase (žiadne UTC posuny)
  var pub = new Date(y, mo - 1, da);
  var now = new Date(), today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  var days = Math.round((today - pub) / 86400000);
  if (days < 0) return full;                 // budúci dátum -> plný dátum
  if (days === 0) return "dnes";
  if (days === 1) return "včera";
  if (days < 7) return "pred " + days + " dňami";
  if (days < 28) { var w = Math.round(days / 7); return "pred " + w + (w === 1 ? " týždňom" : " týždňami"); }
  return full;
};

/* odhad času čítania */
window.readingMin = function (a) {
  if (a.reading_min) return a.reading_min;
  var t = ((a.intro || "") + " " + (a.worth_it || "") + " " + (a.excerpt || "")).trim();
  var words = t ? t.split(/\s+/).length : 0;
  return Math.max(3, Math.round(words / 180));
};

/* Prepočet zemepisných súradníc na súradnice mapy (0..1000 x, 0..500 y).
   Mapa je ekvidištantná valcová projekcia; konštanty odvodené z existujúcich pinov. */
window.lonLatToMap = function (lon, lat) {
  var x = 2.5 * lon + 500;
  var y = 242 - 2.93 * lat;
  return { x: Math.max(0, Math.min(1000, Math.round(x * 10) / 10)),
           y: Math.max(0, Math.min(500, Math.round(y * 10) / 10)) };
};

/* Geokódovanie názvu miesta -> {x,y,lon,lat,label} cez OpenStreetMap Nominatim. */
window.geocode = async function (query) {
  var url = "https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&accept-language=sk&q=" + encodeURIComponent(query);
  var r = await fetch(url, { headers: { "Accept": "application/json" } });
  if (!r.ok) throw new Error("Geokódovanie zlyhalo (" + r.status + ")");
  var a = await r.json();
  if (!a || !a.length) return null;
  var lon = parseFloat(a[0].lon), lat = parseFloat(a[0].lat);
  var m = window.lonLatToMap(lon, lat);
  return { x: m.x, y: m.y, lon: lon, lat: lat, label: a[0].display_name };
};
