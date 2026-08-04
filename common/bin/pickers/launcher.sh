#!/usr/bin/env bash
source "$HOME/bin/pickers/dependencies/core.sh"

ENGINE="${ROFI_ENGINE:-rofi}"

if [[ "$ENGINE" == "tofi" ]]; then
  APP_DIRS=(
    "$HOME/.local/share/applications"
    "/usr/share/applications"
    "/usr/local/share/applications"
  )

  # 1. Buscamos todos los .desktop (siguiendo symlinks)
  # 2. Leemos la primera línea Name= de cada archivo
  # 3. Formateamos la lista con un delimitador limpio " :: " para evitar alertas en awk
  DESKTOP_LIST=$(find -L "${APP_DIRS[@]}" -type f -name "*.desktop" 2>/dev/null | awk -F'/' '
    {
        file = $0
        name = ""
        while ((getline line < file) > 0) {
            if (line ~ /^Name=/ && name == "") {
                sub(/^Name=/, "", line)
                name = line
            }
        }
        close(file)
        if (name != "") {
            print name " :: " file
        }
    }' | sort -u)

  # Lanzar Tofi en modo dmenu
  SELECTION=$(echo "$DESKTOP_LIST" | tofi --prompt-text "Apps: ")

  if [[ -n "$SELECTION" ]]; then
    # Extraer la ruta completa que está después de " :: "
    DESKTOP_FILE="${SELECTION#* :: }"

    # gio launch abre directamente cualquier .desktop pasando la ruta absoluta
    if command -v gio &>/dev/null; then
      setsid gio launch "$DESKTOP_FILE" >/dev/null 2>&1 &
    else
      # Fallback usando gtk-launch
      basename_file=$(basename "$DESKTOP_FILE")
      setsid gtk-launch "$basename_file" >/dev/null 2>&1 &
    fi
  fi
else
  rofi_core -m "drun" -w "25ch" -i -c "listview {lines:8;}"
fi
