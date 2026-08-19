# shellcheck shell=bash
# Shared helpers. Sourced by every script here, never run directly.

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

die() {
  echo "error: $*" >&2
  exit 1
}

# The CLI is not a dependency of this repo, so fall back to npx.
supa() {
  if command -v supabase >/dev/null 2>&1; then
    supabase "$@"
  else
    npx --yes supabase "$@"
  fi
}

# apps/<slug> owns schema app_<slug with dashes as underscores>. No registry.
schema_of() {
  printf 'app_%s' "${1//-/_}"
}

require_app() {
  local app=${1:-}
  [[ -n $app ]] || die "missing app slug (see apps/)"
  [[ $app != _* ]] || die "'$app' is a template, not an app"
  [[ -d $ROOT/apps/$app ]] || die "unknown app '$app' (see apps/)"
}

# A migration's version is its 14-digit UTC timestamp and the CLI keys the applied
# history by it, so two files must never share one. Bump a second until it is free.
next_version() {
  local epoch ts
  epoch=$(date -u +%s)
  while :; do
    ts=$(date -u -d "@$epoch" +%Y%m%d%H%M%S)
    compgen -G "$ROOT/supabase/migrations/${ts}_*.sql" >/dev/null || break
    epoch=$((epoch + 1))
  done
  printf '%s' "$ts"
}

load_env() {
  [[ -f $ROOT/.env ]] || return 0
  set -a
  # shellcheck disable=SC1091
  . "$ROOT/.env"
  set +a
}
