#!/usr/bin/env bash

# Simple idea, giventh some dirs, return a
# name list that then can be opened via sioyek process
# we want to open epub and pdf from Documents, Library

ROFI_CORE="$HOME/.config/rofi/bin/dependencies/rofi-core.sh"
SEARCH_DIRS=(
  "$HOME/Documents"
  "$HOME/Library"
)

if [[ -f "$ROFI_CORE" ]]; then
  source "$ROFI_CORE"
else
  echo "Error: No se encontró rofi-core.sh en $ROFI_CORE" >&2
  exit 1
fi

DOCS=$(
  fd -e pdf -e epub . "${SEARCH_DIRS[@]}" 2>/dev/null | awk -F'/' '{
        full_path = $0
        filename = $NF
        parent_dir = $(NF-1)

        display_name = substr(filename, 1, 30)

        print display_name "\t\t\t " parent_dir "\t" full_path
    }' | column -t -s $'\t'
)

[[ -z "$DOCS" ]] && exit 1

SELECTED=$(printf '%s\n' "$DOCS" | rofi_core -w "40%" -p "Docs:")

if [[ -n "$SELECTED" ]]; then
  REAL_PATH=$(echo "$SELECTED" | awk -F '  +' '{print $NF}')
  sioyek "$REAL_PATH" &>/dev/null &
  disown
fi
