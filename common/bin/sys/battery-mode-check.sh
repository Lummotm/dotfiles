#!/usr/bin/env bash

# Definir opciones
OPT_DESKTOP="󰚥 Desktop Mode (Cap at 80%)"
OPT_FULL="󱊣 Full Charge (100%)"

CHOICE=$(echo -e "$OPT_FULL\n$OPT_DESKTOP" | timeout 8 rofi -dmenu \
    -p "Battery Mode" \
    -i \
    -lines 2 \
    -no-custom)

if [[ "$CHOICE" == "$OPT_FULL" ]]; then
    echo 100 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold >/dev/null
    notify-send "Carga al 100%" -i battery-full
else
    echo 80 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold >/dev/null
    notify-send "Carga al 80% " -i battery-good
fi
