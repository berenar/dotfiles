# Claude Code ↔ tmux ↔ xbar monitoring

A small system that surfaces, at a glance, which Claude Code sessions are
**thinking** and which are **waiting for input**, across every tmux window — in
the tmux status bar, a tiled live monitor, and the macOS menu bar (xbar).

## How it works, in one picture

```
Claude Code hooks            tmux window options              consumers
(producers)                  (shared state)                   (readers)

UserPromptSubmit ─┐          @claude_running          ┌─► window-status colour (amber)
Stop / Notif.  ───┤  set/    (thinking)               ├─► session switcher badges
SessionStart ─────┘  clear   @claude_waiting_unfocused ├─► tmux-claude-monitor tiles
                             window_bell_flag (native) ├─► status-right alert pill
                             (waiting for input)       └─► xbar menu-bar glyph ✻
```

The **only shared state is a set of per-window tmux options.** Claude Code hooks
write them; several independent scripts read them. Nothing polls Claude directly
and there is no daemon — every consumer just reads tmux window flags on demand.

## The shared state (tmux window options)

| Flag | Meaning | Set by | Cleared by |
| --- | --- | --- | --- |
| `@claude_running` | Claude is actively responding ("thinking") | `set-claude-running.sh on` (UserPromptSubmit) | `set-claude-running.sh off` (Stop / Notification / SessionStart) |
| `window_bell_flag` | Waiting for input — window is **not** the current one | native tmux bell from `flag-tmux-window.sh` | tmux itself, automatically, when the window is viewed |
| `@claude_waiting_unfocused` | Waiting for input — window **is** current + attached, but kitty isn't frontmost | `flag-tmux-window.sh` | next `UserPromptSubmit`, **or** the `pane-focus-in` tmux hook when the window is viewed, **or** clicking the xbar entry |

A fourth per-window option, `@claude_caffeinate`, exists in the same family (set
via the same `helpers.sh` `set_window_activity_flag`) but belongs to a separate
subsystem — keeping the Mac awake while Claude thinks — and is out of scope here.

Why two different "waiting" flags? tmux **refuses to raise the bell flag for a
client's own current window** (verified: even a raw `\a` written to the pane tty
is dropped). So when the just-finished session happens to be the window you're
looking at — but you've tabbed away from kitty to another macOS app — there is no
bell to raise. `flag-tmux-window.sh` detects that case and sets the
`@claude_waiting_unfocused` window option instead, which the consumers treat
exactly like a bell.

## Producers — the Claude Code hooks

Wired in `dotfiles/claude/.claude/settings.json`. All are `async` so they never
block the session — the one exception is the `Notification` →
`play-sound-if-unfocused.sh` hook, which is **not** marked `async` (it runs
synchronously and blocks on `afplay`).

