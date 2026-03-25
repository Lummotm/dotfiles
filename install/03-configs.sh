#!/usr/bin/env bash

# If executed standalone
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    source "$SCRIPT_DIR/00-utils.sh"
fi

service_install() {
    local service="$1"
    local flag="$2"

    local systemctl_cmd="sudo systemctl"
    if [[ "$flag" == "--user" ]]; then
        systemctl_cmd="systemctl --user"
    fi

    log "Habilitando y iniciando el servicio $service ..."
    if ! $systemctl_cmd enable --now "$service"; then
        log "Error: No se pudo habilitar $service."
        exit 1
    fi

    if ! $systemctl_cmd is-enabled "$service" &>/dev/null; then
        log "Error: $service no se habilitó correctamente."
        exit 1
    fi

    log "Servicio $service habilitado correctamente.  "
}

setup_mpd_service() {
    log "Configurando servicio MPD..."

    mkdir -p ~/.config/mpd ~/.config/mpd/playlists ~/.local/state/mpd
    chmod 755 ~/.config/mpd ~/.local/state/mpd
    [ -d ~/Music ] && chmod 755 ~/Music

    service_install mpd --user

    log "Servicio MPD configurado y en ejecución."
}

setup_keyd_service() {
    log "Configurando servicio keyd..."
    local KEYD_CONFIG_DEST="/etc/keyd/default.conf"
    local KEYD_CONFIG_SOURCE="$HOME/dotfiles/extra/keyd/default.conf"

    if [ ! -f "$KEYD_CONFIG_SOURCE" ]; then
        log "Error: El archivo de configuración de keyd no se encuentra en $KEYD_CONFIG_SOURCE."
        exit 1
    fi

    if [ -f "$KEYD_CONFIG_DEST" ]; then
        log "Sobrescribiendo configuración existente de keyd..."
    fi

    log "Copiando configuración de keyd..."
    sudo mkdir -p "$(dirname "$KEYD_CONFIG_DEST")"
    sudo cp "$KEYD_CONFIG_SOURCE" "$KEYD_CONFIG_DEST"

    service_install keyd

    log "Servicio keyd configurado y en ejecución."
}

setup_fish_shell() {
    log "Configurando Fish como shell por defecto..."

    local FISH_PATH="/usr/bin/fish"

    local CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)

    if [ ! -x "$FISH_PATH" ]; then
        log "Error: Fish no está instalado en $FISH_PATH"
        exit 1
    fi

    if [ "$CURRENT_SHELL" = "$FISH_PATH" ]; then
        log "Fish ya es el shell por defecto."
        return 0
    fi

    if chsh -s "$FISH_PATH"; then
        log "Shell cambiado a Fish correctamente."
        log "El cambio se aplicará en la próxima sesión."
    else
        log "Error: No se pudo cambiar el shell a Fish."
        exit 1
    fi
}

setup_login() {
    local auto_yes_flag="$1"
    local de_profile="$2"
    local machine_type="$3"

    log "Paso 6/6: Configurando el gestor de sesión..."

    case "$machine_type" in
    "desktop")
        log "Configurando para Desktop: Autologin con greetd"
        if $auto_yes_flag; then
            REPLY="y"
        else
            read -p "¿Quieres configurar autologin con greetd? (y/N): " -n 1 -r
            log
        fi

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "Saltando configuración de autologin."
            return 0
        fi

        log "Instalando dependencias de greetd..."
        sudo pacman -S --needed greetd

        local GREETD_CONFIG_DEST="/etc/greetd/config.toml"
        sudo mkdir -p "$(dirname "$GREETD_CONFIG_DEST")"
        log "Escribiendo $GREETD_CONFIG_DEST para $de_profile..."
        if [[ "$de_profile" == "niri" ]]; then
            sudo cp ~/dotfiles/extra/greetd/niri.toml "$GREETD_CONFIG_DEST"
        elif [[ "$de_profile" == "hyprland" ]]; then
            sudo cp ~/dotfiles/extra/greetd/hyprland.toml "$GREETD_CONFIG_DEST"
        fi
        service_install greetd
        log "Servicio greetd (autologin) habilitado correctamente."

        ;;

    "laptop")
        log "Configurando para Laptop: Login manager 'ly'"
        log "Esto te permitirá elegir la sesión que ejecuta el script de GPU."

        sudo pacman -S --needed ly

        sudo systemctl disable getty@tty2.service
        sudo systemctl enable ly@tty2.service

        log "Servicio 'ly' habilitado correctamente."
        log "Tus scripts de .desktop (instalados por setup_toggle_gpu) se usarán."
        ;;
    esac

    log "Configuración del gestor de sesión completada."
    log ""
}

