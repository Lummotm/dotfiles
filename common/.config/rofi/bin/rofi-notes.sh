#!/usr/bin/env bash
set -e

source "$HOME/.config/rofi/bin/dependencies/rofi-core.sh"

# Wrapper para estandarizar el tamaño y la vista de lista en Rofi
rofi_cmd() {
    # Desactivo la opcion de aceptado alterno (que devuelve 0)
    # Activo esta que devuelve 1
    rofi_core -w "50%" \
        -c 'listview {lines: 8;}' \
        -sort \
        -kb-accept-alt "" \
        -kb-custom-1 "Shift+Return" \
        "$@"
}

SYNC=" Sync"
TMP_NOTE=" Temp Note"
NEW_NOTE=" New Note"
DAILY_NOTE=" Daily Note"

QUICKNOTES_PATTERN="quicknotes"
DAILY_NOTES_PATTERN="daily"

NOTE_PATH="$HOME/Documents/Obsidian"
TEMP_PATH="$HOME/temp/temp_notes"
SYNC_SCRIPT="$HOME/bin/sys/sync-git.sh"

cd "$NOTE_PATH" || exit 1

# Localiza el primer directorio que coincida con el patrón (ej. daily o quicknotes)
get_folder_by_pattern() {
    local pattern="$1"
    local path
    path=$(find "$NOTE_PATH" -maxdepth 1 -type d -name "*$pattern*" | head -n 1)
    if ! [ -d "$path" ]; then
        notify-send "No existe path" "$path"
        exit 1
    else
        echo "$path"
    fi
}

# Ejecuta el actualizador de tareas externo
update_todos() {
    local script_path="$HOME/.config/rofi/bin/dependencies/update-todos.py"
    if [ -f "$script_path" ]; then
        python3 "$script_path" "$NOTE_PATH"
    else
        notify-send "Error" "No se encontró el script: $script_path"
    fi
}

# Interfaz con el script de Python para formatear el menú o parsear la ruta final
parse_selected() {
    local SELECTED=$1
    local script_path="$HOME/.config/rofi/bin/dependencies/note-formatter.py"
    if [ -f "$script_path" ]; then
        python3 "$script_path" "$NOTE_PATH" "$SELECTED"
    else
        notify-send "Error" "No se encontró el script: note-formatter.py"
    fi
}

# Comprime adjuntos para evitar inflar el repositorio Git
optimize_attachments() {
    local attachment_script="$HOME/.config/rofi/bin/dependencies/image_compresion.py"
    if [ -f "$attachment_script" ]; then
        python3 "$attachment_script"
    else
        notify-send "Error" "No se encontró el script: optimize-attachments.py"
    fi
}

# Flujo de edición: Abre Neovim, optimiza imágenes e invoca el sync solo si hay cambios en Git
edit_and_sync() {
    local target="$1"

    cd "$NOTE_PATH" || exit

    nvim "$target"
    python3 "$HOME/.config/rofi/bin/dependencies/image_compresion.py"
    python3 "$HOME/.config/rofi/bin/dependencies/update-todos.py"

    # Verifica si hay archivos modificados (porcelain devuelve string vacío si no los hay)
    if [ -n "$(git -C "$NOTE_PATH" status --porcelain)" ]; then
        bash "$SYNC_SCRIPT" "$NOTE_PATH"
    else
        notify-send 'Obsidian' 'Sin cambios, saltando sync.'
    fi
}

# Exportación necesaria para que las subshells en 'setsid bash -c' reconozcan variables y funciones
export NOTE_PATH
export SYNC_SCRIPT
export -f edit_and_sync

