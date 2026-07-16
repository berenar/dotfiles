#!/bin/bash
# Flags the enclosing tmux window so the "waiting for input" indicators light up
# when Claude finishes responding.
#
# Normal case (not the terminal's current window): send a real bell, which
# tmux turns into window_bell_flag -- covers window-tab highlighting and every
# existing bell-based consumer.
#
# Foreground case (this IS the current window of an attached session): tmux
# itself refuses to ever raise window_bell_flag for a client's current window,
# regardless of OS-level focus (verified: even a raw bell sent straight to the
# pane tty is dropped). So when the terminal app isn't actually frontmost on
# the Mac (user switched to another app), set a separate @claude_waiting_unfocused
# window option instead -- cleared on the next UserPromptSubmit by
# set-claude-running.sh.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

require_live_tmux_pane || exit 0

INPUT=$(read_hook_input)

is_main_session_hook "$INPUT" || exit 0

has_pending_background_agents "$INPUT" && exit 0

INFO=$(tmux display-message -p -t "$TMUX_PANE" '#{window_active} #{session_attached} #{pane_tty}' 2>/dev/null || true)
[ -z "$INFO" ] && exit 0
read -r WIN_ACTIVE SESS_ATTACHED PANE_TTY <<<"$INFO"

if [ "$WIN_ACTIVE" = "1" ] && [ "${SESS_ATTACHED:-0}" != "0" ]; then
	is_kitty_frontmost && exit 0
	tmux set-option -w -t "$TMUX_PANE" @claude_waiting_unfocused 1 2>/dev/null || true
	exit 0
fi

[ -n "$PANE_TTY" ] || exit 0
printf '\a' >"$PANE_TTY" 2>/dev/null || true
