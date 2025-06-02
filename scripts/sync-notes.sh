#!/usr/bin/env bash

cd ~/Documents/Obsidian/ || exit

find . -type d -empty -exec touch {}/.gitkeep \;

if ! git diff --cached --quiet; then
    fecha=$(date '+%Y-%m-%d %H:%M')
    git commit -m "Sync desde PC $fecha"
fi
git pull --rebase
git push
