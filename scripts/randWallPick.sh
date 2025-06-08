#!/usr/bin/env bash
base="$HOME/Pictures/Wallpapers/rand-wall"

file=$(fd -e png -e jpg . "$HOME/Pictures/Wallpapers/wall-randomizer/" | shuf -n 1)
swww img "$file" --transition-type random --transition-step 255 --transition-fps 60

ext="${file##*.}"
if [ "$ext" != "png" ]; then
    rm -f "$base.png"
    ffmpeg -y -i "$file" "$base.png" >/dev/null 2>&1
else
    [ "$file" != "$base.png" ] && cp "$file" "$base.png"
fi
