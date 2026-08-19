#!/usr/bin/env bash
# Creates an empty migration, timestamped and prefixed with the app's schema.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

app=${1:-}
desc=${2:-}
[[ -n $app && -n $desc ]] || die "usage: $0 <app-slug> <description>"
require_app "$app"

schema=$(schema_of "$app")
slug=$(printf '%s' "$desc" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '_' | tr -s '_')
slug=${slug#_}
slug=${slug%_}
[[ -n $slug ]] || die "description has no usable characters"

file="$ROOT/supabase/migrations/$(next_version)_${schema}_${slug}.sql"
cat > "$file" <<SQL
-- App: $app (schema: $schema)
-- $desc

SQL
echo "${file#"$ROOT"/}"
