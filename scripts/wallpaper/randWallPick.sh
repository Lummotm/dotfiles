#!/usr/bin/env bash
base="$HOME/Pictures/Wallpapers/rand-wall"

file=$(fd -e png -e jpg . "$HOME/Pictures/Wallpapers/wall-randomizer/" | shuf -n 1)
swww img "$file" --transition-type random --transition-step 255 --transition-fps 60

# Reshuffle for lockscreen
file=$(fd -e png -e jpg . "$HOME/Pictures/Wallpapers/wall-randomizer/" | shuf -n 1)

rm -f "$base.png"
ffmpeg -i "$selected_file" "$base.png"
