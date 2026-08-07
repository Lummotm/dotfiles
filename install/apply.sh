#!/usr/bin/env bash

DOTFILES_DIR="$HOME/dotfiles"
THEME_SELECTOR="$HOME/dotfiles/common/bin/ui/theme-selector.sh"
RESOURCES_ZIP="$HOME/dotfiles/extra/resources.7z"
TARGET_WALL_DIR="$HOME/Pictures/Wallpapers"
TARGET_THEMES_DIR="$HOME/.themes"
COMPRESSED_WALL_DIR="$HOME/temp/wallpapers_1080p-webp"

log() { echo "[$(date '+%H:%M:%S')] $*"; }

manage_resources() {
  echo ""
  read -p "¿Deseas restaurar/actualizar los recursos pesados? (s/N): " confirm
  if [[ "$confirm" =~ ^[sS]$ ]]; then
    log "Iniciando gestión de recursos..."
    TEMP_EXTRACT="/tmp/dotfiles_resources"
    mkdir -p "$TEMP_EXTRACT"

    if [ -f "$RESOURCES_ZIP" ]; then
      7z x "$RESOURCES_ZIP" -o"$TEMP_EXTRACT" -aoa >/dev/null

      if [ ! -d "$HOME/.local/share/fonts" ] || [ -z "$(ls -A "$HOME/.local/share/fonts" 2>/dev/null)" ]; then
        mkdir -p "$HOME/.local/share/fonts"
        [ -d "$TEMP_EXTRACT/fonts" ] && rsync -au "$TEMP_EXTRACT/fonts/" "$HOME/.local/share/fonts/"
      fi

      if [ ! -d "$HOME/.local/share/icons" ] || [ -z "$(ls -A "$HOME/.local/share/icons" 2>/dev/null)" ]; then
        mkdir -p "$HOME/.local/share/icons"
        [ -d "$TEMP_EXTRACT/icons" ] && rsync -au "$TEMP_EXTRACT/icons/" "$HOME/.local/share/icons/"
      fi

      if [ ! -d "$TARGET_THEMES_DIR" ] || [ -z "$(ls -A "$TARGET_THEMES_DIR" 2>/dev/null)" ]; then
        [ -d "$TEMP_EXTRACT/themes" ] && rsync -au "$TEMP_EXTRACT/themes/" "$TARGET_THEMES_DIR/"
      fi

      mkdir -p "$TARGET_WALL_DIR"
      shopt -s nullglob
      for dir in "$TEMP_EXTRACT/Wallpapers"/0-*/; do
        folder_name=$(basename "$dir")
        if [ ! -d "$TARGET_WALL_DIR/$folder_name" ] || [ -z "$(ls -A "$TARGET_WALL_DIR/$folder_name" 2>/dev/null)" ]; then
          mkdir -p "$TARGET_WALL_DIR/$folder_name"
          rsync -au "$dir" "$TARGET_WALL_DIR/$folder_name/"
        fi
      done
      shopt -u nullglob
    else
      mkdir -p "$(dirname "$RESOURCES_ZIP")"
    fi

    if [ -x "$HOME/bin/utils/reduce-img-quality.sh" ]; then
      "$HOME/bin/utils/reduce-img-quality.sh"
    fi

    mkdir -p "$TEMP_EXTRACT"/{fonts,icons,themes,Wallpapers}
    rsync -au "$HOME/.local/share/fonts/" "$TEMP_EXTRACT/fonts/"
    rsync -au "$HOME/.local/share/icons/" "$TEMP_EXTRACT/icons/"
    rsync -au "$TARGET_THEMES_DIR/" "$TEMP_EXTRACT/themes/"

    shopt -s nullglob
    for dir in "$COMPRESSED_WALL_DIR"/0-*/; do
      folder_name=$(basename "$dir")
      mkdir -p "$TEMP_EXTRACT/Wallpapers/$folder_name"
      rsync -au "$dir" "$TEMP_EXTRACT/Wallpapers/$folder_name/"
    done
    shopt -u nullglob

    cd "$TEMP_EXTRACT" || exit
    7z u -t7z -m0=lzma2 -mx=9 -md=128m -ms=on "$RESOURCES_ZIP" . >/dev/null
    cd "$DOTFILES_DIR" || exit

    rm -rf "$TEMP_EXTRACT"
    fc-cache -fv >/dev/null
    update-desktop-database ~/.local/share/applications/ >/dev/null 2>&1
  fi
}

ask_theme_selector() {
  echo ""
  read -p "¿Deseas abrir el selector de temas visual? (s/N): " confirm_theme
  if [[ "$confirm_theme" =~ ^[sS]$ ]]; then
    [ -f "$THEME_SELECTOR" ] && bash "$THEME_SELECTOR"
  fi
}

if ! command -v stow &>/dev/null || ! command -v 7z &>/dev/null || ! command -v rsync &>/dev/null; then
  sudo pacman -S --noconfirm --needed stow p7zip rsync || exit 1
fi

rm -rf $HOME/.config/{waybar,rofi,niri,dunst} $HOME/.local/bin/
find "$HOME/.local/share" -xtype l -delete 2>/dev/null

mkdir -vp \
  "$HOME/.config"/{waybar,rofi,niri,discord,zathura,dunst,nvim,sioyek} \
  "$HOME/.local/share"/{applications,icons,fonts,zoxide} \
  "$TARGET_THEMES_DIR" \
  "$HOME/temp" \
  "$HOME/.local/bin" >/dev/null

manage_resources

# Recursos variables que no queremos que git haga tracking
git update-index --assume-unchanged "$HOME/dotfiles/common/.config/rofi/colors.rasi"
git update-index --assume-unchanged "$HOME/dotfiles/common/.config/waybar/colors.css"
git update-index --assume-unchanged "$HOME/dotfiles/common/.config/zathura/zathurarc"
git update-index --assume-unchanged "$HOME/dotfiles/common/.config/dunst/dunstrc"
git update-index --assume-unchanged "$HOME/dotfiles/common/.config/nvim/lazy-lock.json"
git update-index --assume-unchanged "$HOME/dotfiles/common/.config/discord/settings.json"
git update-index --assume-unchanged "$HOME/dotfiles/common/.config/sioyek/prefs_user.config"
git update-index --assume-unchanged "$HOME/dotfiles/common/.config/niri/colors.kdl"

# Mejora util
git config --global http.postBuffer 52428800

cd "$DOTFILES_DIR" || exit

case "$1" in
laptop | desktop)
  log "Aplicando perfil: $1..."
  [ -f "extra/mimeapps.list" ] && cp "extra/mimeapps.list" "$HOME/.config/mimeapps.list"

  stow --target="$HOME" --ignore='opencode\.desktop' -S common
  (cd "$DOTFILES_DIR/themes" && stow --target="$HOME" -S vertbar-bordered)
  stow --target="$HOME" -S "$1"

  ask_theme_selector
  log "¡Hecho!"
  ;;
*)
  echo "Uso: $0 <laptop|desktop>"
  exit 1
  ;;
esac
