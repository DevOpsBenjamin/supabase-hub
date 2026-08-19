#!/usr/bin/env bash
# Regenerates apps/<app>/types/database.ts from the linked project.
set -euo pipefail
. "$(dirname "$0")/lib.sh"
load_env

app=${1:-}
[[ -n $app ]] || die "usage: $0 <app-slug>"
require_app "$app"

schema=$(schema_of "$app")
out="$ROOT/apps/$app/types/database.ts"
mkdir -p "$(dirname "$out")"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

cd "$ROOT"
supa gen types typescript --linked --schema "$schema" > "$tmp"
mv "$tmp" "$out"
trap - EXIT
echo "${out#"$ROOT"/}"
