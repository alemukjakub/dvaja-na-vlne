-- ============================================================
--  Dvaja na vlne — kompletné nastavenie databázy
--  Skopíruj CELÝ tento súbor do Supabase → SQL Editor → Run.
--  Vytvorí tabuľku článkov, zapne bezpečnosť (verejné čítanie,
--  zápis len pre prihláseného používateľa) a naplní 16 článkov.
-- ============================================================

create extension if not exists pgcrypto;

create table if not exists public.articles (
  id            uuid primary key default gen_random_uuid(),
  slug          text unique not null,
  place         text not null,
  title         text not null,
  category      text not null default 'article'
                  check (category in ('favorite','article','planned')),
  published_at  timestamptz not null default now(),   -- dátum publikovania (automaticky)
  map_x         numeric not null default 500,          -- poloha pinu 0..1000
  map_y         numeric not null default 250,          -- poloha pinu 0..500
  gradient      text not null default 'linear-gradient(150deg,#3FA9DB,#0B4D74)',
  image_url     text default '',                       -- URL nahranej fotky (nahrádza gradient)
  excerpt       text default '',
  intro         text default '',
  quote         text default '',
  worth_it      text default '',
  reading_min   int,
  featured      boolean not null default false,
  created_at    timestamptz not null default now()
);

create index if not exists articles_published_idx on public.articles (published_at desc);

alter table public.articles enable row level security;

-- verejné čítanie (návštevníci webu cez anon key)
drop policy if exists "public read articles" on public.articles;
create policy "public read articles" on public.articles
  for select to anon, authenticated using (true);

-- zápis LEN pre prihlásených používateľov (teba – po vytvorení používateľa v Authentication)
drop policy if exists "auth insert articles" on public.articles;
create policy "auth insert articles" on public.articles
  for insert to authenticated with check (true);
drop policy if exists "auth update articles" on public.articles;
create policy "auth update articles" on public.articles
  for update to authenticated using (true) with check (true);
drop policy if exists "auth delete articles" on public.articles;
create policy "auth delete articles" on public.articles
  for delete to authenticated using (true);

-- ---------- počiatočné články (migrácia existujúceho obsahu) ----------
insert into public.articles
  (slug, place, title, category, published_at, map_x, map_y, gradient, featured, excerpt, intro, quote, worth_it)
