#!/usr/bin/env bash

# Archivo de registro para depuración
DEBUG_LOG="/tmp/sioyek_opener_debug.log"
echo "=== Nueva ejecución: $(date) ===" >"$DEBUG_LOG"

debug() {
  echo "[DEBUG] $1" >>"$DEBUG_LOG"
}

debug "Script iniciado."

ROFI_CORE="$HOME/bin/pickers/dependencies/core.sh"
SEARCH_DIRS=(
  "$HOME/Documents/University/current-course/"
  "$HOME/Library"
)

debug "Directorios de búsqueda configurados: ${SEARCH_DIRS[*]}"

if ! command -v sioyek &>/dev/null; then
  debug "Sioyek no encontrado. Intentando instalar con yay..."
  echo "Sioyek no está instalado. Instalando mediante yay..."

  if command -v yay &>/dev/null; then
    yay -S --noconfirm sioyek || {
      debug "ERROR: Falló la instalación de Sioyek."
      echo "Error: Falló la instalación de Sioyek con yay." >&2
      exit 1
    }
    debug "Sioyek instalado correctamente."
  else
    debug "ERROR: Ni sioyek ni yay están instalados."
    echo "Error: 'sioyek' no está instalado y tampoco se encontró 'yay'." >&2
    exit 1
  fi
fi

if [[ -f "$ROFI_CORE" ]]; then
  debug "Cargando dependencias de rofi desde: $ROFI_CORE"
  source "$ROFI_CORE"
else
  debug "ERROR: No se encontró rofi-core.sh en $ROFI_CORE"
  echo "Error: No se encontró rofi-core.sh en $ROFI_CORE" >&2
  exit 1
fi

SEARCH_DIRS_JOINED=$(
  IFS=:
  echo "${SEARCH_DIRS[*]}"
)
debug "Generando lista de documentos con fd..."

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
  debug "ADVERTENCIA: No se encontraron documentos. Saliendo del script."
  exit 1
fi

debug "Documentos encontrados exitosamente. Abriendo Rofi..."

SELECTED=$(printf '%s\n' "$DOCS" | rofi_core -w "40%" -p "Docs:")

if [[ -n "$SELECTED" ]]; then
  debug "Selección de usuario capturada: $SELECTED"

  RAW_PATH="${SELECTED#*///}"
  debug "Ruta en bruto extraída (RAW_PATH): $RAW_PATH"

  if [[ -n "$RAW_PATH" ]]; then
    REAL_PATH=$(realpath "$RAW_PATH" 2>/dev/null || readlink -f "$RAW_PATH" 2>/dev/null)
    debug "Ruta real resuelta (REAL_PATH): $REAL_PATH"

    if [[ -n "$REAL_PATH" && -f "$REAL_PATH" ]]; then
      debug "Ejecutando: sioyek \"$REAL_PATH\""
      QT_QPA_PLATFORM=xcb sioyek "$REAL_PATH" &>/dev/null &
      disown
      debug "Sioyek lanzado correctamente."
    else
      debug "ERROR: REAL_PATH está vacío o el archivo no existe."
    fi
  else
    debug "ERROR: RAW_PATH está vacío tras la extracción."
  fi
else
  debug "Rofi cerrado sin selección de usuario."
fi
