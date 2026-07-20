#!/usr/bin/env bash
FILE="${1:-}"
if [[ -n "$FILE" ]]; then
    kitty --title "opencode" opencode "$FILE"
else
    kitty --title "opencode" opencode
fi