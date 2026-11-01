#!/usr/bin/env bash

PREFIX="term-"
SELF="$(realpath "$0")"

# Modo 1: dentro de tmux -> detach
if [ -n "$TMUX" ]; then
  tmux detach-client
  exit 0
fi

# Modo 2: lanzado desde una terminal con "--inner" -> lógica de sesiones
if [ "$1" = "--inner" ]; then
  for i in {1..10}; do
    session_name="${PREFIX}${i}"
    if tmux has-session -t "$session_name" 2>/dev/null; then
      attached=$(tmux display-message -p -t "$session_name" '#{session_attached}')
      [ "$attached" -eq 0 ] && exec tmux attach -t "$session_name"
    else
      exec tmux new-session -s "$session_name"
    fi
  done
  exec tmux new-session
fi

# Modo 3: lanzado desde el compositor -> abrir la terminal elegida
term="${1:-kitty}"
case "$term" in
kitty) exec kitty --title=tmux -e "$SELF" --inner ;;
foot) exec foot --title=tmux "$SELF" --inner ;;
ghostty) exec ghostty --title=tmux -e "$SELF" --inner ;;
*)
  echo "Terminal no soportada: $term" >&2
  exit 1
  ;;
esac
