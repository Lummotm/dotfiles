#!/usr/bin/env bash
cd ~/Documents/Obsidian || exit

# Crear .gitkeep en directorios vacíos
find . -type d -empty -exec touch {}/.gitkeep \;

# Agregar todos los cambios
git add -A

# Verificar si hay cambios remotos
git fetch

# Hacer commit si hay cambios locales
if ! git diff --cached --quiet; then
    fecha=$(date '+%Y-%m-%d %H:%M')
    git commit -m "Sync desde PC $fecha"
fi

# Sincronizar siempre (por si hay cambios remotos)
git pull --rebase && git push
