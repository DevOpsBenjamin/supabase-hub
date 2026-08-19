# {{APP}}

| | |
|---|---|
| Schema | `{{SCHEMA}}` |
| App repo | _fill in_ |
| Auth | _authenticated users / anon + SECURITY DEFINER RPC_ |
| Storage buckets | `{{APP}}-*` (none yet) |
| Edge functions | `{{APP}}-*` (none yet) |

## Tables

_Fill in as migrations land. One line per table, what it holds, who can see it._

## Client wiring

```ts
import { createClient } from '@supabase/supabase-js'
import type { Database } from './types/database'

export const supabase = createClient<Database, '{{SCHEMA}}'>(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY,
  { db: { schema: '{{SCHEMA}}' } },
)
```

With `db.schema` set, `.from('table')` and `.rpc('fn')` resolve inside
`{{SCHEMA}}`. Reaching another schema needs an explicit `.schema('other')`.

The schema must be listed in `supabase/config.toml` under `[api] schemas` and in
the dashboard under Project Settings > API > Exposed schemas. Otherwise every
call fails with `The schema must be one of the following`.

## Commands

```bash
scripts/new-migration.sh {{APP}} "add whatever table"
scripts/push.sh
scripts/gen-types.sh {{APP}}    # regenerates types/database.ts
scripts/snapshot.sh {{APP}}     # regenerates schema.sql
```
