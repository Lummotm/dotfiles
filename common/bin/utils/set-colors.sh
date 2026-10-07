#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="$HOME/.tmp/current_color_theme"
LIGHT_FLAG="$HOME/.tmp/light_flag"
MODE=${1:-}

mkdir -p "$HOME/.tmp"

# 1. Diccionario de parejas (Oscuro <-> Claro)
declare -A TOGGLE_MAP=(
  ["rose-pine"]="rose-pine-dawn"
  ["rose-pine-dawn"]="rose-pine"
  ["catppuccin-mocha"]="catppuccin-latte"
  ["catppuccin-latte"]="catppuccin-mocha"
  ["one-dark"]="one-light"
  ["one-light"]="one-dark"
  ["gruvbox-dark"]="gruvbox-light"
  ["gruvbox-light"]="gruvbox-dark"
  ["tokyo-night"]="tokyo-night-day"
  ["tokyo-night-day"]="tokyo-night"
  ["solarized-dark"]="solarized-light"
  ["solarized-light"]="solarized-dark"
)

# 2. Lógica de selección
if [[ "$MODE" == "toggle" ]]; then
  if [[ -f "$STATE_FILE" ]]; then
    current=$(cat "$STATE_FILE")
    # Si existe una pareja definida en el diccionario, la usa. Si no, mantiene el actual.
    theme_name="${TOGGLE_MAP[$current]:-$current}"
  else
    theme_name="rose-pine" # Fallback por defecto
  fi
else
  theme_name="$MODE"
fi

# Guardar el estado actual
echo "$theme_name" >"$STATE_FILE"

# 3. Detectar si es un tema claro para aplicar los flags GTK/Pywal correctos
# (Se basa en el nombre del tema para saber si activar el modo claro)
if [[ "$theme_name" == *"dawn"* || "$theme_name" == *"light"* || "$theme_name" == *"latte"* ]]; then
  wal_opts="-l"
  gtk_theme="Colloid-Grey-Light-Nord"
  color_scheme="prefer-light"
  touch "$LIGHT_FLAG"
else
  wal_opts=""
  gtk_theme="Colloid-Grey-Dark-Nord"
  color_scheme="prefer-dark"
  rm -f "$LIGHT_FLAG"
fi

# 4. Aplicar paleta con Pywal (sin tocar fondo)
wal --theme "$theme_name" $wal_opts -n >/dev/null 2>&1

# 5. Distribuir archivos a tus dotfiles
cp ~/.cache/wal/colors-custom.rasi ~/.config/rofi/colors.rasi
cp ~/.cache/wal/custom-waybar.css ~/.config/waybar/colors.css
cp ~/.cache/wal/colors.kdl ~/.config/niri/colors.kdl
cp ~/.cache/wal/zathurarc ~/.config/zathura/zathurarc
cp ~/.cache/wal/dunstrc ~/.config/dunst/dunstrc

if ! [[ -f "$HOME/Documents/Obsidian/.obsidian/snippets/pywal-theme.css" ]]; then
  cp "$HOME/.cache/wal/obsidian-pywal.css" "$HOME/Documents/Obsidian/.obsidian/snippets/pywal-theme.css"
fi

# 6. Aplicar entorno y recargar
gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
dconf write /org/gnome/desktop/interface/color-scheme "\"$color_scheme\""

python3 "$HOME/bin/ui/pywal-sioyek.py" 2>/dev/null || true
pkill -SIGUSR2 waybar 2>/dev/null || (killall waybar && waybar &)
niri msg action reload-config 2>/dev/null || true
# pkill -x dunst || true
sleep 0.3
dunst || true &
disown
notify-send "Paleta aplicada" "$theme_name" -t 5000 -i preferences-desktop-color
