#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
SOURCE_BIN="$ROOT_DIR/bin/agent-attn"
TARGET_DIR="${HOME}/.local/bin"
TARGET_BIN="$TARGET_DIR/agent-attn"
DRY_RUN="0"

usage() {
  cat <<'EOF'
Usage: install.sh [--dry-run]

Installs agent-attn into ~/.local/bin.
EOF
}

if [[ $# -gt 1 ]]; then
  usage >&2
  exit 2
fi

if [[ $# -eq 1 ]]; then
  case "$1" in
    --dry-run)
      DRY_RUN="1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
fi

if [[ ! -x "$SOURCE_BIN" ]]; then
  printf 'Source binary not found or not executable: %s\n' "$SOURCE_BIN" >&2
  exit 1
fi

printf 'INSTALL TARGET: %s\n' "$TARGET_BIN"

if [[ "$DRY_RUN" == "1" ]]; then
  printf 'DRY RUN: would create %s and copy binary.\n' "$TARGET_DIR"
  exit 0
fi

mkdir -p "$TARGET_DIR"
install -m 0755 "$SOURCE_BIN" "$TARGET_BIN"

printf 'Installed: %s\n' "$TARGET_BIN"
if [[ ":$PATH:" != *":$TARGET_DIR:"* ]]; then
  printf 'Note: %s is not in PATH. Add this line to your shell profile:\n' "$TARGET_DIR"
  printf 'export PATH="$HOME/.local/bin:$PATH"\n'
fi
