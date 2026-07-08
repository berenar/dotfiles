#!/bin/bash
# Opens Markdown files written by Claude Code in Markdown Preview.app, but only
# when the app is already running — the hook never launches it on its own.
# Runs async from Claude Code's PostToolUse hook (Write). Failures are silent.
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(jq -r '.tool_input.file_path // ""' <<< "$INPUT")

[ -z "$FILE_PATH" ] && exit 0
[[ "$FILE_PATH" == *.md || "$FILE_PATH" == *.markdown ]] || exit 0
[ -f "$FILE_PATH" ] || exit 0
pgrep -f "Markdown Preview.app" >/dev/null 2>&1 || exit 0

open -a "/System/Volumes/Data/Applications/Markdown Preview.app" "$FILE_PATH"
