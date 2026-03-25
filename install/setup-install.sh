#!/usr/bin/env bash

set -e
auto_yes=false
machine_type=""
de_profile=""

while [[ $# -gt 0 ]]; do
    case "$1" in
    -y | --yes)
        auto_yes=true
        ;;
    laptop | desktop)
        machine_type="$1"
        ;;
    niri | hyprland)
        de_profile="$1"
        ;;
    *)
        echo "Uso: $0 <laptop|desktop> <niri|hyprland> [-y|--yes]"
        exit 1
        ;;
    esac
    shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/00-utils.sh"
source "$SCRIPT_DIR/01-dotfiles.sh"
source "$SCRIPT_DIR/02-packages.sh"
source "$SCRIPT_DIR/03-configs.sh"

# Menús interactivos
if [ -z "$machine_type" ]; then
    log "Elige el tipo de máquina:"
    # Opciones: "laptop" "desktop" y "salir"
    select type in "laptop" "desktop" "salir"; do
        case $type in
        laptop | desktop)
            machine_type=$type
            break
            ;;
        salir)
            echo "Instalación cancelada."
            exit 0
            ;;
        *) echo "Opción inválida. Intenta de nuevo." ;;
        esac
    done
fi

if [ -z "$de_profile" ]; then
    log "Elige el perfil de Entorno de Escritorio:"
    # Opciones: "niri" "hyprland" y "salir"
    select profile in "niri" "hyprland" "salir"; do
        case $profile in
        niri | hyprland)
            de_profile=$profile
            break
            ;;
        salir)
            echo "Instalación cancelada."
            exit 0
            ;;
        *) echo "Opción inválida. Intenta de nuevo." ;;
        esac
    done
fi

# Función principal
main_installation() {
    log "Iniciando instalación..."
    log "MÁQUINA: $machine_type | PERFIL: $de_profile"

    validate_input "$machine_type"
    check_internet
    check_disk_space
    perform_system_update

    install_dotfiles "$machine_type"
    install_all_packages "$machine_type" "$de_profile"
    setup_services_and_configs "$machine_type" "$de_profile"
    setup_autologin "$auto_yes" "$de_profile" "$machine_type"

    log "Instalación completada."

    if $auto_yes; then
        echo "Flag de auto_yes aplicada. Se reiniciará en 5 seg."
        sleep 5
        REPLY="y"
    else
        log "Recuerda reiniciar o iniciar tu sesión"
        read -p "¿Quieres reiniciar? (y/N): " -n 1 -r
        echo
    fi

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        reboot
    fi
}

# Comprobación final antes de ejecutar
if [ -n "$machine_type" ] && [ -n "$de_profile" ]; then
    main_installation
else
    log "Error: Faltaron variables (machine_type o de_profile). Abortando."
    exit 1
fi
