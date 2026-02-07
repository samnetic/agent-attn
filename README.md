# agent-attn

Universal AI coding agent notifications for **WSL2 + Windows 11 + Windows Terminal**.

Get reliable "needs your approval" alerts from **Claude Code**, **Codex**, and **OpenCode** without babysitting terminal tabs.

## Why this is a good universal UX

- One notifier command for all agents: `agent-attn`
- Native Windows toast path (PowerShell + BurntToast when available)
- Terminal fallback path (`BEL`) for taskbar flash/sound in Windows Terminal
- Tab attention marker: sets title to `[ATTN] <App>` so the active tab is visually flagged
- Optional bell latch mode: keeps tab bell signal active until you clear it
- Works even if one notification channel is unavailable

## Quickstart (2 minutes)

### One-line install (curl | bash)

```bash
curl -fsSL https://raw.githubusercontent.com/samnetic/agent-attn/main/scripts/bootstrap.sh | bash
```

Pin to a version (recommended for teams):

```bash
curl -fsSL https://raw.githubusercontent.com/samnetic/agent-attn/main/scripts/bootstrap.sh | bash -s -- --version v0.1.0
```

Dry-run the installer plan:

```bash
curl -fsSL https://raw.githubusercontent.com/samnetic/agent-attn/main/scripts/bootstrap.sh | bash -s -- --dry-run
```

### Manual clone install

```bash
git clone https://github.com/samnetic/agent-attn.git
cd agent-attn
bash scripts/install.sh
bash scripts/doctor.sh
```

Test your notifier:

```bash
agent-attn --dry-run --app "Smoke" --event "test" --message "Hello"
```

Send a real notification and mark tab title:

```bash
agent-attn --app "Smoke" --event "test" --message "Hello"
```

Keep alerting until you clear it (best for missed approvals):

```bash
agent-attn --latch --app "Claude Code" --event "permission" --message "Approval needed"
```

Clear the tab marker after you've handled it:

```bash
agent-attn --clear-tab-mark --app "Ubuntu"
```

Clear background bell latch:

```bash
agent-attn --clear-latch
```

Note: Ubuntu/bash often resets tab titles. If title markers disappear quickly, keep using `--latch` for persistent tab attention.

## Windows Terminal setup (important)

Set bell style in your Windows Terminal `settings.json`:

```json
{
  "profiles": {
    "defaults": {
      "bellStyle": "all"
    }
  }
}
```

This enables taskbar flash/sound fallback when `agent-attn` emits a bell.

## Integrations

### Claude Code

Merge `examples/claude-settings.json` into `~/.claude/settings.json`.

### Codex

Merge `examples/codex-config.toml` into `~/.codex/config.toml`.

### OpenCode

Copy `examples/opencode-plugin.js` to `.opencode/plugins/agent-attn.js` (or global plugins dir).

## Scripts

- `scripts/bootstrap.sh`: curl-pipe installer with latest-release default and optional `--version`
- `scripts/install.sh`: installs `agent-attn` into `~/.local/bin`
- `scripts/uninstall.sh`: removes installed binary
- `scripts/doctor.sh`: validates WSL/PowerShell/BurntToast prerequisites
- `scripts/test-e2e.sh`: runs test suite + smoke checks

## Testing

Run all tests:

```bash
bash scripts/test-e2e.sh
```

## Optional: better Windows toasts

In Windows PowerShell:

```powershell
Install-Module BurntToast -Scope CurrentUser
```

## SEO keywords

WSL2 notifications, Windows Terminal bell notifications, Claude Code approval prompts, Codex notification hooks, OpenCode permission alerts, AI coding agent attention alerts.

## License

MIT
