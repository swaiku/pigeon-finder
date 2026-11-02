insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('photos',  'photos',  false, 5242880, array['image/jpeg']),
  ('dataset', 'dataset', false, null,    null)
on conflict (id) do nothing;

-- Upload : uniquement dans son propre dossier
create policy photos_insert on storage.objects for insert to authenticated
  with check (
    bucket_id = 'photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- Lecture : mes photos, ou celles de posts actuellement visibles
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
    )
  );

-- Pas d'UPDATE ni DELETE client. Bucket "dataset" : aucune policy (service_role only).