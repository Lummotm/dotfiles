#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/Wallpapers/0-god/"

# -t quita el \n al final de cada linea
mapfile -t DIRS < <(find "$WALL_DIR" -type d)

for dir in "${DIRS[@]}"; do
    # ${dir,,} makes it lowercase
    if [[ "${dir,,}" =~ "phone" ]]; then
        true
    fi
    if [[ "${dir,,}" =~ "zip" ]]; then
        true
    fi
    CLEAN_DIRS+=("$dir")
done

FILES=()
for dir in "${CLEAN_DIRS[@]}"; do
    mapfile -t TMP < <(find "$dir" -type f)
    FILES+=("${TMP[@]}")
done

RANDOM_WALLPAPER=$(printf "%s\n" "${FILES[@]}" | shuf -n 1)

"$HOME/bin/ui/wallpaper-handler.sh" "$RANDOM_WALLPAPER"