values
  ('amalfi','Amalfi · Taliansko','Amalfi za úsvitu, keď ešte spia turisti aj mesto','favorite','2026-06-28',535.9,124,'linear-gradient(150deg,#3FA9DB,#0B4D74)',true,
   'Vstali sme o pol piatej, aby sme videli, ako sa slnko obtáča okolo útesov. Malý sprievodca po serpentínach, kávach a schodoch.',
   'Ráno bolo ešte chladné, keď sme vyšli k moru. Vzduch mal tú soľnú ostrosť, ktorá sa nedá vyfotiť, len zapamätať. Cesta viedla popri vode a s každou zákrutou sa otváral nový výhľad — presne kvôli takýmto chvíľam sme si tento denník založili.',
   'More má tú vlastnosť, že aj keď ho poznáš, vždy ťa niečím prekvapí.',
   'Skoré ráno. Vážne. Kým sa zobudia autobusy a davy, patrí pobrežie len tým, čo vstali. Druhá rada: nechať si čas. Najlepšie miesta sme našli vtedy, keď sme sa niekde len tak zastavili a nikam sa neponáhľali.'),

  ('santorini','Santorini · Grécko','Modré kupoly a kde ich fotiť bez davov','favorite','2026-06-21',563.7,137.1,'linear-gradient(150deg,#7FD0E8,#1391CE)',false,
   'Tri miesta, kam sa dostaneš pešo skôr ako výletné lode.',
   'Ráno bolo ešte chladné, keď sme vyšli k moru. Vzduch mal tú soľnú ostrosť, ktorá sa nedá vyfotiť, len zapamätať. Cesta viedla popri vode a s každou zákrutou sa otváral nový výhľad — presne kvôli takýmto chvíľam sme si tento denník založili.',
   'More má tú vlastnosť, že aj keď ho poznáš, vždy ťa niečím prekvapí.',
   'Skoré ráno. Vážne. Kým sa zobudia autobusy a davy, patrí pobrežie len tým, čo vstali. Druhá rada: nechať si čas. Najlepšie miesta sme našli vtedy, keď sme sa niekde len tak zastavili a nikam sa neponáhľali.'),

  ('algarve','Algarve · Portugalsko','Skryté pláže pod útesmi Lagosu','article','2026-06-12',478.4,134.9,'linear-gradient(150deg,#5FB8DE,#0B4D74)',false,
   'Kajakom do jaskýň Benagil a späť pred prílivom.',
   'Ráno bolo ešte chladné, keď sme vyšli k moru. Vzduch mal tú soľnú ostrosť, ktorá sa nedá vyfotiť, len zapamätať. Cesta viedla popri vode a s každou zákrutou sa otváral nový výhľad — presne kvôli takýmto chvíľam sme si tento denník založili.',
   'More má tú vlastnosť, že aj keď ho poznáš, vždy ťa niečím prekvapí.',
   'Skoré ráno. Vážne. Kým sa zobudia autobusy a davy, patrí pobrežie len tým, čo vstali. Druhá rada: nechať si čas. Najlepšie miesta sme našli vtedy, keď sme sa niekde len tak zastavili a nikam sa neponáhľali.'),

  ('lofoty','Lofoty · Nórsko','More, ktoré nikdy nezotmie','favorite','2026-06-03',527.8,44,'linear-gradient(150deg,#1391CE,#0B3A5C)',false,
   'Polnočné slnko nad rybárskymi domčekmi v Reine.',
   'Ráno bolo ešte chladné, keď sme vyšli k moru. Vzduch mal tú soľnú ostrosť, ktorá sa nedá vyfotiť, len zapamätať. Cesta viedla popri vode a s každou zákrutou sa otváral nový výhľad — presne kvôli takýmto chvíľam sme si tento denník založili.',
   'More má tú vlastnosť, že aj keď ho poznáš, vždy ťa niečím prekvapí.',
   'Skoré ráno. Vážne. Kým sa zobudia autobusy a davy, patrí pobrežie len tým, čo vstali. Druhá rada: nechať si čas. Najlepšie miesta sme našli vtedy, keď sme sa niekde len tak zastavili a nikam sa neponáhľali.'),

  ('dubrovnik','Dubrovník · Chorvátsko','Po hradbách o šiestej ráno','article','2026-05-25',544.1,117.8,'linear-gradient(150deg,#9BD9EC,#2E9BD6)',false,
   'Ako obísť vstupenkové rady a mať mesto pre seba.',
   'Ráno bolo ešte chladné, keď sme vyšli k moru. Vzduch mal tú soľnú ostrosť, ktorá sa nedá vyfotiť, len zapamätať. Cesta viedla popri vode a s každou zákrutou sa otváral nový výhľad — presne kvôli takýmto chvíľam sme si tento denník založili.',
   'More má tú vlastnosť, že aj keď ho poznáš, vždy ťa niečím prekvapí.',
   'Skoré ráno. Vážne. Kým sa zobudia autobusy a davy, patrí pobrežie len tým, čo vstali. Druhá rada: nechať si čas. Najlepšie miesta sme našli vtedy, keď sme sa niekde len tak zastavili a nikam sa neponáhľali.'),

  ('madeira','Madeira · Portugalsko','Levady, oceán a mračná pod nohami','article','2026-05-14',457,148.5,'linear-gradient(150deg,#2E9BD6,#0B3A5C)',false,
   'Túra, kde sa Atlantik díva na teba zhora aj zdola.',
   'Ráno bolo ešte chladné, keď sme vyšli k moru. Vzduch mal tú soľnú ostrosť, ktorá sa nedá vyfotiť, len zapamätať. Cesta viedla popri vode a s každou zákrutou sa otváral nový výhľad — presne kvôli takýmto chvíľam sme si tento denník založili.',
   'More má tú vlastnosť, že aj keď ho poznáš, vždy ťa niečím prekvapí.',
   'Skoré ráno. Vážne. Kým sa zobudia autobusy a davy, patrí pobrežie len tým, čo vstali. Druhá rada: nechať si čas. Najlepšie miesta sme našli vtedy, keď sme sa niekde len tak zastavili a nikam sa neponáhľali.'),

  ('mallorca','Mallorca · Španielsko','Zátoky na severe, ktoré nikto neobjavil','article','2026-05-02',506.5,127.3,'linear-gradient(150deg,#3FA9DB,#0B4D74)',false,
   'Autom po serpentínach k tyrkysovým calas.',
   'Ráno bolo ešte chladné, keď sme vyšli k moru. Vzduch mal tú soľnú ostrosť, ktorá sa nedá vyfotiť, len zapamätať. Cesta viedla popri vode a s každou zákrutou sa otváral nový výhľad — presne kvôli takýmto chvíľam sme si tento denník založili.',
   'More má tú vlastnosť, že aj keď ho poznáš, vždy ťa niečím prekvapí.',
   'Skoré ráno. Vážne. Kým sa zobudia autobusy a davy, patrí pobrežie len tým, čo vstali. Druhá rada: nechať si čas. Najlepšie miesta sme našli vtedy, keď sme sa niekde len tak zastavili a nikam sa neponáhľali.'),

  ('nice','Nice · Francúzsko','Promenáda za súmraku','article','2026-04-24',517.6,114.6,'linear-gradient(150deg,#7FD0E8,#1391CE)',false,
   'Promenáda des Anglais, keď sa nebo farbí do ružova.',
   'Ráno bolo ešte chladné, keď sme vyšli k moru. Vzduch mal tú soľnú ostrosť, ktorá sa nedá vyfotiť, len zapamätať. Cesta viedla popri vode a s každou zákrutou sa otváral nový výhľad — presne kvôli takýmto chvíľam sme si tento denník založili.',
   'More má tú vlastnosť, že aj keď ho poznáš, vždy ťa niečím prekvapí.',
   'Skoré ráno. Vážne. Kým sa zobudia autobusy a davy, patrí pobrežie len tým, čo vstali. Druhá rada: nechať si čas. Najlepšie miesta sme našli vtedy, keď sme sa niekde len tak zastavili a nikam sa neponáhľali.'),

  ('cinque-terre','Cinque Terre · Taliansko','Päť dedín, jeden chodník','article','2026-04-15',523.5,113.3,'linear-gradient(150deg,#1391CE,#0B3A5C)',false,
   'Päť dedín spojených jedným pobrežným chodníkom.',
   'Ráno bolo ešte chladné, keď sme vyšli k moru. Vzduch mal tú soľnú ostrosť, ktorá sa nedá vyfotiť, len zapamätať. Cesta viedla popri vode a s každou zákrutou sa otváral nový výhľad — presne kvôli takýmto chvíľam sme si tento denník založili.',
   'More má tú vlastnosť, že aj keď ho poznáš, vždy ťa niečím prekvapí.',
   'Skoré ráno. Vážne. Kým sa zobudia autobusy a davy, patrí pobrežie len tým, čo vstali. Druhá rada: nechať si čas. Najlepšie miesta sme našli vtedy, keď sme sa niekde len tak zastavili a nikam sa neponáhľali.'),

  ('kotor','Kotor · Čierna Hora','Fjord, čo nie je fjord','article','2026-04-06',545.7,118.5,'linear-gradient(150deg,#5FB8DE,#0B4D74)',false,
   'Zátoka zovretá horami, čo vyzerá ako severský fjord.',
   'Ráno bolo ešte chladné, keď sme vyšli k moru. Vzduch mal tú soľnú ostrosť, ktorá sa nedá vyfotiť, len zapamätať. Cesta viedla popri vode a s každou zákrutou sa otváral nový výhľad — presne kvôli takýmto chvíľam sme si tento denník založili.',
   'More má tú vlastnosť, že aj keď ho poznáš, vždy ťa niečím prekvapí.',
   'Skoré ráno. Vážne. Kým sa zobudia autobusy a davy, patrí pobrežie len tým, čo vstali. Druhá rada: nechať si čas. Najlepšie miesta sme našli vtedy, keď sme sa niekde len tak zastavili a nikam sa neponáhľali.'),

  ('kreta','Kréta · Grécko','Ružová pláž Elafonisi','article','2026-03-28',562.3,140.7,'linear-gradient(150deg,#9BD9EC,#2E9BD6)',false,
   'Ružový piesok Elafonisi a voda ako z pohľadnice.',
   'Ráno bolo ešte chladné, keď sme vyšli k moru. Vzduch mal tú soľnú ostrosť, ktorá sa nedá vyfotiť, len zapamätať. Cesta viedla popri vode a s každou zákrutou sa otváral nový výhľad — presne kvôli takýmto chvíľam sme si tento denník založili.',
   'More má tú vlastnosť, že aj keď ho poznáš, vždy ťa niečím prekvapí.',
   'Skoré ráno. Vážne. Kým sa zobudia autobusy a davy, patrí pobrežie len tým, čo vstali. Druhá rada: nechať si čas. Najlepšie miesta sme našli vtedy, keď sme sa niekde len tak zastavili a nikam sa neponáhľali.'),

  ('big-sur','Big Sur · USA','Cesta č. 1 nad oceánom','article','2026-03-18',195.2,137.5,'linear-gradient(150deg,#2E9BD6,#0B3A5C)',false,
   'Slávna Highway 1 sa vlní nad Tichým oceánom.',
   'Ráno bolo ešte chladné, keď sme vyšli k moru. Vzduch mal tú soľnú ostrosť, ktorá sa nedá vyfotiť, len zapamätať. Cesta viedla popri vode a s každou zákrutou sa otváral nový výhľad — presne kvôli takýmto chvíľam sme si tento denník založili.',
   'More má tú vlastnosť, že aj keď ho poznáš, vždy ťa niečím prekvapí.',
   'Skoré ráno. Vážne. Kým sa zobudia autobusy a davy, patrí pobrežie len tým, čo vstali. Druhá rada: nechať si čas. Najlepšie miesta sme našli vtedy, keď sme sa niekde len tak zastavili a nikam sa neponáhľali.'),

  ('azory','Azory · Portugalsko','Na zozname snov','planned','2026-07-01',436.1,132.9,'linear-gradient(150deg,#3FA9DB,#0B4D74)',false,'Na zozname snov.','','',''),
  ('faerske-ostrovy','Faerské ostrovy','Na zozname snov','planned','2026-07-01',485.4,60.8,'linear-gradient(150deg,#7FD0E8,#1391CE)',false,'Na zozname snov.','','',''),
  ('bali','Bali · Indonézia','Na zozname snov','planned','2026-07-01',806.4,275.8,'linear-gradient(150deg,#1391CE,#0B3A5C)',false,'Na zozname snov.','','',''),
  ('zanzibar','Zanzibar · Tanzánia','Na zozname snov','planned','2026-07-01',604.5,269,'linear-gradient(150deg,#5FB8DE,#0B4D74)',false,'Na zozname snov.','','','')
on conflict (slug) do nothing;
