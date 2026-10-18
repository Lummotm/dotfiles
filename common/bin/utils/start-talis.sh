#!/usr/bin/env bash

HOUR=$(date +%H)

if [ "$HOUR" -ge 7 ] && [ "$HOUR" -lt 20 ]; then
  SCENE="day"
else
  SCENE="night"
fi

PLAYER=$(playerctl --list-all 2>/dev/null | grep -m 1 'mpd')

ARGS=("--scene" "$SCENE" "--start-minimized")
[ -n "$PLAYER" ] && ARGS+=("--player" "$PLAYER")

talis "${ARGS[@]}" "$@" &

sleep 0.5
TALIS_WIN_ID=$(niri msg --json windows | jq '.[] | select(.app_id == "io.github.azizstark.Talis") | .id')
if [ -n "$TALIS_WIN_ID" ]; then
  niri msg action close-window --id "$TALIS_WIN_ID"
fi
