#!/usr/bin/env bash

CARRIER_FILE="/sys/class/net/enp4s0f3u1c2/carrier"

if [ -f "$CARRIER_FILE" ] && [ "$(cat "$CARRIER_FILE")" == "1" ]; then
    nmcli device wifi hotspot ifname wlan0 ssid ThinkingRock band bg password ThinkingRock123 && nmcli dev wifi show-password
else
    echo "Ethernet not connected"
    exit 0
fi
