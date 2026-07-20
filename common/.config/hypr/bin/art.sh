#!/usr/bin/env bash
set -euo pipefail

musicdir="$HOME/Music"
coverdir="$musicdir/.cover"
mkdir -p "$coverdir"

mpcname=$(mpc current -f %file%)
[ -z "$mpcname" ] && exit 0

filename="$musicdir/$mpcname"
basename=$(basename "$filename")
cover="$coverdir/${basename%.*}.png"
current="/tmp/current.png"

# Si la portada ya existe, solo copiar a current.png
if [ -f "$cover" ]; then
    cp "$cover" "$current"
    echo "$current"
    exit 0
else
    ffmpeg -y -i "$filename" -vf scale=256:256 -an "$cover" 2>/dev/null
fi

[ -s "$cover" ] && cp "$cover" "$current" && echo "$current"
