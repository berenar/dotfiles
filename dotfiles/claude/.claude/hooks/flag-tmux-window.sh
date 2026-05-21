#!/bin/bash
# Flags the enclosing tmux window (via monitor-bell) so the title is highlighted
# when Claude finishes responding. Skips if the user is already viewing this
# window in an attached session.
set -euo pipefail

[ -z "${TMUX:-}" ] && exit 0
[ -z "${TMUX_PANE:-}" ] && exit 0

INFO=$(tmux display-message -p -t "$TMUX_PANE" '#{window_active} #{session_attached} #{pane_tty}' 2>/dev/null || true)
[ -z "$INFO" ] && exit 0
read -r WIN_ACTIVE SESS_ATTACHED PANE_TTY <<< "$INFO"

if [ "$WIN_ACTIVE" = "1" ] && [ "${SESS_ATTACHED:-0}" != "0" ]; then
  exit 0
fi

[ -n "$PANE_TTY" ] || exit 0
printf '\a' > "$PANE_TTY" 2>/dev/null || true
