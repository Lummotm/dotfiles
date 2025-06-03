#!/usr/bin/env bash

cd ~/Documents/Obsidian/ || exit

find . -type d -empty -exec touch {}/.gitkeep \;

git add -A
# Comprobar si hay algo para comitear
if ! git diff --cached --quiet; then
    fecha=$(date '+%Y-%m-%d %H:%M')
    git commit -m "Sync desde PC $fecha"
    git pull --rebase
    git push
else
    echo "No hay cambios para sincronizar."
fi
