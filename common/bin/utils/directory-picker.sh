#!/usr/bin/env bash
set -euo pipefail

search_paths=(
    "$HOME/Documents/University/current-course/"
    "$HOME/.config/"
    "$HOME/Documents/Obsidian/"
    "/mnt/usb-drive/"
    "$HOME/bin/"
)

valid_paths=""

for path in "${search_paths[@]}"; do
    if [[ -d "$path" ]]; then
        valid_paths+="$path "
    fi
done

if [[ -n "$valid_paths" ]]; then
    results=$(
        {
            find -L $valid_paths -mindepth 1 -maxdepth 1 -type d
        } | fzf \
            --preview 'command -v exa >/dev/null && exa -1 --color=always {} || ls --color=always {}' \
            --preview-window=down:3 \
            --layout=reverse \
            --height=40% \
            --border
    )

    if [[ -n "$results" ]]; then
        echo "$results"
    fi
else
    echo "Ninguno de los directorios de búsqueda existe."
fi
