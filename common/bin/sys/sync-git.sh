#!/usr/bin/env bash

LOG="$HOME/logs/sync-repo.log"
trap "log 'Deteniendo sincronizacion'; exit" SIGINT SIGTERM
COMMIT_MESSAGE="Sync PC $(date '+%Y-%m-%d %H:%M')"

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

sync_repo() {
    local dir="$1"
    local repo_name
    repo_name=$(basename "$dir")

    cd "$dir" || {
        notify "Error" "No se puede acceder a $dir"
        return 1
    }

    if ! git pull --rebase --autostash origin main >/dev/null 2>&1; then
        notify "Conflicto en $repo_name" "Revisar repositorio manualmente"
        return 1
    fi

    git add -A
    local changes_made=false
    if ! git diff --cached --quiet; then
        git commit -m "$COMMIT_MESSAGE" >/dev/null
        changes_made=true
    fi

    if ! git push origin main >/dev/null 2>&1; then
        notify "Error de red" "Fallo al subir $repo_name"
        return 2
    fi

    if ! $loopFlag; then
        notify "Sync Completado" "$repo_name sincronizado"
    elif $changes_made; then
        notify "Sync Automatico" "Nuevos cambios subidos en $repo_name"
    fi

    return 0
}

main() {
    if ! $loopFlag; then
        notify "Iniciando Sync" "Sincronizacion manual iniciada"
    fi

    while true; do
        for repo in "${repos[@]}"; do
            sync_repo "$repo"
            local status=$?

            if [ $status -eq 1 ] && $loopFlag; then
                notify "Bucle detenido" "Resuelve el conflicto en $repo para continuar"
                exit 1
            fi
        done

        if ! $loopFlag; then
            break
        fi

        sleep 300
    done
}

main "$@"
