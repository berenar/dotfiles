# tmux idle-session lazygit suspend

Reclaim the CPU/RAM held by the **lazygit instances in tmux sessions you are not
looking at**: kill them off after an idle threshold, and relaunch them the moment
you switch back.

## Why

A fleet of idle background lazygit instances each re-run their `git diff | delta`
refresh loop every ~10s forever. On big-diff repos (minified / auto-generated
JSON) that pins a CPU core and balloons delta's memory past 1GB, even for
sessions sitting untouched.

> The acute heat/memory case was fixed separately with `.gitattributes -diff`
> on the offending repos (a local, per-repo `.git/info/attributes` change, not
> in this dotfiles tree). This feature reclaims the *remaining* idle-lazygit
> CPU/RAM by removing the instances you are not looking at and bringing them
> back on refocus.

## Why kill + relaunch, not freeze

**The whole design hinges on this.** The obvious approach — `SIGSTOP` the idle
lazygit, `SIGCONT` it later — does not work.

A stopped TUI is frozen mid raw-mode with its terminal left in the alternate
screen and **mouse tracking ON**, and it cannot run code to clean up (`SIGSTOP`
is uncatchable; lazygit does not restore the terminal on `SIGTSTP` either). With
tmux `mouse on`, every mouse move over that pane makes tmux forward SGR mouse
reports (`ESC[<...M`) to whatever now reads input — the shell — as a flood of
garbage, and it also corrupts any injected `fg` keystroke (seen live as
`zsh: command not found: 2@Mfg`).

Verified with tmux's own `mouse_*_flag` formats: a killed **or** stopped lazygit
leaves `mouse_all_flag=1`; only `tmux send-keys -R` (reset pane terminal state)
reliably clears it back to `0`.

> **Debugging note:** `#{alternate_on}` is **not** a reliable terminal-cleanliness
> proxy — it stays `1` even after the process dies. Use the `mouse_*_flag`
> formats (`mouse_any_flag`, `mouse_all_flag`, `mouse_sgr_flag`, …) instead.

So instead of freezing we **terminate** lazygit (it is stateless — nothing to
lose) and `send-keys -R` the pane immediately after, while the session is still
detached so it never flashes on screen. On refocus we retype the command to
bring it back.

**nvim is deliberately excluded** from the target list: killing it would drop
unsaved buffers/undo, and it cannot be cleanly frozen either. An earlier version
that targeted `nvim` + `SIGSTOP` corrupted real nvim panes (same mouse-garbage
trap, then mangled through a buggy `fg` resume), so nvim is simply left running.

## How it works

```
tmux-idle-suspend --daemon                 focus hooks -> tmux-idle-resume
(pidfile-guarded loop, every interval)     (session-window-changed /
        │                                   client-session-changed /
        ▼                                    client-attached)
for each DETACHED session idle >                    │
  @idle-suspend-seconds:                            ▼
    kill -TERM the shell's lazygit           for each ATTACHED pane
    tmux send-keys -R  (mouse off)           tagged @idle_frozen:
    tag pane @idle_frozen=1                     send-keys -R   (reset)
             @idle_relaunch=lazygit             send-keys C-c  (clear input)
                                                send-keys <relaunch> Enter
                                                unset both tags
```

The **only shared state is two per-pane tmux options**: `@idle_frozen` (this pane
was suspended by the daemon) and `@idle_relaunch` (the command to bring back).

### `tmux-idle-suspend` (the daemon)

- **reap pass:** for each **detached** session whose last-attached age exceeds
  `@idle-suspend-seconds`, find the pane shell's foreground lazygit child,
  `kill -TERM` it, `send-keys -R` the pane, and tag the pane `@idle_frozen=1` +
  `@idle_relaunch=<cmd>`.
- Only lazygit running **under a shell** is killed; a pane whose *direct* command
  is lazygit (no shell parent) is skipped, so we never close a window.
- `--daemon` runs a self-guarded loop (pidfile in `$TMPDIR`); a reload is a no-op
  while one is alive. `--list` shows suspended panes. A bare run does one reap
  pass.
- The loop uses `sleep N & wait $!` (not a bare `sleep`) so a trapped `TERM`/`INT`
  (reload, logout) interrupts immediately instead of sitting queued behind the
  sleep for up to a full interval — which reads as an unkillable daemon.

