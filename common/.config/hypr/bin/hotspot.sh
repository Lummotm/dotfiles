#!/usr/bin/env bash
set -euo pipefail

is_hotspot_active() {
    local wifi_mode=$(nmcli -t -f GENERAL.CONNECTION dev show "$WIFI_INTERFACE" 2>/dev/null | cut -d: -f2)
    [[ "$wifi_mode" == "Hotspot" ]] && return 0

    nmcli con show --active | grep -q "Hotspot\|wifi.*ap" && return 0

    local device_state=$(nmcli -t -f GENERAL.STATE dev show "$WIFI_INTERFACE" 2>/dev/null | cut -d: -f2)
    [[ "$device_state" == "connected" ]] && nmcli -t -f connection.type con show "$(nmcli -t -f GENERAL.CONNECTION dev show "$WIFI_INTERFACE" | cut -d: -f2)" 2>/dev/null | grep -q "802-11-wireless"
}

if is_hotspot_active; then
    printf "󱜠 \n"
else
    printf "󱜡 \n"
fi
