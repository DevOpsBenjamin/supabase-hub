# handibaby

| | |
|---|---|
| Schema | `app_handibaby` |
| App repo | https://github.com/DevOpsBenjamin/HandiBaby |
| Auth | none: anon role calling SECURITY DEFINER RPCs behind an organiser passphrase |
| Storage buckets | `handibaby-*` (none yet) |
| Edge functions | `handibaby-*` (none yet) |

## Tables

None yet. The app repo has no versioned SQL, so its schema has to be written
here before it can point at this project. Only the schema and its grants exist.

## Client wiring

```ts
import { createClient } from '@supabase/supabase-js'
import type { Database } from './types/database'

export const supabase = createClient<Database, 'app_handibaby'>(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY,
  {
    db: { schema: 'app_handibaby' },
    // No session to persist: writes go through passphrase-guarded RPCs.
    auth: { persistSession: false, autoRefreshToken: false },
  },
)
```

With `db.schema` set, `.from('table')` and `.rpc('fn')` resolve inside
`app_handibaby`. Reaching another schema needs an explicit `.schema('other')`.

The schema must be listed in `supabase/config.toml` under `[api] schemas` and in
the dashboard under Project Settings > API > Exposed schemas. Otherwise every
call fails with `The schema must be one of the following`.

## Commands

```bash
scripts/new-migration.sh handibaby "add whatever table"
scripts/push.sh
scripts/gen-types.sh handibaby    # regenerates types/database.ts
scripts/snapshot.sh handibaby     # regenerates schema.sql
```
