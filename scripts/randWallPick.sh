#!/usr/bin/env bash

# Ruta base sin extensión
base="$HOME/Pictures/Wallpapers/rand-wall"

# Seleccionar imagen aleatoria
file=$(fd -e png -e jpg . "$HOME/Pictures/Wallpapers/wall-randomizer/" | shuf -n 1)
swww img $file --transition-type grow --transition-step 255 --transition-fps 60

# Obtener extensión original
ext="${file##*.}"

# Ruta con la extensión original (por si quieres guardarla también)
copied="$base.$ext"

if [ "$ext" != "png" ]; then
    rm -f "$base.png"
    ffmpeg -y -i "$copied" "$base.png"
else
    # Solo copiar si los paths no son idénticos
    if [ "$copied" != "$base.png" ]; then
        cp "$copied" "$base.png"
    fi
fi