### `tmux-idle-resume` (wired to the focus hooks)

- Fires on `session-window-changed` / `client-session-changed` /
  `client-attached`. A suspended session is always detached, so it is only ever
  reached via an in-tmux switch or a fresh attach — these three cover every path.
  `pane-focus-in` is intentionally omitted: it only ever fires on the
  already-visible, never-suspended session, so it would be a redundant no-op.
- For each **attached** pane tagged `@idle_frozen`: `send-keys -R` (reset), `C-c`
  (discard any garbage that leaked into the shell's input line), then retype
  `@idle_relaunch` + `Enter`. Both tags are cleared either way, so a pane you
  revived by hand self-heals.
- Acts **only when the pane's fg is a shell**, so keys never land inside some app
  you started there.
- **Single-flight `noclobber` lock** (`$TMPDIR`): one switch fires several hooks
  at once; without the lock two resumes race and relaunch twice. A dead owner's
  lock is reclaimed so a crashed run can't wedge resume forever.

## Config (global tmux options)

| Option | Default | Meaning |
| --- | --- | --- |
| `@idle-suspend-enabled` | `off` | master switch — **opt-in** (see below) |
| `@idle-suspend-seconds` | `14400` | idle threshold before a session is reaped (4h) |
| `@idle-suspend-interval` | `60` | seconds between daemon reap passes |
| `@idle-suspend-processes` | `lazygit` | space-separated basenames to target |

## Off by default (important footgun)

`@idle-suspend-enabled` defaults to **`off`**. When it was left `'on'`, a routine
`prefix`+r config reload re-read the `set -g @idle-suspend-enabled 'on'` line, the
daemon reaped **every** session idle past the threshold at once, and a fleet of
sessions were left as bare shells (plus orphaned stopped `git|delta` pager
pipelines from the kills). Opt in explicitly when you actually want it:

```sh
tmux set -g @idle-suspend-enabled on
```

## Operating / debugging

```sh
tmux set -g @idle-suspend-enabled on     # turn on
tmux-idle-suspend --list                 # what's suspended right now
tmux-idle-suspend                        # one manual reap pass
# lower @idle-suspend-seconds to test without waiting out 4h
```

If a pane is ever left in a wrong state, the manual recovery is the same shape as
resume: kill its lazygit/nvim, reset the pane, relaunch, clear the tags.

```sh
kill -TERM <pid>
tmux send-keys -R -t <pane>
tmux send-keys -t <pane> C-c
tmux send-keys -t <pane> lazygit Enter
tmux set-option -p -t <pane> -u @idle_frozen
tmux set-option -p -t <pane> -u @idle_relaunch
```

## File map

```
dotfiles/tmux/
  .tmux.conf                         idle-resume focus hooks + @idle-suspend-* options + daemon launch
  .local/bin/
    tmux-idle-suspend                daemon: kill idle lazygit, reset pane, tag for relaunch (--daemon/--list)
    tmux-idle-resume                 focus-hook handler: reset + relaunch tagged panes, single-flight lock
```

## Gotchas

- **Both scripts are bash 3.2 compatible** — tmux `run-shell` uses the system
  bash (`/bin/bash`, 3.2 on macOS), not your interactive shell. No `mapfile`,
  `${x^^}`, associative arrays, etc.
- **New files need a `stow`** — after pulling, `tmux-idle-suspend` /
  `tmux-idle-resume` must be symlinked into `~/.local/bin`, or the daemon launch
  and hooks silently no-op.
- **Restarting the daemon after editing the script:** a running `--daemon` holds
  the *old* code in memory; a config reload won't replace it (the pidfile guard
  makes the relaunch a no-op). Kill the old daemon first, then relaunch.
- **`@idle-suspend-processes` are killed, not frozen** — only add processes that
  are safe to terminate and cheap to relaunch (stateless). Do **not** add `nvim`
  or anything with unsaved state.
- **Mouse mode is the tell.** If you ever see terminal garbage on mouse-move over
  a pane, check `#{mouse_all_flag}` — `1` on a pane whose foreground is a plain
  shell means a TUI left it dirty; `tmux send-keys -R -t <pane>` resets it.
```
