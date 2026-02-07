#!/usr/bin/env bash
set -euo pipefail

ok() {
  printf 'OK: %s\n' "$1"
}

warn() {
  printf 'WARN: %s\n' "$1"
}

if grep -qi microsoft /proc/version 2>/dev/null; then
  ok "Running inside WSL"
else
  warn "WSL not detected; this project is optimized for WSL2 + Windows Terminal"
fi

if command -v /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe >/dev/null 2>&1; then
  ok "PowerShell bridge available"
else
  warn "PowerShell bridge missing at /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
fi

if command -v /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe >/dev/null 2>&1; then
  set +e
  /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "if (Get-Module -ListAvailable -Name BurntToast) { exit 0 } else { exit 1 }" >/dev/null 2>&1
  rc=$?
  set -e
  if [[ "$rc" -eq 0 ]]; then
    ok "BurntToast module installed"
  else
    warn "BurntToast not installed (optional). Install in PowerShell: Install-Module BurntToast -Scope CurrentUser"
  fi
fi

printf 'Doctor complete\n'