setup_autocpufreq() {
    log "Installing autocpufreq"

    if systemctl is-enabled cpupower.service &>/dev/null; then
        log "Deshabilitando cpupower.service servicio conflictivo"
        sudo systemctl disable cpupower.service
        sudo systemctl stop cpupower.service
    fi

    if systemctl is-enabled thermald.service &>/dev/null; then
        log "Deshabilitando thermald.service servicio conflictivo"
        sudo systemctl disable thermald.service
        sudo systemctl stop thermald.service
    fi

    if systemctl is-active auto-cpufreq.service &>/dev/null; then
        log "auto-cpufreq ya esta activo removiendo"
        sudo auto-cpufreq --remove
    fi

    if sudo auto-cpufreq --install; then
        log "Instalación exitosa"

        if systemctl is-active auto-cpufreq.service &>/dev/null; then
            log "auto-cpufreq esta funcionando correctamenete"
        else
            log "auto-cpufreq no esta funcionando correctamenete"
        fi
    else
        log "Fallo al instalar auto-cpufreq"
        return 1
    fi
}

setup_toggle_gpu() {
    log "¿Quiere desactivar la gráfica NVIDIA?"
    read -p "[y/n] " -n 1 -r
    log

    local GPU_SUDOERS_SRC="$HOME/dotfiles/extra/sudoers/gpu-rules"
    local GPU_SUDOERS_DEST="/etc/sudoers.d/gpu-rules"

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Configurando GPU toggle..."

        sudo cp ~/dotfiles/extra/wayland-sessions/gpu-toggle.sh /usr/local/bin/gpu-toggle
        sudo chown root:root /usr/local/bin/gpu-toggle
        sudo chmod 755 /usr/local/bin/gpu-toggle

        if [ -f "$GPU_SUDOERS_SRC" ]; then
            sudo cp "$GPU_SUDOERS_SRC" "$GPU_SUDOERS_DEST"
            sudo chown root:root "$GPU_SUDOERS_DEST"
            sudo chmod 440 "$GPU_SUDOERS_DEST"

            if ! sudo visudo -c; then
                log "Error en gpu-rules. Revirtiendo..."
                sudo rm "$GPU_SUDOERS_DEST"
                return 1
            fi
        fi

        sudo mkdir -p /usr/share/wayland-sessions/
        sudo cp ~/dotfiles/extra/wayland-sessions/niri.desktop /usr/share/wayland-sessions/niri.desktop
        sudo cp ~/dotfiles/extra/wayland-sessions/hyprland.desktop /usr/share/wayland-sessions/hyprland.desktop

        log "GPU toggle configurado correctamente"
    else
        log "Configuración de GPU toggle omitida"
    fi
}

setup_general_sudoers() {
    log "Configurando reglas generales de sudoers (custom-rules)..."
    local GENERAL_SRC="$HOME/dotfiles/extra/sudoers/custom-rules"
    local GENERAL_DEST="/etc/sudoers.d/custom-rules"

    if [ -f "$GENERAL_SRC" ]; then
        sudo cp "$GENERAL_SRC" "$GENERAL_DEST"
        sudo chown root:root "$GENERAL_DEST"
        sudo chmod 440 "$GENERAL_DEST"

        if ! sudo visudo -c; then
            log "Error en custom-rules. Revirtiendo..."
            sudo rm "$GENERAL_DEST"
            return 1
        fi
        log "Reglas generales aplicadas correctamente."
    fi
}

