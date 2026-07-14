#!/bin/bash
# <xbar.title>Claude Code</xbar.title>
# <xbar.version>v1.1</xbar.version>
# <xbar.author>Bernat Pericàs</xbar.author>
# <xbar.desc>Shows ✻ in the menu bar when a Claude Code tmux window is waiting for input, plus per-account session/weekly usage.</xbar.desc>
# <xbar.dropdown>true</xbar.dropdown>

export PATH="/opt/homebrew/bin:/usr/bin:/bin:$PATH"

WAITING_COLOR="#EC5F36"
MONITOR="$HOME/.local/bin/tmux-claude-monitor"

# Per-account Claude Code usage. Each entry is "label:config-dir[:flag]"; the
# OAuth token lives in the macOS keychain under a service name derived from the
# config dir, and /api/oauth/usage returns the same numbers as /usage. A flag of
# "unlimited" skips the lookup and just prints unlimited (unlimited extra usage).
USAGE_ACCOUNTS=(
	"claude-mvst:$HOME/.claude-mvst"
	"claude-clbrt:$HOME/.claude-clbrt:unlimited"
)
USAGE_TTL=60
USAGE_CACHE_DIR="$HOME/.cache/claude-usage-xbar"
USER_ACCT="${USER:-$(id -un)}"

keychain_service_for() {
	local hash
	hash=$(printf '%s' "$1" | shasum -a 256 | cut -c1-8)
	printf 'Claude Code-credentials-%s' "$hash"
}

cache_is_fresh() {
	local cache="$1" mtime now
	[ -f "$cache" ] || return 1
	mtime=$(stat -f %m "$cache" 2>/dev/null) || return 1
	now=$(date +%s)
	[ $((now - mtime)) -lt "$USAGE_TTL" ]
}

fetch_usage() {
	local cfg="$1" cache="$2" svc token resp
	svc=$(keychain_service_for "$cfg")
	token=$(security find-generic-password -a "$USER_ACCT" -s "$svc" -w 2>/dev/null | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
	[ -z "$token" ] && return 1
	resp=$(curl -sS --max-time 5 https://api.anthropic.com/api/oauth/usage \
		-H "Authorization: Bearer $token" \
		-H "Content-Type: application/json" \
		-H "anthropic-beta: oauth-2025-04-20" 2>/dev/null)
	printf '%s' "$resp" | jq -e '.five_hour.utilization != null' >/dev/null 2>&1 || return 1
	printf '%s' "$resp" >"$cache"
}

humanize_until() {
	local iso="$1" ep now diff d h m
	{ [ -z "$iso" ] || [ "$iso" = "null" ]; } && {
		printf '?'
		return
	}
	ep=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "${iso:0:19}" +%s 2>/dev/null) || {
		printf '?'
		return
	}
	now=$(date -u +%s)
	diff=$((ep - now))
	[ "$diff" -lt 0 ] && diff=0
	d=$((diff / 86400))
	h=$(((diff % 86400) / 3600))
	m=$(((diff % 3600) / 60))
	if [ "$d" -gt 0 ]; then
		printf '%dd %dh' "$d" "$h"
	elif [ "$h" -gt 0 ]; then
		printf '%dh %dm' "$h" "$m"
	else
		printf '%dm' "$m"
	fi
}

usage_line() {
	local label="$1" cfg="$2" flag="$3"
	if [ "$flag" = "unlimited" ]; then
		printf '%-15sunlimited | font="SF Mono" size=12\n' "$label"
		return
	fi
	local cache="$USAGE_CACHE_DIR/$label.json"
	mkdir -p "$USAGE_CACHE_DIR"
	cache_is_fresh "$cache" || fetch_usage "$cfg" "$cache"
	if [ ! -f "$cache" ]; then
		printf '%s: usage unavailable | font="SF Mono" size=12 color=#888888\n' "$label"
		return
	fi
	local s w sr wr
	s=$(jq -r '.five_hour.utilization // 0 | round' "$cache" 2>/dev/null)
	w=$(jq -r '.seven_day.utilization // 0 | round' "$cache" 2>/dev/null)
	sr=$(humanize_until "$(jq -r '.five_hour.resets_at // empty' "$cache" 2>/dev/null)")
	wr=$(humanize_until "$(jq -r '.seven_day.resets_at // empty' "$cache" 2>/dev/null)")
	printf '%-15ssession %3d%% (%s)   ·   week %3d%% (%s) | font="SF Mono" size=12\n' \
		"$label" "$s" "$sr" "$w" "$wr"
}

WAITING=$(tmux list-windows -a -F '#{window_bell_flag}|#{@claude_waiting_unfocused}|#{session_name}|#{window_name}|#{window_id}' 2>/dev/null | awk -F'|' '$1=="1" || $2=="1"')
COUNT=$(printf '%s\n' "$WAITING" | grep -c . || true)

if [ "$COUNT" -gt 0 ]; then
	echo "✻ | color=$WAITING_COLOR size=15 font=\"SF Mono\""
else
	echo " "
fi

echo "---"
if [ "$COUNT" -gt 0 ]; then
	printf '%s\n' "$WAITING" | awk -F'|' -v monitor="$MONITOR" '{
		printf "%s : %s waiting for input | bash=%s param1=\"--open-window\" param2=\"%s\" param3=\"%s\" terminal=false\n", $3, $4, monitor, $3, $5
	}'
else
	echo "No Claude sessions waiting"
fi

echo "---"
for entry in "${USAGE_ACCOUNTS[@]}"; do
	IFS=: read -r label cfg flag <<<"$entry"
	usage_line "$label" "$cfg" "$flag"
done

echo "---"
echo "Open Claude Monitor | bash=$HOME/.local/bin/tmux-claude-monitor terminal=false"
echo "Refresh | refresh=true"
