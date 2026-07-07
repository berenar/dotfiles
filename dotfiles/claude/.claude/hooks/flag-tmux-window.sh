#!/bin/bash
# Flags the enclosing tmux window (via monitor-bell) so the title is highlighted
# when Claude finishes responding. Skips if the user is already viewing this
# window in an attached session.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

[ -n "${CLAUDE_TMUX_RENAME_ACTIVE:-}" ] && exit 0
[ -z "${TMUX:-}" ] && exit 0
[ -z "${TMUX_PANE:-}" ] && exit 0

INPUT=""
if [ ! -t 0 ]; then
	INPUT=$(cat)
fi

is_main_session_hook "$INPUT" || exit 0

INFO=$(tmux display-message -p -t "$TMUX_PANE" '#{window_active} #{session_attached} #{pane_tty}' 2>/dev/null || true)
[ -z "$INFO" ] && exit 0
read -r WIN_ACTIVE SESS_ATTACHED PANE_TTY <<<"$INFO"

if [ "$WIN_ACTIVE" = "1" ] && [ "${SESS_ATTACHED:-0}" != "0" ]; then
	exit 0
fi

[ -n "$PANE_TTY" ] || exit 0
printf '\a' >"$PANE_TTY" 2>/dev/null || true
