#!/usr/bin/env bash

DOTFILES_DIR="$HOME/dotfiles"
THEME_SELECTOR="$HOME/dotfiles/common/bin/ui/theme-selector.sh"
RESOURCES_ZIP="$HOME/dotfiles/extra/resources.7z"

log() {
    echo "[$(date '+%H:%M:%S')] $*"
}

if ! command -v stow &>/dev/null; then
    sudo pacman -Sy --noconfirm stow || exit 1
fi

# Directorios base
mkdir -vp \
    "$HOME/.config"/{waybar,rofi,niri,discord,zathura,dunst,nvim,sioyek} \
    "$HOME/.local/share"/{applications,icons,fonts,zoxide} \
    "$HOME/temp"

if [ -f "$RESOURCES_ZIP" ]; then
    # Verificar dependencias
    command -v 7z &>/dev/null || sudo pacman -S --noconfirm --needed p7zip
    command -v rsync &>/dev/null || sudo pacman -S --noconfirm --needed rsync

    log "Instalando recursos desde $RESOURCES_ZIP..."
    TEMP_EXTRACT="/tmp/dotfiles_resources"
    mkdir -p "$TEMP_EXTRACT"

    7z x "$RESOURCES_ZIP" -o"$TEMP_EXTRACT" -aoa >/dev/null

    # Solo si existen sincronizamos
    [ -d "$TEMP_EXTRACT/fonts" ] && rsync -av --ignore-existing "$TEMP_EXTRACT/fonts/" "$HOME/.local/share/fonts/"
    [ -d "$TEMP_EXTRACT/icons" ] && rsync -av --ignore-existing "$TEMP_EXTRACT/icons/" "$HOME/.local/share/icons/"

    rm -rf "$TEMP_EXTRACT"
    fc-cache -fv >/dev/null
fi

# Git
cd "$DOTFILES_DIR" || exit 1
git update-index --assume-unchanged common/.config/rofi/colors.rasi
git update-index --assume-unchanged common/.config/waybar/colors.css
git update-index --assume-unchanged common/.config/zathura/zathurarc
git update-index --assume-unchanged common/.config/dunst/dunstrc
git update-index --assume-unchanged common/.config/nvim/lazy-lock.json
git update-index --assume-unchanged common/.config/discord/settings.json
git update-index --assume-unchanged common/.config/sioyek/prefs_user.config
git update-index --assume-unchanged common/.config/niri/colors.kdl

git config --global http.postBuffer 52428800

# Stow
case "$1" in
laptop | desktop)
    cd "$DOTFILES_DIR"
    [ -f "extra/mimeapps.list" ] && cp "extra/mimeapps.list" "$HOME/.config/mimeapps.list"

    log "Aplicando stow ($1)..."
    stow --target="$HOME" common
    stow --target="$HOME" "$1"

    [ -f "$THEME_SELECTOR" ] && bash "$THEME_SELECTOR"
    ;;
*)
    echo "Uso: $0 <laptop|desktop>"
    exit 1
    ;;
esac