# Gestión de apertura: Sincroniza Git preventivamente y decide cómo abrir el archivo
open_content() {
    local target="$1"
    local mode="$2"

    # Pull asíncrono en subshell para evitar bloqueos y conflictos antes de editar
    (
        git fetch origin main >/dev/null 2>&1
        local LOCAL
        LOCAL=$(git rev-parse @)
        local REMOTE
        REMOTE=$(git rev-parse @{u})

        if [ "$LOCAL" != "$REMOTE" ]; then
            notify-send "Sincronizando" "Hay cambios remotos, actualizando..."
            git pull --rebase --autostash origin main >/dev/null 2>&1
        fi
    ) &

    # Redirección mediante URI de Obsidian para archivos que requieren entorno gráfico nativo
    # Y para la opcion de modo obsidian que se accede con Shift + Enter
    if [[ "$target" == *.excalidraw.md ]] || [[ "$target" == *.base ]] || [[ "$mode" == "OBSIDIAN" ]]; then
        local encoded="${target// /%20}"
        xdg-open "obsidian://open?path=$encoded" >/dev/null 2>&1 &
    else
        # Preprocesado de to-dos si se abren los archivos índice
        if [[ "$target" == "$NOTE_PATH/01_todo_inbox.md" ]] || [[ "$target" == "$NOTE_PATH/00_todo.md" ]]; then
            update_todos
        fi

        # Generamos un nombre de sesión único y limpio basado en el archivo
        local filename=$(basename "$target")
        local session_name="note_${filename//[^a-zA-Z0-9]/_}"

        # Expandimos los comandos en una variable para no depender de funciones exportadas dentro de Tmux
        local inner_cmd="cd '$NOTE_PATH' && nvim '$target'; python3 '$HOME/.config/rofi/bin/dependencies/image_compresion.py'; python3 '$HOME/.config/rofi/bin/dependencies/update-todos.py'; if [ -n \"\$(git -C '$NOTE_PATH' status --porcelain)\" ]; then bash '$SYNC_SCRIPT' '$NOTE_PATH'; else notify-send 'Obsidian' 'Sin cambios, saltando sync.'; fi"

        # Envolvemos el comando en una sesión de Tmux con el flag -A (Attach/Create)
        if [[ "$target" == "$NOTE_PATH"/* ]]; then
            setsid kitty --title="notes" -e tmux new-session -A -s "$session_name" bash -c "$inner_cmd" >/dev/null 2>&1 </dev/null &
        else
            setsid kitty --title="notes" -e tmux new-session -A -s "$session_name" bash -c "nvim '$target'" >/dev/null 2>&1 </dev/null &
        fi
    fi
}

sync_notes() {
    # Funcion de limpieza
    optimizar_vault() {
        python3 "$HOME/.config/rofi/bin/dependencies/image_compresion.py"
        python3 "$HOME/.config/rofi/bin/dependencies/update-todos.py"
    }

    # Tu menú interactivo de estrategia
    local strategy
    local opt=(
        " Standart"
        " PC Priority"
        "󰊄 Mobile Priority"
    )

    strategy=$(printf "%s\n" "${opt[@]}" | rofi_cmd -w "23ch" -mesg "Select a sync mode: " -N)

    # Si pulsas ESC y no seleccionas nada, salimos sin romper nada
    [[ -z "$strategy" ]] && exit 0

    # La lógica de ejecución basada en tu variable $strategy
    case "$strategy" in
    " Standart")
        notify-send "Git" "Sync Standart..."

        # Limpiamos, guardamos lo nuestro, traemos la nube, limpiamos lo nuevo y subimos
        optimizar_vault
        git add -A
        git diff --cached --quiet || git commit -m "Sync PC: $(date +%R)"

        if ! git pull --rebase --autostash -Xours origin main; then
            notify-send -u critical "Git Error" "Conflicto serio. Usa Mobile/PC Priority."
            git rebase --abort
            exit 1
        fi

        optimizar_vault
        if ! git diff --quiet; then
            git add -A && git commit -m "Auto-compresión post-descarga"
        fi
        git push origin main
        ;;

    " PC Priority")
        notify-send "Git" "Prioridad PC (Force Push)..."
        # Limpiamos y aplastamos la nube con nuestra versión local
        optimizar_vault
        git add -A
        git commit -m "PC Priority: $(date +%R)" || true
        git push origin main --force
        ;;

    "󰊄 Mobile Priority")
        notify-send "Git" "Prioridad Móvil (Hard Reset)..."
        # Bajamos la versión cruda de la nube, la limpiamos y la resubimos limpia
        git fetch origin main
        git reset --hard origin/main
        optimizar_vault

        if ! git diff --quiet; then
            git add -A && git commit -m "Limpieza post-descarga móvil"
            git push origin main
        fi
        ;;

    esac

    notify-send "Obsidian" "Estrategia '$strategy' completada "
}

# Construye las opciones fijas y anexa la lista de notas extraídas por el parseador
options="$SYNC\n$TMP_NOTE\n$NEW_NOTE\n$DAILY_NOTE"

# Queremos capturar el codigo de error para usar la tecla alterna (codigo es 10)
set +e

SELECTED=$( (
    echo -e "$options"
    parse_selected
) | rofi_cmd)
EXIT_CODE=$?

# Reactivamos el exit (en fallo inesperado)
set -e

[[ -z "$SELECTED" ]] && exit 0

if [[ "$EXIT_CODE" -eq 10 ]]; then
    MODE="OBSIDIAN"
else
    MODE=""
fi

case "$SELECTED" in
"$SYNC")
    sync_notes
    ;;
"$TMP_NOTE")
    mkdir -p "$TEMP_PATH"
    tmp_file="$TEMP_PATH/temp_$(date +%Y%m%d-%H%M).md"
    touch "$tmp_file"
    open_content "$tmp_file"
    ;;
"$DAILY_NOTE")
    python3 "$HOME/.config/rofi/bin/dependencies/update-todos.py"
    daily_path=$(get_folder_by_pattern "$DAILY_NOTES_PATTERN")
    current_date=$(date +%d-%m-%Y)
    open_content "$daily_path/$current_date.md"
    ;;
"$NEW_NOTE")
    name=$(rofi_cmd -p "Note name:") || exit 0
    [[ "$name" != *.md ]] && name="${name}.md"

    dir=$(fd --type d --exclude .git --base-directory "$NOTE_PATH" | rofi_cmd -p "Select a folder:")

    # Fallback a la carpeta de notas rápidas si no se elige un subdirectorio
    if [[ -z "$dir" ]]; then
        dir_full=$(get_folder_by_pattern "$QUICKNOTES_PATTERN")
    else
        dir_full="$NOTE_PATH/$dir"
    fi

    final_path="$dir_full/$name"
    touch "$final_path"
    open_content "$final_path"
    ;;
*)
    open_content "$(parse_selected "$SELECTED")" "$MODE"
    ;;
esac
