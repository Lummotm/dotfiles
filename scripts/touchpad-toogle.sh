#!/usr/bin/env bash

DEVICE="asue120b:00-04f3:31c0-touchpad"
VAR="device[$DEVICE]:enabled"
FLAG="/tmp/hypr-touchpad-disabled"

if [ -f "$FLAG" ]; then
    hyprctl keyword "$VAR" true
    rm "$FLAG"
    notify-send "🖱 Touchpad activado"
else
    hyprctl keyword "$VAR" false
    touch "$FLAG"
    notify-send "🖱 Touchpad desactivado"
fi
