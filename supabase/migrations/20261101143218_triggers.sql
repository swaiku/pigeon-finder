-- ── Création du profil à l'inscription ──────────────────────────
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, username, training_consent_at)
  values (
    new.id,
    new.raw_user_meta_data ->> 'username',
    case when coalesce((new.raw_user_meta_data ->> 'training_consent')::boolean, false)
         then now() end
  );
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ── posts : champs serveur + rate limit ─────────────────────────
create function public.posts_before_insert() returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  -- auth.uid() est null uniquement pour postgres/service_role (seed, scripts)
  new.user_id    := coalesce(auth.uid(), new.user_id);
  new.created_at := now();
  new.hidden_at  := null;
  new.points     := new.pigeon_count * public.points_per_pigeon();

  if auth.uid() is not null and (
       select count(*) from public.posts
       where user_id = new.user_id
         and created_at > now() - interval '1 hour'
     ) >= public.max_posts_per_hour()
  then
    raise exception 'rate_limit_exceeded' using errcode = 'P0001';
  end if;

  return new;
end $$;

create trigger posts_before_insert
  before insert on public.posts
  for each row execute function public.posts_before_insert();

-- ── posts : ajout au dataset si consentement ────────────────────
create function public.posts_after_insert() returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.training_samples (post_id, pigeon_count, label_source)
  select new.id, new.pigeon_count, 'user'
  from public.profiles pr
  where pr.id = new.user_id and pr.training_consent_at is not null;
  return new;
end $$;

create trigger posts_after_insert
  after insert on public.posts
  for each row execute function public.posts_after_insert();

-- ── reports : masquage au 3e signalement ────────────────────────
create function public.reports_after_insert() returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  if (select count(*) from public.reports where post_id = new.post_id)
       >= public.report_threshold() then
    update public.posts set hidden_at = now()
    where id = new.post_id and hidden_at is null;

    if found then  -- le post vient d'être masqué
      update public.training_samples
      set pigeon_count = 0, label_source = 'moderation'
      where post_id = new.post_id;
    end if;
  end if;
  return new;
end $$;

create trigger reports_after_insert
  after insert on public.reports
  for each row execute function public.reports_after_insert();

-- ── Retrait du consentement ─────────────────────────────────────
create function public.profiles_consent_withdrawn() returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  delete from public.training_samples ts
  using public.posts p
  where ts.post_id = p.id and p.user_id = new.id;
  return new;
end $$;

create trigger profiles_consent_withdrawn
  after update of training_consent_at on public.profiles
  for each row
  when (old.training_consent_at is not null and new.training_consent_at is null)
  execute function public.profiles_consent_withdrawn();

-- ── Les fonctions de trigger ne sont pas appelables via l'API ───
revoke execute on function
  public.handle_new_user(), public.posts_before_insert(), public.posts_after_insert(),
  public.reports_after_insert(), public.profiles_consent_withdrawn()
from public, anon, authenticated;