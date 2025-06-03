#!/usr/bin/env bash

# Ruta base sin extensión
base="$HOME/Pictures/Wallpapers/rand-wall"

# Seleccionar imagen aleatoria
filetemp=$(fd -e png -e jpg . "$HOME/Pictures/Wallpapers/wall-randomizer/" | shuf -n 1)

# Usar la imagen como fondo (swww)
swww img "$filetemp" --transition-type random --transition-step 255 --transition-fps 60

file=$(fd -e png -e jpg . "$HOME/Pictures/Wallpapers/wall-randomizer/" | shuf -n 1)

# Obtener extensión original y definir 'copied'
ext="${file##*.}"
copied="$file"

# Convertir a PNG y guardar como rand-wall.png
if [ "$ext" != "png" ]; then
    rm -f "$base.png"
    ffmpeg -y -i "$copied" "$base.png" >/dev/null 2>&1
else
    # Solo copiar si no son el mismo path
    if [ "$copied" != "$base.png" ]; then
        cp "$copied" "$base.png"
    fi
fi
