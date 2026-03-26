#!/usr/bin/env bash

set -e
auto_yes=false
machine_type=""
de_profile=""
gpu_type=""
is_personal=false
dry_run=false

if [[ "$USER" == "davidn" ]]; then
    is_personal=true
fi

interactive_wizard() {
    clear
    echo "Asistente de instalación"
    echo 
    read -p "1. ¿Ejecutar en modo DRY-RUN? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then dry_run=true; fi
    echo ""
    
    echo "2. ¿Qué tipo de máquina es esta?"
    select type in "laptop" "desktop" "salir"; do
        case $type in laptop|desktop) machine_type=$type; break ;; salir) exit 0 ;; *) echo "Opción inválida." ;; esac
    done
    echo

    echo "3. ¿Qué Entorno de Escritorio quieres instalar?"
    select profile in "niri" "hyprland" "salir"; do
        case $profile in niri|hyprland) de_profile=$profile; break ;; salir) exit 0 ;; *) echo "Opción inválida." ;; esac
    done
    echo ""

    echo "4. Selecciona tus drivers gráficos:"
    select gpu in "amd" "nvidia" "intel" "amd+nvidia" "intel+nvidia" "ninguna" "salir"; do
        case $gpu in 
            amd|nvidia|intel|amd+nvidia|intel+nvidia) gpu_type=$gpu; break ;; 
            ninguna) gpu_type="none"; break ;;
            salir) exit 0 ;; 
            *) echo "Opción inválida." ;; 
        esac
    done
    echo ""

}

if [[ $# -eq 0 ]]; then
    interactive_wizard
else
    while [[ $# -gt 0 ]]; do
        case "$1" in
        -y | --yes) auto_yes=true ;;
        --personal) is_personal=true ;;
        -d | --dry-run) dry_run=true ;;
        laptop | desktop) machine_type="$1" ;;
        niri | hyprland) de_profile="$1" ;;
        amd|nvidia|intel|amd+nvidia|intel+nvidia|none) gpu_type="$1" ;;
        *)
            echo "Uso: $0 <laptop|desktop> <niri|hyprland> [gpu] [-y|--yes] [--personal] [-d|--dry-run]"
            exit 1
            ;;
        esac
        shift
    done
fi

if [ -z "$machine_type" ] || [ -z "$de_profile" ] || [ -z "$gpu_type" ]; then
    echo "Faltan parámetros esenciales."
    sleep 1
    interactive_wizard
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/00-utils.sh"
source "$SCRIPT_DIR/01-dotfiles.sh"
source "$SCRIPT_DIR/02-packages.sh"
source "$SCRIPT_DIR/03-configs.sh"

print_summary_and_check() {
    clear
    echo "Plan de instalación:"
    echo " Máquina       : $machine_type"
    echo " Entorno       : $de_profile"
    echo " Gráfica       : $gpu_type"
    echo " Modo Personal : $is_personal"
    echo " Auto-Yes      : $auto_yes"
    echo " Dry-Run Mode  : $dry_run"
    echo ""
    echo " Acciones:"
    echo "  1. Actualizar repositorios y sistema"
    echo "  2. Instalar yay"
    echo "  3. Clonar y aplicar Dotfiles"
    echo "  4. Instalar lista masiva de paquetes"
    
    if [[ "$gpu_type" != "none" ]]; then
        echo "  5. Instalar drivers de GPU ($gpu_type)"
    else
        echo "  5. Omitir instalación de drivers gráficos"
    fi
    
    echo "  6. Configurar servicios base"
    
    if [[ "$machine_type" == "laptop" ]]; then
        echo "  7. Configurar optimizaciones de batería"
    fi

    if [[ "$is_personal" == "true" ]]; then
        echo "  * [Personal] Configurar fstab"
        if [[ "$machine_type" == "laptop" ]]; then
            echo "  * [Personal] Configurar Hotspot y red"
            echo "  * [Personal] Instalar script GPU Toggle y Ly"
        fi
    fi

    if [[ "$is_personal" != "true" || "$machine_type" == "desktop" ]]; then
        echo "  8. Configurar Autologin con Greetd"
    fi
    echo ""

    if [[ "$dry_run" == "true" ]]; then
        echo "[DRY-RUN]: No se ha realizado ninguna modificación."
        exit 0
    fi

    if [[ "$auto_yes" != "true" ]]; then
        read -p "¿Continuar con la instalación real? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Instalación abortada."
            exit 0
        fi
    fi
}

main_installation() {
    sleep 1
    validate_input "$machine_type"
    check_internet
    check_disk_space
    perform_system_update

    install_dotfiles "$machine_type"
    install_all_packages "$machine_type" "$de_profile" "$gpu_type"
    setup_services_and_configs "$machine_type" "$de_profile" "$is_personal"
    setup_login "$auto_yes" "$de_profile" "$machine_type" "$is_personal"

    log "Instalación completada."

    if $auto_yes; then
        sleep 5
        REPLY="y"
    else
        read -p "¿Reiniciar ahora? (y/N): " -n 1 -r
        echo
    fi

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        reboot
    fi
}

print_summary_and_check
main_installation
