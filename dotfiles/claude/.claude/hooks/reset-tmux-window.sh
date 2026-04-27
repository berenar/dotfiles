#!/bin/bash
# Resets the enclosing tmux window name to "claude" when a new Claude Code
# session starts, so a stale label from a prior session doesn't linger before
# the UserPromptSubmit hook generates a fresh one.
set -euo pipefail

[ -z "${TMUX:-}" ] && exit 0
[ -z "${TMUX_PANE:-}" ] && exit 0

tmux set-window-option -t "$TMUX_PANE" automatic-rename off \; \
     set-window-option -t "$TMUX_PANE" allow-rename off \; \
     rename-window -t "$TMUX_PANE" "claude" 2>/dev/null || true
