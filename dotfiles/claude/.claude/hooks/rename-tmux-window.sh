#!/bin/bash
# Renames the enclosing tmux window based on the user's prompts.
# Runs async from Claude Code's UserPromptSubmit hook. Failures are silent.
set -euo pipefail

[ -z "${TMUX:-}" ] && exit 0
[ -z "${TMUX_PANE:-}" ] && exit 0
[ -n "${CLAUDE_TMUX_RENAME_ACTIVE:-}" ] && exit 0

INPUT=$(cat)
PROMPT=$(jq -r '.prompt // ""' <<< "$INPUT")
SESSION_ID=$(jq -r '.session_id // ""' <<< "$INPUT")
SESSION_TITLE=$(jq -r '.session_title // ""' <<< "$INPUT")
[ -z "$SESSION_ID" ] && exit 0

STATE_FILE="$HOME/.claude/session-state/$SESSION_ID.label"
STORED_LABEL=""
[ -f "$STATE_FILE" ] && STORED_LABEL=$(<"$STATE_FILE")

if [ -n "$SESSION_TITLE" ] && [ "$SESSION_TITLE" != "$STORED_LABEL" ]; then
  mkdir -p "${STATE_FILE%/*}"
  tmux set-window-option -t "$TMUX_PANE" automatic-rename off \; \
       set-window-option -t "$TMUX_PANE" allow-rename off \; \
       rename-window -t "$TMUX_PANE" "$SESSION_TITLE" 2>/dev/null || true
  printf '%s' "$SESSION_TITLE" > "$STATE_FILE"
  exit 0
fi

PR_ID=""
PR_NUM=$(grep -oEi '(PR[[:space:]#-]*[0-9]+|github\.com/[^[:space:]]+/pull/[0-9]+)' <<< "$PROMPT" | grep -oE '[0-9]+' | head -1 || true)
[ -n "$PR_NUM" ] && PR_ID="PR-$PR_NUM"

BLOCKLIST='^(UTF|SHA|HTTP|HTTPS|CVE|GPT|RFC|ISO|MD|SSL|TLS|HTML|CSS|JSON|YAML|XML|ASCII|IEEE|RGBA|MP|MP3|MP4|H|H264|H265)$'
LINEAR_ID=""
while IFS= read -r CANDIDATE; do
  CANDIDATE=$(tr '[:lower:]' '[:upper:]' <<< "$CANDIDATE")
  [[ "${CANDIDATE%%-*}" =~ $BLOCKLIST ]] || { LINEAR_ID="$CANDIDATE"; break; }
done < <(grep -oEi '[A-Z][A-Z0-9]{1,9}-[0-9]+' <<< "$PROMPT" || true)

NEW_LABEL="${LINEAR_ID:-$PR_ID}"

CURRENT_NAME=$(tmux display-message -p -t "$TMUX_PANE" '#W' 2>/dev/null || true)
if [ -n "$STORED_LABEL" ] && [ "$CURRENT_NAME" != "$STORED_LABEL" ] && [ -z "$NEW_LABEL" ]; then
  exit 0
fi

if [ -z "$NEW_LABEL" ] && [ -z "$STORED_LABEL" ]; then
  INSTRUCTION="Summarize this task in 1-2 words as a lowercase kebab-case label (letters, digits, hyphens only). Output ONLY the label, no quotes, no explanation. Task: $PROMPT"
  NEW_LABEL=$(
    CLAUDE_TMUX_RENAME_ACTIVE=1 claude -p --model haiku "$INSTRUCTION" 2>/dev/null \
      | grep -oE '[a-z0-9][a-z0-9-]{0,31}' | head -1 || true
  )
fi

[ -z "$NEW_LABEL" ] && exit 0
[ "$NEW_LABEL" = "$STORED_LABEL" ] && exit 0

mkdir -p "${STATE_FILE%/*}"
tmux set-window-option -t "$TMUX_PANE" automatic-rename off \; \
     set-window-option -t "$TMUX_PANE" allow-rename off \; \
     rename-window -t "$TMUX_PANE" "$NEW_LABEL" 2>/dev/null || true
printf '%s' "$NEW_LABEL" > "$STATE_FILE"
