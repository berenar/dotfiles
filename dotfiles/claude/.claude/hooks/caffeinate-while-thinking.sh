#!/bin/bash
# Keeps the Mac awake (caffeinate) while Claude is actively working, across any
# number of concurrent sessions. Each session flags its tmux window via a
# @claude_caffeinate window option; a single machine-wide `caffeinate` process
# is reconciled against those flags: it starts when the first session begins
# thinking and stops only once the last one finishes.
#   caffeinate-while-thinking.sh on    Claude started responding (UserPromptSubmit)
#   caffeinate-while-thinking.sh off   Claude stopped or is waiting (Stop/Notification/SessionStart)
# tmux drops a window's option when its pane closes, so a crashed session cannot
# strand caffeinate on: the next "off" reconcile finds no flagged windows.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

action="${1:-off}"
set_window_activity_flag @claude_caffeinate "$action" || exit 0

STATE_DIR="${TMPDIR:-/tmp}/claude-caffeinate"
PID_FILE="$STATE_DIR/caffeinate.pid"
LOCK_DIR="$STATE_DIR/lock"
[ -d "$STATE_DIR" ] || mkdir -p "$STATE_DIR"

acquire_lock() {
	local tries
	for ((tries = 0; tries < 20; tries++)); do
		mkdir "$LOCK_DIR" 2>/dev/null && return
		sleep 0.1
	done
	rmdir "$LOCK_DIR" 2>/dev/null || true
	mkdir "$LOCK_DIR" 2>/dev/null || true
}

is_our_caffeinate_alive() {
	local pid="$1" comm
	[ -n "$pid" ] || return 1
	comm=$(ps -p "$pid" -o comm= 2>/dev/null) || return 1
	[[ "$comm" == *caffeinate ]]
}

any_flagged_windows() {
	tmux list-windows -a -F '#{@claude_caffeinate}' 2>/dev/null | grep -q '^1$'
}

acquire_lock
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

pid=""
[ -f "$PID_FILE" ] && pid=$(<"$PID_FILE")
is_our_caffeinate_alive "$pid" || { rm -f "$PID_FILE"; pid=""; }

if [ "$action" = "on" ]; then
	if [ -z "$pid" ]; then
		nohup caffeinate -i >/dev/null 2>&1 &
		cpid=$!
		disown "$cpid" 2>/dev/null || true
		echo "$cpid" >"$PID_FILE"
	fi
elif [ -n "$pid" ] && ! any_flagged_windows; then
	kill "$pid" 2>/dev/null || true
	rm -f "$PID_FILE"
fi
