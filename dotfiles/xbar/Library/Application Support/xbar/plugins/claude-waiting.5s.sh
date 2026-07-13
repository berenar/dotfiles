#!/bin/bash
# <xbar.title>Claude Waiting</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Bernat Pericàs</xbar.author>
# <xbar.desc>Shows ✻ in the menu bar when a Claude Code tmux window is waiting for input (window_bell_flag set by flag-tmux-window.sh).</xbar.desc>
# <xbar.dropdown>true</xbar.dropdown>

export PATH="/opt/homebrew/bin:$PATH"

WAITING_COLOR="#EC5F36"

WAITING=$(tmux list-windows -a -F '#{window_bell_flag}|#{session_name}|#{window_name}' 2>/dev/null | awk -F'|' '$1=="1"')
COUNT=$(printf '%s\n' "$WAITING" | grep -c . || true)

if [ "$COUNT" -gt 0 ]; then
	echo "✻ | color=$WAITING_COLOR size=15 font=\"SF Mono\""
else
	echo " "
fi

echo "---"
if [ "$COUNT" -gt 0 ]; then
	printf '%s\n' "$WAITING" | awk -F'|' '{printf "%s : %s waiting for input\n", $2, $3}'
else
	echo "No Claude sessions waiting"
fi
echo "---"
echo "Open Claude Monitor | bash=$HOME/.local/bin/tmux-claude-monitor terminal=true"
echo "Refresh | refresh=true"
