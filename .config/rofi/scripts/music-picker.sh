#!/usr/bin/env bash

# Mostrar lista si rofi está en modo selección
if [ -z "$ROFI_RETV" ] || [ "$ROFI_RETV" -eq 0 ]; then
    echo "󰏤  Pausar música"
    #find ~/Music -type f \( -iname "*.mp3" -o -iname "*.m4a" \) |
    # Antes usaba find, fd parece ser mucho mas rápido
    fd -e mp3 -e m4a . ~/Music |
        sed "s|^/home/$USER/Music/||"
    exit 0
fi

file="$1"
[ -z "$file" ] && exit 0 # Salir si no se seleccionó nada

if [ "$file" = "󰏤  Pausar música" ]; then
    mpc pause >/dev/null
    notify-send "󰏤  Pausar música"
    exit 0
fi

mpc insert "$file"

# Obtener número total de canciones en la cola
position=$(mpc status | grep -o '#[0-9]\+/[0-9]\+' | cut -d'/' -f2)

if [ -z "$position" ]; then
    # Si la cola estaba vacía, empieza a reproducir
    mpc play >/dev/null

    # Revisar si realmente estaba vacía la cola

    # Recalcular posición tras reproducir
    position=$(mpc status | grep -o '#[0-9]\+/[0-9]\+' | cut -d'/' -f2)

    # Si no es la primera, saltar al final (última insertada)
    if [ "$position" -ne 1 ]; then
        mpc play "$position" >/dev/null
    fi
else
    # Si ya había algo reproduciéndose, saltar a la nueva última
    mpc play "$position" >/dev/null
fi

notify-send "🎵 Reproduciendo $file"
