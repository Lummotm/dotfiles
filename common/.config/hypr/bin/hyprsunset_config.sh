#!/usr/bin/env bash
set -euo pipefail

while true; do
    killall -9 hyprsunset 2>/dev/null || true # expected to error
    current_time=$(date +"%H")
    echo "Current time: $current_time" >>/tmp/hyprlight.log
    hours=(0 2 5 7 9 12 17 19 21 22 24)
    temperature=(2700 2700 3000 3500 5000 6500 6500 5000 4000 3000 2700)
    for ((i = 0; i < ${#hours[@]} - 1; i++)); do
        if ((current_time >= hours[i] && current_time < hours[i + 1])); then
            # El & es crucial - hyprsunset se queda corriendo como daemon y bloqueaba el script
            /usr/bin/hyprsunset -t ${temperature[i]} >>/tmp/hyprlight.log 2>&1 &
            break
        fi
    done

    min=$(date +"%M")
    min=${min#0}
    time=$((60 * (60 - min)))
    ((time > 0)) || time=60 # Evita sleep 0
    sleep "$time"
done
