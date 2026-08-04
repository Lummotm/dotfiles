#!/usr/bin/env bash

# Simple idea, given some dirs, return a name list that
# then can be opened via sioyek process we want to open
# epub and pdf from Documents, Library

ROFI_CORE="$HOME/bin/pickers/dependencies/core.sh"
SEARCH_DIRS=(
  "$HOME/Documents"
  "$HOME/Library"
)

if ! command -v sioyek &>/dev/null; then
  echo "Sioyek no está instalado. Instalando mediante yay..."

  if command -v yay &>/dev/null; then
    yay -S --noconfirm sioyek || {
      echo "Error: Falló la instalación de Sioyek con yay." >&2
      exit 1
    }
  else
    echo "Error: 'sioyek' no está instalado y tampoco se encontró 'yay'." >&2
    exit 1
  fi
fi

if [[ -f "$ROFI_CORE" ]]; then
  source "$ROFI_CORE"
else
  echo "Error: No se encontró rofi-core.sh en $ROFI_CORE" >&2
  exit 1
fi

DOCS=$(
  fd -e pdf -e epub . "${SEARCH_DIRS[@]}" 2>/dev/null | awk -F'/' '{
        filename = $NF
        parent_dir = $(NF-1)
        chars = 35

        if (length(filename) > chars) {
            short_name = substr(filename, 1, chars) "…"
        } else {
            short_name = filename
        }

        print short_name "\t " parent_dir "\t                                        \t///" parent_dir "///" filename
    }' | column -t -s $'\t'
)

[[ -z "$DOCS" ]] && exit 1

SELECTED=$(printf '%s\n' "$DOCS" | rofi_core -w "40%" -p "Docs:")

if [[ -n "$SELECTED" ]]; then
  PARENT_DIR=$(echo "$SELECTED" | awk -F'///' '{print $2}')
  FILENAME=$(echo "$SELECTED" | awk -F'///' '{print $3}')

  REAL_PATH=$(fd -F "$FILENAME" "${SEARCH_DIRS[@]}" 2>/dev/null | grep -F "/$PARENT_DIR/$FILENAME" | head -n 1)

  if [[ -n "$REAL_PATH" && -f "$REAL_PATH" ]]; then
    sioyek "$REAL_PATH" &>/dev/null &
    disown
  fi
fi
