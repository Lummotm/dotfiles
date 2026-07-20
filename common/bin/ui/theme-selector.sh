#!/usr/bin/env bash
set -euo pipefail

THEMES_DIR="$HOME/dotfiles/themes"
STATE_DIR="$HOME/.cache/theme-selector"
MANIFEST="$STATE_DIR/manifest"
CURRENT_FILE="$STATE_DIR/current"

mkdir -p "$STATE_DIR"

die() {
    echo "Error: $*" >&2
    notify-send "Theme selector" "$*" 2>/dev/null || true
    exit 1
}

list_theme_files() {
    local theme="$1"
    local base="$THEMES_DIR/$theme/.config"
    [ -d "$base" ] || die "El tema '$theme' no tiene carpeta .config"
    find "$base" -type f -printf '%P\n' | sort
}

# Limpia symlinks huérfanos: compara el manifiesto actual (archivos del tema anterior)
# contra el listado del nuevo tema. Elimina solo los archivos que no están en el nuevo.
cleanup_stale() {
    local new_files="$1"
    [ -f "$MANIFEST" ] || return 0

    # comm -23 compara líneas únicas del archivo 1 (el manifiesto anterior)
    # y descarta las que coinciden con el archivo 2 (los archivos del tema actual).
    comm -23 <(sort "$MANIFEST") <(echo "$new_files") | while IFS= read -r rel; do
        [ -z "$rel" ] && continue
        local dst="$HOME/.config/$rel"

        # Verificación de seguridad: solo borramos si es un symlink apuntando a nuestra carpeta de temas.
        if [ -L "$dst" ]; then
            local target
            target="$(readlink -f "$dst" || true)"
            if [[ "$target" == "$THEMES_DIR"/* ]]; then
                rm -f "$dst"
                # Intentamos limpiar directorios vacíos tras borrar el symlink.
                rmdir -p --ignore-fail-on-non-empty "$(dirname "$dst")" 2>/dev/null || true
            fi
        fi
    done
}

apply_theme() {
    local theme="$1"
    local base="$THEMES_DIR/$theme/.config"
    local new_files
    new_files="$(list_theme_files "$theme")"

    cleanup_stale "$new_files"

    while IFS= read -r rel; do
        [ -z "$rel" ] && continue
        local src="$base/$rel"
        local dst="$HOME/.config/$rel"
        mkdir -p "$(dirname "$dst")"
        ln -sfn "$src" "$dst"
    done <<<"$new_files"

    echo "$new_files" >"$MANIFEST"
    echo "$theme" >"$CURRENT_FILE"

    reload_apps
    notify-send "Theme selector" "Tema aplicado: $theme" 2>/dev/null || true
}

reload_apps() {
    pkill -SIGUSR2 waybar 2>/dev/null || true
    niri msg action reload-config 2>/dev/null || true
}

list_theme_names() {
    find "$THEMES_DIR" -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort
}

pick_with_terminal() {
    [ -d "$THEMES_DIR" ] || die "No se encontró $THEMES_DIR"
    local themes=()
    while IFS= read -r t; do themes+=("$t"); done < <(list_theme_names)
    [ "${#themes[@]}" -gt 0 ] || die "No hay temas en $THEMES_DIR"

    echo "Selecciona un tema:"
    select choice in "${themes[@]}" "Cancelar"; do
        if [ "$choice" == "Cancelar" ]; then
            return 0
        elif [ -n "$choice" ]; then
            apply_theme "$choice" && return 0
        fi
        echo "Opción inválida."
    done
}

case "${1:-}" in
--current) [ -f "$CURRENT_FILE" ] && cat "$CURRENT_FILE" || echo "(ninguno)" ;;
--terminal | "") pick_with_terminal ;;
--theme)
    [ -n "${2:-}" ] || die "Uso: $0 --theme NOMBRE"
    apply_theme "$2"
    ;;
*) echo "Uso: theme-selector.sh [--terminal|--theme NOMBRE|--current]" ;;
esac