setup_laptop_sudoers() {
    log "Configurando reglas de sudoers para portátil (laptop-rules)..."
    local LAPTOP_SRC="$HOME/dotfiles/extra/sudoers/laptop-rules"
    local LAPTOP_DEST="/etc/sudoers.d/laptop-rules"

    if [ -f "$LAPTOP_SRC" ]; then
        sudo cp "$LAPTOP_SRC" "$LAPTOP_DEST"
        sudo chown root:root "$LAPTOP_DEST"
        sudo chmod 440 "$LAPTOP_DEST"

        if ! sudo visudo -c; then
            log "Error en laptop-rules. Revirtiendo..."
            sudo rm "$LAPTOP_DEST"
            return 1
        fi
        log "Reglas de batería aplicadas correctamente."
    fi
}

setup_hotspot_network() {
    log "Configurando red para Hotspot (Forwarding y UFW)..."

    # Detectar interfaces automáticamente
    local ETH_INT=$(nmcli -t -f DEVICE,TYPE device status | grep ":ethernet" | head -n1 | cut -d: -f1)
    local WIFI_INT=$(nmcli -t -f DEVICE,TYPE device status | grep ":wifi" | head -n1 | cut -d: -f1)

    if [[ -z "$ETH_INT" || -z "$WIFI_INT" ]]; then
        log "Advertencia: No se detectaron ambas interfaces (Ethernet/Wi-Fi). Saltando configuración de red."
        return 1
    fi

    # IP Forwarding permanente
    log "Habilitando IP Forwarding..."
    echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-hotspot.conf
    sudo sysctl --system

    # Reglas de UFW (Permanentes)
    log "Configurando reglas de UFW para $WIFI_INT -> $ETH_INT"
    sudo ufw route allow in on "$WIFI_INT" out on "$ETH_INT"
    sudo ufw allow in on "$WIFI_INT" to any port 67 proto udp
    sudo ufw allow in on "$WIFI_INT" to any port 53

    # Asegurar que UFW esté activo
    sudo ufw --force enable
}

setup_nm_hotspot_connection() {
    log "Creando conexión de NetworkManager para Hotspot..."

    local WIFI_INT=$(nmcli -t -f DEVICE,TYPE device status | grep ":wifi" | head -n1 | cut -d: -f1)
    local CON_NAME="Hotspot"
    local SSID="Hostpot"
    local PASS="ThinkingRock123"

    # Borrar si ya existe
    nmcli con delete "$CON_NAME" 2>/dev/null || true

    # Crear conexión con los parámetros de seguridad que funcionan para tu MediaTek
    nmcli con add type wifi ifname "$WIFI_INT" con-name "$CON_NAME" autoconnect no ssid "$SSID" \
        802-11-wireless.mode ap \
        802-11-wireless-security.key-mgmt wpa-psk \
        802-11-wireless-security.psk "$PASS" \
        802-11-wireless-security.proto rsn \
        802-11-wireless-security.group ccmp \
        802-11-wireless-security.pairwise ccmp \
        802-11-wireless-security.pmf 0 \
        ipv4.method shared

    log "Conexión $CON_NAME creada correctamente."
}

