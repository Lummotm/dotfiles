#!/usr/bin/env bash

selected_file="$1"
base="$HOME/Pictures/Wallpapers/rand-wall"

# Verificar que se pasó un archivo
if [ -z "$selected_file" ] || [ ! -f "$selected_file" ]; then
    echo "Error: No se proporcionó un archivo válido"
    exit 1
fi

# Cambiar wallpaper con swww
swww img "$selected_file" --transition-type random --transition-step 255 --transition-fps 60

# Procesar para lockscreen
ext="${selected_file##*.}"
if [ "$ext" != "png" ]; then
    rm -f "$base.png"
    ffmpeg -y -i "$selected_file" "$base.png"
else
    cp "$selected_file" "$base.png"
fi

notify-send "Wallpaper cambiado: $selected_file"
