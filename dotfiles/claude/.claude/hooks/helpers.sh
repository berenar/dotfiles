#!/bin/bash

is_main_session_hook() {
	local input="$1"

	jq -e '(.agent_id // "") == "" and ((.transcript_path // "") | contains("/subagents/") | not)' <<<"$input" >/dev/null 2>&1
}
