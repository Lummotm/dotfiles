#!/usr/bin/env bash
# Session
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=niri
export XDG_CURRENT_DESKTOP=niri

# Wayland stuff
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1

# La idea es mover el script de gpu-check a /usr/local/bin/ tambien
gpu-check
exec niri-session "$@"
