-- Mumbai Split: run this once in Supabase → SQL Editor → New query → Run.
-- Creates two new, empty tables (prefixed ms_). Your Dharamshala tables (ds_) are not touched.

create table if not exists public.ms_expenses (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  kind text not null default 'expense' check (kind in ('expense', 'settle')),
  note text not null default 'Expense' check (char_length(note) <= 60),
  amount numeric(12,2) not null check (amount > 0 and amount < 10000000),
  payer smallint not null check (payer between 0 and 4),
  split boolean[] not null check (array_length(split, 1) between 1 and 5)
);

create table if not exists public.ms_settings (
  id int primary key default 1 check (id = 1),
  names text[] not null default array['Schoolboy', 'Bathroom guy', 'Andekha', 'Aayush', 'Stuti'],
  budget numeric(12,2) not null default 0 check (budget >= 0 and budget < 100000000)
);
insert into public.ms_settings (id) values (1) on conflict (id) do nothing;

alter table public.ms_expenses enable row level security;
alter table public.ms_settings enable row level security;

drop policy if exists "ms_expenses read" on public.ms_expenses;
drop policy if exists "ms_expenses add" on public.ms_expenses;
drop policy if exists "ms_expenses delete" on public.ms_expenses;
drop policy if exists "ms_settings read" on public.ms_settings;
drop policy if exists "ms_settings edit" on public.ms_settings;

create policy "ms_expenses read"   on public.ms_expenses for select to anon, authenticated using (true);
create policy "ms_expenses add"    on public.ms_expenses for insert to anon, authenticated with check (true);
create policy "ms_expenses delete" on public.ms_expenses for delete to anon, authenticated using (true);
create policy "ms_settings read"   on public.ms_settings for select to anon, authenticated using (true);
create policy "ms_settings edit"   on public.ms_settings for update to anon, authenticated using (id = 1) with check (id = 1);

grant select, insert, delete on public.ms_expenses to anon, authenticated;
grant select, update on public.ms_settings to anon, authenticated;

do $$ begin
  alter publication supabase_realtime add table public.ms_expenses;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.ms_settings;
exception when duplicate_object then null; end $$;
