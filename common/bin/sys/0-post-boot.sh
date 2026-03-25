#!/usr/bin/env bash

# Don't wanna dupe scripts
SCRIPTS=(
    "battery-notification.sh"
)

for s in "${SCRIPTS[@]}"; do
    pkill -f "$s"
done

~/bin/sys/mute-sound.sh
~/bin/sys/monitor-toggle.sh startup
brightnessctl set 30%

{
    ~/bin/sys/battery-mode-check.sh
    ~/bin/sys/battery-notification.sh
} &

{
    ~/bin/sys/sync-git.sh ~/Documents/Obsidian/ ~/Documents/Keepass/
} &

{
    ~/bin/ui/wallpaper-handler.sh ~/Pictures/Wallpapers/current-wallpaper
    ~/.config/rofi/bin/bgselector/bgselector --cache
} &

# Clipboard
cliphist wipe
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
