-- ── Classement : même score que my_score(), filtré par zone ─────
-- scope : 'city' | 'region' | 'country' compare la colonne du post à zone ;
-- tout autre valeur (ex. 'world') prend tous les posts. Renvoie le top `lim`
-- plus la ligne de l'appelant s'il n'y est pas. Pas d'user_id exposé.
-- next_score / next_rank : sur la ligne de l'appelant seulement, score et rang
-- du joueur juste devant (null s'il est en tête).
create function public.leaderboard(
  scope text default 'world',
  zone text default null,
  lim integer default 50
)
returns table (
  rank bigint, username text, score bigint, pigeons bigint, me boolean,
  next_score bigint, next_rank bigint
)
language sql stable security definer set search_path = ''
as $$
  with scored as (
    select
      p.user_id,
      sum(p.points + public.points_per_like()
          * (select count(*) from public.likes l where l.post_id = p.id))::bigint as score,
      sum(p.pigeon_count)::bigint as pigeons
    from public.posts p
    where p.hidden_at is null
      and case scope
            when 'city'    then p.city    = zone
            when 'region'  then p.region  = zone
            when 'country' then p.country = zone
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

revoke execute on function public.leaderboard(text, text, integer) from public, anon;
grant  execute on function public.leaderboard(text, text, integer) to authenticated;
