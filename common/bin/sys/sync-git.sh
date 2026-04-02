#!/usr/bin/env bash

LOG="$HOME/logs/sync-repo.log"
mkdir -p "$(dirname "$LOG")"
COMMIT_MESSAGE="Sync PC (Auto) $(date '+%Y-%m-%d %H:%M')"

loopFlag=false
repos=()

for item in "$@"; do
    if [[ "$item" == "--loop" ]]; then
        loopFlag=true
    else
        repos+=("$item")
    fi
done

log() {
    echo "[$(date '+%H:%M:%S')] $1" >>"$LOG"
}

notify() {
    local title="$1"
    local msg="$2"
    log "$title: $msg"
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$title" "$msg"
    fi
}

# Solo para Obsidian: optimizar imágenes y tareas
optimizar_si_es_obsidian() {
    local dir="$1"
    if [[ "$dir" == *"Obsidian"* ]]; then
        python3 "$HOME/.config/rofi/bin/dependencies/image_compresion.py" >/dev/null 2>&1 || true
        python3 "$HOME/.config/rofi/bin/dependencies/update-todos.py" "$dir" >/dev/null 2>&1 || true
    fi
}

sync_repo() {
    local dir="$1"
    local repo_name
    repo_name=$(basename "$dir")

    cd "$dir" || return 1

    # 1. Limpieza de bloqueos previos (por si el PC se apagó mal)
    git rebase --abort >/dev/null 2>&1 || true
    git merge --abort >/dev/null 2>&1 || true

    # 2. Mantenimiento previo
    optimizar_si_es_obsidian "$dir"

    # 3. Guardar cambios locales
    git add -A
    local changes_made=false
    if ! git diff --cached --quiet; then
        git commit -m "$COMMIT_MESSAGE" >/dev/null
        changes_made=true
    fi

    # 4. Pull Seguro (Sin -Xours)
    # Si hay conflicto, el script de fondo SE PARA para no romper nada.
    if ! git pull --rebase --autostash origin main >/dev/null 2>&1; then
        notify "Conflicto en $repo_name" "Sincronización automática detenida. Resuelve manualmente."
        return 1
    fi

    # 5. Push
    if ! git push origin main >/dev/null 2>&1; then
        log "Error de red al subir $repo_name"
        return 2
    fi

    # 6. Notificaciones discretas
    if ! $loopFlag; then
        notify "Sync Completado" "$repo_name al día"
    elif $changes_made; then
        log "Sync Automático: Cambios subidos en $repo_name"
    fi

    return 0
}

main() {
    # Solo notifica al inicio si no es bucle
    if ! $loopFlag; then
        log "Iniciando Sincronización Manual..."
    fi

    while true; do
        for repo in "${repos[@]}"; do
            sync_repo "$repo"
            local status=$?

            # Si hay conflicto en modo bucle, paramos para que el usuario se entere
            if [ $status -eq 1 ] && $loopFlag; then
                notify "Sync Detenido" "Conflicto en $repo. Abre una terminal."
                exit 1
            fi
        done

        if ! $loopFlag; then break; fi
        sleep 300
    done
}

main "$@"
