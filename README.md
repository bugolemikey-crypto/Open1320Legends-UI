# nitto1320-log-sidecar

A small sidecar for [Open1320Legends](https://github.com/oblongy/open1320legends): pulls the
backend's `journalctl` logs over SSH once a minute and gives you a live dashboard to browse them
and manage the service, in your browser or a terminal.

It has three pieces:

- **Puller** (`src/puller.js`, `src/ssh-journal-client.js`) — SSHes into the VPS, runs
  `journalctl -u nitto-backend.service -o json`, and resumes exactly where it left off using
  journald's own cursor (no gaps, no re-downloading). Entries are normalized (parsing the
  backend's structured JSON log lines for level/message/meta) and appended to a local NDJSON
  file per unit.
- **Browser dashboard** (`public/`, `src/web-server.js`) — a local web page with live-streaming
  logs, level/search filters, one-click presets, click-to-filter on any log field, a log-volume
  chart, an auto-grouped "top errors & warnings" list, a status sidebar (service state, uptime,
  load, memory, disk, connections), and buttons to restart/stop/start the service or run a deploy,
  with live streamed output. This is the easiest way to use the tool day-to-day.
- **Terminal viewer** (`src/tui.js`) — the same capabilities as the browser dashboard, but as an
  interactive terminal UI, for when you'd rather stay in a terminal or are SSH'd into somewhere
  without a browser.

## Quick start (Windows)

1. `git clone https://github.com/oblongy/nitto1320-log-sidecar.git` and open the folder.
2. Double-click **`start-dashboard.bat`**. First run installs dependencies and creates `.env` for
   you (edit `SIDECAR_SSH_KEY` in it to point at a private key that can SSH into the VPS, then
   double-click again).
3. Your browser opens automatically to the dashboard.

`start-dashboard.bat` runs via `cmd.exe`, not PowerShell, so it isn't affected by PowerShell's
script execution policy — no `Set-ExecutionPolicy` needed.

## Setup (manual / any OS)

```bash
npm install
cp .env.example .env
# edit .env: at minimum set SIDECAR_SSH_KEY to a private key that can SSH into the VPS
```

Defaults target the known production VPS (`root@162.141.167.11`, unit `nitto-backend.service`,
matching `deploy.sh` in Open1320Legends) — override via `.env` for a different host/unit.

## Usage

```bash
npm run dashboard  # browser dashboard: opens automatically at http://127.0.0.1:4173
npm run run        # same thing, but as a terminal UI instead of a browser
npm run pull       # one-shot: fetch new lines and exit
npm run watch      # headless: keep pulling every interval, print a summary per tick
npm run view       # browse already-downloaded logs in the terminal, no SSH/pulling
```

Or directly: `node bin/nitto-log-sidecar.mjs <pull|watch|view|run|dashboard>`.

### Browser dashboard

`npm run dashboard` starts the puller (pulling every `SIDECAR_POLL_INTERVAL_MS`, default 60s),
starts a local web server on `SIDECAR_WEB_PORT` (default `4173`, bound to `127.0.0.1` only — not
reachable from other machines), and opens it in your default browser. Everything updates live:
new log lines stream in, the status sidebar auto-refreshes, and action buttons (Start / Restart /
Stop / Run deploy) hit the same SSH connection the terminal version uses. Restart/Stop/Deploy ask
for a browser confirmation before running since they affect the live game server.

Stop it with `Ctrl+C` in the terminal it's running in (or close `start-dashboard.bat`'s window).

**Digging into errors/warnings:**

- **Log volume chart** — a stacked bar showing line count per level over time, right above the log
  stream. Toggle it with the "Hide/Show chart" button. Hover a bar for the exact per-level counts
  at that moment.
- **Top errors & warnings** (sidebar) — every warn/error line is grouped by its backend `action`
  field (or by message shape, with ids/numbers stripped, for lines without one), so instead of a
  wall of repeated lines you see e.g. `garage — 39` with when it was last seen. Click a group to
  filter the log stream to just those lines.
