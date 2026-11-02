alter table public.profiles         enable row level security;
alter table public.posts            enable row level security;
alter table public.likes            enable row level security;
alter table public.reports          enable row level security;
alter table public.training_samples enable row level security;

-- ── Droits de table (défense en profondeur, en plus de la RLS) ──
alter default privileges in schema public revoke all on tables from anon;
revoke all on all tables in schema public from anon;

revoke all on public.training_samples from authenticated;

revoke insert, delete, update on public.profiles from authenticated;
grant  update (username, avatar_path, training_consent_at) on public.profiles to authenticated;

revoke update, delete on public.posts   from authenticated;
revoke update         on public.likes   from authenticated;
revoke update, delete on public.reports from authenticated;

-- ── profiles ────────────────────────────────────────────────────
create policy profiles_select on public.profiles for select to authenticated
  using (true);
create policy profiles_update on public.profiles for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

-- ── posts ───────────────────────────────────────────────────────
create policy posts_select on public.posts for select to authenticated
  using (
    user_id = (select auth.uid())
    or (hidden_at is null and created_at > now() - public.post_lifetime())
  );
create policy posts_insert on public.posts for insert to authenticated
  with check (user_id = (select auth.uid()));

-- ── likes ───────────────────────────────────────────────────────
create policy likes_select on public.likes for select to authenticated
  using (user_id = (select auth.uid()));

create policy likes_insert on public.likes for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (
      select 1 from public.posts p
      where p.id = likes.post_id
        and p.user_id <> (select auth.uid())
        and p.hidden_at is null
        and p.created_at > now() - public.post_lifetime()
    )
  );

create policy likes_delete on public.likes for delete to authenticated
  using (
    user_id = (select auth.uid())
    and exists (
      select 1 from public.posts p
      where p.id = likes.post_id
        and p.hidden_at is null
        and p.created_at > now() - public.post_lifetime()
    )
  );

-- ── reports ─────────────────────────────────────────────────────
create policy reports_select on public.reports for select to authenticated
  using (user_id = (select auth.uid()));

create policy reports_insert on public.reports for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (
      select 1 from public.posts p
      where p.id = reports.post_id
        and p.user_id <> (select auth.uid())
        and p.hidden_at is null
        and p.created_at > now() - public.post_lifetime()
    )
  );

-- training_samples : RLS activée, aucune policy → service_role uniquement.