-- App: handibaby (schema: app_handibaby)
-- create quiz attempts table and cleanup tournaments

-- 1. Create dedicated table for quiz attempts
create table if not exists app_handibaby.quiz_attempts (
    id bigint generated always as identity primary key,
    public_id text not null unique,
    candidate_name text not null,
    score integer not null,
    total_questions integer not null,
    answers jsonb not null default '{}'::jsonb,
    completed_at bigint not null,
    created_at timestamp with time zone not null default now()
);

alter table app_handibaby.quiz_attempts enable row level security;

-- Drop policy if exists then recreate
drop policy if exists quiz_attempts_select on app_handibaby.quiz_attempts;
create policy quiz_attempts_select on app_handibaby.quiz_attempts
    for select to anon, authenticated
    using (true);

grant select on table app_handibaby.quiz_attempts to anon, authenticated;

-- 2. Create RPC to insert / upsert quiz attempts securely
create or replace function app_handibaby.save_quiz_attempt(
    p_public_id text,
    p_candidate_name text,
    p_score integer,
    p_total_questions integer,
    p_answers jsonb,
    p_completed_at bigint
) returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into app_handibaby.quiz_attempts (
        public_id,
        candidate_name,
        score,
        total_questions,
        answers,
        completed_at
    ) values (
        p_public_id,
        p_candidate_name,
        p_score,
        p_total_questions,
        p_answers,
        p_completed_at
    )
    on conflict (public_id) do update
    set candidate_name = excluded.candidate_name,
        score = excluded.score,
        total_questions = excluded.total_questions,
        answers = excluded.answers,
        completed_at = excluded.completed_at;
end;
$$;

grant execute on function app_handibaby.save_quiz_attempt(text, text, integer, integer, jsonb, bigint) to anon, authenticated;

-- 3. Clean up fake quiz entries from tournaments and associated tables
delete from app_handibaby.scores_journal
where tournament_public_id like 'quiz-%'
   or tournament_public_id in (
       select public_id from app_handibaby.tournaments where status = 'quiz' or label ilike '%quiz%'
   );

delete from app_handibaby.frozen_editions
where tournament_public_id like 'quiz-%'
   or tournament_public_id in (
       select public_id from app_handibaby.tournaments where status = 'quiz' or label ilike '%quiz%'
   );

delete from app_handibaby.matches
where tournament_public_id like 'quiz-%'
   or tournament_public_id in (
       select public_id from app_handibaby.tournaments where status = 'quiz' or label ilike '%quiz%'
   );

delete from app_handibaby.tournament_players
where tournament_public_id like 'quiz-%'
   or tournament_public_id in (
       select public_id from app_handibaby.tournaments where status = 'quiz' or label ilike '%quiz%'
   );

delete from app_handibaby.teams
where tournament_public_id like 'quiz-%'
   or tournament_public_id in (
       select public_id from app_handibaby.tournaments where status = 'quiz' or label ilike '%quiz%'
   );

delete from app_handibaby.tournaments
where status = 'quiz' or public_id like 'quiz-%' or label ilike '%quiz%';
