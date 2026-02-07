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
  assert_contains "TAB_MARK=1" "$out"
  assert_contains "TAB_PREFIX=[ATTN]" "$out"
  assert_contains "LATCH=0" "$out"
  assert_contains "WINDOW=" "$out"
  assert_contains "WINDOW_TAB=0" "$out"
  assert_contains "CLICK_FOCUS=none" "$out"
  rm -f "$out"
}

test_window_focus_dry_run() {
  local out
  out="$(mktemp)"
  "$BIN" --dry-run --window "claude-main" --tab 2 --app "TestApp" >"$out"
  assert_contains "WINDOW=claude-main" "$out"
  assert_contains "WINDOW_TAB=2" "$out"
  assert_contains "CLICK_FOCUS=protocol" "$out"
  rm -f "$out"
}

test_clear_tab_mark_dry_run() {
  local out
  out="$(mktemp)"
  "$BIN" --dry-run --clear-tab-mark --app "TestApp" >"$out"
  assert_contains "TAB_ACTION=clear" "$out"
  rm -f "$out"
}

test_latch_dry_run() {
  local out
  out="$(mktemp)"
  "$BIN" --dry-run --latch --latch-interval 2 --app "TestApp" >"$out"
  assert_contains "LATCH=1" "$out"
  assert_contains "LATCH_INTERVAL=2" "$out"
  rm -f "$out"
}

test_clear_latch_dry_run() {
  local out
  out="$(mktemp)"
  "$BIN" --dry-run --clear-latch --app "TestApp" >"$out"
  assert_contains "LATCH_ACTION=clear" "$out"
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

test_invalid_tab_exits_2() {
  set +e
  "$BIN" --dry-run --tab xyz >/dev/null 2>&1
  local rc=$?
  set -e
  [[ "$rc" -eq 2 ]] || fail "expected exit code 2 for invalid tab, got $rc"
}

main() {
  test_script_exists_and_is_executable
  test_dry_run_outputs_bell_marker
  test_help_outputs_usage
  test_unknown_option_exits_2
  test_invalid_tab_exits_2
  test_clear_tab_mark_dry_run
  test_latch_dry_run
  test_clear_latch_dry_run
  test_window_focus_dry_run
  printf 'All tests passed.\n'
}

main "$@"
