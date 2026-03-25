#!/usr/bin/env bash
source "$HOME/.config/rofi/bin/dependencies/rofi-core.sh"

rofi_cmd() {
    # Desactivo la opcion de aceptado alterno (que devuelve 0)
    # Activo esta que devuelve 1
    rofi_core -w "30ch" \
        -N -c 'textbox{ padding: 5px;}' \
        -c 'listview {lines: 5; columns:2;}' \
        -sort \
        -kb-accept-alt "" \
        -kb-custom-1 "Shift+Return"\
        # -mesg "Select a menu:" \
}

ROFI_DIR="$HOME/.config/rofi/bin"

OPT_AUDIO="  Audio"
OPT_NET=" 󰛳 Network"
OPT_MONITOR=" 󰍹 Monitor"
OPT_BLUETOOTH="  Bluetooth"
OPT_WALL=" 󰸉 Wallpaper"
OPT_THEME=" 󰴱 Theme"
OPT_POWER=" ⏻ Power"
OPT_CALC="  Calc"
OPT_MOUNT="  Mount"
OPT_KILL="  Killer"

# Implento logica de selcción diferente para lanzar wallapaper random en shift + enter
CHOICE=$(echo -e "$OPT_AUDIO\n$OPT_NET\n$OPT_BLUETOOTH\n$OPT_MONITOR\n$OPT_WALL\n$OPT_THEME\n$OPT_KILL\n$OPT_CALC\n$OPT_MOUNT\n$OPT_POWER" | rofi_cmd)
EXIT_CODE=$?

[[ -z "$CHOICE" ]] && exit 0

if [[ "$EXIT_CODE" -eq 10 ]]; then
    MODE="RANDOM"
else
    MODE=""
fi

case "$CHOICE" in
"$OPT_AUDIO") "$ROFI_DIR/rofi-audio.sh" ;;
"$OPT_NET") "$ROFI_DIR/ronema/rofi-network.sh" ;;
"$OPT_BLUETOOTH") "$ROFI_DIR/rofi-bluetooth.sh" ;;
"$OPT_MONITOR") "$ROFI_DIR/rofi-monitors.sh" ;;
"$OPT_WALL")
    if [[ "$MODE" == "RANDOM" ]]; then
        "$HOME/bin/ui/wallpaper-randomizer.sh"
    else
        # "$ROFI_DIR/wallpaper-selector/rofi-wallpaper.sh"
        "$ROFI_DIR/bgselector/bgselector"
    fi
    ;;
"$OPT_THEME") "$ROFI_DIR/rofi-theme-selector.sh";;
"$OPT_KILL") "$ROFI_DIR/rofi-process-killer.sh" ;;
"$OPT_POWER") "$ROFI_DIR/powermenu/rofi-power.sh" ;;
"$OPT_CALC") "$ROFI_DIR/rofi-calc.sh" ;;
"$OPT_MOUNT") "$ROFI_DIR/rofi-mount.sh" ;;
esac
