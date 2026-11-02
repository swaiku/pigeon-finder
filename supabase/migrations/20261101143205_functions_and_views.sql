-- ── Lectures : posts autour d'une position ──────────────────────
create or replace function public.posts_around(
  lat double precision,
  lng double precision,
  radius_m integer default 5000
)
returns table (
  id uuid, username text, city text, photo_path text,
  latitude double precision, longitude double precision,
  created_at timestamptz, pigeon_count smallint, points integer,
  coos bigint, reports bigint, mine boolean, liked_by_me boolean
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
    exists (select 1 from public.likes l where l.post_id = p.id and l.user_id = auth.uid())
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

-- ── Pigeondex / profil : posts non masqués, sans limite de 24 h ─
create or replace function public.my_posts(
  before_ts timestamptz default now(),
  lim integer default 30
)
returns table (
  id uuid, username text, city text, photo_path text,
  latitude double precision, longitude double precision,
  created_at timestamptz, pigeon_count smallint, points integer,
  coos bigint, reports bigint, mine boolean, liked_by_me boolean
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
    false
  from public.posts p
  join public.profiles pr on pr.id = p.user_id
  where p.user_id = auth.uid()
    and p.hidden_at is null
    and p.created_at < before_ts
  order by p.created_at desc
  limit least(greatest(lim, 1), 100);
$$;

-- ── Score : deux sous-requêtes agrégées, pas de jointure posts×likes ─
create or replace function public.my_score()
returns bigint
language sql stable security definer set search_path = ''
as $$
  select
    coalesce((select sum(p.points)
              from public.posts p
              where p.user_id = auth.uid() and p.hidden_at is null), 0)
    + public.points_per_like() * coalesce((select count(*)
              from public.likes l
              join public.posts p on p.id = l.post_id
              where p.user_id = auth.uid() and p.hidden_at is null), 0);
$$;

-- ── Droits d'exécution : jamais anon ────────────────────────────
revoke execute on function
  public.posts_around(double precision, double precision, integer),
  public.my_posts(timestamptz, integer),
  public.my_score(),
  public.post_lifetime(), public.report_threshold(), public.points_per_pigeon(),
  public.points_per_like(), public.max_posts_per_hour()
from public, anon;

grant execute on function
  public.posts_around(double precision, double precision, integer),
  public.my_posts(timestamptz, integer),
  public.my_score(),
  public.post_lifetime(), public.report_threshold(), public.points_per_pigeon(),
  public.points_per_like(), public.max_posts_per_hour()
to authenticated;