-- ── Inscription : ne jamais échouer à cause du pseudo ou du consentement ─
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  wanted text := new.raw_user_meta_data ->> 'username';
begin
  -- Pseudo absent, invalide ou déjà pris : on en génère un (modifiable ensuite)
  if wanted is null
     or char_length(wanted) not between 3 and 30
     or wanted !~ '^[A-Za-z0-9_]+$'
     or exists (select 1 from public.profiles where lower(username) = lower(wanted))
  then
    wanted := 'pigeon_' || left(replace(new.id::text, '-', ''), 12);
  end if;

  insert into public.profiles (id, username, training_consent_at)
  values (
    new.id,
    wanted,
    -- Comparaison jsonb : une valeur invalide vaut "pas de consentement" au lieu de lever une erreur
    case when new.raw_user_meta_data -> 'training_consent' = 'true'::jsonb then now() end
  );
  return new;
end $$;

-- ── posts : la photo doit être dans le dossier de l'auteur ──────
drop policy posts_insert on public.posts;
create policy posts_insert on public.posts for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and (storage.foldername(photo_path))[1] = (select auth.uid())::text
  );

-- ── Avatar : uniquement la photo d'un de ses propres posts visibles ─
alter table public.profiles
  add constraint profiles_avatar_path_fkey
  foreign key (avatar_path) references public.posts (photo_path) on delete set null;
create index profiles_avatar_path_idx on public.profiles (avatar_path);

drop policy profiles_update on public.profiles;
create policy profiles_update on public.profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (
    id = (select auth.uid())
    and (
      avatar_path is null
      or exists (
        select 1 from public.posts p
        where p.photo_path = profiles.avatar_path
          and p.user_id = (select auth.uid())
          and p.hidden_at is null
      )
    )
  );

-- Un post masqué par modération ne peut pas rester en avatar
create or replace function public.reports_after_insert() returns trigger
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

      update public.profiles
      set avatar_path = null
      where avatar_path = (select photo_path from public.posts where id = new.post_id);
    end if;
  end if;
  return new;
end $$;

-- Les avatars restent lisibles après les 24 h de vie du post
drop policy photos_select on storage.objects;
create policy photos_select on storage.objects for select to authenticated
  using (
    bucket_id = 'photos'
    and (
      (storage.foldername(name))[1] = (select auth.uid())::text
      or exists (
        select 1 from public.posts p
        where p.photo_path = storage.objects.name
          and p.hidden_at is null
          and p.created_at > now() - public.post_lifetime()
      )
      or exists (
        select 1 from public.profiles pr
        where pr.avatar_path = storage.objects.name
      )
    )
  );
