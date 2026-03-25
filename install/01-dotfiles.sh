#!/usr/bin/env bash

# If executed standalone
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    source "$SCRIPT_DIR/00-utils.sh"
fi

install_dotfiles() {
    local machine_type="$1"
    local OLD_USER="davidn"
    local NEW_USER="$USER"
    local SCRIPT_NAME=$(basename "$0")

    log "Paso 2/6: Clonando y configurando dotfiles..."
    local DOTFILES_REPO="https://github.com/Lummotm/dotfiles"
    local DOTFILES_DIR="$HOME/dotfiles"
    local STOW_SCRIPT="$DOTFILES_DIR/install/stow-config.sh"

    if [ ! -d "$DOTFILES_DIR" ]; then
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"

    else
        log "Directorio de dotfiles ya existe. Saltando clonación."
    fi

    # Cambio de usuario al nuevo usuario, por si instala alguien que no sea yo
    log "Personalizando nombres de usuario: $OLD_USER -> $NEW_USER"
    cd "$DOTFILES_DIR" || return 1
    find . -path "./.git" -prune -o -type f ! -name "$SCRIPT_NAME" -exec sed -i "s/$OLD_USER/$NEW_USER/g" {} +
    log "Personalización completada."

    if [ ! -f "$STOW_SCRIPT" ]; then
        echo "Error: stow-config.sh no encontrado. Verifica el repo de dotfiles."
        exit 1
    fi
    chmod +x "$STOW_SCRIPT"

    if ! "$STOW_SCRIPT" "$machine_type"; then
        echo "Error: Falló la configuración de stow."
        exit 1
    fi

    if [ ! -d "$HOME/dotfiles/extra" ]; then
        echo "Error: Directorio extra no encontrado en dotfiles"
        exit 1
    fi

    # Actualizar caches
    fc-cache -fv
    update-desktop-database ~/.local/share/applications/

    log "Caches actualizados"
    log "Dotfiles configurados."
    echo ""
}

# Main execution
# If executed standalone
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    if [ -z "$1" ]; then
        log "Error: Se requiere un tipo de máquina (laptop|desktop) como argumento."
        log "Uso: $0 <laptop|desktop>"
        exit 1
    fi
    validate_input "$1" # validate_input viene de 00-utils.sh
    install_dotfiles "$1"
fi
