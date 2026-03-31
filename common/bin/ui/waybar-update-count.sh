#!/usr/bin/env bash

OFFICIAL_UPDATES=$(checkupdates 2>/dev/null)
AUR_UPDATES=$(yay -Qua 2>/dev/null)

COUNT_OFFICIAL=$(echo "$OFFICIAL_UPDATES" | grep -c '[^[:space:]]')
COUNT_AUR=$(echo "$AUR_UPDATES" | grep -c '[^[:space:]]')
TOTAL=$((COUNT_OFFICIAL + COUNT_AUR))

HAS_KERNEL=$(echo "$OFFICIAL_UPDATES" | grep -iE "^linux(-cachyos| )" | wc -l)

if [ "$HAS_KERNEL" -gt 0 ] || [ "$TOTAL" -ge 50 ]; then
    ICON="󰮯"
    [[ "$HAS_KERNEL" -gt 0 ]] && ICON="⚠"

    echo "{\"text\": \"$ICON\", \"tooltip\": \"Paquetes: $TOTAL\nKernel detectado: $HAS_KERNEL\n\nClick para safe-update\"}"
else
    echo "{\"text\": \"\", \"tooltip\": \"\"}"
fi
