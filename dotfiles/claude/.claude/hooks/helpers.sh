#!/bin/bash

is_main_session_hook() {
	local input="$1"

	jq -e '(.agent_id // "") == "" and ((.transcript_path // "") | contains("/subagents/") | not)' <<<"$input" >/dev/null 2>&1
}

# Returns 0 if the main session currently has >=1 background/async agent pending.
# Reads the last turn_duration system entry from the transcript named in the
# hook's stdin JSON. The count is omitted (not written as 0) when none pend.
has_pending_background_agents() {
	local input="$1"
	local transcript count
	transcript=$(jq -r '.transcript_path // ""' <<<"$input" 2>/dev/null || true)
	[ -n "$transcript" ] && [ -f "$transcript" ] || return 1
	count=$(grep '"subtype":"turn_duration"' "$transcript" 2>/dev/null | tail -1 \
		| grep -oE '"pendingBackgroundAgentCount":[0-9]+' | grep -oE '[0-9]+$' || true)
	[ -n "$count" ] && [ "$count" -ge 1 ]
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
