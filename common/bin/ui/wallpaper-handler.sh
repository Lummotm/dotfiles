#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CURRENT_WALL="$HOME/.cache/current-wallpaper"
LIGHT_FLAG="$HOME/.tmp/light_flag"
TMP_FILE_PATH="$HOME/.cache/tmp.png"

SELECTED="$1"

mkdir -p "$HOME/.tmp"

notificar_error() {
  local linea=$1
  echo "¡Error en la línea $linea!"
}
trap 'notificar_error $LINENO' ERR

# Use the actual wallpaper instead of the copy, it errors on gif
apply_wallpaper() {
  awww img "$SELECTED" --transition-type random --transition-step 60 --transition-fps 120
}

set_theme() {
  local mode=$1

  if [[ "$mode" == "light" ]]; then
    wal_opts="-l"
    gtk_theme="Colloid-Grey-Light-Nord"
    color_scheme="prefer-light"
    touch "$LIGHT_FLAG"
  else
    wal_opts="-n"
    gtk_theme="Colloid-Grey-Dark-Nord"
    color_scheme="prefer-dark"
    rm -f "$LIGHT_FLAG"
  fi

  {
    wal -i "$CURRENT_WALL" $wal_opts
    cp ~/.cache/wal/colors-custom.rasi ~/.config/rofi/colors.rasi
    cp ~/.cache/wal/custom-waybar.css ~/.config/waybar/colors.css
    cp ~/.cache/wal/zathurarc ~/.config/zathura/zathurarc
    cp ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc
    cp ~/.cache/wal/colors.kdl ~/.config/niri/colors.kdl
    if ! [[ -f "$HOME/Documents/Obsidian/.obsidian/snippets/pywal-theme.css" ]]; then
      cp "$HOME/.cache/wal/obsidian-pywal.css" "$HOME/Documents/Obsidian/.obsidian/snippets/pywal-theme.css"
    fi
    python3 "$HOME/bin/ui/pywal-sioyek.py"
    killall waybar && waybar &
    pkill -f dunst
    dunst &
  } &>/dev/null

  gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
  dconf write /org/gnome/desktop/interface/color-scheme "\"$color_scheme\""
}

if [[ -z "${1:-}" ]]; then
  exit 1
fi

case "$1" in
"toggle")
  [ ! -f "$CURRENT_WALL" ] && exit 1

  apply_wallpaper &>/dev/null &

  if [ -f "$LIGHT_FLAG" ]; then
    set_theme "dark"
  else
    set_theme "light"
  fi

  notify-send "Tema cambiado" || true
  ;;

"time")
  [ ! -f "$CURRENT_WALL" ] && exit 1

  current_hour=$(date +%-H)
  if ((current_hour >= 18 || current_hour < 6)); then
    [ -f "$LIGHT_FLAG" ] && set_theme "dark"
  else
    [ ! -f "$LIGHT_FLAG" ] && set_theme "light"
  fi
  ;;

*)
  if [[ "$1" == "$WALLPAPER_DIR/random-wall" ]]; then
    "$HOME/bin/ui/wallpaper-randomizer.sh"
    exit 0
  fi
  if [[ "$1" == "$WALLPAPER_DIR/current-wallpaper" ]]; then
    apply_wallpaper &>/dev/null &
    exit 0
  fi

  if [ ! -f "$1" ]; then
    echo "error: archivo no válido: $1"
    exit 1
  fi

  cp "$1" "$CURRENT_WALL"

  # There are certain programs that require the usage of a png even if the file is a gif
  rm "$TMP_FILE_PATH" || true
  ffmpeg -i "$CURRENT_WALL" -frames:v 1 "$TMP_FILE_PATH" || true

  apply_wallpaper &>/dev/null &

  if [ -f "$LIGHT_FLAG" ]; then
    set_theme "light"
  else
    set_theme "dark"
  fi

  notify-send "Fondo aplicado" || true
  ;;
esac
