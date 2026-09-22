#!/usr/bin/env bash

# Simple idea, given some dirs, return a name list that
# then can be opened via sioyek process we want to open
# epub and pdf from Documents, Library

ROFI_CORE="$HOME/bin/pickers/dependencies/core.sh"
SEARCH_DIRS=(
  "$HOME/Documents/University/current-course/"
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
  fd -L -e pdf -e epub . "${SEARCH_DIRS[@]}" 2>/dev/null | awk -F'/' '{
        full_path = $0
        filename = $NF
        parent_dir = $(NF-1)
        chars = 35

        if (length(filename) > chars) {
            short_name = substr(filename, 1, chars) "…"
        } else {
            short_name = filename
        }

        # Guardamos la ruta completa (full_path) en el delimitador '///'
        print short_name "\t " parent_dir "\t                                        \t///" full_path
    }' | column -t -s $'\t'
)

[[ -z "$DOCS" ]] && exit 1

SELECTED=$(printf '%s\n' "$DOCS" | rofi_core -w "40%" -p "Docs:")

if [[ -n "$SELECTED" ]]; then
  # Extraemos la ruta completa del elemento seleccionado
  RAW_PATH=$(echo "$SELECTED" | awk -F'///' '{print $2}' | xargs)

  if [[ -n "$RAW_PATH" ]]; then
    # Resolvemos el symlink a la ruta real ejecutable/legible por Sioyek
    REAL_PATH=$(realpath "$RAW_PATH" 2>/dev/null || readlink -f "$RAW_PATH" 2>/dev/null)

    if [[ -n "$REAL_PATH" && -f "$REAL_PATH" ]]; then
      sioyek "$REAL_PATH" &>/dev/null &
      disown
    fi
  fi
fi
