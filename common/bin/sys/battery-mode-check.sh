#!/usr/bin/env bash

BAT_PATH="/sys/class/power_supply/BAT0/charge_control_end_threshold"
AC_PATH="/sys/class/power_supply/AC0/online"

# Revisar primero si existe si quiera la bateria o el cargador (torre no tiene eso)
if [[ ! -f "$BAT_PATH" || ! -f "$AC_PATH" ]]; then
    exit 0
fi

OPT_DESKTOP="󰚥 Desktop Mode (Cap at 80%)"
OPT_FULL="󱊣 Full Charge (100%)"
POWER_SUPPLY_STATUS="$(cat "$AC_PATH")"

if [[ "$POWER_SUPPLY_STATUS" != 0 ]]; then
    CHOICE=$(echo -e "$OPT_FULL\n$OPT_DESKTOP" | timeout 8 rofi -dmenu \
        -p "Battery Mode" \
        -i \
        -lines 2 \
        -no-custom)

    if [[ "$CHOICE" == "$OPT_FULL" ]]; then
        echo 100 | sudo tee "$BAT_PATH" >/dev/null
        notify-send "Carga al 100%" -i battery-full
    else
        echo 80 | sudo tee "$BAT_PATH" >/dev/null
        notify-send "Carga al 80%" -i battery-good
    fi
fi
