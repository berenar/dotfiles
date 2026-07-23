#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Claude Alerts Menu
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔔
# @raycast.packageName Claude Code

# Documentation:
# @raycast.description Opens the xbar Claude Code dropdown (waiting sessions + usage), same as clicking the menu-bar glyph. Assign a hotkey to this command in Raycast Preferences -> Extensions -> Script Commands.

# Refresh the plugin once before opening so the dropdown isn't showing data up
# to 5s stale. xbar re-renders (and visibly blinks) the menu bar item on every
# refresh, so this stays a single one-off refresh rather than a fast-poll loop.
open -g "xbar://app.xbarapp.com/refreshPlugin?path=claude-code.5s.sh"

# osascript prints the clicked element's AppleScript reference to stdout;
# discard it so Raycast's silent mode doesn't surface it as output.
osascript -e 'tell application "System Events" to tell process "xbar" to click menu bar item 1 of menu bar 2' >/dev/null 2>&1
