# What one project actually shares

Schema-per-app buys namespacing, not isolation. Everything below is project-wide
and stays project-wide. Read this before adding an app that matters.

## The same anon key for everyone

One project, one anon key and one service_role key. Every app ships the same anon
key, so any app's key can hit any schema listed under Exposed schemas. RLS is the
only boundary between two apps' data.

Consequences:

- Every table gets `enable row level security` in the same migration that creates
  it. A table without policies and with a grant is world-readable to all apps.
- Never expose a schema whose tables are not covered yet.
- service_role never leaves the server side. It bypasses RLS everywhere, for
  every app.

## The same user pool

`auth.users` is project-wide. Someone who signs up through app A can sign in to
app B with the same credentials, and `auth.uid()` is the same value in both.

If an app needs its own membership, add `app_x.profiles` referencing
`auth.users(id)` and make every policy require a row in it. Presence in
`auth.users` proves nothing about which app the user belongs to.

Auth settings are project-wide too: providers, session length, email templates,
password rules. One app cannot enable magic links without the others getting them.

Each app's origin has to be added under Authentication > URL Configuration
(Site URL and redirect allow list), or its OAuth and email links bounce.

## Flat namespaces

| Resource | Scope | Convention |
|---|---|---|
| Storage buckets | project | `<app>-<bucket>` |
| Edge functions | project, flat directory | `<app>-<function>` |
| Realtime | one publication, `supabase_realtime` | add tables explicitly, per app |
| Cron / queues / vault secrets | project | prefix with the app slug |

Storage policies live on `storage.objects` for the whole project, so scope them
by bucket name in the policy itself.

## The same blast radius

- Quotas, connection pool, database size and egress are shared. One app's bad
  loop degrades the others.
- Backups and PITR restore the whole project. Restoring app A to yesterday takes
  app B back with it. This is the strongest reason to split an app out.
- Pausing, upgrading Postgres, or blowing a quota hits everything at once.

## When to stop sharing

Split an app into its own project once any of these is true: it has real users,
it needs its own auth rules, its data would hurt if another app's key leaked, or
it needs a restore path independent of the rest.
