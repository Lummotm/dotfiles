#!/usr/bin/env bash
source "$HOME/bin/pickers/dependencies/core.sh"

COLUMNS=2
LINES=5
CHARS="35ch"

# 1. Exportar ROFI_ENGINE para que todos los scripts hijos lo hereden por defecto
export ROFI_ENGINE="${ROFI_ENGINE:-rofi}"

# 2. rofi_cmd unificado que usa rofi_core (compatible tanto con rofi como con tofi)
rofi_cmd() {
  rofi_core -w "$CHARS" \
    -N -c 'textbox{ padding: 5px;}' \
    -c "listview {lines: $LINES; columns:$COLUMNS;}" \
    -sort \
    -kb-accept-alt "" \
    -kb-custom-1 "Shift+Return"
}

PICKERS_DIR="$HOME/bin/pickers"

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
OPT_DOCUMENTS=" 󱔗 Documents"

# Detección de batería
for bat in /sys/class/power_supply/BAT*; do
  if [[ -d "$bat" ]]; then
    if [[ -f /sys/class/power_supply/AC0/online ]] && [[ $(cat /sys/class/power_supply/AC0/online) == 1 ]]; then
      OPT_CHARGING_MODE="  Charge Mode"
    fi
    break
  fi
done

# 3. Lanzar el menú usando rofi_cmd (ahora respeta ROFI_ENGINE)
CHOICE=$(echo -e "$OPT_AUDIO\n$OPT_NET\n$OPT_BLUETOOTH\n$OPT_MONITOR\n$OPT_BRIGHTNESS\n$OPT_WALL\n$OPT_THEME\n$OPT_KILL\n$OPT_MOUNT\n$OPT_POWER\n$OPT_COLORS\n$OPT_ICONS\n$OPT_CALC\n$OPT_HOTKEYS\n$OPT_CHARGING_MODE\n$OPT_MUSIC\n$OPT_NOTES\n$OPT_DOCUMENTS" | rofi_cmd)
EXIT_CODE=$?

[[ -z "$CHOICE" ]] && exit 0

# En Rofi: Shift+Enter activa custom-1 (exit code 10).
# En Tofi: Alt+Enter es el accept-custom por defecto (exit code 10).
if [[ "$EXIT_CODE" -eq 10 ]]; then
  MODE="ALTERNATIVE_MODE"
else
  MODE=""
fi

case "$CHOICE" in
"$OPT_AUDIO") "$PICKERS_DIR/audio.sh" ;;
"$OPT_NET") "$PICKERS_DIR/ronema/ronema/network.sh" ;;
"$OPT_BLUETOOTH") "$PICKERS_DIR/bluetooth.sh" ;;
"$OPT_MONITOR") "$PICKERS_DIR/monitors.sh" ;;
"$OPT_BRIGHTNESS") "$PICKERS_DIR/brightness.sh" ;;
"$OPT_WALL")
  if [[ "$MODE" == "ALTERNATIVE_MODE" ]]; then
    bash "$HOME/bin/ui/wallpaper-randomizer.sh" "--score"
  else
    "$PICKERS_DIR/bgselector/bg.sh"
  fi
  ;;
"$OPT_THEME") "$PICKERS_DIR/theme-selector.sh" ;;
"$OPT_KILL") "$PICKERS_DIR/process-killer.sh" ;;
"$OPT_POWER") "$PICKERS_DIR/powermenu/powermenu/power.sh" ;;
"$OPT_CALC") "$PICKERS_DIR/calc.sh" ;;
"$OPT_ICONS") "$PICKERS_DIR/nerd-icons.sh" ;;
"$OPT_COLORS")
  yad --color --title="Selector" | wl-copy
  ;;
"$OPT_CHARGING_MODE")
  "$HOME/bin/sys/battery-mode-check.sh"
  ;;
"$OPT_MOUNT") "$PICKERS_DIR/mount.sh" ;;
"$OPT_HOTKEYS")
  "$HOME/.config/niri/bin/show_binds" "$HOME/dotfiles/common/.config/niri/keybinds.kdl"
  ;;
"$OPT_MUSIC") "$PICKERS_DIR/music" ;;
"$OPT_NOTES") "$PICKERS_DIR/notes.sh" ;;
"$OPT_DOCUMENTS") "$PICKERS_DIR/sioyek-document-opener.sh" ;;
esac
