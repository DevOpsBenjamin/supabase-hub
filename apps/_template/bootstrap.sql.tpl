-- App: {{APP}} (schema: {{SCHEMA}})
-- Private namespace for the app, plus the minimum PostgREST needs to serve it.
--
-- These grants are not a security boundary: every app in this project shares the
-- same anon key, so any exposed schema is reachable by any app. Row Level
-- Security on every table is what actually isolates data.
create schema if not exists {{SCHEMA}};

-- USAGE alone exposes nothing; it lets the API roles resolve names in the schema.
grant usage on schema {{SCHEMA}} to anon, authenticated, service_role;

-- Applies to objects created later by the same role that runs migrations
-- (postgres, both locally and through `supabase db push`).
alter default privileges in schema {{SCHEMA}}
  grant select, insert, update, delete on tables to authenticated;
alter default privileges in schema {{SCHEMA}}
  grant usage, select on sequences to authenticated;

-- anon gets no table privileges by default. Grant EXECUTE per function when the
-- app needs an unauthenticated write path through a SECURITY DEFINER RPC.
