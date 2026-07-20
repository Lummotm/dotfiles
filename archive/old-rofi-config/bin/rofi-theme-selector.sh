#!/usr/bin/env bash

THEMES_DIR="$HOME/dotfiles/themes"
THEME_SELECTOR="$HOME/bin/ui/theme-selector.sh"

source "$HOME/.config/rofi/bin/dependencies/rofi-core.sh"

if [ ! -d "$THEMES_DIR" ]; then
    notify-send "Error" "No se encontró el directorio de temas."
    exit 1
fi

themes_list=$(find "$THEMES_DIR" -maxdepth 1 -mindepth 1 -type d -printf '%f\n')

CHOICE=$(echo "$themes_list" | rofi_core -w "30ch" -p "󰏘 Tema:" -c 'listview {lines: 6;}')

if [[ -n "$CHOICE" ]]; then
    "$THEME_SELECTOR" --theme "$CHOICE"
fi
