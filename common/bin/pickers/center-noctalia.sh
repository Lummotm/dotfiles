#!/usr/bin/env bash
# center-noctalia.sh - hub de pickers para el launcher de Noctalia.
#
#   center-noctalia.sh --list      imprime las opciones, una por linea
#   center-noctalia.sh "<opcion>"  ejecuta la opcion (Noctalia pasa {selection})
#   center-noctalia.sh             menu interactivo (fallback rofi/tofi)

source "$HOME/bin/pickers/dependencies/core.sh"

P="$HOME/bin/pickers"

pick_color() { yad --color --title="Selector" | wl-copy; }

# Orden de la lista y comando asociado a cada opcion
ORDER=(Audio Network Monitor Brightness Killer Mount "Color Picker" Icons Notes Documents)
declare -A ACTIONS=(
  [Audio]="$P/audio.sh"
  [Network]="$P/ronema/network.sh"
  [Monitor]="$P/monitors.sh"
  [Brightness]="$P/brightness.sh"
  [Killer]="$P/process-killer.sh"
  [Mount]="$P/mount.sh"
  ["Color Picker"]=pick_color
  [Icons]="$P/nerd-icons.sh"
  [Notes]="$P/notes.sh"
  [Documents]="$P/document-opener.sh"
)

# Charge Mode: solo en portatil enchufado
if compgen -G "/sys/class/power_supply/BAT*" >/dev/null &&
  [[ $(cat /sys/class/power_supply/AC0/online 2>/dev/null) == 1 ]]; then
  ORDER+=("Charge Mode")
  ACTIONS["Charge Mode"]="$HOME/bin/sys/battery-mode-check.sh"
fi

trim() {
  local s="${1#"${1%%[![:space:]]*}"}"
  printf '%s' "${s%"${s##*[![:space:]]}"}"
}

if [[ "$1" == "--list" ]]; then
  printf '%s\n' "${ORDER[@]}"
  exit 0
fi

if [[ -n "$1" ]]; then
  choice=$(trim "$1")
  export PICKER_ENGINE="${PICKER_ENGINE:-noctalia}"
else
  export PICKER_ENGINE="${PICKER_ENGINE:-rofi}"
  choice=$(printf '%s\n' "${ORDER[@]}" | rofi_core -w "35ch" -p "Select Menu:")
  choice=$(trim "$choice")
fi

[[ -n "${ACTIONS[$choice]}" ]] && "${ACTIONS[$choice]}"
