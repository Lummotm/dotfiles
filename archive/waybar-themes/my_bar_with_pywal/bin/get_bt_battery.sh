#!/usr/bin/env bash
set -uo pipefail

# NOTA: Si no hay "format": {} en waybar, si un script pasa cosas, el primer echo va al slot de icono y el segundo al slot de tooltip

get_battery_icon() {
    local PERCENTAGE
    PERCENTAGE=$(printf "%.0f" "${1:-0}")
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

IS_POWERED=$(busctl get-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered 2>/dev/null | awk '{print $2}')

if [[ "$IS_POWERED" != "true" ]]; then
    echo "󰂲"
    exit 0
fi

BLUETOOTH_DEV=()
BATERY_LEVEL=""

mapfile -t BLUETOOTH_DEV < <(busctl tree org.bluez | grep 'hci0/dev_' | awk '{print $2}' | grep -v sep | grep org || true)

if [ ${#BLUETOOTH_DEV[@]} -eq 0 ]; then
    echo ""
    exit 0
fi

for DEV in "${BLUETOOTH_DEV[@]}"; do
    BATERY_LEVEL=$(busctl --system get-property org.bluez "$DEV" org.bluez.Battery1 Percentage 2>/dev/null | cut -d " " -f2 || true)
    if ! [[ -z "$BATERY_LEVEL" ]]; then
        break
    fi
done

BATTERY_ICON=$(get_battery_icon "$BATERY_LEVEL")

if [[ -z "$BATERY_LEVEL" ]]; then
    echo ""
else
    BATTERY_ICON=$(get_battery_icon "$BATERY_LEVEL")
    echo " $BATTERY_ICON"
    echo ": $BATERY_LEVEL%"
fi
