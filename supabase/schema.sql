-- Global Sound Universe: Supabase foundation
create extension if not exists pgcrypto;
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 username text unique, display_name text, avatar_url text, bio text,
 role text not null default 'listener' check (role in ('listener','artist','admin')),
 created_at timestamptz not null default now()
);
create table if not exists public.artists (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null unique references auth.users(id) on delete cascade,
 stage_name text not null, country text, biography text,
 verified boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.tracks (
 id uuid primary key default gen_random_uuid(),
 artist_id uuid not null references public.artists(id) on delete cascade,
 title text not null, audio_url text not null, cover_url text, genre text,
 duration_seconds integer check (duration_seconds is null or duration_seconds >= 0),
 status text not null default 'pending' check (status in ('pending','published','rejected')),
 created_at timestamptz not null default now()
);
create table if not exists public.playlists (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 title text not null, is_public boolean not null default false,
 created_at timestamptz not null default now()
);
create table if not exists public.playlist_tracks (
 playlist_id uuid not null references public.playlists(id) on delete cascade,
 track_id uuid not null references public.tracks(id) on delete cascade,
 position integer not null default 0, primary key (playlist_id,track_id)
);
create table if not exists public.community_posts (
 id uuid primary key default gen_random_uuid(),
 author_id uuid not null references auth.users(id) on delete cascade,
 body text not null check (char_length(body) between 1 and 5000),
 created_at timestamptz not null default now()
);
create table if not exists public.community_comments (
 id uuid primary key default gen_random_uuid(),
 post_id uuid not null references public.community_posts(id) on delete cascade,
 author_id uuid not null references auth.users(id) on delete cascade,
 body text not null check (char_length(body) between 1 and 2000),
 created_at timestamptz not null default now()
);
create table if not exists public.gs_coins_ledger (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 amount integer not null check (amount <> 0), reason text not null,
 reference_id uuid, created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.artists enable row level security;
alter table public.tracks enable row level security;
alter table public.playlists enable row level security;
alter table public.playlist_tracks enable row level security;
alter table public.community_posts enable row level security;
alter table public.community_comments enable row level security;
alter table public.gs_coins_ledger enable row level security;

create policy "Profiles readable" on public.profiles for select using (true);
create policy "Users create own profile" on public.profiles for insert with check (auth.uid() = id);
create policy "Users update own profile" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);
create policy "Artists readable" on public.artists for select using (true);
create policy "Users create own artist profile" on public.artists for insert with check (auth.uid() = user_id);
create policy "Users update own artist profile" on public.artists for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Published tracks or own artist tracks readable" on public.tracks for select using (
 status = 'published' or exists (select 1 from public.artists a where a.id = artist_id and a.user_id = auth.uid())
);
create policy "Artists submit own tracks" on public.tracks for insert with check (
 exists (select 1 from public.artists a where a.id = artist_id and a.user_id = auth.uid())
);
create policy "Artists update own tracks" on public.tracks for update using (
 exists (select 1 from public.artists a where a.id = artist_id and a.user_id = auth.uid())
) with check (
 exists (select 1 from public.artists a where a.id = artist_id and a.user_id = auth.uid())
);
create policy "Public playlists or owner readable" on public.playlists for select using (is_public or owner_id = auth.uid());
create policy "Owners manage playlists" on public.playlists for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "Playlist tracks readable" on public.playlist_tracks for select using (
 exists (select 1 from public.playlists p where p.id = playlist_id and (p.is_public or p.owner_id = auth.uid()))
);
create policy "Playlist owners manage tracks" on public.playlist_tracks for all using (
 exists (select 1 from public.playlists p where p.id = playlist_id and p.owner_id = auth.uid())
) with check (
 exists (select 1 from public.playlists p where p.id = playlist_id and p.owner_id = auth.uid())
);
create policy "Community posts readable" on public.community_posts for select using (true);
create policy "Users create own posts" on public.community_posts for insert with check (author_id = auth.uid());
create policy "Users update own posts" on public.community_posts for update using (author_id = auth.uid()) with check (author_id = auth.uid());
create policy "Users delete own posts" on public.community_posts for delete using (author_id = auth.uid());
create policy "Community comments readable" on public.community_comments for select using (true);
create policy "Users create own comments" on public.community_comments for insert with check (author_id = auth.uid());
create policy "Users update own comments" on public.community_comments for update using (author_id = auth.uid()) with check (author_id = auth.uid());
create policy "Users delete own comments" on public.community_comments for delete using (author_id = auth.uid());
create policy "Users read own coin ledger" on public.gs_coins_ledger for select using (user_id = auth.uid());
-- Intentionally no client write policy for G.S Coins. Trusted server functions only.
