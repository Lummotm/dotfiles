#!/usr/bin/env bash
EXTERNAL="HDMI-A-1"
EXTERNAL_2="DP-1"
INTERNAL="eDP-1"
STATE_FILE="/tmp/monitor-off-flag"

monitor_toggle_cmd() {
    monitor=$1
    compositor=$2
    state=$3

    if [[ "$compositor" == "niri" ]]; then
        niri msg output "$monitor" "$state"
    elif [[ "$compositor" == "hyprland" ]]; then
        if [[ "$state" == "off" ]]; then
            hyprctl keyword monitor "$monitor, disable"
        else
            hyprctl keyword monitor "$monitor, preferred, auto, 1"
        fi
    fi
}

if [[ -n "$(pgrep niri-session)" ]]; then
    COMPOSITOR="niri"
elif [[ -n "$(pgrep hyprland)" ]]; then
    COMPOSITOR="hyprland"
fi

if [[ "$1" == "startup" ]]; then
    if [[ "$COMPOSITOR" == "niri" ]]; then
        if niri msg --json outputs | grep -q "$EXTERNAL"; then
            monitor_toggle_cmd $INTERNAL "$COMPOSITOR" off
        fi
    fi
    if [[ "$COMPOSITOR" == "hyprland" ]]; then
        if hyprctl monitors | grep -q "$EXTERNAL"; then
            monitor_toggle_cmd $INTERNAL "$COMPOSITOR" off
        fi
    fi
else
    # Verifica si hay al menos un monitor con "logical" (encendido)
    if [[ "$COMPOSITOR" == "niri" ]]; then
        if niri msg --json outputs | grep -q '"logical"'; then
            niri msg action power-off-monitors
        fi
    fi
fi
