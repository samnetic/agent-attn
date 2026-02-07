#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
INSTALL="$ROOT_DIR/scripts/install.sh"
DOCTOR="$ROOT_DIR/scripts/doctor.sh"
E2E="$ROOT_DIR/scripts/test-e2e.sh"
UNINSTALL="$ROOT_DIR/scripts/uninstall.sh"
BOOTSTRAP="$ROOT_DIR/scripts/bootstrap.sh"

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

test_scripts_exist() {
  [[ -x "$INSTALL" ]] || fail "missing executable: $INSTALL"
  [[ -x "$DOCTOR" ]] || fail "missing executable: $DOCTOR"
  [[ -x "$E2E" ]] || fail "missing executable: $E2E"
  [[ -x "$UNINSTALL" ]] || fail "missing executable: $UNINSTALL"
  [[ -x "$BOOTSTRAP" ]] || fail "missing executable: $BOOTSTRAP"
}

test_install_dry_run() {
  local out
  out="$(mktemp)"
  "$INSTALL" --dry-run >"$out"
  assert_contains "INSTALL TARGET" "$out"
  rm -f "$out"
}

test_doctor_runs() {
  local out
  out="$(mktemp)"
  "$DOCTOR" >"$out"
  assert_contains "Doctor complete" "$out"
  rm -f "$out"
}

test_bootstrap_dry_run() {
  local out
  out="$(mktemp)"
  "$BOOTSTRAP" --dry-run >"$out"
  assert_contains "Bootstrap plan" "$out"
  assert_contains "repository: samnetic/agent-attn" "$out"
  rm -f "$out"
}

test_bootstrap_unknown_option_exits_2() {
  set +e
  "$BOOTSTRAP" --wat >/dev/null 2>&1
  local rc=$?
  set -e
  [[ "$rc" -eq 2 ]] || fail "expected bootstrap unknown option exit code 2, got $rc"
}

main() {
  test_scripts_exist
  test_install_dry_run
  test_doctor_runs
  test_bootstrap_dry_run
  test_bootstrap_unknown_option_exits_2
  printf 'All script tests passed.\n'
}

main "$@"
