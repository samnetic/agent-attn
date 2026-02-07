#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
INSTALL="$ROOT_DIR/scripts/install.sh"
DOCTOR="$ROOT_DIR/scripts/doctor.sh"
E2E="$ROOT_DIR/scripts/test-e2e.sh"
UNINSTALL="$ROOT_DIR/scripts/uninstall.sh"

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

main() {
  test_scripts_exist
  test_install_dry_run
  test_doctor_runs
  printf 'All script tests passed.\n'
}

main "$@"
