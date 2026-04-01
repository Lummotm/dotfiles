#!/usr/bin/env bash

IGNORE_PATTERN="^(haskell-|python-)"

OFFICIAL_UPDATES=$(checkupdates 2>/dev/null | grep -vE "$IGNORE_PATTERN")
AUR_UPDATES=$(yay -Qua 2>/dev/null | grep -vE "$IGNORE_PATTERN")

COUNT_OFFICIAL=$(echo "$OFFICIAL_UPDATES" | grep -c '[^[:space:]]')
COUNT_AUR=$(echo "$AUR_UPDATES" | grep -c '[^[:space:]]')
TOTAL=$((COUNT_OFFICIAL + COUNT_AUR))

HAS_KERNEL=$(echo "$OFFICIAL_UPDATES" | grep -iE "^linux(-cachyos| )" | wc -l)

if [ "$TOTAL" -gt 50 ]; then
    ICON="󰮯"
    [[ "$HAS_KERNEL" -gt 0 ]] && ICON="⚠"

    echo "{\"text\": \"$ICON\", \"tooltip\": \"Paquetes: $TOTAL\nKernel detectado: $HAS_KERNEL\n\nClick para safe-update\"}"
else
    # Si después del filtro no queda nada, Waybar no muestra nada
    echo "{\"text\": \"\", \"tooltip\": \"\"}"
fi
