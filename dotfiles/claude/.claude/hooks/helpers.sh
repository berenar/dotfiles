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

# Returns 0 only for a real main-session activity event in a live tmux pane:
# not the nested rename-labeller (CLAUDE_TMUX_RENAME_ACTIVE), and inside tmux
# with a pane to target. Callers use `require_live_tmux_pane || exit 0`.
require_live_tmux_pane() {
	[ -z "${CLAUDE_TMUX_RENAME_ACTIVE:-}" ] || return 1
	[ -n "${TMUX:-}" ] || return 1
	[ -n "${TMUX_PANE:-}" ] || return 1
}

# Reads the hook's JSON payload from stdin (empty when attached to a tty).
read_hook_input() {
	[ -t 0 ] && return 0
	cat
}

# Pins the enclosing window's name (disabling tmux auto-rename first) so a
# hook-set label isn't immediately overwritten by the running command.
pin_window_name() {
	tmux set-window-option -t "$TMUX_PANE" automatic-rename off \; \
	     set-window-option -t "$TMUX_PANE" allow-rename off \; \
	     rename-window -t "$TMUX_PANE" "$1" 2>/dev/null || true
}

# Returns 0 when the terminal emulator (kitty) is the frontmost macOS app.
# Switching terminals means changing only this check.
is_kitty_frontmost() {
	local front
	front=$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null || true)
	[[ "$front" == *'"kitty"'* ]]
}

# Sets or clears a per-window tmux flag tracking "Claude is actively working in
# this window". Returns non-zero (so callers can `|| exit 0`) when the event is
# not a real main-session activity event for a live tmux pane: outside tmux, the
# nested labeling claude (CLAUDE_TMUX_RENAME_ACTIVE), or a subagent on "on".
#   set_window_activity_flag @claude_running on
#   set_window_activity_flag @claude_running off
set_window_activity_flag() {
	local option="$1" action="${2:-off}"

	require_live_tmux_pane || return 1

	if [ "$action" = "on" ]; then
		local input
		input=$(read_hook_input)
		is_main_session_hook "$input" || return 1
		tmux set-option -w -t "$TMUX_PANE" "$option" 1 2>/dev/null || true
	else
		tmux set-option -uw -t "$TMUX_PANE" "$option" 2>/dev/null || true
	fi
}
