#!/usr/bin/env bash

WallDir=${1:-"$HOME/Pictures/Wallpapers/"}
WallChangeCommand="$HOME/scripts/wallpaper/wallpaper-handler.sh"
ROFI_THEME="$HOME/.config/rofi/wallpaper-selector/wallpaper-selector.rasi"

PREVIEW=true \
    rofi -theme "$ROFI_THEME" \
    -show filebrowser -filebrowser-command "$WallChangeCommand" \
    -filebrowser-directory "$WallDir" \
    -filebrowser-sorting-method mtime\
    -selected-row 1 >/dev/null
