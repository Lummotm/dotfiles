#!/usr/bin/env bash

# Ruta base sin extensión
base="$HOME/.config/rofi/images/rofi-wall"

# Seleccionar imagen aleatoria
file=$(fd -e png -e jpg . "$HOME/Pictures/Wallpapers/wall-randomizer/" | shuf -n 1)

# Obtener extensión original
ext="${file##*.}"

# Ruta con la extensión original (por si quieres guardarla también)
copied="$base.$ext"

# Copiar la imagen original
cp "$file" "$copied"

if [ "$ext" != "png" ]; then
    rm -f "$base.png"
    ffmpeg -y -i "$copied" "$base.png"
else
    cp "$copied" "$base.png"
fi
