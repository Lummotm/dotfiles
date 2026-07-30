#!/usr/bin/env bash
source "$HOME/.config/rofi/bin/dependencies/rofi-core.sh"

COLUMNS=2
LINES=5
CHARS="35ch"

rofi_cmd() {
    # Desactivo la opcion de aceptado alterno (que devuelve 0)
    # Activo esta que devuelve 1
    rofi_core -w "$CHARS" \
        -N -c 'textbox{ padding: 5px;}' \
        -c "listview {lines: $LINES; columns:$COLUMNS;}" \
        -sort \
        -kb-accept-alt "" \
        -kb-custom-1 "Shift+Return"
}
ROFI_DIR="$HOME/.config/rofi/bin"

OPT_AUDIO="  Audio"
OPT_NET=" 󰛳 Network"
OPT_MONITOR=" 󰍹 Monitor"
OPT_BLUETOOTH="  Bluetooth"
OPT_BRIGHTNESS=" 󰃞 Brightness"
OPT_WALL=" 󰸉 Wallpaper"
OPT_THEME=" 󰴱 Theme"
OPT_POWER=" ⏻ Power"
OPT_CALC="  Calc"
OPT_MOUNT="  Mount"
OPT_KILL="  Killer"
OPT_ICONS="  Icons"
OPT_COLORS="  Color Picker"
OPT_HOTKEYS=" 󰧺 Binds/Hotkeys"
OPT_CHARGING_MODE=""
OPT_MUSIC="  Music"
OPT_NOTES=" 󰂺 Notes"

# Si encuentra al menos una bateria hay bateria
for bat in /sys/class/power_supply/BAT*; do
    if [[ -d "$bat" ]]; then

        if [[ -f /sys/class/power_supply/AC0/online ]] && [[ $(cat /sys/class/power_supply/AC0/online) == 1 ]]; then
            OPT_CHARGING_MODE="  Charge Mode"
        fi

        break
    fi
done

# Implento logica de selcción diferente para lanzar wallapaper random en shift + enter
CHOICE=$(echo -e "$OPT_AUDIO\n$OPT_NET\n$OPT_BLUETOOTH\n$OPT_MONITOR\n$OPT_BRIGHTNESS\n$OPT_WALL\n$OPT_THEME\n$OPT_KILL\n$OPT_MOUNT\n$OPT_POWER\n$OPT_COLORS\n$OPT_ICONS\n$OPT_CALC\n$OPT_HOTKEYS\n$OPT_CHARGING_MODE\n$OPT_MUSIC\n$OPT_NOTES" | rofi_cmd)
EXIT_CODE=$?

[[ -z "$CHOICE" ]] && exit 0

if [[ "$EXIT_CODE" -eq 10 ]]; then
    MODE="ALTERNATIVE_MODE"
else
    MODE=""
fi

case "$CHOICE" in
"$OPT_AUDIO") "$ROFI_DIR/rofi-audio.sh" ;;
"$OPT_NET") "$ROFI_DIR/ronema/rofi-network.sh" ;;
"$OPT_BLUETOOTH") "$ROFI_DIR/rofi-bluetooth.sh" ;;
"$OPT_MONITOR") "$ROFI_DIR/rofi-monitors.sh" ;;
"$OPT_BRIGHTNESS") "$ROFI_DIR/rofi-brightness.sh" ;;
"$OPT_WALL")
    if [[ "$MODE" == "ALTERNATIVE_MODE" ]]; then
        bash "$HOME/bin/ui/wallpaper-randomizer.sh" "--score"
    else
        # "$ROFI_DIR/wallpaper-selector/rofi-wallpaper.sh"
        "$ROFI_DIR/bgselector/rofi-bg.sh"
    fi
    ;;
"$OPT_THEME") "$ROFI_DIR/rofi-theme-selector.sh" ;;
"$OPT_KILL") "$ROFI_DIR/rofi-process-killer.sh" ;;
"$OPT_POWER") "$ROFI_DIR/powermenu/rofi-power.sh" ;;
"$OPT_CALC") "$ROFI_DIR/rofi-calc.sh" ;;
"$OPT_ICONS") "$ROFI_DIR/rofi-nerd-icons.sh" ;;
"$OPT_COLORS")
    yad --color --title="Selector" | wl-copy
    ;;
"$OPT_CHARGING_MODE")
    "$HOME/bin/sys/battery-mode-check.sh"
    ;;
"$OPT_MOUNT") "$ROFI_DIR/rofi-mount.sh" ;;
"$OPT_HOTKEYS")
    "$HOME/.config/niri/bin/show_binds" "$HOME/dotfiles/common/.config/niri/keybinds.kdl"
    ;;
"$OPT_MUSIC") "$ROFI_DIR/rofi-mpc" ;;
"$OPT_NOTES") "$ROFI_DIR/rofi-notes.sh" ;;
esac
