#!/usr/bin/env bash
# From https://github.com/madhur/rofi-process-killer refined to use my theme and my defaults

set -e

source "$HOME/.config/rofi/bin/dependencies/rofi-core.sh"

rofi_cmd() {
    rofi_core -w "100ch" \
        -c 'listview {lines: 15;} element-text { font: "JetBrainsMono Nerd Font 10"; }' \
        -p "Kill Process"
}

get_processes() {
    local header=$(printf "%-8s | %-7s | %-7s | %-10s | %s" "PID" "CPU%" "MEM%" "USER" "COMMAND")
    # Sorting by memory
    local body=$(ps auxww --sort=-pmem --no-headers | awk '
    $11 !~ /^\\[.*\\]$/ {
        # Evitamos que el propio script aparezca
        if ($11 ~ /rofi/ || $11 ~ /process-killer/) next;
        
        printf "%-8s | %-7s | %-7s | %-10s | ", $2, $3"%", $4"%", $1
        for(i=11; i<=NF; i++) {
            printf "%s ", $i
        }
        printf "\n"
    }')

    echo -e "$header\n$body"
}

kill_process() {
    local selection="$1"

    # Don't kill the header
    [[ "$selection" == PID* ]] && exit 0

    # Get the PID
    local pid=$(echo "$selection" | awk '{print $1}')

    if [[ -z "$pid" || ! "$pid" =~ ^[0-9]+$ ]]; then
        exit 1
    fi

    # Notification of the cpu level
    local name=$(echo "$selection" | awk -F' | ' '{print $5}')

    if kill "$pid" 2>/dev/null; then
        notify-send "Proceso Terminado" "$name"
    else
        kill -9 "$pid" 2>/dev/null && notify-send "Proceso Forzado" "$name"
    fi
}

SELECTED=$(get_processes | rofi_cmd)

if [[ -n "$SELECTED" ]]; then
    kill_process "$SELECTED"
fi
