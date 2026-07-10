#!/bin/bash

is_main_session_hook() {
	local input="$1"

	jq -e '(.agent_id // "") == "" and ((.transcript_path // "") | contains("/subagents/") | not)' <<<"$input" >/dev/null 2>&1
}

# Sets or clears a per-window tmux flag tracking "Claude is actively working in
# this window". Returns non-zero (so callers can `|| exit 0`) when the event is
# not a real main-session activity event for a live tmux pane: outside tmux, the
# nested labeling claude (CLAUDE_TMUX_RENAME_ACTIVE), or a subagent on "on".
#   set_window_activity_flag @claude_running on
#   set_window_activity_flag @claude_running off
set_window_activity_flag() {
	local option="$1" action="${2:-off}"

	[ -n "${CLAUDE_TMUX_RENAME_ACTIVE:-}" ] && return 1
	[ -z "${TMUX:-}" ] && return 1
	[ -z "${TMUX_PANE:-}" ] && return 1

	if [ "$action" = "on" ]; then
		local input=""
		[ -t 0 ] || IFS= read -rd '' input || true
		is_main_session_hook "$input" || return 1
		tmux set-option -w -t "$TMUX_PANE" "$option" 1 2>/dev/null || true
	else
		tmux set-option -uw -t "$TMUX_PANE" "$option" 2>/dev/null || true
	fi
}
