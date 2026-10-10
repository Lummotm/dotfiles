#!/usr/bin/env bash

DOTFILES_DIR="$HOME/dotfiles"
THEME_SELECTOR="$HOME/dotfiles/common/bin/ui/theme-selector.sh"
RESOURCES_ZIP="$HOME/dotfiles/extra/resources.7z"
TARGET_WALL_DIR="$HOME/Pictures/Wallpapers"
TARGET_THEMES_DIR="$HOME/.themes"
COMPRESSED_WALL_DIR="$HOME/temp/wallpapers_1080p-webp"

PROFILE=""
UPDATE_RESOURCES=false
INTERACTIVE_THEME=true
THEME_TO_APPLY=""
SYMLINKS_ONLY=false

log() { echo "[$(date '+%H:%M:%S')] $*"; }

manage_resources() {
  if [ "$UPDATE_RESOURCES" = true ]; then
    log "Iniciando gestión de recursos pesados..."
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
    log "Gestión de recursos finalizada."
  fi
}

handle_theme() {
  if [ "$SYMLINKS_ONLY" = true ]; then
    if [ -f "$THEME_SELECTOR" ]; then
      CURRENT_THEME=$(bash "$THEME_SELECTOR" --current)
      if [ "$CURRENT_THEME" != "(ninguno)" ]; then
        bash "$THEME_SELECTOR" --theme "$CURRENT_THEME"
      fi
    fi
    return 0
  fi

  if [ -n "$THEME_TO_APPLY" ]; then
    log "Aplicando tema: $THEME_TO_APPLY"
    if [ -f "$THEME_SELECTOR" ]; then
      bash "$THEME_SELECTOR" --theme "$THEME_TO_APPLY"
    else
      (cd "$DOTFILES_DIR/themes" && stow --target="$HOME" -S "$THEME_TO_APPLY")
    fi
  elif [ "$INTERACTIVE_THEME" = true ] && [ -f "$THEME_SELECTOR" ]; then
    log "Abriendo selector de temas..."
    bash "$THEME_SELECTOR"
  else
    log "Aplicando tema de fallback (vertbar-bordered)..."
    (cd "$DOTFILES_DIR/themes" && stow --target="$HOME" -S vertbar-bordered)
  fi
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
  laptop | desktop)
    PROFILE="$1"
    shift
    ;;
  --update-resources)
    UPDATE_RESOURCES=true
    shift
    ;;
  --symlinks-only)
    SYMLINKS_ONLY=true
    INTERACTIVE_THEME=false
    UPDATE_RESOURCES=false
    shift
    ;;
  --noctalia)
    THEME_TO_APPLY="noctalia"
    INTERACTIVE_THEME=false
    shift
    ;;
  --theme)
    THEME_TO_APPLY="$2"
    INTERACTIVE_THEME=false
    shift 2
    ;;
  -h | --help)
    echo "Uso: $0 <laptop|desktop> [OPCIONES]"
    echo "Opciones:"
    echo "  --update-resources  Extrae/actualiza fuentes, iconos, wallpapers (omite por defecto)"
    echo "  --symlinks-only     Solo regenera los enlaces stow (ignora temas interactivos)"
    echo "  --noctalia          Aplica directamente el tema 'noctalia'"
    echo "  --theme <nombre>    Aplica un tema específico directamente"
    exit 0
    ;;
  *)
    echo "Error: Argumento desconocido: $1"
    exit 1
    ;;
  esac
done

if [ -z "$PROFILE" ]; then
  echo "Error: Debes especificar un perfil."
  echo "Uso: $0 <laptop|desktop> [OPCIONES]"
  exit 1
fi

if ! command -v stow &>/dev/null || ! command -v 7z &>/dev/null || ! command -v rsync &>/dev/null; then
  sudo pacman -S --noconfirm --needed stow p7zip rsync || exit 1
fi

rm -rf $HOME/.config/{waybar,rofi,niri,dunst}
find "$HOME/.local/share" -xtype l -delete 2>/dev/null

mkdir -vp \
  "$HOME/.config"/{waybar,rofi,niri,discord,zathura,dunst,nvim,sioyek} \
  "$HOME/.local/share"/{applications,icons,fonts,zoxide} \
  "$TARGET_THEMES_DIR" \
  "$HOME/temp" \
  "$HOME/.local/bin" >/dev/null

manage_resources

cd "$DOTFILES_DIR" || exit

git update-index --assume-unchanged "dotfiles/common/.config/rofi/colors.rasi" 2>/dev/null
git update-index --assume-unchanged "dotfiles/common/.config/waybar/colors.css" 2>/dev/null
git update-index --assume-unchanged "dotfiles/common/.config/zathura/zathurarc" 2>/dev/null
git update-index --assume-unchanged "dotfiles/common/.config/dunst/dunstrc" 2>/dev/null
git update-index --assume-unchanged "dotfiles/common/.config/nvim/lazy-lock.json" 2>/dev/null
git update-index --assume-unchanged "dotfiles/common/.config/discord/settings.json" 2>/dev/null
git update-index --assume-unchanged "dotfiles/common/.config/sioyek/prefs_user.config" 2>/dev/null
git update-index --assume-unchanged "dotfiles/common/.config/niri/colors.kdl" 2>/dev/null
git update-index --assume-unchanged "common/.config/btop/themes/noctalia.theme" 2>/dev/null
git update-index --assume-unchanged "common/.config/gtk-3.0/noctalia.css" 2>/dev/null
git update-index --assume-unchanged "common/.config/noctalia/launcher.toml" 2>/dev/null
git update-index --assume-unchanged "common/.config/tmux/themes/noctalia.conf" 2>/dev/null
git update-index --assume-unchanged "common/.config/yazi/flavors/noctalia.yazi/flavor.toml" 2>/dev/null
git update-index --assume-unchanged "common/.config/yazi/flavors/noctalia.yazi/tmtheme.xml" 2>/dev/null
git update-index --assume-unchanged "common/.local/state/noctalia/settings.toml" 2>/dev/null

git config --global http.postBuffer 52428800

cd "$DOTFILES_DIR" || exit

log "Aplicando perfil: $PROFILE..."
[ -f "extra/mimeapps.list" ] && cp "extra/mimeapps.list" "$HOME/.config/mimeapps.list"

stow --target="$HOME" --ignore='opencode\.desktop' -S common
stow --target="$HOME" -S "$PROFILE"

handle_theme

log "¡Hecho!"
