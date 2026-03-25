#!/usr/bin/env bash
log() {
    echo "[$(date '+%H:%M:%S')] $1"
    echo "[$(date '+%H:%M:%S')] $1" >>"$HOME/install_dotfiles.log"

}

cleanup() {
    rm -rf /tmp/yay_install 2>/dev/null || true
}

trap cleanup exit

validate_input() {
    local machine_type="$1"
    if [[ ! "$machine_type" =~ ^(laptop|desktop)$ ]]; then
        echo "Error: Tipo de máquina debe ser 'laptop' o 'desktop'"
        exit 1
    fi
}

check_internet() {
    if ! ping -c 1 github.com &>/dev/null; then
        echo "Error: No hay conexión a internet"
        exit 1
    fi
}

check_disk_space() {
    local available
    available=$(df / | awk 'NR==2{print $4}')

    # Check if there are 10GB (more than needed)
    if [ "$available" -lt 10000000 ]; then
        log "Advertencia: Poco espacio en disco disponible"
    fi
}

perform_system_update() {
    log "Paso 1/6: Actualizando el sistema..."
    log "Ordenando Mirrors"
    if ! sudo reflector --latest 10 --sort rate --protocol https --country Spain,France,Germany --save /etc/pacman.d/mirrorlist; then
        log "Reflector falló, reintentando..."
        sleep 2
        sudo reflector --latest 10 --sort rate --protocol https --country Spain,France,Germany --save /etc/pacman.d/mirrorlist || {
            log "Reflector falló dos veces, continuando sin actualizar mirrors..."
        }
    fi
    sudo pacman -Syu --noconfirm --needed
    log "Sistema actualizado."

    echo ""
}

# If executed standalone
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    log "Script de utilidades cargado."
    log "Probando check_internet..."
    check_internet
    log "Probando check_disk_space..."
    check_disk_space
    log "Pruebas de utils completadas."
fi
