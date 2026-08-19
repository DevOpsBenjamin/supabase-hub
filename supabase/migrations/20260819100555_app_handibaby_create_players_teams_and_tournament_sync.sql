-- App: handibaby (schema: app_handibaby)
-- Creates players, tournament_players, teams, and frozen_editions tables with sync functions.

create table if not exists app_handibaby.players (
    id bigint generated always as identity primary key,
    first_name text not null,
    last_name text not null,
    name_key text not null unique,
    created_at timestamptz default timezone('utc'::text, now()) not null
);

alter table app_handibaby.players enable row level security;

create policy "Public read players"
on app_handibaby.players for select
using (true);

grant select on app_handibaby.players to anon, authenticated;

create table if not exists app_handibaby.tournament_players (
    id bigint generated always as identity primary key,
    tournament_public_id text not null references app_handibaby.tournaments(public_id) on delete cascade,
    player_name_key text not null references app_handibaby.players(name_key) on delete cascade,
    unique (tournament_public_id, player_name_key)
);

alter table app_handibaby.tournament_players enable row level security;

create policy "Public read tournament players"
on app_handibaby.tournament_players for select
using (true);

grant select on app_handibaby.tournament_players to anon, authenticated;

create table if not exists app_handibaby.teams (
    id bigint generated always as identity primary key,
    tournament_public_id text not null references app_handibaby.tournaments(public_id) on delete cascade,
    label text not null,
    player_one_name_key text not null references app_handibaby.players(name_key),
    player_two_name_key text not null references app_handibaby.players(name_key),
    team_index integer not null,
    unique (tournament_public_id, team_index)
);

alter table app_handibaby.teams enable row level security;

create policy "Public read teams"
on app_handibaby.teams for select
using (true);

grant select on app_handibaby.teams to anon, authenticated;

create table if not exists app_handibaby.frozen_editions (
    tournament_public_id text primary key references app_handibaby.tournaments(public_id) on delete cascade,
    data jsonb not null,
    frozen_at bigint not null
);

alter table app_handibaby.frozen_editions enable row level security;

create policy "Public read frozen editions"
on app_handibaby.frozen_editions for select
using (true);

grant select on app_handibaby.frozen_editions to anon, authenticated;

-- Function to save / upsert a tournament and its players
create or replace function app_handibaby.save_tournament(
    p_public_id text,
    p_label text,
    p_start_date text,
    p_status text,
    p_passphrase_hash text,
    p_created_at bigint
) returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into app_handibaby.tournaments (
        public_id,
        label,
        start_date,
        status,
        passphrase_hash,
        created_at
    ) values (
        p_public_id,
        p_label,
        p_start_date,
        p_status,
        p_passphrase_hash,
        p_created_at
    )
    on conflict (public_id)
    do update set
        label = excluded.label,
        start_date = excluded.start_date,
        status = excluded.status,
        passphrase_hash = excluded.passphrase_hash;
end;
$$;

-- Function to save a player
create or replace function app_handibaby.save_player(
    p_first_name text,
    p_last_name text,
    p_name_key text
) returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into app_handibaby.players (
        first_name,
        last_name,
        name_key
    ) values (
        p_first_name,
        p_last_name,
        p_name_key
    )
    on conflict (name_key)
    do update set
        first_name = excluded.first_name,
        last_name = excluded.last_name;
end;
$$;

grant execute on function app_handibaby.save_tournament(text, text, text, text, text, bigint) to anon, authenticated, service_role;
grant execute on function app_handibaby.save_player(text, text, text) to anon, authenticated, service_role;
