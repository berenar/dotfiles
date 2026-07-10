#!/bin/bash
# Marks the enclosing tmux window as "claude is thinking" via a @claude_running
# window option, so the session switcher can distinguish sessions where Claude
# is actively working from ones that are idle or waiting for input.
#   set-claude-running.sh on    Claude started responding (UserPromptSubmit)
#   set-claude-running.sh off   Claude stopped or is waiting (Stop/Notification)
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

set_window_activity_flag @claude_running "${1:-off}" || exit 0