- **Click-to-filter** — every `key=value` in a log line's metadata is clickable; click one to
  filter the stream to just that account/connection/room/action. Active filters show as removable
  chips above the log stream, alongside the search box's filter.
- **Row detail** — click anywhere else on a line to open its full detail: pretty-printed `meta`,
  the stack trace if the line carries one, and the underlying journald fields (pid, hostname,
  transport, boot id).

### Terminal viewer keybindings (`run` / `view`)

| Key | Action |
|---|---|
| `q` / `Ctrl+C` | Quit |
| `/` | Search (substring match on message + meta) |
| `Esc` | Clear search |
| `1` `2` `3` `4` | Toggle debug / info / warn / error visibility |
| `p` | Filter presets menu (all / errors only / warnings+ / KOTH events / HTTP errors) |
| `f` | Toggle follow mode (auto-scroll to newest) |
| `g` / `Shift+G` | Jump to top / bottom |
| `r` | Manual refresh (pull now, only in `run`) |
| `a` | **Actions menu** (`run` only): refresh status, restart/stop/start the service, run deploy |
| `s` | Manual stats refresh (`run` only) |

The actions menu and status sidebar only appear in `run`/`dashboard` — `view` is read-only with no
SSH access, matching its purpose (browsing history offline).

## Configuration

All config is environment variables (see `.env.example`):

| Variable | Default | Purpose |
|---|---|---|
| `SIDECAR_SSH_HOST` | `162.141.167.11` | VPS address |
| `SIDECAR_SSH_PORT` | `22` | SSH port |
| `SIDECAR_SSH_USER` | `root` | SSH user |
| `SIDECAR_SSH_KEY` | `~/.ssh/id_rsa` | Private key path |
| `SIDECAR_SSH_KEY_PASSPHRASE` | (none) | Key passphrase, if any |
| `SIDECAR_SYSTEMD_UNIT` | `nitto-backend.service` | Unit to read via `journalctl -u` |
| `SIDECAR_POLL_INTERVAL_MS` | `60000` | Pull interval for `watch`/`run`/`dashboard` |
| `SIDECAR_BACKFILL_LINES` | `1000` | Lines to backfill on the very first pull |
| `SIDECAR_DATA_DIR` | `./data` | Where `cursors.json` and `<unit>.ndjson` live |
| `SIDECAR_STATS_INTERVAL_MS` | `15000` | How often the status sidebar auto-refreshes |
| `SIDECAR_DEPLOY_SCRIPT` | (none) | Path to your local `deploy.sh`/`deploy.ps1`. Unset disables the "Run deploy script" action. |
| `SIDECAR_DEPLOY_CWD` | script's own directory | Working directory to run the deploy script from |
| `SIDECAR_WEB_PORT` | `4173` | Port for the browser dashboard (`dashboard` only) |

Service control (restart/stop/start) runs `systemctl <verb> nitto-backend.service` directly over
SSH — no `sudo` prefix, since the default SSH user is already `root`. If you point
`SIDECAR_SSH_USER` at a non-root user, that user needs passwordless `systemctl` permission on the
unit for those actions to work.

The deploy action just spawns your existing deploy script as a local child process and streams
its output into the dashboard — it doesn't reimplement deploy.sh's own SSH/rsync/sudo logic, so
whatever env vars deploy.sh normally needs (e.g. `NITTO_SUDO_PASSWORD`) still need to be set in
the shell (or `start-dashboard.bat`'s environment) you launch `nitto-log-sidecar` from.

## Data on disk

- `data/cursors.json` — last journald cursor seen per unit, so pulls resume without gaps or
  duplicates.
- `data/<unit>.ndjson` — every normalized log line ever pulled, one JSON object per line.

Both are gitignored; delete `data/` to force a full re-backfill.

## Tests

```bash
npm test
```
