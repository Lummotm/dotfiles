#!/usr/bin/env bash

ROFI_CORE="$HOME/bin/pickers/dependencies/core.sh"
SEARCH_DIRS=(
  "$HOME/Documents/University/current-course/"
  "$HOME/Library"
)

if [[ -f "$ROFI_CORE" ]]; then
  source "$ROFI_CORE"
else
  echo "Error: No se encontró rofi-core.sh en $ROFI_CORE" >&2
  exit 1
fi

SEARCH_DIRS_JOINED=$(
  IFS=:
  echo "${SEARCH_DIRS[*]}"
)

DOCS=$(
  fd -L -e pdf -e epub . "${SEARCH_DIRS[@]}" 2>/dev/null | awk -v search_dirs="$SEARCH_DIRS_JOINED" -F'/' '{
        full_path = $0
        filename = $NF
        
        n_dirs = split(search_dirs, dirs, ":")
        rel_path = full_path
        
        for (i=1; i<=n_dirs; i++) {
            d = dirs[i]
            gsub(/\/+$/, "", d)
            if (index(full_path, d "/") == 1) {
                rel_path = substr(full_path, length(d) + 2)
                break
            }
        }

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

        if (dir_path == "") dir_path = "."

        print short_name "\t " dir_path "\t                                        \t///" full_path
    }' | column -t -s $'\t'
)

if [[ -z "$DOCS" ]]; then
  exit 1
fi

SELECTED=$(printf '%s\n' "$DOCS" | rofi_core -w "40%" -p "Docs:")

if [[ -n "$SELECTED" ]]; then
  RAW_PATH="${SELECTED#*///}"

  if [[ -n "$RAW_PATH" ]]; then
    REAL_PATH=$(realpath "$RAW_PATH" 2>/dev/null || readlink -f "$RAW_PATH" 2>/dev/null)

    if [[ -n "$REAL_PATH" && -f "$REAL_PATH" ]]; then
      EXTENSION="${REAL_PATH##*.}"

      # Convierte la extensión a minúsculas por seguridad y comprueba el tipo
      if [[ "${EXTENSION,,}" == "epub" ]]; then
        foliate "$REAL_PATH" &>/dev/null &
      elif [[ "${EXTENSION,,}" == "pdf" ]]; then
        zathura "$REAL_PATH" &>/dev/null &
      fi

      disown
    fi
  fi
fi
