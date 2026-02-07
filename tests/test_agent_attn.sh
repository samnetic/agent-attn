#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
BIN="$ROOT_DIR/bin/agent-attn"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local needle="$1"
  local haystack_file="$2"
  if ! grep -Fq "$needle" "$haystack_file"; then
    fail "expected '$needle' in $haystack_file"
  fi
}

test_script_exists_and_is_executable() {
  [[ -x "$BIN" ]] || fail "expected executable: $BIN"
}

test_dry_run_outputs_bell_marker() {
  local out
  out="$(mktemp)"
  "$BIN" --dry-run --app "TestApp" --event "permission" --message "Needs approval" >"$out"
  assert_contains "BELL" "$out"
  assert_contains "APP=TestApp" "$out"
  assert_contains "EVENT=permission" "$out"
  assert_contains "MESSAGE=Needs approval" "$out"
  rm -f "$out"
}

test_help_outputs_usage() {
  local out
  out="$(mktemp)"
  "$BIN" --help >"$out"
  assert_contains "Usage: agent-attn" "$out"
  rm -f "$out"
}

test_unknown_option_exits_2() {
  set +e
  "$BIN" --wat >/dev/null 2>&1
  local rc=$?
  set -e
  [[ "$rc" -eq 2 ]] || fail "expected exit code 2 for unknown option, got $rc"
}

main() {
  test_script_exists_and_is_executable
  test_dry_run_outputs_bell_marker
  test_help_outputs_usage
  test_unknown_option_exits_2
  printf 'All tests passed.\n'
}

main "$@"
