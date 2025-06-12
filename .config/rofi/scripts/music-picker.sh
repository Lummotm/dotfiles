#!/usr/bin/env bash

# Mostrar lista si rofi está en modo selección
if [ -z "$ROFI_RETV" ] || [ "$ROFI_RETV" -eq 0 ]; then
    echo "󰏤  Pausar música / Pause music"
    echo "  Reanudar música / Play music"
    echo "󰒭  Canción siguiente / Next song"
    echo "󰒮  Canción previa / Previous song"
    echo "󰛉  Parar música / Stop music"
    fd -e mp3 -e m4a . ~/Music | sed "s|^/home/$USER/Music/||"
    exit 0
fi

file="$1"
[ -z "$file" ] && exit 0

case "$file" in
*"Pause"*)
    mpc pause >/dev/null
    notify-send "󰏤  Music paused"
    exit 0
    ;;
*"Play"*)
    mpc play >/dev/null
    notify-send "  Music playing"
    exit 0
    ;;
*"Next"*)
    mpc next >/dev/null
    notify-send "󰒭  Next song"
    exit 0
    ;;
*"Previous"*)
    mpc prev >/dev/null
    notify-send "󰒮  Previous song"
    exit 0
    ;;
*"Stop"*)
    mpc stop >/dev/null
    notify-send "󰛉  Music stopped"
    exit 0
    ;;
esac

# Si no es un comando, asumimos que es una canción a reproducir

# Añadir y reproducir la canción
mpc add "$file" >/dev/null

# Obtener la nueva posición total
new_position=$(mpc playlist | wc -l)

# Reproducir si nada está sonando
if ! mpc status | grep -q "\[playing\]" && ! mpc status | grep -q "\[paused\]"; then
    mpc play >/dev/null
fi

# Reproducir la canción agregada
mpc play "$new_position" >/dev/null

notify-send "󰎈  Reproduciendo $file"
