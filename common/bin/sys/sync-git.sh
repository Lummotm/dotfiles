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

optimizar_si_es_obsidian() {
    local dir="$1"
    if [[ "$dir" == *"Obsidian"* ]]; then
        local pylib="$HOME/dotfiles/common/bin/pylib"
        PYTHONPATH="$pylib:$PYTHONPATH" python3 -c "
import image_optimizer; import todos;
image_optimizer.run_optimizer('$dir'); todos.run_update('$dir')
" >/dev/null 2>&1 || true
    fi
}

sync_repo() {
    local dir="$1"
    local repo_name
    repo_name=$(basename "$dir")

    if [ ! -d "$dir" ]; then
        log "Error: El directorio $dir no existe."
        return 1
    fi

    cd "$dir" || return 1

    git rebase --abort >/dev/null 2>&1 || true
    git merge --abort >/dev/null 2>&1 || true
    git checkout main >/dev/null 2>&1 || true

    optimizar_si_es_obsidian "$dir"

    git add -A
    local changes_made=false
    if ! git diff --cached --quiet; then
        git commit -m "$COMMIT_MESSAGE" >/dev/null
        changes_made=true
    fi

    if ! git pull --rebase --autostash origin main >/dev/null 2>&1; then
        notify "Conflicto en $repo_name" "Sincronización automática detenida. Resuelve manualmente."
        return 1
    fi

    optimizar_si_es_obsidian "$dir"
    git add -A
    if ! git diff --cached --quiet; then
        git commit -m "Auto-compresión post-descarga (Auto)" >/dev/null
        changes_made=true
    fi

    if ! git push origin main >/dev/null 2>&1; then
        log "Error de red al subir $repo_name"
        return 2
    fi

    if ! $loopFlag; then
        notify "Sync Completado" "$repo_name al día"
    elif $changes_made; then
        log "Sync Automático: Cambios subidos en $repo_name"
    fi

    return 0
}

main() {

    # Checkear si hay internet, usando curl para que funcione en cualquier lado (eduroam bloquea pings)
    if curl -s --head --request GET 1.1.1.1 --connect-timeout 2 &>/dev/null; then
        if ! $loopFlag; then
            log "Iniciando Sincronización Manual..."
        fi

        while true; do
            for repo in "${repos[@]}"; do
                sync_repo "$repo"
                local status=$?

                if [ $status -eq 1 ] && $loopFlag; then
                    notify "Sync Detenido" "Conflicto en $repo. Abre una terminal."
                    exit 1
                fi
            done

            if ! $loopFlag; then break; fi
            sleep 300
        done
    else
        log "No hay internet jefe"
        notify-send "No hay internet jefe"
    fi
}

main "$@"
