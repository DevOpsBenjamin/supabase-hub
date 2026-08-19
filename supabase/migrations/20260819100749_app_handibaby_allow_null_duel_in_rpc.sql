-- App: handibaby (schema: app_handibaby)
-- Updates record_score and correct_score to allow null duel and rank_in_duel for playoff matches.

create or replace function app_handibaby.record_score(
    p_journal_entry_id text,
    p_tournament_public_id text,
    p_phase text,
    p_winning_side text,
    p_loser_score integer,
    p_written_at bigint,
    p_duel integer default null,
    p_rank_in_duel integer default null
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
    p_winning_side text,
    p_loser_score integer,
    p_previous jsonb,
    p_written_at bigint,
    p_duel integer default null,
    p_rank_in_duel integer default null
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

grant execute on function app_handibaby.record_score(text, text, text, text, integer, bigint, integer, integer) to anon, authenticated, service_role;
grant execute on function app_handibaby.correct_score(text, text, text, text, integer, jsonb, bigint, integer, integer) to anon, authenticated, service_role;
