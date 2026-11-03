-- 연결된 Supabase 프로젝트의 SQL Editor에서 실행하세요.
-- 사용자 로그인에는 기존 Supabase Auth를 사용합니다.
begin;

create table if not exists public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  recipe_id bigint not null,
  created_at timestamptz not null default now(),
  constraint favorites_user_recipe_unique unique (user_id, recipe_id)
);

alter table public.favorites enable row level security;

grant usage on schema public to authenticated;
grant select, insert, delete on public.favorites to authenticated;
revoke all on public.favorites from anon;

drop policy if exists favorites_select_own on public.favorites;
create policy favorites_select_own on public.favorites
  for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists favorites_insert_own on public.favorites;
create policy favorites_insert_own on public.favorites
  for insert to authenticated with check ((select auth.uid()) = user_id);

drop policy if exists favorites_delete_own on public.favorites;
create policy favorites_delete_own on public.favorites
  for delete to authenticated using ((select auth.uid()) = user_id);

notify pgrst, 'reload schema';
commit;