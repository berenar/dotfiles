#!/bin/sh

file="$1"

open -a "Markdown Preview" "$file"

osascript <<'APPLESCRIPT'
tell application "Finder"
  set screenBounds to bounds of window of desktop
end tell

set screenWidth to item 3 of screenBounds
set screenHeight to item 4 of screenBounds
set menuBarHeight to 25
set halfWidth to screenWidth / 2
set usableHeight to screenHeight - menuBarHeight

tell application "System Events"
  repeat until (exists front window of process "Markdown Preview")
    delay 0.02
  end repeat

  tell process "Markdown Preview"
    set position of front window to {0, menuBarHeight}
    set size of front window to {halfWidth, usableHeight}
  end tell

  tell process "kitty"
    set position of front window to {halfWidth, menuBarHeight}
    set size of front window to {halfWidth, usableHeight}
  end tell
end tell
APPLESCRIPT
