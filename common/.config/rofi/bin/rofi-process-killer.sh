#!/usr/bin/env bash
# Process killer con rofi - diseñado para funcionar desde rofi-center

source "$HOME/.config/rofi/bin/dependencies/rofi-core.sh" 2>/dev/null || true

rofi_cmd() {
    rofi_core -w "100ch" \
        -c 'listview {lines: 10;}' \
        -p "Kill Process" \
        -i
}

get_processes() {
    local header=$(printf "%-8s | %-7s | %-7s | %-10s | %s" "PID" "CPU%" "MEM%" "USER" "COMMAND")

    # 1. ps extrae ordenado por memoria (--sort=-pmem)
    # 2. awk filtra la basura y añade la longitud del comando al inicio
    # 3. head -50 atrapa las 50 aplicaciones más pesadas (los padres y sus derivados)
    # 4. sort -k1,1n ordena ESOS 50 por el texto más corto
    # 5. cut quita el número de longitud antes de enviarlo a Rofi

    local body=$(ps auxww --sort=-pmem --no-headers 2>/dev/null | awk '
    {
        cmd = $11
        full_cmd = ""
        for(i=11; i<=NF; i++) full_cmd = full_cmd $i " "
        
        # Filtros básicos
        if (cmd ~ /^\[/ || cmd ~ /rofi/ || cmd ~ /awk/ || cmd ~ /ps / || cmd ~ /bash.*process-killer/) next;
        if (cmd ~ /^systemd/ && cmd !~ /--user/ && length(cmd) < 50) next;
            
        printf "%d|%-8s | %-7s | %-7s | %-10s | %s\n", length(full_cmd), $2, $3"%", $4"%", $1, full_cmd
    }' | head -50 | sort -t'|' -k1,1n | cut -d'|' -f2-)

    echo -e "$header"
    echo "$body"
}

kill_process() {
    local selection="$1"

    # Ignorar si es header o está vacío
    [[ "$selection" == PID* || -z "$selection" ]] && exit 0

    # Extraer PID (primera columna antes del |)
    local pid=$(echo "$selection" | awk -F'|' '{print $1}' | xargs)

    # Validar que sea número
    if [[ ! "$pid" =~ ^[0-9]+$ ]]; then
        exit 1
    fi

    # Extraer nombre del proceso
    local name=$(echo "$selection" | awk -F' | ' '{print $5}' | xargs | cut -d' ' -f1)

    # Intentar kill normal primero, luego -9
    if kill "$pid" 2>/dev/null; then
        notify-send -u low "✓ Proceso Terminado" "$name (PID: $pid)"
        exit 0
    fi

    if kill -9 "$pid" 2>/dev/null; then
        notify-send -u normal "⚡ Proceso Forzado" "$name (PID: $pid)"
        exit 0
    fi

    notify-send -u critical "✗ Error" "No se pudo matar el proceso $pid"
    exit 1
}

# Programa principal
main() {
    local processes=$(get_processes)

    if [[ -z "$processes" ]]; then
        exit 0
    fi

    # Mostrar en rofi y capturar selección
    SELECTED=$(echo "$processes" | rofi_cmd)
    EXIT_CODE=$?

    # Si cancela rofi (Escape), no hacer nada
    [[ $EXIT_CODE -ne 0 || -z "$SELECTED" ]] && exit 0

    # Matar el proceso seleccionado
    kill_process "$SELECTED"
}

main "$@"
