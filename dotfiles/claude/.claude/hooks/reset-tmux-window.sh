#!/bin/bash
# Resets the enclosing tmux window name to "claude" when a new Claude Code
# session starts, so a stale label from a prior session doesn't linger before
# the UserPromptSubmit hook generates a fresh one.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

require_live_tmux_pane || exit 0

pin_window_name "claude"
