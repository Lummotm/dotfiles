#!/bin/bash

THRESHOLD_1=25
THRESHOLD_2=15

NOTIFIED_25=false
NOTIFIED_15=false

while true; do
    battery_level=$(cat /sys/class/power_supply/BAT0/capacity)
    charger_connected=$(cat /sys/class/power_supply/AC0/online)

    if [ "$charger_connected" = "0" ]; then # NO está enchufado
        echo "hola"
        if [ "$battery_level" -le "$THRESHOLD_1" ] && [ "$NOTIFIED_25" = false ]; then
            notify-send "󱃌 Batería baja" "Quedan ${battery_level}%. Considera conectar el cargador."
            NOTIFIED_25=true
        fi

        if [ "$battery_level" -le "$THRESHOLD_2" ] && [ "$NOTIFIED_15" = false ]; then
            notify-send "󱃌 Batería crítica" "Solo queda ${battery_level}%. ¡Conecta el cargador ya!"
            paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null
            NOTIFIED_15=true
        fi
    else
        # Está conectado → resetear
        NOTIFIED_25=false
        NOTIFIED_15=false
    fi

    sleep 60
done
