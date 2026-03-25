#!/usr/bin/env bash
set -euo pipefail

get_battery_icon() {
    local PERCENTAGE
    PERCENTAGE=$(printf "%.0f" "$1")
    local ICON=""

    if ((PERCENTAGE <= 15)); then
        ICON="󰁺"
    elif ((PERCENTAGE <= 29)); then
        ICON="󰁻"
    elif ((PERCENTAGE <= 39)); then
        ICON="󰁼"
    elif ((PERCENTAGE <= 59)); then
        ICON="󰁽"
    elif ((PERCENTAGE <= 69)); then
        ICON="󰁾"
    elif ((PERCENTAGE <= 79)); then
        ICON="󰁿"
    elif ((PERCENTAGE <= 89)); then
        ICON="󰂀"
    elif ((PERCENTAGE <= 99)); then
        ICON="󰂁"
    else
        ICON="󰁹"
    fi
    echo "$ICON"
}

if ! busctl --system list | grep -q 'org.bluez'; then
    echo "󰂲"
    exit 0
fi

BLUETOOTH_DEV=()
BLUETOOTH_BATTERY=""

mapfile -t BLUETOOTH_DEV < <(busctl tree org.bluez | grep 'hci0/dev_' | awk '{print $2}' | grep -v sep | grep org || true)

if [ ${#BLUETOOTH_DEV[@]} -eq 0 ]; then
    echo ""
    exit 0
fi

for DEV in "${BLUETOOTH_DEV[@]}"; do
    BLUETOOTH_BATTERY=$(busctl --system get-property org.bluez "$DEV" org.bluez.Battery1 Percentage 2>/dev/null | cut -d " " -f2 || true)
    if ! [[ -z "$BLUETOOTH_BATTERY" ]]; then
        break
    fi
done

if [[ -z "$BLUETOOTH_BATTERY" ]]; then
    echo ""
else
    BATTERY_ICON=$(get_battery_icon "$BLUETOOTH_BATTERY")
    echo " $BATTERY_ICON"
fi
