# simple-body-graph

| | |
|---|---|
| Schema | `app_simple_body_graph` |
| App repo | https://github.com/DevOpsBenjamin/SimpleBodyGraph |
| Auth | Supabase Auth, every row scoped by `auth.uid()` |
| Storage buckets | `simple-body-graph-*` (none yet) |
| Edge functions | `simple-body-graph-*` (none yet) |

## Tables

| Table | Holds | Visible to |
|---|---|---|
| `logs` | mass and body fat, one row per user per date | its owner only |
| `measurements` | waist, chest, arms, thighs per user per date | its owner only |

Squashed from the app repo's `supabase/migrations`: the `is_sick` column was
added and dropped there, so it never appears in this repo's history.

## Not wired yet

The app still targets `public.logs` / `public.measurements` on its own project.
Pointing it here means setting `db.schema` in its client and migrating any data
worth keeping; nothing in the app repo was changed.

## Client wiring

```ts
import { createClient } from '@supabase/supabase-js'
import type { Database } from './types/database'

export const supabase = createClient<Database, 'app_simple_body_graph'>(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY,
  { db: { schema: 'app_simple_body_graph' } },
)
```

With `db.schema` set, `.from('table')` and `.rpc('fn')` resolve inside
`app_simple_body_graph`. Reaching another schema needs an explicit `.schema('other')`.

The schema must be listed in `supabase/config.toml` under `[api] schemas` and in
the dashboard under Project Settings > API > Exposed schemas. Otherwise every
call fails with `The schema must be one of the following`.

## Commands

```bash
scripts/new-migration.sh simple-body-graph "add whatever table"
scripts/push.sh
scripts/gen-types.sh simple-body-graph    # regenerates types/database.ts
scripts/snapshot.sh simple-body-graph     # regenerates schema.sql
```
