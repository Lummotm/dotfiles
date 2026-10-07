#!/usr/bin/env bash
source "$HOME/bin/pickers/dependencies/core.sh"

rofi_cmd() {
  rofi_core -w "30%" -p "Clipboard:" "$@"
}

cliphist list | rofi_cmd | cliphist decode | wl-copy
