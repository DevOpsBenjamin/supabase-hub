-- App: handibaby (schema: app_handibaby)
-- purge_quiz_tournaments_and_guard_sync

-- 1. Purge quiz pseudo-tournaments from all tables
delete from app_handibaby.scores_journal
where tournament_public_id like 'quiz-%'
   or tournament_public_id = 'test-quiz'
   or tournament_public_id in (
       select public_id from app_handibaby.tournaments where status = 'quiz' or label ilike '%quiz%'
   );

delete from app_handibaby.frozen_editions
where tournament_public_id like 'quiz-%'
   or tournament_public_id = 'test-quiz'
   or tournament_public_id in (
       select public_id from app_handibaby.tournaments where status = 'quiz' or label ilike '%quiz%'
   );

delete from app_handibaby.matches
where tournament_public_id like 'quiz-%'
   or tournament_public_id = 'test-quiz'
   or tournament_public_id in (
       select public_id from app_handibaby.tournaments where status = 'quiz' or label ilike '%quiz%'
   );

delete from app_handibaby.tournament_players
where tournament_public_id like 'quiz-%'
   or tournament_public_id = 'test-quiz'
   or tournament_public_id in (
       select public_id from app_handibaby.tournaments where status = 'quiz' or label ilike '%quiz%'
   );

delete from app_handibaby.teams
where tournament_public_id like 'quiz-%'
   or tournament_public_id = 'test-quiz'
   or tournament_public_id in (
       select public_id from app_handibaby.tournaments where status = 'quiz' or label ilike '%quiz%'
   );

delete from app_handibaby.tournaments
where status = 'quiz' or public_id like 'quiz-%' or public_id = 'test-quiz' or label ilike '%quiz%';

-- 2. Guard sync_tournament_bundle against legacy quiz pseudo-tournaments
create or replace function app_handibaby.sync_tournament_bundle(
    p_tournament jsonb,
    p_players jsonb default '[]'::jsonb,
    p_tournament_players jsonb default '[]'::jsonb,
    p_teams jsonb default '[]'::jsonb,
    p_matches jsonb default '[]'::jsonb,
    p_frozen_edition jsonb default null::jsonb
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_player jsonb;
    v_tp jsonb;
    v_team jsonb;
    v_match jsonb;
    v_public_id text;
begin
    v_public_id := p_tournament->>'public_id';
    if v_public_id is null or v_public_id = '' then
        raise exception 'Missing tournament public_id';
    end if;

    -- Reject quiz pseudo-tournaments from polluting tournaments table
    if coalesce(p_tournament->>'status', '') = 'quiz'
       or v_public_id like 'quiz-%'
       or v_public_id = 'test-quiz'
       or coalesce(p_tournament->>'label', '') ilike '%quiz%' then
        return;
    end if;

    -- Upsert tournament
    insert into app_handibaby.tournaments (
        public_id,
        label,
        start_date,
        status,
        passphrase_hash,
        created_at
    ) values (
        v_public_id,
        coalesce(p_tournament->>'label', 'Tournoi'),
        coalesce(p_tournament->>'start_date', to_char(now(), 'YYYY-MM-DD')),
        coalesce(p_tournament->>'status', 'draft'),
        coalesce(p_tournament->>'passphrase_hash', ''),
        coalesce((p_tournament->>'created_at')::bigint, (extract(epoch from now()) * 1000)::bigint)
    )
    on conflict (public_id)
    do update set
        label = excluded.label,
        start_date = excluded.start_date,
        status = excluded.status,
        passphrase_hash = excluded.passphrase_hash;

    -- Upsert players
    if p_players is not null and p_players != 'null'::jsonb then
        for v_player in select * from jsonb_array_elements(p_players)
        loop
            insert into app_handibaby.players (
                first_name,
                last_name,
                name_key
            ) values (
                v_player->>'first_name',
                v_player->>'last_name',
                v_player->>'name_key'
            )
            on conflict (name_key)
            do update set
                first_name = excluded.first_name,
                last_name = excluded.last_name;
        end loop;
    end if;

    -- Upsert tournament players
    if p_tournament_players is not null and p_tournament_players != 'null'::jsonb then
        for v_tp in select * from jsonb_array_elements(p_tournament_players)
        loop
            insert into app_handibaby.tournament_players (
                tournament_public_id,
                player_name_key
            ) values (
                v_public_id,
                v_tp->>'player_name_key'
            )
            on conflict (tournament_public_id, player_name_key) do nothing;
        end loop;
    end if;

    -- Upsert teams
    if p_teams is not null and p_teams != 'null'::jsonb then
        for v_team in select * from jsonb_array_elements(p_teams)
        loop
            insert into app_handibaby.teams (
                tournament_public_id,
                label,
                player_one_name_key,
                player_two_name_key,
                team_index
            ) values (
                v_public_id,
                coalesce(v_team->>'label', 'Équipe'),
                v_team->>'player_one_name_key',
                v_team->>'player_two_name_key',
                (v_team->>'team_index')::integer
            )
            on conflict (tournament_public_id, team_index)
            do update set
                label = excluded.label,
                player_one_name_key = excluded.player_one_name_key,
                player_two_name_key = excluded.player_two_name_key;
        end loop;
    end if;

    -- Upsert matches: preserve true sides_swapped
    if p_matches is not null and p_matches != 'null'::jsonb then
        for v_match in select * from jsonb_array_elements(p_matches)
        loop
            insert into app_handibaby.matches (
                tournament_public_id,
                phase,
                duel,
                rank_in_duel,
                winning_side,
                loser_score,
                entered_at,
                sides_swapped
            ) values (
                v_public_id,
                v_match->>'phase',
                (v_match->>'duel')::integer,
                (v_match->>'rank_in_duel')::integer,
                v_match->>'winning_side',
                (v_match->>'loser_score')::integer,
                (v_match->>'entered_at')::bigint,
                coalesce((v_match->>'sides_swapped')::boolean, false)
            )
            on conflict (tournament_public_id, phase, duel, rank_in_duel)
            do update set
                winning_side = coalesce(excluded.winning_side, app_handibaby.matches.winning_side),
                loser_score = coalesce(excluded.loser_score, app_handibaby.matches.loser_score),
                entered_at = coalesce(excluded.entered_at, app_handibaby.matches.entered_at),
                sides_swapped = app_handibaby.matches.sides_swapped or coalesce((v_match->>'sides_swapped')::boolean, false);
        end loop;
    end if;

    -- Upsert frozen edition if present
    if p_frozen_edition is not null and p_frozen_edition != 'null'::jsonb then
        insert into app_handibaby.frozen_editions (
            tournament_public_id,
            data,
            frozen_at
        ) values (
            v_public_id,
            p_frozen_edition->'data',
            coalesce((p_frozen_edition->>'frozen_at')::bigint, (extract(epoch from now()) * 1000)::bigint)
        )
        on conflict (tournament_public_id)
        do update set
            data = excluded.data,
            frozen_at = excluded.frozen_at;
    end if;
end;
$$;

grant execute on function app_handibaby.sync_tournament_bundle(jsonb, jsonb, jsonb, jsonb, jsonb, jsonb) to anon, authenticated;
