-- ── Avatar : une photo envoyée depuis la galerie ou la caméra ───
-- Avant : avatar_path devait être la photo d'un de ses posts (clé étrangère).
-- Maintenant : un fichier `<uid>/avatar-<uuid>.jpg` dans le bucket photos, à la
-- racine du dossier de l'utilisateur pour que delete-account le supprime aussi.
-- La lecture par les autres reste couverte par photos_select (pr.avatar_path).
alter table public.profiles drop constraint profiles_avatar_path_fkey;

-- Un ancien avatar (photo de post) bloquerait toute mise à jour du profil avec
-- la nouvelle policy : on le retire.
update public.profiles set avatar_path = null
where avatar_path not like id::text || '/avatar-%.jpg';

drop policy profiles_update on public.profiles;
create policy profiles_update on public.profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (
    id = (select auth.uid())
    and (
      avatar_path is null
      or avatar_path like (select auth.uid())::text || '/avatar-%.jpg'
    )
  );

-- L'ancien avatar est supprimé au changement : uniquement ses propres avatars,
-- jamais les photos de posts.
create policy photos_delete_avatar on storage.objects for delete to authenticated
  using (
    bucket_id = 'photos'
    and name like (select auth.uid())::text || '/avatar-%.jpg'
  );
