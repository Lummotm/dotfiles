#!/usr/bin/env bash

# Mostrar lista si rofi está en modo selección
if [ -z "$ROFI_RETV" ] || [ "$ROFI_RETV" -eq 0 ]; then
    echo "󰏤  Pausar música"
    echo " Reanudar música"
    echo " Canción siguiente"
    echo " Canción previa"
    fd -e mp3 -e m4a . ~/Music | sed "s|^/home/$USER/Music/||"
    exit 0
fi

file="$1"
[ -z "$file" ] && exit 0

if [ "$file" = "󰏤  Pausar música" ]; then
    mpc pause >/dev/null
    notify-send "󰏤  Pausar música"
    exit 0
fi

if [ "$file" = " Reanudar música" ]; then
    mpc play >/dev/null
    notify-send " Reanudar música"
    exit 0
fi

if [ "$file" = " Canción siguiente" ]; then
    mpc next >/dev/null
    notify-send " Canción Siguiente"
    exit 0
fi

if [ "$file" = " Canción previa" ]; then
    mpc prev >/dev/null
    notify-send " Canción Previa"
    exit 0
fi

# Reproducir canción seleccionada
mpc add "$file" >/dev/null

# Obtener la nueva posición total (que será la posición de la canción recién agregada)
new_position=$(mpc playlist | wc -l)

# Si no había nada reproduciéndose, empezar
if ! mpc status | grep -q "\[playing\]" && ! mpc status | grep -q "\[paused\]"; then
    mpc play >/dev/null
fi

# Saltar a la canción recién agregada
mpc play "$new_position" >/dev/null

notify-send "🎵 Reproduciendo $file"
