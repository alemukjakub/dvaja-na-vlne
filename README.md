# Dvaja na vlne 🌊

Statický cestovateľský blog (vanilla HTML/CSS/JS, žiadny build). Články žijú v databáze **Supabase** a pridávajú sa cez jednoduchý **admin panel**.

## Stránky
- `dvaja-na-vlne-domov.html` — domovská stránka (najnovší + „Z denníka")
- `dvaja-na-vlne-mapa.html` — interaktívna mapa ciest (piny = články)
- `dvaja-na-vlne-clanok.html` — článok (načíta sa podľa `?slug=`)
- `dvaja-na-vlne-o-nas.html` — o nás (Jakub + Alenka)
- `admin.html` — administrácia (prihlásenie e-mailom + heslom)
- `index.html` — presmerovanie na domov

## Dáta a backend
- `dvaja-supabase.js` — pripojenie na Supabase (verejný anon key + RLS: čítať môže každý, zapisovať len prihlásený)
- `dvaja-nav.js` — mobilné menu
- `world-map.js` — SVG mapa sveta pre výber polohy v admine
- `supabase-setup.sql` — vytvorenie tabuľky + bezpečnosť + počiatočné články
- `supabase-obrazky.sql` — zapnutie obrázkov (stĺpec `image_url` + Storage bucket `obrazky`)

## Hosting
Statické súbory: **GitHub Pages** (Settings → Pages → deploy from branch → main / root).
Databáza a obrázky: **Supabase** (bežia nezávisle).
