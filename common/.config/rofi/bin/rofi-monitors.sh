#!/usr/bin/env bash
source "$HOME/.config/rofi/bin/dependencies/rofi-core.sh"

INTERNAL="eDP-1"
EXT_HDMI="HDMI-A-1"
EXT_DP="DP-1"
STATE_FLAG="/tmp/monitor-off-flag"
ROTATED_FLAG="/tmp/monitor-rotated-flag"

LAPTOP_ONLY=" Only Laptop"
EXT_ONLY="󰍹 Only External"
ROTATE=" Swap to Vertical"
TOGGLE_ON_OF="󰶐 All Off"

rofi_cmd() {
    rofi_core -w "21ch" -mesg "Select an option:" -N -c 'textbox{ padding: 5px;}'
}

if [ -f "$ROTATED_FLAG" ]; then
    ROTATE=" Swap to Horizontal"
fi
if [ -f "$STATE_FLAG" ]; then
    TOGGLE_ON_OF="󰍺 All On"
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
    local CONFIG_FILE="$HOME/.config/niri/config.kdl"
    local FIELD="HDMI-A-1"
    local PROPERTY="transform \"90\""
    local SCRIPT="$HOME/.config/niri/bin/niri_prop_toggle.py"

    python3 "$SCRIPT" "$CONFIG_FILE" "$FIELD" "$PROPERTY"
}

options="$LAPTOP_ONLY\n$EXT_ONLY\n$TOGGLE_ON_OF\n$ROTATE"
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
"$TOGGLE_ON_OF")
    if [ -f "$STATE_FLAG" ]; then
        monitor_toggle_cmd "$EXT_HDMI" "$COMPOSITOR" on
        monitor_toggle_cmd "$EXT_DP" "$COMPOSITOR" on
        monitor_toggle_cmd "$INTERNAL" "$COMPOSITOR" on
        rm -f "$STATE_FLAG"
    else
        monitor_toggle_cmd "$EXT_HDMI" "$COMPOSITOR" off
        monitor_toggle_cmd "$EXT_DP" "$COMPOSITOR" off
        monitor_toggle_cmd "$INTERNAL" "$COMPOSITOR" off
        touch "$STATE_FLAG"
    fi
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
