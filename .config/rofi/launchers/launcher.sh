#!/usr/bin/env bash
dir="$HOME/.config/rofi/launchers/style-launcher.rasi"
music="$HOME/.config/rofi/scripts/music-picker.sh"
rofi \
    -modi "drun,music:$music,window" \
    -show drun \
    -theme "$dir"

# se pueden añadir mas opciones cambiando el modi por ahora esta asi porque es comodo
