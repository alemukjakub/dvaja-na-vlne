-- ============================================================
--  Dvaja na vlne — zapnutie obrázkov k článkom
--  ------------------------------------------------------------
--  NAJPRV vytvor bucket v UI (spoľahlivé):
--    Storage → New bucket → Name: obrazky → Public bucket ✔ → Save
--  POTOM spusti tento súbor: SQL Editor → New query → vlož → Run.
--  (Vytvorenie bucketu cez SQL býva blokované právami, preto ho robíme v UI.)
-- ============================================================

-- 1) stĺpec pre URL obrázka
alter table public.articles add column if not exists image_url text default '';

-- 2) práva na Storage bucket „obrazky": verejné čítanie, zápis len prihlásený
drop policy if exists "verejne citanie obrazky" on storage.objects;
create policy "verejne citanie obrazky" on storage.objects
  for select to public using (bucket_id = 'obrazky');

drop policy if exists "prihlaseni upload obrazky" on storage.objects;
create policy "prihlaseni upload obrazky" on storage.objects
  for insert to authenticated with check (bucket_id = 'obrazky');

drop policy if exists "prihlaseni update obrazky" on storage.objects;
create policy "prihlaseni update obrazky" on storage.objects
  for update to authenticated using (bucket_id = 'obrazky') with check (bucket_id = 'obrazky');
