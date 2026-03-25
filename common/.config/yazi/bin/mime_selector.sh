#!/usr/bin/env bash
FILE="$1"
MODE="$2"

PYTHON_SCRIPT="$HOME/.config/yazi/bin/get_mimeapps.py"
FZF_CMD="fzf --margin 25%,25% --border --layout=reverse --prompt='App: '"

case "$MODE" in
"set")
    # Listar apps y guardar la seleccionada como default
    SELECTED=$(python3 "$PYTHON_SCRIPT" --list "$FILE" | eval "$FZF_CMD")
    if [ -n "$SELECTED" ]; then
        APP_ID=$(echo "$SELECTED" | grep -oP '\(\K[^)]+')
        RESULT=$(python3 "$PYTHON_SCRIPT" --set "$APP_ID" "$FILE")
        notify-send "MimeApps" "$RESULT" -t 2000
    fi
    # Copiar la nueva versión a mis dotfiles
    cp ~/.config/mimeapps.list ~/dotfiles/extra/mimeapps.list || true
    ;;
"open")
    # Listar apps y abrir el archivo una sola vez
    SELECTED=$(python3 "$PYTHON_SCRIPT" --list "$FILE" | eval "$FZF_CMD")
    if [ -n "$SELECTED" ]; then
        APP_ID=$(echo "$SELECTED" | grep -oP '\(\K[^)]+')
        gtk-launch "$APP_ID" "$FILE" >/dev/null 2>&1 &
    fi
    ;;
*)
    echo "Uso: $0 <archivo> [set|open]"
    ;;
esac
