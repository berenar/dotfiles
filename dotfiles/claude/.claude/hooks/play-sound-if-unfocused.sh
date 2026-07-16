#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

[ -n "${CLAUDE_TMUX_RENAME_ACTIVE:-}" ] && exit 0
sound="${1:-}"
[ -z "$sound" ] && exit 0

input=$(read_hook_input)

is_main_session_hook "$input" || exit 0

notification_type=$(jq -r '.notification_type // ""' <<<"$input" 2>/dev/null || true)
if [ "$notification_type" = "idle_prompt" ] && has_pending_background_agents "$input"; then
	exit 0
fi

is_kitty_frontmost && exit 0
afplay "$sound"
