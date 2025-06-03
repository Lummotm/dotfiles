#!/bin/sh

WallDir=${1:-"$HOME/Pictures/Wallpapers/wall-randomizer/"}
WallChangeCommand="swww img --transition-type random \
    --transition-step 255 --transition-fps 60"
ROFI_THEME="$HOME/.config/rofi/wallpaper-selector/wallpaper-selector.rasi"

PREVIEW=true \
    rofi -theme "$ROFI_THEME" \
    -show filebrowser -filebrowser-command "$WallChangeCommand" \
    -filebrowser-directory "$WallDir" \
    -filebrowser-sorting-method mtime \
    -selected-row 1 >/dev/null
