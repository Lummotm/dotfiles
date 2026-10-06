#!/usr/bin/env bash
set -euo pipefail

CURRENT_WALL="$HOME/.cache/current-wallpaper"
TMP_FILE_PATH="$HOME/.cache/tmp.png"

if [[ -z "${1:-}" || ! -f "$1" ]]; then
  exit 1
fi

cp "$1" "$CURRENT_WALL"

rm -f "$TMP_FILE_PATH" || true
ffmpeg -i "$CURRENT_WALL" -frames:v 1 "$TMP_FILE_PATH" 2>/dev/null || true

awww img "$CURRENT_WALL" --transition-type random --transition-step 60 --transition-fps 120 &>/dev/null &

notify-send "Fondo aplicado" -i image-x-generic
