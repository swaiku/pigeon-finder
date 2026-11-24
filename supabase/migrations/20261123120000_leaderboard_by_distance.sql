-- ── Classement par distance et code pays ────────────────────────
-- Les noms (city, country) dépendent de la langue du téléphone qui a publié
-- ("Genève" / "Geneva"), donc on ne filtre plus dessus : rayon autour d'un
-- point pour 'nearby' et 'city', code ISO 3166-1 alpha-2 pour 'country'.
alter table public.posts
  add column country_code text check (country_code ~ '^[A-Z]{2}$');
create index posts_country_code_idx on public.posts (country_code);

drop function public.leaderboard(text, text, integer);

-- scope : 'nearby' (2 km) | 'city' (20 km) | 'country' | tout autre = monde.
-- Sans lat/lng ni country_iso, prend la position et le pays du dernier post
-- de l'appelant. Même score que my_score(). Renvoie le top `lim` plus la
-- ligne de l'appelant ; next_score / next_rank (sur cette ligne seulement) :
-- score et rang du joueur juste devant, null s'il est en tête.
create function public.leaderboard(
  scope text default 'world',
  lat double precision default null,
  lng double precision default null,
  country_iso text default null,
  lim integer default 50
)
returns table (
  rank bigint, username text, score bigint, pigeons bigint, me boolean,
  next_score bigint, next_rank bigint
)
language sql stable security definer set search_path = ''
as $$
  with origin as (
    select
      coalesce(
        case when lat is not null and lng is not null then
          extensions.st_setsrid(extensions.st_makepoint(lng, lat), 4326)::extensions.geography
        end,
        (select p.location from public.posts p
         where p.user_id = auth.uid() and p.hidden_at is null
         order by p.created_at desc limit 1)
      ) as location,
      coalesce(
        upper(country_iso),
        (select p.country_code from public.posts p
         where p.user_id = auth.uid() and p.hidden_at is null
           and p.country_code is not null
         order by p.created_at desc limit 1)
      ) as country_code
  ),
  scored as (
    select
      p.user_id,
      sum(p.points + public.points_per_like()
          * (select count(*) from public.likes l where l.post_id = p.id))::bigint as score,
      sum(p.pigeon_count)::bigint as pigeons
    from public.posts p
    cross join origin o
    where p.hidden_at is null
      and case scope
            when 'nearby'  then extensions.st_dwithin(p.location, o.location, 2000)
            when 'city'    then extensions.st_dwithin(p.location, o.location, 20000)
            when 'country' then p.country_code = o.country_code
            else true
          end
    group by p.user_id
  ),
  ranked as (
    select
      rank()       over (order by s.score desc) as rnk,
      row_number() over (order by s.score desc, pr.username) as rn,
      pr.username,
      s.score,
      s.pigeons,
      s.user_id = auth.uid() as me
    from scored s
    join public.profiles pr on pr.id = s.user_id
  ),
  ahead as (
    select min(s.score) as score
    from scored s
    where s.score > (select m.score from scored m where m.user_id = auth.uid())
  )
  select
    r.rnk, r.username, r.score, r.pigeons, r.me,
    case when r.me then a.score end,
    case when r.me then (select min(r2.rnk) from ranked r2 where r2.score = a.score) end
  from ranked r
  cross join ahead a
  where r.rn <= least(greatest(lim, 1), 100) or r.me
  order by r.rn;
$$;
-- shortcut: agrège tous les posts de la zone à chaque appel, passer à une vue
-- matérialisée rafraîchie périodiquement si les posts se comptent en millions

revoke execute on function
  public.leaderboard(text, double precision, double precision, text, integer)
from public, anon;
grant execute on function
  public.leaderboard(text, double precision, double precision, text, integer)
to authenticated;
