#!/usr/bin/env bash

DOTFILES_DIR="$HOME/dotfiles"
THEME_SELECTOR="$HOME/dotfiles/common/bin/ui/theme-selector.sh"
RESOURCES_ZIP="$HOME/dotfiles/extra/resources.7z"

log() {
    echo "[$(date '+%H:%M:%S')] $*"
}

# Asegurar dependencias de sincronización
if ! command -v stow &>/dev/null || ! command -v 7z &>/dev/null || ! command -v rsync &>/dev/null; then
    log "Instalando dependencias necesarias (stow, p7zip, rsync)..."
    sudo pacman -S --noconfirm --needed stow p7zip rsync || exit 1
fi

# Crear directorios base necesarios
log "Creando estructura de directorios..."
find "$HOME/.local/share" -xtype l -delete 2>/dev/null

mkdir -vp \
    "$HOME/.config"/{waybar,rofi,niri,discord,zathura,dunst,nvim,sioyek} \
    "$HOME/.local/share"/{applications,icons,fonts,zoxide} \
    "$HOME/temp"

# Descomprimir y aplicar iconos/fuentes (Tu lógica original intacta)
if [ -f "$RESOURCES_ZIP" ]; then
    log "Instalando recursos desde $RESOURCES_ZIP..."
    TEMP_EXTRACT="/tmp/dotfiles_resources"
    mkdir -p "$TEMP_EXTRACT"

    7z x "$RESOURCES_ZIP" -o"$TEMP_EXTRACT" -aoa >/dev/null

    # Sincronizar solo si existen en el zip
    [ -d "$TEMP_EXTRACT/fonts" ] && rsync -av --ignore-existing "$TEMP_EXTRACT/fonts/" "$HOME/.local/share/fonts/"
    [ -d "$TEMP_EXTRACT/icons" ] && rsync -av --ignore-existing "$TEMP_EXTRACT/icons/" "$HOME/.local/share/icons/"

    # Recomprimir si hay algo nuevo en el sistema que no esté en el zip
    log "Actualizando recursos comprimidos..."
    mkdir -p "$TEMP_EXTRACT/fonts" "$TEMP_EXTRACT/icons"
    rsync -av --ignore-existing "$HOME/.local/share/fonts/" "$TEMP_EXTRACT/fonts/"
    rsync -av --ignore-existing "$HOME/.local/share/icons/" "$TEMP_EXTRACT/icons/"

    cd "$TEMP_EXTRACT" || exit
    7z u "$RESOURCES_ZIP" . >/dev/null
    cd "$DOTFILES_DIR" || exit

    rm -rf "$TEMP_EXTRACT"
    fc-cache -fv >/dev/null
    update-desktop-database ~/.local/share/applications/ >/dev/null 2>&1
fi

# Configuraciones locales de Git (Ignorar archivos generados localmente)
log "Configurando exclusiones de Git..."
cd "$DOTFILES_DIR" || exit 1
git update-index --assume-unchanged common/.config/rofi/colors.rasi 2>/dev/null || true
git update-index --assume-unchanged common/.config/waybar/colors.css 2>/dev/null || true
git update-index --assume-unchanged common/.config/zathura/zathurarc 2>/dev/null || true
git update-index --assume-unchanged common/.config/dunst/dunstrc 2>/dev/null || true
git update-index --assume-unchanged common/.config/nvim/lazy-lock.json 2>/dev/null || true
git update-index --assume-unchanged common/.config/discord/settings.json 2>/dev/null || true
git update-index --assume-unchanged common/.config/sioyek/prefs_user.config 2>/dev/null || true
git update-index --assume-unchanged common/.config/niri/colors.kdl 2>/dev/null || true

git config --global http.postBuffer 52428800

# Enlazar archivos con Stow
case "$1" in
laptop | desktop)
    log "Aplicando stow para perfil: $1..."

    # Copiar mimeapps si existe (fuera de stow porque suele dar problemas de symlink con navegadores)
    [ -f "extra/mimeapps.list" ] && cp "extra/mimeapps.list" "$HOME/.config/mimeapps.list"

    stow --target="$HOME" --restow common
    stow --target="$HOME" --restow "$1"

    # Lanzar el selector de temas si está disponible
    if [ -f "$THEME_SELECTOR" ]; then
        log "Lanzando selector de temas..."
        bash "$THEME_SELECTOR"
    fi

    log "¡Configuración aplicada con éxito!"
    ;;
*)
    echo "Uso: $0 <laptop|desktop>"
    exit 1
    ;;
esac