| Hook event | Script | Effect |
| --- | --- | --- |
| `UserPromptSubmit` | `set-claude-running.sh on` | set `@claude_running`; clear `@claude_waiting_unfocused` (you're engaging with this window again) |
| `Stop` | `set-claude-running.sh off` + `flag-tmux-window.sh` | clear `@claude_running`; raise the waiting alert |
| `Notification` (`permission_prompt\|idle_prompt\|elicitation_dialog`) | `set-claude-running.sh off` + `flag-tmux-window.sh` (+ `play-sound-if-unfocused.sh`) | same as Stop, plus a sound if kitty isn't frontmost |
| `SessionStart` (`startup`) | `set-claude-running.sh off` + `reset-tmux-window.sh` | clear stale state and reset the window name to `claude` |

The table lists only the monitoring-relevant scripts. Two more hooks fire on the
same events but are out of scope for this doc:

- `caffeinate-while-thinking.sh` — `on` (UserPromptSubmit) / `off` (Stop,
  Notification, SessionStart), same cadence as `set-claude-running.sh`. Keeps the
  Mac awake while Claude thinks via a `@claude_caffeinate` window option
  reconciled across sessions.
- `rename-tmux-window.sh` — `UserPromptSubmit`. Auto-names the window from the
  prompt (Linear/PR id, or a nested `claude -p --model haiku` summary). It's what
  sets `CLAUDE_TMUX_RENAME_ACTIVE=1`, the guard the alert scripts skip on so the
  nested labeller can't raise its own alerts.

### `flag-tmux-window.sh` — how the waiting alert is raised

1. Bail out unless this is a real **main-session** hook in a live tmux pane
   (skips subagents, the nested rename-labeller `CLAUDE_TMUX_RENAME_ACTIVE`, and
   sessions with pending background agents — see `helpers.sh`).
2. Read `window_active`, `session_attached`, `pane_tty` for the pane.
3. If the window **is** the current window of an **attached** session:
   - if kitty **is** frontmost → do nothing (you're already looking at it);
   - otherwise → set `@claude_waiting_unfocused 1`.
4. Otherwise → write a bell (`\a`) to the pane tty, which tmux turns into
   `window_bell_flag`.

`helpers.sh` provides the shared guards: `is_main_session_hook` (ignore
subagents / `/subagents/` transcripts), `has_pending_background_agents` (don't
alert while background agents are still running), and `set_window_activity_flag`
(set/clear a window option, with all the tmux/pane guards).

## Consumers — the readers

| Consumer | File | What it does |
| --- | --- | --- |
| **xbar menu-bar plugin** | `dotfiles/xbar/Library/Application Support/xbar/plugins/claude-code.5s.sh` | menu-bar `✻` glyph + dropdown of waiting sessions + per-account usage |
| **Live monitor** | `dotfiles/tmux/.local/bin/tmux-claude-monitor` | tiled tmux view mirroring every active Claude pane, colour-coded by state |
| **Status-right alert pill** | `dotfiles/tmux/.local/bin/tmux-alert-indicator` | shows / jumps to the most-recently-alerted window |
| **Window-tab colour** | `dotfiles/tmux/.local/bin/tmux-claude-window-style` | amber window name while `@claude_running` is set |
| **Session switcher** | `dotfiles/tmux/.local/bin/tmux-session-switcher` | marks sessions that have a running Claude |

### xbar plugin (`claude-code.5s.sh`)

Refreshes every 5s (the `.5s.` in the filename).

- **Menu-bar glyph:** always shows `✻`.
  - orange `#EC5F36` when ≥1 session is waiting for input;
  - light grey `#E8EFF4` (`IDLE_COLOR`) when none are — the item stays visible so
    the usage dropdown is always reachable.
  - (The `✻` glyph is a dingbat macOS renders from a fixed-weight symbol font, so
    the `font=` weight is ignored — it can't be made bold.)
- **Dropdown, waiting sessions:** one clickable row per waiting window
  (`session : window waiting for input`). Clicking runs
  `tmux-claude-monitor --open-window <session> <window_id>`, which jumps straight
  to that exact window (and clears `@claude_waiting_unfocused`, see below).
- **Dropdown, usage:** per-account 5-hour + 7-day Claude usage. Accounts are
  listed in `USAGE_ACCOUNTS` as `label:config-dir[:flag]`. The OAuth token is read
  from the macOS keychain (service name derived from a sha256 of the config dir),
  and `/api/oauth/usage` is queried. Results cache in
  `~/.cache/claude-usage-xbar` for `USAGE_TTL` (60s). A `:unlimited` flag skips
  the lookup and just prints `unlimited`.
- **Detection query:**
  ```sh
  tmux list-windows -a -F '#{window_bell_flag}|#{@claude_waiting_unfocused}|…' \
    | awk -F'|' '$1=="1" || $2=="1"'
  ```

### Live monitor (`tmux-claude-monitor`)

`prefix + M` opens/attaches a `claude-monitor` tmux session; `prefix + G` jumps
from the focused tile to its real session. It hand-tiles one mirror pane per
active Claude window, with a coloured border: amber = thinking, red = waiting.
Idle Claude sessions are omitted. `--open-window` (used by the xbar dropdown)
jumps to a session/window, reusing the current kitty client when possible or
spawning a new kitty window otherwise.

## Lifecycle of a "waiting for input" alert

Setting the alert is the easy half; the interesting part is the **clearing**,
which historically had a gap (see below).

```
Claude finishes (Stop / Notification)
        │
        ▼
flag-tmux-window.sh
        ├─ not current window ........... window_bell_flag = 1
        └─ current + attached + kitty bg  @claude_waiting_unfocused = 1

Cleared when:
  window_bell_flag           → tmux auto-clears the moment the window is viewed
  @claude_waiting_unfocused  → next UserPromptSubmit (set-claude-running.sh on)
                             → pane-focus-in tmux hook when the window is viewed
                             → clicking the xbar entry (open_window)
```

### The stuck-alert bug (fixed)

`@claude_waiting_unfocused` is a plain window option — unlike the native bell
flag, tmux does **not** auto-clear it on view. Originally it was only cleared on
the next `UserPromptSubmit`. So if Claude in that pane went idle or exited and
never got another prompt, the flag — and its xbar entry — stuck forever (e.g. an
entry lingering "since yesterday" that clicking never dismissed).

Two changes close the gap, mirroring how the bell flag clears on view:

1. **`tmux.conf`** — a `pane-focus-in` hook clears the option as soon as the
   window is focused (switching to it, or bringing kitty back to front):
   ```tmux
   set-hook -g pane-focus-in "set-option -uw -t '#{hook_pane}' @claude_waiting_unfocused"
   ```
   (Relies on `set -g focus-events on`, already set.)
2. **`tmux-claude-monitor` `open_window()`** — clears the option directly when
   you click the xbar entry, because a background `switch-client` may not emit a
   focus event.

## File map

```
dotfiles/claude/.claude/
  settings.json                     hook wiring (Stop / Notification / UserPromptSubmit / SessionStart)
  hooks/
    helpers.sh                      shared guards (main-session, background-agents, set flag)
    set-claude-running.sh           @claude_running on/off; clears @claude_waiting_unfocused on "on"
    flag-tmux-window.sh             raises the waiting alert (bell or @claude_waiting_unfocused)
    reset-tmux-window.sh            resets window name to "claude" on SessionStart
    play-sound-if-unfocused.sh      plays a sound on Notification when kitty isn't frontmost (sync, not async)
    caffeinate-while-thinking.sh    keeps the Mac awake while thinking (@claude_caffeinate; out of scope)
    rename-tmux-window.sh           auto-names the window from the prompt; sets CLAUDE_TMUX_RENAME_ACTIVE (out of scope)

dotfiles/tmux/
  .tmux.conf                        focus-events, pane-focus-in clear hook, keybinds (M/G), status bar
  .local/bin/
    tmux-claude-monitor             tiled live monitor + --open-window / --jump
    tmux-alert-indicator            status-right alert pill + --goto
    tmux-claude-window-style        amber window name while @claude_running
    tmux-session-switcher           session picker, flags running Claude sessions

dotfiles/xbar/Library/Application Support/xbar/plugins/
  claude-code.5s.sh                 menu-bar glyph + waiting dropdown + per-account usage
```

## Gotchas

- **kitty-frontmost detection** uses `lsappinfo front` / `lsappinfo info -only
  name`, matching `"kitty"`. If you switch terminals, update the checks in
  `flag-tmux-window.sh` and `play-sound-if-unfocused.sh`.
- **Subagents and background agents never alert** — `helpers.sh` filters
  `/subagents/` transcripts and sessions with `pendingBackgroundAgentCount ≥ 1`.
- **Hooks are `async`** (except `play-sound-if-unfocused.sh`, which is
  synchronous) — they must never block; all guards `exit 0` cheaply when not
  applicable.
- **xbar refresh cadence** is encoded in the filename (`.5s.`). Rename to change
  it; use the dropdown's *Refresh* item to force an update.
- **Reloading tmux config** (`prefix + r`) re-registers the `pane-focus-in` hook;
  a stuck flag from before the fix can be cleared once manually with
  `tmux set-option -uw -t <window_id> @claude_waiting_unfocused`.
```
