#!/usr/bin/env bash

EXTERNAL="HDMI-A-1"
EXTERNAL_2="DP-1" # EXTERNAL ON DESKTOP
INTERNAL="eDP-1"  # Laptop
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
        if niri msg --json outputs | grep -q $EXTERNAL; then
            monitor_toggle_cmd $INTERNAL "$COMPOSITOR" off
        fi
    fi
    if [[ "$COMPOSITOR" == "hyprland" ]]; then
        if hyprctl monitors | grep -q $EXTERNAL; then
            monitor_toggle_cmd $INTERNAL "$COMPOSITOR"
        fi
    fi
else
    if [[ -e "$STATE_FILE" ]]; then
        monitor_toggle_cmd $INTERNAL "$COMPOSITOR" on
        monitor_toggle_cmd $EXTERNAL "$COMPOSITOR" on
        monitor_toggle_cmd $EXTERNAL_2 "$COMPOSITOR" on
        rm "$STATE_FILE"
    else
        notify-send "Turning off monitors in 3 seconds"
        sleep 3
        monitor_toggle_cmd $INTERNAL "$COMPOSITOR" off
        monitor_toggle_cmd $EXTERNAL "$COMPOSITOR" off
        monitor_toggle_cmd $EXTERNAL_2 "$COMPOSITOR" off
        touch "$STATE_FILE"
    fi
fi
