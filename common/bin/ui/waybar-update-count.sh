#!/usr/bin/env bash

# Generally dependecies from other packages, can ignore them
IGNORE_PATTERN="^(haskell-|python-)"
# Important packages, used daily should update
PRIORITY_PATTERN="(niri|hyprlock|waybar|greetd|linux-cachyos|systemd)"

OFFICIAL=$(checkupdates 2>/dev/null | grep -vE "$IGNORE_PATTERN")
AUR=$(yay -Qua 2>/dev/null | grep -vE "$IGNORE_PATTERN")
ALL_UPDATES=$(echo -e "$OFFICIAL\n$AUR" | sed '/^\s*$/d')

TOTAL=$(echo "$ALL_UPDATES" | grep -c '[^[:space:]]')
HAS_PRIORITY=$(echo "$ALL_UPDATES" | grep -iE "$PRIORITY_PATTERN" | wc -l)

if [ "$HAS_PRIORITY" -gt 0 ]; then
    ICON="⚠"
    MSG="Críticos: $HAS_PRIORITY | Total: $TOTAL"
elif [ "$TOTAL" -gt 50 ]; then
    ICON="󰮯"
    MSG="Paquetes: $TOTAL"
else
    ICON=""
fi

if [ -n "$ICON" ]; then
    echo "{\"text\": \"$ICON\", \"tooltip\": \"$MSG\"}"
else
    echo "{\"text\": \"\", \"tooltip\": \"\"}"
fi
