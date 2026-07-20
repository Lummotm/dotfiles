#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ]; then
    echo " Usage: $0 --title | --artist | --album | --length | --cover"
fi

case "$1" in
--title)
    title=$(mpc --format '%title%' current)
    echo "$title"
    ;;
--artist)
    artist=$(mpc --format '%artist%' current)
    echo "$artist"
    ;;
--album)
    album=$(mpc --format '%album%' current)
    echo "$album"
    ;;
--length)
    length=$(mpc status | awk 'NR==2 {print $3}' | tr '/' ' ' | awk '{print $2}')
    echo "$length"
    ;;
--cover)
    python3 $HOME/bin/ui/mpd_album_art.py

    echo "$HOME/.covers/current"
    sxiv "$HOME/.covers/current"
    ;;

esac
