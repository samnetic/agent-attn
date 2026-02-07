#!/usr/bin/env bash
set -euo pipefail

TARGET_BIN="${HOME}/.local/bin/agent-attn"

if [[ -f "$TARGET_BIN" ]]; then
  rm -f "$TARGET_BIN"
  printf 'Removed: %s\n' "$TARGET_BIN"
else
  printf 'Not installed: %s\n' "$TARGET_BIN"
fi
