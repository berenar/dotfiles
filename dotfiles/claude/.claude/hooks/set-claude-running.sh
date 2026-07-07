#!/bin/bash
# Marks the enclosing tmux window as "claude is thinking" via a @claude_running
# window option, so the session switcher can distinguish sessions where Claude
# is actively working from ones that are idle or waiting for input.
#   set-claude-running.sh on    Claude started responding (UserPromptSubmit)
#   set-claude-running.sh off   Claude stopped or is waiting (Stop/Notification)
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

[ -n "${CLAUDE_TMUX_RENAME_ACTIVE:-}" ] && exit 0
[ -z "${TMUX:-}" ] && exit 0
[ -z "${TMUX_PANE:-}" ] && exit 0

if [ "${1:-off}" = "on" ]; then
	INPUT=""
	[ -t 0 ] || INPUT=$(cat)
	is_main_session_hook "$INPUT" || exit 0
	tmux set-option -w -t "$TMUX_PANE" @claude_running 1 2>/dev/null || true
else
	tmux set-option -uw -t "$TMUX_PANE" @claude_running 2>/dev/null || true
fi
