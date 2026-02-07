#!/usr/bin/env bash
set -euo pipefail

REPO="samnetic/agent-attn"
VERSION=""
INSTALL_DIR="${HOME}/.local/bin"
DRY_RUN="0"

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [options]

Options:
  --version <ref>      Install from a specific tag/branch/commit
  --install-dir <dir>  Install directory (default: ~/.local/bin)
  --repo <owner/name>  GitHub repository (default: samnetic/agent-attn)
  --dry-run            Print plan and exit
  -h, --help           Show this help

Examples:
  curl -fsSL https://raw.githubusercontent.com/samnetic/agent-attn/main/scripts/bootstrap.sh | bash
  curl -fsSL https://raw.githubusercontent.com/samnetic/agent-attn/main/scripts/bootstrap.sh | bash -s -- --version v0.1.0
EOF
}

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$cmd" >&2
    exit 1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --install-dir)
      INSTALL_DIR="$2"
      shift 2
      ;;
    --repo)
      REPO="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="1"
      shift
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
done

require_command curl

REF="$VERSION"
if [[ -z "$REF" ]]; then
  API_URL="https://api.github.com/repos/${REPO}/releases/latest"
  set +e
  release_json="$(curl -fsSL "$API_URL" 2>/dev/null)"
  rc=$?
  set -e
  if [[ "$rc" -eq 0 ]]; then
    REF="$(printf '%s' "$release_json" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
  fi
fi

if [[ -z "$REF" ]]; then
  REF="main"
fi

BIN_URL="https://raw.githubusercontent.com/${REPO}/${REF}/bin/agent-attn"
CHECKSUM_URL="https://raw.githubusercontent.com/${REPO}/${REF}/checksums.txt"
TARGET_BIN="${INSTALL_DIR}/agent-attn"

printf 'Bootstrap plan\n'
printf '  repository: %s\n' "$REPO"
printf '  ref: %s\n' "$REF"
printf '  install: %s\n' "$TARGET_BIN"

if [[ "$DRY_RUN" == "1" ]]; then
  exit 0
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

bin_file="$tmp_dir/agent-attn"
curl -fsSL "$BIN_URL" -o "$bin_file"

if command -v sha256sum >/dev/null 2>&1; then
  set +e
  checksum_file="$tmp_dir/checksums.txt"
  curl -fsSL "$CHECKSUM_URL" -o "$checksum_file" 2>/dev/null
  checksum_rc=$?
  set -e
  if [[ "$checksum_rc" -eq 0 ]]; then
    expected="$(grep ' bin/agent-attn$' "$checksum_file" | awk '{print $1}' || true)"
    if [[ -n "$expected" ]]; then
      actual="$(sha256sum "$bin_file" | awk '{print $1}')"
      if [[ "$expected" != "$actual" ]]; then
        printf 'Checksum verification failed for agent-attn\n' >&2
        exit 1
      fi
      printf 'Checksum verified.\n'
    else
      printf 'Checksum file found but no entry for bin/agent-attn. Continuing.\n'
    fi
  else
    printf 'No checksums.txt found for %s. Continuing without checksum verification.\n' "$REF"
  fi
fi

mkdir -p "$INSTALL_DIR"
install -m 0755 "$bin_file" "$TARGET_BIN"

printf 'Installed agent-attn to %s\n' "$TARGET_BIN"
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  printf 'Add to PATH if needed: export PATH="%s:$PATH"\n' "$INSTALL_DIR"
fi
