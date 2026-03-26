#!/usr/bin/env bash

# If executed standalone
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
    source "$SCRIPT_DIR/00-utils.sh"
fi

install_packages_smart() {
    local packages=("$@")
    local official_packages=()
    local aur_packages=()

    if ! command -v yay &>/dev/null; then
        log "Yay no encontrado. Instalando Yay..."
        sudo pacman -S --noconfirm --needed git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay_install
        (cd /tmp/yay_install && makepkg -si --noconfirm)

        if ! command -v yay &>/dev/null; then
            echo "Error: yay no se instaló correctamente"
            exit 1
        fi
        log "Yay instalado correctamente."
    fi

    local missing_packages
    mapfile -t missing_packages < <(pacman -T "${packages[@]}")

    if [ ${#missing_packages[@]} -eq 0 ]; then
        log "Todos los paquetes ya están instalados. Saltando..."
        return 0
    fi

    log "Faltan ${#missing_packages[@]} paquetes. Clasificando..."

    local db_pkgs
    mapfile -t db_pkgs < <(pacman -Slq)

    for pkg in "${missing_packages[@]}"; do
        if printf "%s\n" "${db_pkgs[@]}" | grep -qx "$pkg"; then
            official_packages+=("$pkg")
        else
            aur_packages+=("$pkg")
        fi
    done

    if [ ${#official_packages[@]} -gt 0 ]; then
        log "Instalando ${#official_packages[@]} paquetes oficiales con pacman..."
        sudo pacman -S --needed --noconfirm "${official_packages[@]}" || {
            log "Error instalando el grupo de paquetes oficiales, reintentando de uno en uno..."
            for pkg in "${official_packages[@]}"; do
                sudo pacman -S --needed --noconfirm "$pkg" || log "Error al instalar $pkg (oficial), saltando..."
            done
        }
    fi

    if ping -c 1 aur.archlinux.org &>/dev/null; then
        if [ ${#aur_packages[@]} -gt 0 ]; then
            log "Instalando ${#aur_packages[@]} paquetes de AUR con yay..."
            yay -S --needed --noconfirm "${aur_packages[@]}" || {
                log "Error instalando el grupo de paquetes AUR, reintentando de uno en uno..."
                for pkg in "${aur_packages[@]}"; do
                    yay -S --needed --noconfirm "$pkg" || log "Error al instalar $pkg (AUR), saltando..."
                done
            }
        fi
    fi
}

install_all_packages() {
    local machine_type="$1"
    local de_profile="$2"
    local gpu_type="$3"
    local packages
    local ALL_PACKAGES=()

    local PKG_CORE=(
        git stow base-devel pipewire pipewire-alsa pipewire-pulse libpulse
        unzip unrar 7zip ncdu fish tmux starship reflector inotify-tools
        zip expect bc libgit2 libmpdclient
    )

    local PKG_USER_APPS=(
        neovim vlc vlc-plugin-ffmpeg mpd mpc rmpc yazi btop eza fzf zoxide
        sioyek-git mpd-mpris kitty npm zen-browser-bin yt-dlp keepassxc
        discord lazygit wikiman man-db man-pages arch-wiki-docs steam
        proton-ge-custom-bin protonplus heroic-games-launcher-bin
        calibre-bin udsiks2 proton-vpn-gtk-app gimp atlauncher-bin
        obsidian-bin anki-bin qpdf transmission-qt perl-image-exiftool
    )

    local PKG_NVIM_DEPS=(
        tree-sitter tree-sitter-c tree-sitter-cli tree-sitter-lua
        tree-sitter-markdown tree-sitter-query tree-sitter-vim tree-sitter-vimdoc
        python python-pip gcc clang make cmake typst nodejs
    )

    local PKG_DE_GENERAL=(
        libxkbcommon-x11 libdecor rofi rofi-calc waybar swww cliphist keyd
        pywal nwg-look aurutils polkit-gnome tumbler gvfs-mtp sxiv hyprlock dunst gtk2
    )

    local PKG_LAPTOP=(
        brightnessctl auto-cpufreq
    )
    
    local PKG_DESKTOP=()

    local PKG_NIRI=(
        niri xwayland-satellite xdg-desktop-portal-gnome
    )
    
    local PKG_HYPRLAND=(
        hyprland hyprcursor hyprgraphics hyprland-qt-support hyprland-qtutils
        hyprlang hyprshot hyprsunset hyprwayland-scanner xdg-desktop-portal-hyprland hyprutils
    )

    local PKG_GPU=()
    if [[ "$gpu_type" == *"amd"* ]]; then
        PKG_GPU+=(amd-ucode mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon xf86-video-amdgpu linux-firmware-amdgpu)
        log "Añadiendo paquetes de GPU: AMD"
    fi
    if [[ "$gpu_type" == *"intel"* ]]; then
        PKG_GPU+=(intel-ucode mesa lib32-mesa vulkan-intel lib32-vulkan-intel)
        log "Añadiendo paquetes de GPU: Intel"
    fi
    if [[ "$gpu_type" == *"nvidia"* ]]; then
        PKG_GPU+=(nvidia nvidia-utils lib32-nvidia-utils egl-wayland)
        log "Añadiendo paquetes de GPU: NVIDIA"
    fi

    # Construir la lista total
    ALL_PACKAGES+=(
        "${PKG_CORE[@]}"
        "${PKG_USER_APPS[@]}"
        "${PKG_NVIM_DEPS[@]}"
        "${PKG_DE_GENERAL[@]}"
        "${PKG_GPU[@]}"
    )

    if [[ "$machine_type" == "laptop" ]]; then
        ALL_PACKAGES+=("${PKG_LAPTOP[@]}")
        log "Añadiendo paquetes de 'laptop'."
    elif [[ "$machine_type" == "desktop" ]]; then
        ALL_PACKAGES+=("${PKG_DESKTOP[@]}")
        log "Añadiendo paquetes de 'desktop'."
    fi

    if [[ "$de_profile" == "niri" ]]; then
        ALL_PACKAGES+=("${PKG_NIRI[@]}")
        log "Añadiendo paquetes de 'niri'."
    elif [[ "$de_profile" == "hyprland" ]]; then
        ALL_PACKAGES+=("${PKG_HYPRLAND[@]}")
        log "Añadiendo paquetes de 'hyprland'."
    fi

    # Undupe packages
    mapfile -t packages < <(printf '%s\n' "${ALL_PACKAGES[@]}" | sort -u)

    if [ ${#packages[@]} -eq 0 ]; then
        log "No se encontraron paquetes para instalar. Saltando."
        return
    fi

    log "Se procesarán ${#packages[@]} paquetes únicos."
    install_packages_smart "${packages[@]}"
    log "Instalación de paquetes completada."
    echo ""
}

# Standalone
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        log "Error: Se requieren argumentos."
        log "Uso: $0 <laptop|desktop> <niri|hyprland> <amd|nvidia|intel|amd+nvidia|intel+nvidia>"
        exit 1
    fi
    validate_input "$1"

    if [[ ! "$2" =~ ^(niri|hyprland)$ ]]; then
        log "Error: Perfil DE debe ser 'niri' o 'hyprland'"
        exit 1
    fi

    install_all_packages "$1" "$2" "$3"
fi
