#!/usr/bin/env bash
set -euo pipefail

# The idea for this program is to make it so that I call the program from a keybind with some argument lets say "I up the volume with the special key", well instead
# of just upping the volume, it will send a notification with the volume.

is_number() {
    local TEST=$1
    if [[ ! $TEST =~ ^[0-9]+$ ]]; then
        return 1
    else
        return 0
    fi
}
# I'm getting kinda used to this
get_volume() {
    wpctl get-volume "@DEFAULT_AUDIO_SINK@" |
        awk ' { volume =$2; printf "%d\n", volume * 100}'
}
get_brightness() {
    # Claude Cooked
    # brightnessctl -m gives a machine readable version
    brightnessctl -m | cut -d',' -f4 | tr -d '%'

    # Mi version
    # brightnessctl  awk '{percentaje=$4; printf "%s\n", percentaje}' | grep -v class | tr -d '()' | tr -d '%' | tr -d '\n'
}
get_volume_icon() {
    local VOLUME=$1
    if ((VOLUME == 0)); then
        echo " "
    elif ((VOLUME <= 40)); then
        echo " "
    elif ((VOLUME > 40)); then
        echo " "
    fi
}
get_brightness_icon() {
    local BRIGHTNESS=$1
    if ((BRIGHTNESS <= 10)); then
        echo ""
    elif ((BRIGHTNESS <= 20)); then
        echo ""
    elif ((BRIGHTNESS <= 30)); then
        echo ""
    elif ((BRIGHTNESS <= 40)); then
        echo ""
    elif ((BRIGHTNESS <= 50)); then
        echo ""
    elif ((BRIGHTNESS <= 60)); then
        echo ""
    elif ((BRIGHTNESS <= 70)); then
        echo ""
    elif ((BRIGHTNESS <= 85)); then
        echo ""
    else
        echo ""
    fi
}

get_battery_icon() {
    local BATTERY=$1
    if ((BATTERY <= 15)); then
        echo "󰁻"

    elif ((BATTERY <= 25)); then
        echo "󰁼"
    elif ((BATTERY <= 50)); then
        echo "󰁾"
    elif ((BATTERY <= 75)); then
        echo "󰂀"
    elif ((BATTERY <= 90)); then
        echo "󰂂"
    else
        echo "󰁹"
    fi

}
send_notification_feedback() {
    local FLAG=$1
    local NUMBER
    local NUMBER_ICON
    local GET_FUNCTION
    case $FLAG in
    "brightness")
        GET_FUNCTION="get_brightness"
        ;;
    "volume")
        GET_FUNCTION="get_volume"
        ;;
    *) ;;
    esac

    NUMBER=$("$GET_FUNCTION")
    if ! is_number "$NUMBER"; then
        # Send a notification on format error. No need to fall to fallback.
        notify-send "Format error" "Check what $GET_FUNCTION function is returning: $NUMBER\nScript is on: ${BASH_SOURCE[0]}" -t 5000 -r 999
        exit 0
    fi
    # Icon functions are just function_icon
    ICON_FUNCTION=$GET_FUNCTION"_icon"
    NUMBER_ICON=$("$ICON_FUNCTION" "$NUMBER")
    notify-send "$NUMBER_ICON  $NUMBER%" -t 1000 -r 999
}

case "$1" in
volume_up)
    # --limit 1.0 limits volume to 100%
    wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 5%+
    send_notification_feedback volume
    ;;
volume_down)
    wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 5%-
    send_notification_feedback volume
    ;;
volume_mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    if wpctl get-volume "@DEFAULT_AUDIO_SINK@" | grep MUTED; then
        notify-send " " -t 1000 -r 999
    else
        notify-send " " -t 1000 -r 999
    fi
    ;;
mic_mute)
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    if wpctl get-volume "@DEFAULT_AUDIO_SOURCE@" | grep MUTED; then
        notify-send "󰍭" -t 1000 -r 999
    else
        notify-send "󰍬" -t 1000 -r 999
    fi
    ;;
brightness_up)
    brightnessctl s 5.0%+
    send_notification_feedback brightness
    ;;
brightness_down)
    brightnessctl s 5.0%-
    send_notification_feedback brightness
    ;;
*)
    # How did we get here?
    notify-send "This shouldn't happen" "I guess your bind is wrong my guy.\nThe argument: $1 isn't recognized check for typos."
    exit 1
    ;;
esac

# Uncomment for checks
#get_volume
#get_brightness
