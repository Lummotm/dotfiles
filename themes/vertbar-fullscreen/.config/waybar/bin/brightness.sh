#!/usr/bin/env bash

CACHE_FILE="/tmp/wb_brightness_cache"
TARGET_FILE="/tmp/wb_brightness_target"
BUS_LOCK="/tmp/wb_brightness_bus.lock"

get_active_devices() {
    niri msg --json outputs | jq -r 'to_entries[] | select(.value.logical != null) | .key'
}

get_brightness_icon() {
    local BRIGHTNESS=$1
    if ((BRIGHTNESS <= 10)); then
        echo ""
    elif ((BRIGHTNESS <= 20)); then
        echo ""
    elif ((BRIGHTNESS <= 30)); then
        echo ""
    elif ((BRIGHTNESS <= 40)); then
        echo ""
    elif ((BRIGHTNESS <= 50)); then
        echo ""
    elif ((BRIGHTNESS <= 60)); then
        echo ""
    elif ((BRIGHTNESS <= 70)); then
        echo ""
    elif ((BRIGHTNESS <= 85)); then
        echo ""
    else
        echo ""
    fi
}

get_brightness_hardware() {
    local DEVICES
    readarray -t DEVICES <<<"$(get_active_devices)"
    local FIRST="${DEVICES[0]}"

    if [[ "$FIRST" == eDP* ]]; then
        brightnessctl -m | cut -d',' -f4 | tr -d '%'
    else
        ddcutil getvcp 10 2>/dev/null |
            grep -oP 'current value =\s*\K[0-9]+' |
            head -1
    fi
}

get_tooltip() {
    local DEVICES
    readarray -t DEVICES <<<"$(get_active_devices)"
    local LINES=""

    for DEV in "${DEVICES[@]}"; do
        [[ -z "$DEV" ]] && continue
        local VAL
        if [[ "$DEV" == eDP* ]]; then
            VAL=$(brightnessctl -m | cut -d',' -f4 | tr -d '%')
        else
            VAL=$(cat "$CACHE_FILE" 2>/dev/null || echo "?")
        fi
        LINES+="$DEV: ${VAL}%\n"
    done

    printf "%b" "$LINES"
}

if [[ "$1" == "up" || "$1" == "down" ]]; then
    CURRENT=$(cat "$CACHE_FILE" 2>/dev/null)
    [[ -z "$CURRENT" ]] && CURRENT=$(get_brightness_hardware)
    [[ -z "$CURRENT" ]] && CURRENT=50

    if [[ "$1" == "up" ]]; then
        NEW=$((CURRENT + 5))
    else
        NEW=$((CURRENT - 5))
    fi
    ((NEW > 100)) && NEW=100
    ((NEW < 0)) && NEW=0

    echo "$NEW" >"$CACHE_FILE"
    echo "$NEW" >"$TARGET_FILE"

    (
        flock 200
        TARGET=$(cat "$TARGET_FILE" 2>/dev/null)
        [[ -z "$TARGET" ]] && exit 0
        rm -f "$TARGET_FILE"

        readarray -t DEVICES <<<"$(get_active_devices)"
        for DEV in "${DEVICES[@]}"; do
            [[ -z "$DEV" ]] && continue
            if [[ "$DEV" == eDP* ]]; then
                brightnessctl s "${TARGET}%" -q
            else
                ddcutil setvcp 10 "$TARGET" --noverify 2>/dev/null
            fi
        done
    ) 200>"$BUS_LOCK" &

    pkill -RTMIN+2 waybar
    exit 0
fi

(
    REAL_VAL=$(get_brightness_hardware)
    [[ -n "$REAL_VAL" ]] && echo "$REAL_VAL" >"$CACHE_FILE"
) &

BRIGHTNESS=$(cat "$CACHE_FILE" 2>/dev/null)
[[ -z "$BRIGHTNESS" ]] && BRIGHTNESS=50

ICON=$(get_brightness_icon "${BRIGHTNESS:-0}")

printf '{"text":"%s","alt":"%s","tooltip":"%s","percentage":%s}\n' \
    "$ICON" \
    "${BRIGHTNESS}%" \
    "$(get_tooltip)" \
    "${BRIGHTNESS}"
