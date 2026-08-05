#!/usr/bin/env bash

# Don't wanna dupe scripts
SCRIPTS=(
  "battery-notification.sh"
)
STATUS=$(cat /sys/class/power_supply/AC0/online)

for s in "${SCRIPTS[@]}"; do
  pkill -f "$s"
done

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
awww-daemon &
dunst &
sunsetr &
mpd-mpris &

$HOME/bin/sys/mute-sound.sh
$HOME/bin/sys/monitor-toggle.sh startup
mpc stop

# Launch stuff when on charger
if [[ "$STATUS" == "1" ]]; then
  # steam 2>&1 &
  True
else
  brightnessctl set 20%
fi

{
  $HOME/bin/sys/battery-mode-check.sh
  $HOME/bin/sys/battery-notification.sh
} &

{
  # Deberia de esperar a que se busque wifi antes de sync
  sleep 2
  $HOME/bin/sys/sync-git.sh ~/Documents/Obsidian/ ~/Documents/Keepass/
} &

{
  $HOME/bin/pickers/mount.sh --mount-crucial
} &
$HOME/bin/utils/create-desktops

{
  sleep 2
  # $HOME/bin/ui/wallpaper-randomizer.sh --score
  $HOME/bin/pickers/bgselector/bgselector --cache
  $HOME/.config/hypr/bin/gen-art.sh
} &

# Clipboard
cliphist wipe
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
