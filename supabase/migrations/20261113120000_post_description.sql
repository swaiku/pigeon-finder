-- ── Description des posts dans les lectures ─────────────────────
-- posts_around et my_posts renvoient aussi la description. Le type de retour
-- change : il faut supprimer puis recréer les fonctions, ce qui efface leurs
-- droits d'exécution (rétablis en fin de fichier).
drop function public.posts_around(double precision, double precision, integer);
drop function public.my_posts(timestamptz, integer);

create function public.posts_around(
  lat double precision,
  lng double precision,
  radius_m integer default 5000
)
returns table (
  id uuid, username text, city text, photo_path text,
  latitude double precision, longitude double precision,
  created_at timestamptz, pigeon_count smallint, points integer,
  coos bigint, reports bigint, mine boolean, liked_by_me boolean,
  description text
)
language sql stable security definer set search_path = ''
as $$
  select
    p.id,
    pr.username,
    p.city,
    p.photo_path,
    extensions.st_y(p.location::extensions.geometry),
    extensions.st_x(p.location::extensions.geometry),
    p.created_at,
    p.pigeon_count,
    p.points,
    (select count(*) from public.likes   l where l.post_id = p.id),
    (select count(*) from public.reports r where r.post_id = p.id),
    p.user_id = auth.uid(),
    exists (select 1 from public.likes l where l.post_id = p.id and l.user_id = auth.uid()),
    p.description
  from public.posts p
  join public.profiles pr on pr.id = p.user_id
  where p.hidden_at is null
    and p.created_at > now() - public.post_lifetime()
    and extensions.st_dwithin(
          p.location,
          extensions.st_setsrid(extensions.st_makepoint(lng, lat), 4326)::extensions.geography,
          radius_m)
  order by p.created_at desc
  limit 500;
$$;

create function public.my_posts(
  before_ts timestamptz default now(),
  lim integer default 30
)
returns table (
  id uuid, username text, city text, photo_path text,
  latitude double precision, longitude double precision,
  created_at timestamptz, pigeon_count smallint, points integer,
  coos bigint, reports bigint, mine boolean, liked_by_me boolean,
  description text
)
language sql stable security definer set search_path = ''
as $$
  select
    p.id,
    pr.username,
    p.city,
    p.photo_path,
    extensions.st_y(p.location::extensions.geometry),
    extensions.st_x(p.location::extensions.geometry),
    p.created_at,
    p.pigeon_count,
    p.points,
    (select count(*) from public.likes   l where l.post_id = p.id),
    (select count(*) from public.reports r where r.post_id = p.id),
    true,
    false,
    p.description
  from public.posts p
  join public.profiles pr on pr.id = p.user_id
  where p.user_id = auth.uid()
    and p.hidden_at is null
    and p.created_at < before_ts
  order by p.created_at desc
  limit least(greatest(lim, 1), 100);
$$;

revoke execute on function
  public.posts_around(double precision, double precision, integer),
  public.my_posts(timestamptz, integer)
from public, anon;

grant execute on function
  public.posts_around(double precision, double precision, integer),
  public.my_posts(timestamptz, integer)
to authenticated;
