#!/usr/bin/env bash
sound="$1"
[[ -z "$sound" ]] && exit 0
front=$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null)
[[ "$front" == *'"kitty"'* ]] && exit 0
afplay "$sound"
