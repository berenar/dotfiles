#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

[ -n "${CLAUDE_TMUX_RENAME_ACTIVE:-}" ] && exit 0
sound="${1:-}"
[ -z "$sound" ] && exit 0

input=""
if [ ! -t 0 ]; then
	input=$(cat)
fi

is_main_session_hook "$input" || exit 0

notification_type=$(jq -r '.notification_type // ""' <<<"$input" 2>/dev/null || true)
if [ "$notification_type" = "idle_prompt" ] && has_pending_background_agents "$input"; then
	exit 0
fi

front=$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null)
[[ "$front" == *'"kitty"'* ]] && exit 0
afplay "$sound"
