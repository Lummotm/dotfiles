#!/usr/bin/env bash
NOTE_PATH="$1"

clean_git_history() {
    clear
    echo "ADVERTENCIA: Esto borrará TODO el historial de commits de: $NOTE_PATH"
    echo "Se quedará solo con el estado actual como un único commit."
    read -p "¿Estás seguro? (s/n): " confirm

    if [[ "$confirm" != "s" ]]; then
        echo "Operación cancelada."
        return 1
    fi

    cd "$NOTE_PATH" || exit 1

    # 1. Crear rama huérfana (sin historial)
    git checkout --orphan latest_branch

    # 2. Añadir todos los archivos actuales
    git add -A

    # 3. Primer commit de la nueva era
    git commit -am "Clean state: $(date +'%Y-%m-%d %H:%M')"

    # 4. Borrar la rama principal vieja y renombrar la actual
    git branch -D main
    git branch -m main

    # 5. Push forzado para sobreescribir el remoto
    echo "Subiendo cambios al servidor..."
    git push -f origin main

    notify-send "Git" "Historial de $NOTE_PATH limpiado correctamente"
}

if [ "$1" == "" ]; then
    echo "Expecting directory"
    echo "$0 directory"
    exit 1
else
    clean_git_history
fi
