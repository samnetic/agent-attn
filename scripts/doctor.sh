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

if command -v /mnt/c/Windows/System32/cmd.exe >/dev/null 2>&1; then
  set +e
  /mnt/c/Windows/System32/cmd.exe /c "wt.exe -h" >/dev/null 2>&1
  wt_rc=$?
  set -e
  if [[ "$wt_rc" -eq 0 ]]; then
    ok "wt.exe command is available"
  else
    warn "wt.exe not reachable from cmd.exe; check App Execution Alias for Windows Terminal"
  fi
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

if command -v /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe >/dev/null 2>&1; then
  set +e
  /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "if (Test-Path 'HKCU:\Software\Classes\agent-attn') { exit 0 } else { exit 1 }" >/dev/null 2>&1
  proto_rc=$?
  set -e
  if [[ "$proto_rc" -eq 0 ]]; then
    ok "agent-attn protocol handler registered"
  else
    warn "agent-attn protocol handler not registered yet (auto-registers on first --window notification)"
  fi
fi

printf 'Doctor complete\n'
