#!/bin/bash

# Directorios y archivos
WALLPAPERS_DIR="$HOME/Pictures/Wallpapers/wall-randomizer"
DESTINATION="$HOME/Pictures/Wallpapers/selected-wall"

# Seleccionar wallpaper con sxiv
selected=$(sxiv -b -t -o "$WALLPAPERS_DIR"/*.{jpg,jpeg,png,gif} 2>/dev/null)
[ -z "$selected" ] && exit 0

# Aplicar wallpaper con swww
{
    swww img "$selected" --transition-type random --transition-pos 0.98,0.97 --transition-step 255 --transition-fps 60
} &

# Copia del fondo en .png a $HOME/Pictures/Wallpapers/hyprpaper-wall.png
# para cosas que requieran config de wallpaper fija (hyprpaper por ejemplo)
{
    ext="${selected##*.}"

    if [ "$ext" != "png" ]; then
        rm -f "$DESTINATION.png"
        ffmpeg -y -i "$selected" "$DESTINATION.png" >/dev/null 2>&1
    else
        if [ "$selected" != "$DESTINATION.png" ]; then
            cp "$selected" "$DESTINATION.png"
        fi
    fi
} &

{
    wal -i "$selected" >/dev/null 2>&1 &
    if pgrep -f "waybar" >/dev/null; then
        pkill waybar
        waybar >/dev/null 2>&1 &
    fi
} &
