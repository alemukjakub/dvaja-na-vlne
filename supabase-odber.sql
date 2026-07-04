-- ============================================================
--  Dvaja na vlne — (voliteľné) tabuľka pre odber newslettera
--  Skopíruj do Supabase → SQL Editor → Run.
--  Bez tohto formulár „Odoberať" stále poďakuje, len e-mail neuloží.
-- ============================================================

create table if not exists public.subscribers (
  id          uuid primary key default gen_random_uuid(),
  email       text unique not null,
  created_at  timestamptz not null default now()
);

alter table public.subscribers enable row level security;

-- ktokoľvek sa môže prihlásiť na odber (verejný zápis), ale e-maily nikto nečíta
drop policy if exists "verejny odber" on public.subscribers;
create policy "verejny odber" on public.subscribers
  for insert to anon, authenticated with check (true);
-- zámerne žiadna SELECT politika → zoznam e-mailov je súkromný
