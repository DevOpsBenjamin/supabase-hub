#!/usr/bin/env bash
# Adds an app: folder, README, and the migration creating its schema.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

app=${1:-}
[[ -n $app ]] || die "usage: $0 <app-slug>"
[[ $app =~ ^[a-z][a-z0-9-]*$ ]] || die "slug must be lowercase letters, digits and dashes"
[[ ! -e $ROOT/apps/$app ]] || die "apps/$app already exists"

schema=$(schema_of "$app")
migration="$ROOT/supabase/migrations/$(next_version)_${schema}_bootstrap.sql"

mkdir -p "$ROOT/apps/$app/types"
sed "s/{{APP}}/$app/g; s/{{SCHEMA}}/$schema/g" "$ROOT/apps/_template/README.md" \
  > "$ROOT/apps/$app/README.md"
sed "s/{{APP}}/$app/g; s/{{SCHEMA}}/$schema/g" "$ROOT/apps/_template/bootstrap.sql.tpl" \
  > "$migration"

config="$ROOT/supabase/config.toml"
if ! grep -q "\"$schema\"" "$config"; then
  sed -i "s/^schemas = \[\(.*\)\]$/schemas = [\1, \"$schema\"]/" "$config"
fi

cat <<MSG
created apps/$app (schema $schema)
  ${migration#"$ROOT"/}
  supabase/config.toml   [api] schemas += "$schema"

next:
  1. write the tables in a new migration: scripts/new-migration.sh $app "create foo"
  2. scripts/push.sh
  3. dashboard > Project Settings > API > Exposed schemas: add $schema
  4. point the app client at db.schema = '$schema' (see apps/$app/README.md)
MSG
