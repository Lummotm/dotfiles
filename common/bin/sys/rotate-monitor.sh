#!/usr/bin/env bash
set -euo pipefail

FLAG=/tmp/rotated-monitor
MONITOR=DP-1

if [[ -f "$FLAG" ]]; then
    rm "$FLAG"
    hyprctl keyword monitor "$MONITOR",preferred,auto,1,transform,1
else

    touch "$FLAG"
    hyprctl keyword monitor "$MONITOR",preferred,auto,1,transform,0
fi
