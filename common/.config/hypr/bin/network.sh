#!/usr/bin/env bash
set -euo pipefail

# Funcion de deteccion de hotspot por claude
is_hotspot_active() {
    # Método 1: Buscar conexiones activas tipo hotspot
    nmcli con show --active | grep -qi "hotspot\|ap"
    [ $? -eq 0 ] && return 0

    # Método 2: Verificar el modo de la interfaz WiFi
    local wifi_dev=$(nmcli -t -f DEVICE,TYPE device | grep wifi | head -n1 | cut -d: -f1)
    if [ -n "$wifi_dev" ]; then
        local wifi_mode=$(nmcli -t -f GENERAL.CONNECTION dev show "$wifi_dev" 2>/dev/null | cut -d: -f2)
        [ "$wifi_mode" = "Hotspot" ] && return 0
    fi

    # Método 3: Verificar si hay alguna conexión wifi en modo AP
    nmcli -t -f name,type con show --active 2>/dev/null | grep -q ".*:802-11-wireless.*" && {
        local active_con=$(nmcli -t -f GENERAL.CONNECTION dev show "$wifi_dev" 2>/dev/null | cut -d: -f2)
        [ -n "$active_con" ] && {
            nmcli -t -f 802-11-wireless.mode con show "$active_con" 2>/dev/null | grep -qi "ap"
            [ $? -eq 0 ] && return 0
        }
    }

    return 1
}

get_wifi_strength() {
    local strength=$(awk 'NR==3 {print int($3)}' /proc/net/wireless 2>/dev/null)

    if [ -n "$strength" ] && [ "$strength" -ge 0 ]; then
        if [ "$strength" -eq 0 ]; then
            echo "󰤯⠀"
        elif [ "$strength" -le 25 ]; then
            echo "󰤟⠀"
        elif [ "$strength" -le 50 ]; then
            echo "󰤢⠀"
        elif [ "$strength" -le 75 ]; then
            echo "󰤥⠀"
        else
            echo "󰤨⠀"
        fi
    else
        echo "󰤮⠀"
    fi
}

main() {
    local status=$(nmcli general status | grep -oh "\w*connect\w*")

    case "$status" in
    "disconnected")
        printf "󰤮⠀"
        ;;
    "connecting")
        printf "󱍸⠀"
        ;;
    "connected")
        local connection_type=$(nmcli con show --active | awk 'NR==2 {print $5}')

        if [ "$connection_type" = "ethernet" ]; then
            printf "󰈀⠀\n"
        else
            if is_hotspot_active; then
                printf "󰈀⠀\n"
            else
                get_wifi_strength
                printf "\n"
            fi
        fi
        ;;
    *)
        printf "󰤮⠀"
        ;;
    esac
}
main
