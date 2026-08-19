# supabase-hub

One Supabase project shared by several small apps. Each app owns a Postgres
schema; migrations for every app live in a single history at the root.

```
supabase/
  config.toml            [api] schemas lists every app schema
  migrations/            single history, append-only, one file per change
  seeds/                 local-only fixtures, one file per app
apps/
  _template/             source for scripts/new-app.sh
  <app>/README.md        schema name, tables, client wiring
  <app>/types/           generated TypeScript types
  <app>/schema.sql       generated dump, reference only
scripts/
docs/shared-project.md   what one project shares, and what that costs
```

## Why one history

`supabase_migrations.schema_migrations` is one table per database. A `migrations/`
folder per app would interleave timestamps, so every push would land out of order
and need `--include-all`, and `supabase db reset` would only ever see one app.
One folder at the root keeps the order linear and local resets honest.

Filenames are `<14-digit UTC timestamp>_<schema>_<description>.sql`. The CLI
orders migrations by that timestamp, so it cannot be shortened. The schema prefix
is what makes an app's changes greppable.

## Apps

| App | Schema | Repo |
|---|---|---|
| simple-body-graph | `app_simple_body_graph` | https://github.com/DevOpsBenjamin/SimpleBodyGraph |
| handibaby | `app_handibaby` | https://github.com/DevOpsBenjamin/HandiBaby |

Schema name is derived, never configured: `app_` + slug with dashes as
underscores.

## Setup

```bash
cp .env.example .env          # project ref, db password, access token
supabase link --project-ref "$SUPABASE_PROJECT_REF"
scripts/push.sh --dry-run
scripts/push.sh
```

Then, once per app, in the dashboard: Project Settings > API > Exposed schemas,
add the app's schema. `config.toml` only covers the local stack. Without it every
call fails with `The schema must be one of the following`.

The CLI is not installed as a dependency; scripts fall back to `npx supabase`.

## Daily use

```bash
scripts/new-app.sh my-app                    # folder + README + bootstrap migration
scripts/new-migration.sh my-app "create foo" # empty timestamped migration
scripts/push.sh                              # apply to the linked project
scripts/gen-types.sh my-app                  # refresh types/database.ts
scripts/snapshot.sh my-app                   # refresh schema.sql
```

## Rules that matter

- A migration that has been pushed is never edited. Write another one.
- Every table declares `enable row level security` and its policies in the same
  migration that creates it. Grants without policies expose the table to every
  app in the project.
- Nothing touches another app's schema. Cross-app reads mean the apps should have
  been one app, or the data belongs in a shared schema created on purpose.
- `apps/*/schema.sql` and `apps/*/types/` are generated. Read them, never edit.

Read `docs/shared-project.md` before adding an app: auth users, storage, keys,
quotas and backups are all project-wide, and schema-per-app does not change that.
