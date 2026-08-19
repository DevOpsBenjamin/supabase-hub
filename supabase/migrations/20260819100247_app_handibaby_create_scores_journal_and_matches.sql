-- App: handibaby (schema: app_handibaby)
-- Creates scores journal and matches tables with RPC functions for recording and correcting scores.

create table if not exists app_handibaby.tournaments (
    public_id text primary key,
    label text not null,
    start_date text not null,
    status text not null default 'draft',
    passphrase_hash text not null,
    created_at bigint not null
);

alter table app_handibaby.tournaments enable row level security;

create policy "Public read tournaments"
on app_handibaby.tournaments for select
using (true);

grant select on app_handibaby.tournaments to anon, authenticated;

create table if not exists app_handibaby.matches (
    id bigint generated always as identity primary key,
    tournament_public_id text not null,
    phase text not null,
    duel integer,
    rank_in_duel integer,
    winning_side text,
    loser_score integer,
    entered_at bigint,
    constraint matches_unique_slot unique nulls not distinct (tournament_public_id, phase, duel, rank_in_duel)
);

alter table app_handibaby.matches enable row level security;

create policy "Public read matches"
on app_handibaby.matches for select
using (true);

grant select on app_handibaby.matches to anon, authenticated;

create table if not exists app_handibaby.scores_journal (
    entry_id text primary key,
    tournament_public_id text not null,
    phase text not null,
    duel integer,
    rank_in_duel integer,
    operation text not null,
    winning_side text not null,
    loser_score integer not null,
    previous jsonb,
    written_at bigint not null,
    created_at timestamptz default timezone('utc'::text, now()) not null
);

alter table app_handibaby.scores_journal enable row level security;

create policy "Public read scores journal"
on app_handibaby.scores_journal for select
using (true);

grant select on app_handibaby.scores_journal to anon, authenticated;

create or replace function app_handibaby.record_score(
    p_journal_entry_id text,
    p_tournament_public_id text,
    p_phase text,
    p_duel integer,
    p_rank_in_duel integer,
    p_winning_side text,
    p_loser_score integer,
    p_written_at bigint
) returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
    if p_loser_score < 0 or p_loser_score > 9 then
        raise exception 'Invalid loser score: %', p_loser_score;
    end if;

    if p_winning_side not in ('blue', 'white') then
        raise exception 'Invalid winning side: %', p_winning_side;
    end if;

    insert into app_handibaby.scores_journal (
        entry_id,
        tournament_public_id,
        phase,
        duel,
        rank_in_duel,
        operation,
        winning_side,
        loser_score,
        previous,
        written_at
    ) values (
        p_journal_entry_id,
        p_tournament_public_id,
        p_phase,
        p_duel,
        p_rank_in_duel,
        'record',
        p_winning_side,
        p_loser_score,
        null,
        p_written_at
    )
    on conflict (entry_id) do nothing;

    insert into app_handibaby.matches (
        tournament_public_id,
        phase,
        duel,
        rank_in_duel,
        winning_side,
        loser_score,
        entered_at
    ) values (
        p_tournament_public_id,
        p_phase,
        p_duel,
        p_rank_in_duel,
        p_winning_side,
        p_loser_score,
        p_written_at
    )
    on conflict (tournament_public_id, phase, duel, rank_in_duel)
    do update set
        winning_side = excluded.winning_side,
        loser_score = excluded.loser_score,
        entered_at = excluded.entered_at;
end;
$$;

create or replace function app_handibaby.correct_score(
    p_journal_entry_id text,
    p_tournament_public_id text,
    p_phase text,
    p_duel integer,
    p_rank_in_duel integer,
    p_winning_side text,
    p_loser_score integer,
    p_previous jsonb,
    p_written_at bigint
) returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
    if p_loser_score < 0 or p_loser_score > 9 then
        raise exception 'Invalid loser score: %', p_loser_score;
    end if;

    if p_winning_side not in ('blue', 'white') then
        raise exception 'Invalid winning side: %', p_winning_side;
    end if;

    insert into app_handibaby.scores_journal (
        entry_id,
        tournament_public_id,
        phase,
        duel,
        rank_in_duel,
        operation,
        winning_side,
        loser_score,
        previous,
        written_at
    ) values (
        p_journal_entry_id,
        p_tournament_public_id,
        p_phase,
        p_duel,
        p_rank_in_duel,
        'correct',
        p_winning_side,
        p_loser_score,
        p_previous,
        p_written_at
    )
    on conflict (entry_id) do nothing;

    insert into app_handibaby.matches (
        tournament_public_id,
        phase,
        duel,
        rank_in_duel,
        winning_side,
        loser_score,
        entered_at
    ) values (
        p_tournament_public_id,
        p_phase,
        p_duel,
        p_rank_in_duel,
        p_winning_side,
        p_loser_score,
        p_written_at
    )
    on conflict (tournament_public_id, phase, duel, rank_in_duel)
    do update set
        winning_side = excluded.winning_side,
        loser_score = excluded.loser_score,
        entered_at = excluded.entered_at;
end;
$$;

grant execute on function app_handibaby.record_score(text, text, text, integer, integer, text, integer, bigint) to anon, authenticated, service_role;
grant execute on function app_handibaby.correct_score(text, text, text, integer, integer, text, integer, jsonb, bigint) to anon, authenticated, service_role;
