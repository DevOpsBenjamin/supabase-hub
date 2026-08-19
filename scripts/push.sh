#!/usr/bin/env bash
# Applies pending migrations to the linked project. Pass --dry-run to preview.
# The CLI lists what it will run and asks for confirmation.
set -euo pipefail
. "$(dirname "$0")/lib.sh"
load_env

cd "$ROOT"
supa db push "$@"
