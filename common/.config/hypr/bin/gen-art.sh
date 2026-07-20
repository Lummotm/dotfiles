#!/usr/bin/env bash
set -euo pipefail

musicdir="$HOME/Music"
coverdir="$musicdir/.cover"
mkdir -p "$coverdir"

for file in "$musicdir"/*; do
    # Verificar que existe y es archivo
    [[ ! -f "$file" ]] && continue

    filename=$(basename "$file")
    extension="${filename##*.}"
    valid_extensions="mp3 m4a flac"

    # If extension not in valid_extensions skip
    # " $string " =~ $string2 does a regex search from string2 on string if so gives a true
    if [[ ! " $valid_extensions " =~ $extension ]]; then
        continue
    fi

    metadata="${filename%.*}"
    cover="$coverdir/${metadata}.png"

    # If file exists continue
    if [[ -f "$cover" ]]; then
        continue
    fi

    echo "Extrayendo cover de: $filename"
    ffmpeg -y -i "$file" -vf scale=256:256 -an "$cover"
done
