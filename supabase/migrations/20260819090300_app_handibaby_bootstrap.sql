-- App: handibaby (schema: app_handibaby)
-- Private namespace for the app, plus the minimum PostgREST needs to serve it.
--
-- No tables yet: the app repo has no versioned SQL, its schema still has to be
-- written here before it can point at this project.
--
-- This app authenticates nobody: writes go through SECURITY DEFINER RPCs guarded
-- by an organiser passphrase, called with the anon role. So anon needs USAGE on
-- the schema and EXECUTE on those specific functions, and nothing else.
create schema if not exists app_handibaby;

grant usage on schema app_handibaby to anon, authenticated, service_role;

alter default privileges in schema app_handibaby
  grant select, insert, update, delete on tables to authenticated;
alter default privileges in schema app_handibaby
  grant usage, select on sequences to authenticated;
