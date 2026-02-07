#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

bash "$ROOT_DIR/tests/test_agent_attn.sh"
bash "$ROOT_DIR/tests/test_scripts.sh"

tmp="$(mktemp)"
"$ROOT_DIR/bin/agent-attn" --dry-run --app "E2E" --event "approval" --message "Approve now" >"$tmp"
grep -Fq 'BELL' "$tmp"
grep -Fq 'EVENT=approval' "$tmp"
rm -f "$tmp"

printf 'E2E checks passed.\n'
