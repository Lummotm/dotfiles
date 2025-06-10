#!/usr/bin/env bash

# Mostrar lista si rofi está en modo selección
if [ -z "$ROFI_RETV" ] || [ "$ROFI_RETV" -eq 0 ]; then
    echo "󰏤  Pausar música / Pause music"
    echo "  Reanudar música / Restart music"
    echo "󰒭  Canción siguiente / Next song"
    echo "󰒮  Canción previa / Previous song"
    echo "󰛉  Parar música / Stop music"
    fd -e mp3 -e m4a . ~/Music | sed "s|^/home/$USER/Music/||"
    exit 0
fi

file="$1"
[ -z "$file" ] && exit 0

case "$file" in
"󰏤  Pausar música / Pause music")
    mpc pause >/dev/null
    notify-send "󰏤  Pausar música"
    exit 0
    ;;
"  Reanudar música / Restart music")
    mpc play >/dev/null
    notify-send "  Reanudar música"
    exit 0
    ;;
"󰒭  Canción siguiente / Next song")
    mpc next >/dev/null
    notify-send "󰒭  Canción siguiente"
    exit 0
    ;;
"󰒮  Canción previa / Previous song")
    mpc prev >/dev/null
    notify-send "󰒮  Canción previa"
    exit 0
    ;;
"󰛉  Parar música / Stop music")
    mpc stop >/dev/null
    notify-send "󰛉  Parar música"
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
