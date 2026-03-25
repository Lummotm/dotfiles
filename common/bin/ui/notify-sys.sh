#!/usr/bin/env bash
set -euo pipefail

# Find the first available battery in /sys/class/power_supply/
SYS_BATTERY_PATH=""
for bat in /sys/class/power_supply/BAT*; do
    if [[ -d "$bat" ]]; then
        SYS_BATTERY_PATH="$bat"
        break # We'll take the first one found
    fi
done

get_info() {
    local INFO_REQUIRED="$1"
    local BATTERY
    # Try to find the battery in upower that matches the one in /sys
    # (e.g. BAT0, BAT1). If not, take the first one found.
    local BAT_NAME
    BAT_NAME=$(basename "$SYS_BATTERY_PATH") # e.g.: BAT0
    BATTERY=$(upower -e | grep "$BAT_NAME" | head -n 1)

    if [[ -z "$BATTERY" ]]; then
        BATTERY=$(upower -e | grep BAT | head -n 1)
    fi

    # If upower still can't find a battery, we can't continue
    if [[ -z "$BATTERY" ]]; then
        echo ""
        return
    fi

    local INFO_OBTAINED
    INFO_OBTAINED=$(upower -i "$BATTERY" | grep "$INFO_REQUIRED" | cut -d: -f2 | tr -d ' ')
    echo "$INFO_OBTAINED"
}

get_battery_icon() {
    # Convert to integer for comparison
    local BATTERY
    BATTERY=$(printf "%.0f" "$1")

    if ((BATTERY <= 15)); then
        echo "󰁻"
    elif ((BATTERY <= 25)); then
        echo "󰁼"
    elif ((BATTERY <= 50)); then
        echo "󰁾"
    elif ((BATTERY <= 75)); then
        echo "󰂀"
    elif ((BATTERY <= 90)); then
        echo "󰂂"
    else
        echo "󰁹"
    fi
}

battery_info() {
    local BATTERY_NOW
    BATTERY_NOW=$(get_info percentage)
    # Remove '%' and decimals for get_battery_icon
    local BATTERY_NUM
    BATTERY_NUM=$(echo "$BATTERY_NOW" | cut -d'.' -f1 | tr -d '%')

    local BATTERY_ICON
    BATTERY_ICON=$(get_battery_icon "$BATTERY_NUM")
    printf "%s %s" "$BATTERY_ICON" "$BATTERY_NOW"
}

time_left_info() {
    # Use the dynamic battery path $SYS_BATTERY_PATH
    local ENERGY_NOW
    ENERGY_NOW=$(cat "$SYS_BATTERY_PATH/energy_now")
    local POWER_NOW
    POWER_NOW=$(cat "$SYS_BATTERY_PATH/power_now")
    local CHARGE_LIMIT_PERCENT
    CHARGE_LIMIT_PERCENT=$(cat "$SYS_BATTERY_PATH/charge_control_end_threshold")

    if [[ $POWER_NOW != "0" ]]; then
        local TIME_LEFT
        if [[ $BATTERY_STATE == "discharging" ]]; then
            TIME_LEFT=$(echo "scale=4; $ENERGY_NOW / $POWER_NOW" | bc)
        else
            local ENERGY_FULL
            ENERGY_FULL=$(cat "$SYS_BATTERY_PATH/energy_full")
            TIME_LEFT=$(echo "scale=4; ($ENERGY_FULL*($CHARGE_LIMIT_PERCENT/100) - $ENERGY_NOW) / $POWER_NOW" | bc)
        fi

        local HOURS
        HOURS=$(echo "$TIME_LEFT / 1" | bc)
        local DECIMAL_PART
        DECIMAL_PART=$(echo "$TIME_LEFT - $HOURS" | bc)
        local MINUTES
        MINUTES=$(echo "$DECIMAL_PART * 60 / 1 " | bc)

        if [[ $HOURS == "0" ]]; then
            printf "%0.0fm" "$MINUTES"
        else
            printf "%sh %02dm" "$HOURS" "$MINUTES"
        fi
    else
        printf ""
    fi
}

consumption_info() {
    if [[ "$BATTERY_STATE" == "discharging" ]]; then
        local POWER_NOW
        POWER_NOW=$(cat "$SYS_BATTERY_PATH/power_now")
        POWER_NOW=$(echo "scale=2; $POWER_NOW / 10^6" | bc)
        printf "%sW" "$POWER_NOW"
    fi
}

time_info() {
    local CURRENT_TIME
    CURRENT_TIME=$(date +"%d/%m/%y, %H:%M")
    printf "%s" "$CURRENT_TIME"
}

get_bluetooth_battery() {
    local BLUETOOTH_DEV=()
    local BLUETOOTH_ICON
    local BLUETOOTH_BATTERY=""

    mapfile -t BLUETOOTH_DEV < <(busctl tree org.bluez | grep hci0/dev | awk '{print $2}' | grep -v sep | grep org || true)

    for DEV in "${BLUETOOTH_DEV[@]}"; do
        # We give true if error, no need to exit, is an expected error
        BLUETOOTH_BATTERY=$(busctl --system get-property org.bluez "$DEV" org.bluez.Battery1 Percentage 2>/dev/null | cut -d " " -f2 || true)
        if ! [[ -z "$BLUETOOTH_BATTERY" ]]; then
            break
        fi
    done

    BLUETOOTH_ICON=""

    if [[ -z "$BLUETOOTH_BATTERY" ]]; then
        echo ""
        return
    else
        echo "$BLUETOOTH_ICON $BLUETOOTH_BATTERY%"
    fi
}

TIME_STRING=$(time_info)
BLUETOOTH_BATTERY=$(get_bluetooth_battery)

# Check if $SYS_BATTERY_PATH is empty (no battery found)
if [[ -z "$SYS_BATTERY_PATH" ]]; then
    GENERAL_STRING="$TIME_STRING"
    if [[ -n "$BLUETOOTH_BATTERY" ]]; then
        GENERAL_STRING="$GENERAL_STRING\n$BLUETOOTH_BATTERY"
    fi
else
    # Get the state globally, since time_left_info and consumption_info need it
    BATTERY_STATE=$(get_info state)
    TIME_LEFT_STRING=$(time_left_info)
    BATTERY_STRING=$(battery_info)
    CONSUMPTION_STRING=$(consumption_info)

    GENERAL_STRING="$TIME_STRING"

    BATTERY_LINE="$BATTERY_STRING"
    if [[ -n "$BLUETOOTH_BATTERY" ]]; then
        BATTERY_LINE="$BATTERY_LINE • $BLUETOOTH_BATTERY"
    fi
    GENERAL_STRING="$GENERAL_STRING\n$BATTERY_LINE"

    STATUS_LINE=""
    if [[ $BATTERY_STATE == "discharging" ]]; then
        STATUS_LINE="$TIME_LEFT_STRING | $CONSUMPTION_STRING"
    elif [[ $TIME_LEFT_STRING != "" ]]; then
        STATUS_LINE="Full in: $TIME_LEFT_STRING"
    fi

    if [[ -n "$STATUS_LINE" ]]; then
        GENERAL_STRING="$GENERAL_STRING\n$STATUS_LINE"
    fi
fi

case "${1:-notify}" in
"rofi")
    # Aun no ha sido implementado
    echo -e "$GENERAL_STRING"
    ;;
*)
    # Modo por defecto es modo notificación
    notify-send "System Info" "$GENERAL_STRING" -t 2000 -r 999
    ;;
esac
