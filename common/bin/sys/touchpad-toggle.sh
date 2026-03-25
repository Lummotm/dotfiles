#!/usr/bin/env bash
WM_FLAG="$1"
FLAG="/tmp/touchpad-disabled"

# Defino funcion para poder definir variables locales y no definir a lo bruto
touchpad_toggle() {
    case "$WM_FLAG" in
    "niri")
        local CONFIG_FILE="$HOME/.config/niri/config.kdl"
        local PYTHON_SCRIPT="$HOME/.config/niri/bin/niri_prop_toggle.py"
        python3 "$PYTHON_SCRIPT" "$CONFIG_FILE" "touchpad" "off"

        if [ -f "$FLAG" ]; then
            notify-send -i input-touchpad -r 999 "Touchpad activado"
            rm "$FLAG"
        else
            notify-send -i input-touchpad -r 999 "Touchpad desactivado"
            touch "$FLAG"
        fi
        ;;
    "hpyrland")
        local DEVICE="asue120b:00-04f3:31c0-touchpad"
        local VAR="device[$DEVICE]:enabled"
        if [ -f "$FLAG" ]; then
            hyprctl keyword "$VAR" true
            rm "$FLAG"
            notify-send -i input-touchpad "Touchpad Activado" -t 4000 -r 999
        else
            hyprctl keyword "$VAR" false
            touch "$FLAG"
            notify-send -i input-touchpad "Touchpad Desactivado" -t 4000 -r 999
        fi
        ;;
    *)
        notify-send "Not good" "Check the argument, it must be hyprland or niri"
        ;;
    esac
}
touchpad_toggle "$WM_FLAG"
