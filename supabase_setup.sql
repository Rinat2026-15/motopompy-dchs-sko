-- Выполнить один раз в Supabase > SQL Editor.
-- Приложение предполагает, что просмотр данных и фото доступен по публичной ссылке.
create table if not exists public.pump_state (
  id integer primary key check (id=1),
  data jsonb not null default '{"departments":[],"pumps":[]}'::jsonb,
  updated_at timestamptz not null default now()
);
insert into public.pump_state(id,data) values(1,'{"departments":[],"pumps":[]}'::jsonb)
on conflict(id) do nothing;
create table if not exists public.app_admins (
 user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.pump_state enable row level security;
alter table public.app_admins enable row level security;
revoke all on public.pump_state from anon,authenticated;
revoke all on public.app_admins from anon,authenticated;
grant select on public.pump_state to anon,authenticated;
grant update on public.pump_state to authenticated;
grant select on public.app_admins to authenticated;
drop policy if exists "pump_public_read" on public.pump_state;
create policy "pump_public_read" on public.pump_state for select to anon,authenticated using (true);
drop policy if exists "pump_admin_write" on public.pump_state;
create policy "pump_admin_write" on public.pump_state for update to authenticated
using (exists (select 1 from public.app_admins where user_id=(select auth.uid())))
with check (id=1 and exists (select 1 from public.app_admins where user_id=(select auth.uid())));
drop policy if exists "admin_read_self" on public.app_admins;
create policy "admin_read_self" on public.app_admins for select to authenticated
using (user_id=(select auth.uid()));
-- Создать bucket: фото не секретные, доступны всем посетителям.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('pump-photos','pump-photos',true,5242880,array['image/jpeg'])
on conflict(id) do update set public=true, file_size_limit=5242880, allowed_mime_types=array['image/jpeg'];
drop policy if exists "pump_photo_public_read" on storage.objects;
create policy "pump_photo_public_read" on storage.objects for select to anon,authenticated
using (bucket_id='pump-photos');
drop policy if exists "pump_photo_admin_insert" on storage.objects;
create policy "pump_photo_admin_insert" on storage.objects for insert to authenticated
with check (bucket_id='pump-photos' and exists(select 1 from public.app_admins where user_id=(select auth.uid())));
-- После создания пользователя в Authentication > Users:
-- скопировать его UUID и отдельно выполнить:
-- insert into public.app_admins(user_id) values ('ВАШ-UUID') on conflict do nothing;
