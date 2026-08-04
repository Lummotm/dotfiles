#!/usr/bin/env bash
source "$HOME/bin/pickers/dependencies/core.sh"

CONFIG_STR="$HOME/dotfiles/common/.config/niri/monitors.kdl"
PY_TOGGLE="$HOME/.config/niri/bin/niri_prop_toggle.py"

INTERNAL="eDP-1"
EXT_HDMI="HDMI-A-1"
EXT_DP="DP-1"
STATE_FLAG="/tmp/monitor-off-flag"
ROTATED_FLAG="/tmp/monitor-rotated-flag"

LAPTOP_ONLY=" Only Laptop"
EXT_ONLY="󰍹 Only External"
ROTATE=" Swap to Vertical"
TOGGLE_OFF="󰶐 All Off"
TOGGLE_ON="󰍺 All On"

rofi_cmd() {
    rofi_core -w "21ch" -mesg "Select an option:" -N -c 'textbox{ padding: 5px;}'
}

if [ -f "$ROTATED_FLAG" ]; then
    ROTATE=" Swap to Horizontal"
fi

if grep -q '^include "monitor-modes/external-right.kdl"' "$CONFIG_STR"; then
    SIDE_TOGGLE="󰹑 External Left"
else
    SIDE_TOGGLE="󰹈 External Right"
fi

if [[ -n "$(pgrep niri-session)" ]]; then
    COMPOSITOR="niri"
elif [[ -n "$(pgrep hyprland)" ]]; then
    COMPOSITOR="hyprland"
fi

monitor_toggle_cmd() {
    local monitor=$1
    local compositor=$2
    local state=$3

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

monitor_rotate() {
    local FIELD="HDMI-A-1"
    local PROPERTY="transform \"90\""

    python3 "$PY_TOGGLE" "$CONFIG_STR" "$FIELD" "$PROPERTY"
}

options="$LAPTOP_ONLY\n$EXT_ONLY\n$TOGGLE_ON\n$TOGGLE_OFF\n$ROTATE\n$SIDE_TOGGLE"
selected=$(echo -e "$options" | rofi_cmd)

case "$selected" in
"$LAPTOP_ONLY")
    monitor_toggle_cmd "$INTERNAL" "$COMPOSITOR" on
    monitor_toggle_cmd "$EXT_HDMI" "$COMPOSITOR" off
    monitor_toggle_cmd "$EXT_DP" "$COMPOSITOR" off
    rm -f "$STATE_FLAG"
    ;;
"$EXT_ONLY")
    monitor_toggle_cmd "$EXT_HDMI" "$COMPOSITOR" on
    monitor_toggle_cmd "$EXT_DP" "$COMPOSITOR" on
    monitor_toggle_cmd "$INTERNAL" "$COMPOSITOR" off
    rm -f "$STATE_FLAG"
    ;;
"$TOGGLE_ON")
    monitor_toggle_cmd "$EXT_HDMI" "$COMPOSITOR" on
    monitor_toggle_cmd "$EXT_DP" "$COMPOSITOR" on
    monitor_toggle_cmd "$INTERNAL" "$COMPOSITOR" on
    ;;
"$TOGGLE_OFF")
    niri msg action power-off-monitors
    ;;
"$SIDE_TOGGLE")
    python3 "$PY_TOGGLE" "$CONFIG_STR" "monitor-modes/external-right.kdl" "include"
    python3 "$PY_TOGGLE" "$CONFIG_STR" "monitor-modes/external-left.kdl" "include"
    niri msg action reload-config
    ;;
"$ROTATE")
    if [ -f "$ROTATED_FLAG" ]; then
        monitor_rotate
        rm "$ROTATED_FLAG"
    else
        monitor_rotate
        touch "$ROTATED_FLAG"
    fi
    if niri msg outputs | grep -qE "($EXT_HDMI|$EXT_DP)"; then
        sleep 1
        monitor_toggle_cmd "$INTERNAL" "$COMPOSITOR" off
    fi
    ;;
esac