setup_crucial_disk_fstab() {
    log "Configurando montaje automático para Crucial X9 en fstab..."

    local TARGET_UUID="D0668FA2668F87C4"
    local MOUNT_POINT="/run/media/$USER/Crucial_X9"

    local FSTAB_LINE="UUID=$TARGET_UUID  $MOUNT_POINT  ntfs3  defaults,user,uid=1000,gid=1000,umask=000,rw,exec,windows_names,iocharset=utf8,nofail  0  0"

    if grep -q "$TARGET_UUID" /etc/fstab; then
        log "El UUID del Crucial X9 ya existe en /etc/fstab. Omitiendo configuración."
        return 0
    fi

    log "Verificando sintaxis de la nueva entrada..."

    if [ ! -d "$MOUNT_POINT" ]; then
        log "Creando punto de montaje para validación..."
        sudo mkdir -p "$MOUNT_POINT"
    fi

    # Archivos temporales para validación segura
    local temp_fstab=$(mktemp /tmp/fstab.XXXXXX)
    local temp_output=$(mktemp /tmp/fstab_check.XXXXXX)

    cp /etc/fstab "$temp_fstab"
    echo "$FSTAB_LINE" >>"$temp_fstab"

    if findmnt --verify --tab-file "$temp_fstab" >"$temp_output" 2>&1; then
        log "Sintaxis validada correctamente. Escribiendo en /etc/fstab..."
        echo -e "\n# Crucial X9 para Steam\n$FSTAB_LINE" | sudo tee -a /etc/fstab >/dev/null

        # Recargar para que systemd se entere de los cambios
        sudo systemctl daemon-reload

        log "Intentando montar..."
        # Si el disco no está conectado no pasa nada, fallará silenciosamente y avisará
        if sudo mount "$MOUNT_POINT" 2>/dev/null; then
            log "Disco montado con éxito en $MOUNT_POINT"
        else
            log "Disco no conectado en este momento, se montará automáticamente cuando se enchufe."
        fi
    else
        log "ERROR CRÍTICO EN FSTAB: La sintaxis no es válida. Abortando configuración del disco."
        grep "\[E\]" "$temp_output" || cat "$temp_output"
        rm -f "$temp_fstab" "$temp_output"
        return 1
    fi

    rm -f "$temp_fstab" "$temp_output"
}

setup_services_and_configs() {
    local machine_type="$1"
    local de_profile="$2"

    log "Paso 4/5: Configurando servicios del sistema..."

    setup_general_sudoers
    setup_mpd_service
    setup_keyd_service
    setup_fish_shell
    service_install bluetooth
    setup_crucial_disk_fstab

    if [[ $machine_type == "laptop" ]]; then
        log "Configurando servicios específicos de portátil..."
        setup_laptop_sudoers
        setup_autocpufreq
        setup_toggle_gpu
        setup_nm_hotspot_connection
        setup_hotspot_network
    else
        log "Omitiendo configuración de servicios de portátil."
    fi

    log "Servicios del sistema configurados."
    echo ""
}

# Main execution
# If executed standalone
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    # Validaciones básicas
    if [ -z "$1" ] || [ -z "$2" ]; then
        log "Error: Se requieren argumentos."
        log "Uso: $0 <laptop|desktop> <niri|hyprland> [modulo1] [modulo2] ..."
        log "Módulos disponibles: hotspot, gpu, login, all"
        exit 1
    fi

    MACHINE="$1"
    PROFILE="$2"
    shift 2

    validate_input "$MACHINE"

    # Si no le pasamos ningún módulo extra, asumimos "all"
    if [ $# -eq 0 ]; then
        MODULES=("all")
    else
        MODULES=("$@") # Guardamos todos los argumentos restantes en un array
    fi

    # Procesamos cada módulo uno por uno
    for MODULE in "${MODULES[@]}"; do
        case "$MODULE" in
        "hotspot")
            log "Re-configurando módulo: Hotspot..."
            setup_nm_hotspot_connection
            setup_hotspot_network
            ;;
        "gpu")
            log "Re-configurando módulo: GPU Toggle..."
            setup_toggle_gpu
            ;;
        "login")
            log "Re-configurando módulo: Autologin / Display Manager..."
            setup_login "false" "$PROFILE" "$MACHINE"
            ;;
        "disk")
            log "Re-configurando módulo: Disco Crucial X9..."
            setup_crucial_disk_fstab
            ;;
        "all")
            log "Ejecutando configuración completa (all)..."
            setup_services_and_configs "$MACHINE" "$PROFILE"
            log "---"
            setup_login "false" "$PROFILE" "$MACHINE"
            ;;
        *)
            log "Error: Módulo '$MODULE' no reconocido. Omitiendo..."
            ;;
        esac
    done
fi
