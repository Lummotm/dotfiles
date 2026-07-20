#!/usr/bin/env bash

# Recorremos todos los carrier que empiecen en enp4s
for CARRIER_FILE in /sys/class/net/enp4s*/carrier; do
    # Si la expansión no encuentra nada, el literal queda tal cual: sáltalo
    [[ -e "$CARRIER_FILE" ]] || continue

    if [[ $(<"$CARRIER_FILE") -eq 1 ]]; then
        ETH_IF=$(basename "$(dirname "$CARRIER_FILE")")
        echo "Interface con enlace activo: $ETH_IF"
        nmcli con up Hotspot
        exit 0
    fi
done

echo "Ningún enp4s* tiene enlace activo"
