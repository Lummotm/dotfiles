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
  fd -L -e pdf -e epub . "${SEARCH_DIRS[@]}" 2>/dev/null | awk -v search_dirs="${SEARCH_DIRS[*]}" -F'/' '{
        full_path = $0
        filename = $NF
        
        # Identificamos la ruta base correspondiente y la recortamos
        n_dirs = split(search_dirs, dirs, " ")
        rel_path = full_path
        
        for (i=1; i<=n_dirs; i++) {
            d = dirs[i]
            gsub(/\/+$/, "", d)
            if (index(full_path, d "/") == 1) {
                rel_path = substr(full_path, length(d) + 2)
                break
            }
        }

        # Construimos la ruta de carpetas relativa excluyendo el archivo final
        n_parts = split(rel_path, parts, "/")
        dir_path = ""
        for (j=1; j<n_parts; j++) {
            dir_path = (j==1) ? parts[j] : dir_path "/" parts[j]
        }

        chars = 35
        if (length(filename) > chars) {
            short_name = substr(filename, 1, chars) "…"
        } else {
            short_name = filename
        }

        # Si el archivo está directamente en la raíz de la búsqueda
        if (dir_path == "") dir_path = "."

        # Guardamos la ruta completa (full_path) en el delimitador '///'
        print short_name "\t " dir_path "\t                                        \t///" full_path
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
