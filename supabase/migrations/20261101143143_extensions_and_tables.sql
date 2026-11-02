create extension if not exists postgis with schema extensions;

-- ── Constantes (seule source de vérité) ─────────────────────────
create function public.post_lifetime()      returns interval language sql immutable set search_path = '' as $$ select interval '24 hours' $$;
create function public.report_threshold()   returns int      language sql immutable set search_path = '' as $$ select 3 $$;
create function public.points_per_pigeon()  returns int      language sql immutable set search_path = '' as $$ select 10 $$;
create function public.points_per_like()    returns int      language sql immutable set search_path = '' as $$ select 1 $$;
create function public.max_posts_per_hour() returns int      language sql immutable set search_path = '' as $$ select 20 $$;

-- ── profiles ────────────────────────────────────────────────────
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null
    check (char_length(username) between 3 and 30 and username ~ '^[A-Za-z0-9_]+$'),
  avatar_path text,
  training_consent_at timestamptz,
  created_at timestamptz not null default now()
);
create unique index profiles_username_lower_key on public.profiles (lower(username));

-- ── posts ───────────────────────────────────────────────────────
create table public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  photo_path text not null,
  description text check (char_length(description) <= 280),
  location extensions.geography(Point, 4326) not null,
  city text,
  region text,
  country text,
  pigeon_count smallint not null check (pigeon_count between 1 and 10),
  points integer not null,
  created_at timestamptz not null default now(),
  hidden_at timestamptz
);
create index posts_location_gix       on public.posts using gist (location);
create index posts_user_created_idx   on public.posts (user_id, created_at desc);
create index posts_created_idx        on public.posts (created_at desc);
create unique index posts_photo_path_key on public.posts (photo_path); -- utilisé par la policy storage

-- ── likes / reports ─────────────────────────────────────────────
create table public.likes (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);
create index likes_user_idx on public.likes (user_id);

create table public.reports (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);
create index reports_user_idx on public.reports (user_id);

-- ── training_samples (aucune donnée personnelle) ────────────────
create table public.training_samples (
  id uuid primary key default gen_random_uuid(),
  post_id uuid unique references public.posts(id) on delete set null,
  pigeon_count smallint not null check (pigeon_count >= 0),
  label_source text not null check (label_source in ('user', 'moderation')),
  dataset_path text,
  copied_at timestamptz,
  created_at timestamptz not null default now()
);