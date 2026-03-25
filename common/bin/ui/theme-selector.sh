#!/usr/bin/env bash

DOTFILES_DIR="$HOME/dotfiles"
THEMES_DIR="$DOTFILES_DIR/themes"

apply_theme() {
    local selected_theme="$1"

    if [ ! -d "$THEMES_DIR/$selected_theme" ]; then
        echo "Error: El tema '$selected_theme' no existe."
        command -v notify-send &>/dev/null && notify-send -a "Theme Selector" "Error" "El tema '$selected_theme' no existe."
        exit 1
    fi

    echo "Aplicando tema: $selected_theme..."

    # 1. Purgar todos los symlinks de temas antiguos
    local all_themes=($(ls -d "$THEMES_DIR"/*/ | xargs -n 1 basename))
    for t in "${all_themes[@]}"; do
        stow -d "$THEMES_DIR" --target="$HOME" -D "$t" 2>/dev/null
    done

    # 2. Aplicar el nuevo
    stow -d "$THEMES_DIR" --target="$HOME" "$selected_theme"

    # 3. Reiniciar Waybar de forma segura
    if pgrep -x "waybar" >/dev/null; then
        pkill waybar
        nohup waybar </dev/null >/dev/null 2>&1 &
    fi

    # 4. Notificar
    command -v notify-send &>/dev/null && notify-send -a "Theme Selector" "Tema Aplicado" "$selected_theme"
    echo "¡Listo! '$selected_theme' activado."
}

# --- LÓGICA DE ARGUMENTOS ---

# Si se llama con: ./theme-selector.sh --theme "nombre-del-tema"
if [[ "$1" == "--theme" && -n "$2" ]]; then
    apply_theme "$2"
    exit 0
fi

# Si se llama sin argumentos (Menú CLI de fallback)
themes_list=($(ls -d "$THEMES_DIR"/*/ | xargs -n 1 basename))

if [[ ${#themes_list[@]} -eq 0 ]]; then
    echo "No hay temas en $THEMES_DIR"
    exit 1
fi

echo "======================================"
echo "Selecciona un tema:"
select chosen in "${themes_list[@]}"; do
    if [[ -n "$chosen" ]]; then
        apply_theme "$chosen"
        break
    else
        echo "Opción no válida."
    fi
done
