#!/usr/bin/env bash
set -e

IS_PERSONAL=false
[[ "$USER" == "davidn" ]] && IS_PERSONAL=true
PS3="Introduce el número de tu elección: "

log() {
    echo -e "\n[$(date '+%H:%M:%S')] $1"
    echo "[$(date '+%H:%M:%S')] $1" >>"$HOME/install_dotfiles.log"
}

trap 'rm -rf /tmp/yay_install 2>/dev/null || true' EXIT

service_install() {
    local service="$1"
    local flag="$2"
    local cmd="sudo systemctl"
    [[ "$flag" == "--user" ]] && cmd="systemctl --user"
    $cmd enable --now "$service" 2>/dev/null || log "Advertencia: No se pudo habilitar $service"
}

ask_machine_type() {
    [[ -n "$machine_type" ]] && return
    echo -e "\n¿Qué tipo de máquina es esta?"
    select machine_type in "laptop" "desktop" "salir"; do
        case $machine_type in
        laptop | desktop) break ;;
        salir) exit 0 ;;
        *) echo "Opción inválida. Inténtalo de nuevo." ;;
        esac
    done
}

ask_de_profile() {
    [[ -n "$de_profile" ]] && return
    echo -e "\n¿Qué Entorno de Escritorio quieres instalar?"
    select de_profile in "niri" "hyprland" "salir"; do
        case $de_profile in
        niri | hyprland) break ;;
        salir) exit 0 ;;
        *) echo "Opción inválida. Inténtalo de nuevo." ;;
        esac
    done
}

ask_gpu_type() {
    [[ -n "$gpu_type" ]] && return
    echo -e "\nSelecciona tus drivers gráficos:"
    select gpu_type in "amd" "nvidia" "intel" "amd+nvidia" "intel+nvidia" "ninguna" "salir"; do
        case $gpu_type in
        amd | nvidia | intel | amd+nvidia | intel+nvidia | ninguna) break ;;
        salir) exit 0 ;;
        *) echo "Opción inválida. Inténtalo de nuevo." ;;
        esac
    done
}

ask_autoyes() {
    [[ -n "$autoyes" ]] && return
    read -p "¿Autoconfirmar todas las instalaciones y reiniciar al terminar? (y/N): " -n 1 -r autoyes
    echo
}

check_basics() {
    log "Comprobando conexión y espacio..."
    ping -c 1 github.com &>/dev/null || {
        echo "Error: Sin internet"
        exit 1
    }
    local available=$(df / | awk 'NR==2{print $4}')
    [ "$available" -lt 10000000 ] && log "Advertencia: Poco espacio en disco (< 10GB)"
}

setup_custom_repo() {
    log "Añadiendo repositorio personalizado oglo-arch-repo..."
    if ! grep -q "\[oglo-arch-repo\]" /etc/pacman.conf; then
        echo -e '\n[oglo-arch-repo]\nSigLevel = Optional DatabaseOptional\nServer = https://gitlab.com/Oglo12/$repo/-/raw/main/$arch' | sudo tee -a /etc/pacman.conf >/dev/null
        sudo pacman -Sy
    else
        log "El repositorio oglo-arch-repo ya estaba configurado."
    fi
}

update_system_and_yay() {
    log "Actualizando sistema e instalando yay..."
    sudo reflector --latest 10 --sort rate --protocol https --country Spain,France,Germany --save /etc/pacman.d/mirrorlist || true
    sudo pacman -Syu --noconfirm --needed base-devel git

    if ! command -v yay &>/dev/null; then
        git clone https://aur.archlinux.org/yay.git /tmp/yay_install
        (cd /tmp/yay_install && makepkg -si --noconfirm)
    fi
}

install_all_packages() {
    local PKG_CORE=(
        git stow base-devel pipewire pipewire-alsa pipewire-pulse libpulse
        unzip unrar 7zip ncdu fish tmux starship reflector inotify-tools
        zip expect bc libgit2 libmpdclient
    )
    local PKG_USER_APPS=(
        neovim vlc vlc-plugin-ffmpeg mpd mpc rmpc yazi btop eza fzf zoxide
        sioyek-git mpd-mpris kitty npm zen-browser-bin yt-dlp keepassxc
        discord lazygit wikiman man-db man-pages arch-wiki-docs steam
        proton-ge-custom-bin protonplus heroic-games-launcher-bin calibre-bin
        udisks2 proton-vpn-gtk-app gimp atlauncher-bin obsidian-bin anki-bin
        qpdf transmission-qt perl-image-exiftool
    )
    local PKG_NVIM_DEPS=(
        tree-sitter tree-sitter-c tree-sitter-cli tree-sitter-lua
        tree-sitter-markdown tree-sitter-query tree-sitter-vim tree-sitter-vimdoc
        python python-pip gcc clang make cmake typst nodejs
    )
    local PKG_DE_GENERAL=(
        libxkbcommon-x11 libdecor rofi rofi-calc waybar swww cliphist keyd
        pywal nwg-look aurutils polkit-gnome tumbler gvfs-mtp sxiv hyprlock
        dunst gtk2
    )
    local PKG_LAPTOP=(brightnessctl auto-cpufreq)
    local PKG_NIRI=(niri xwayland-satellite xdg-desktop-portal-gnome)
    local PKG_HYPRLAND=(
        hyprland hyprcursor hyprgraphics hyprland-qt-support hyprland-qtutils
        hyprlang hyprshot hyprsunset hyprwayland-scanner xdg-desktop-portal-hyprland
        hyprutils
    )
    local PKG_GPU=()

    if [[ "$gpu_type" == *"amd"* ]]; then
        PKG_GPU+=(amd-ucode mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon xf86-video-amdgpu linux-firmware-amdgpu)
    fi
    if [[ "$gpu_type" == *"intel"* ]]; then
        PKG_GPU+=(intel-ucode mesa lib32-mesa vulkan-intel lib32-vulkan-intel)
    fi
    if [[ "$gpu_type" == *"nvidia"* ]]; then
        PKG_GPU+=(nvidia nvidia-utils lib32-nvidia-utils egl-wayland)
    fi

    local ALL_PACKAGES=("${PKG_CORE[@]}" "${PKG_USER_APPS[@]}" "${PKG_NVIM_DEPS[@]}" "${PKG_DE_GENERAL[@]}" "${PKG_GPU[@]}")

    if [[ "$machine_type" == "laptop" ]]; then ALL_PACKAGES+=("${PKG_LAPTOP[@]}"); fi
    if [[ "$de_profile" == "niri" ]]; then ALL_PACKAGES+=("${PKG_NIRI[@]}"); fi
    if [[ "$de_profile" == "hyprland" ]]; then ALL_PACKAGES+=("${PKG_HYPRLAND[@]}"); fi

    mapfile -t packages < <(printf '%s\n' "${ALL_PACKAGES[@]}" | sort -u)

    log "Instalando paquetes. Primero mediante pacman para mayor velocidad..."
    sudo pacman -S --needed --noconfirm "${packages[@]}" 2>/dev/null || true

    log "Asegurando paquetes restantes y de AUR con yay..."
    set +e
    yay -S --needed --noconfirm "${packages[@]}"
    set -e
}

setup_dotfiles() {
    log "Clonando y aplicando dotfiles..."
    local REPO_DIR="$HOME/dotfiles"
    [ ! -d "$REPO_DIR" ] && git clone "https://github.com/Lummotm/dotfiles" "$REPO_DIR"

    cd "$REPO_DIR"
    log "Ajustando variables de usuario en archivos de configuración..."
    find . -type f -not -path "*/\.git/*" -not -name "*.7z" -not -name "*.zip" -not -name "*.png" -not -name "*.jpg" -exec sed -i "s/davidn/$USER/g" {} + 2>/dev/null || true

    local APPLY_SCRIPT="$REPO_DIR/install/apply.sh"
    if [ -f "$APPLY_SCRIPT" ]; then
        chmod +x "$APPLY_SCRIPT"
        "$APPLY_SCRIPT" "$machine_type"
    else
        log "Error: Script de aplicación no encontrado en $APPLY_SCRIPT"
    fi
}

setup_mpd_service() {
    log "Configurando MPD..."
    mkdir -p ~/.config/mpd/playlists ~/.local/state/mpd
    chmod 755 ~/.config/mpd ~/.local/state/mpd
    [ -d ~/Music ] && chmod 755 ~/Music
    service_install mpd --user
}

setup_keyd_service() {
    log "Configurando keyd..."
    local src="$HOME/dotfiles/extra/keyd/default.conf"
    if [ -f "$src" ]; then
        sudo mkdir -p /etc/keyd
        sudo cp "$src" /etc/keyd/default.conf
        service_install keyd
    fi
}

setup_fish_shell() {
    log "Configurando Fish..."
    local current=$(getent passwd "$USER" | cut -d: -f7)
    [ "$current" != "/usr/bin/fish" ] && sudo chsh -s /usr/bin/fish "$USER" || true
}

setup_login() {
    log "Configurando el acceso al sistema..."

    sudo systemctl disable ly.service ly@tty2.service greetd sddm getty@tty2.service 2>/dev/null || true
    sudo rm -f /etc/systemd/system/getty@tty1.service.d/autologin.conf 2>/dev/null
    sudo systemctl daemon-reload

    if [[ "$machine_type" == "desktop" ]]; then
        log "Configurando Greetd (Autologin) para Desktop..."

        sudo pacman -S --needed --noconfirm greetd

        local greetd_config="$HOME/dotfiles/extra/greetd/$([[ "$de_profile" == "niri" ]] && echo "niri.toml" || echo "hyprland.toml")"

        if [ -f "$greetd_config" ]; then
            sudo mkdir -p /etc/greetd
            sudo cp "$greetd_config" /etc/greetd/config.toml
            sudo systemctl enable greetd.service
        else
            log "Error: No se encontró la configuración de greetd en $greetd_config"
        fi

    else
        log "Configurando Ly en TTY2 para Laptop..."

        sudo pacman -S --needed --noconfirm ly
        sudo systemctl disable getty@tty2.service || true
        sudo systemctl enable ly@tty2.service
    fi
}

setup_autocpufreq() {
    log "Instalando autocpufreq..."
    sudo systemctl disable --now cpupower.service thermald.service 2>/dev/null || true
    sudo auto-cpufreq --install || true
}

setup_sudoers() {
    log "Configurando reglas sudoers..."
    if [ -f "$HOME/dotfiles/extra/sudoers/custom-rules" ]; then
        if sudo visudo -cf "$HOME/dotfiles/extra/sudoers/custom-rules" &>/dev/null; then
            sudo cp "$HOME/dotfiles/extra/sudoers/custom-rules" /etc/sudoers.d/custom-rules
            sudo chmod 440 /etc/sudoers.d/custom-rules
        else
            log "Error Crítico: El archivo custom-rules tiene fallos de sintaxis. Omitiendo por seguridad."
        fi
    fi

    if [[ "$machine_type" == "laptop" && -f "$HOME/dotfiles/extra/sudoers/laptop-rules" ]]; then
        if sudo visudo -cf "$HOME/dotfiles/extra/sudoers/laptop-rules" &>/dev/null; then
            sudo cp "$HOME/dotfiles/extra/sudoers/laptop-rules" /etc/sudoers.d/laptop-rules
            sudo chmod 440 /etc/sudoers.d/laptop-rules
        else
            log "Error Crítico: El archivo laptop-rules tiene fallos de sintaxis. Omitiendo por seguridad."
        fi
    fi
}

setup_crucial_disk_fstab() {
    log "Configurando Crucial X9 en fstab (Ruta de usuario)..."

    # Definimos la ruta en tu home para evitar líos de permisos en /run
    local MOUNT_PATH="/home/$USER/mnt/Crucial_X9"
    local UUID_CRUCIAL="D0668FA2668F87C4"

    if ! grep -q "$UUID_CRUCIAL" /etc/fstab; then
        # Creamos la ruta y aseguramos que el dueño seas tú
        mkdir -p "$MOUNT_PATH"
        sudo chown -R "$USER:$USER" "/home/$USER/mnt"

        # Añadimos la línea al fstab
        # Nota: quitamos windows_names e iocharset para máxima compatibilidad con ntfs3
        echo -e "\n# Crucial X9 para Steam\nUUID=$UUID_CRUCIAL  $MOUNT_PATH  ntfs3  user,noauto,uid=1000,gid=1000,umask=000,rw,exec,nofail  0  0" | sudo tee -a /etc/fstab >/dev/null

        log "fstab actualizado. Ruta: $MOUNT_PATH"
        sudo systemctl daemon-reload
    else
        log "La configuración del Crucial X9 ya existe en /etc/fstab."
    fi
}

setup_toggle_gpu() {
    log "Configurando GPU toggle..."
    sudo cp ~/dotfiles/extra/bin/gpu-check.sh /usr/local/bin/gpu-check
    sudo cp ~/dotfiles/extra/bin/gpu-toggle.sh /usr/local/bin/gpu-toggle 2>/dev/null && sudo chmod 755 /usr/local/bin/gpu-toggle || true
    if [ -f "$HOME/dotfiles/extra/sudoers/gpu-rules" ]; then
        if sudo visudo -cf "$HOME/dotfiles/extra/sudoers/gpu-rules" &>/dev/null; then
            sudo cp "$HOME/dotfiles/extra/sudoers/gpu-rules" /etc/sudoers.d/gpu-rules
            sudo chmod 440 /etc/sudoers.d/gpu-rules
        fi
    fi

    sudo mkdir -p /usr/share/wayland-sessions/
    sudo cp ~/dotfiles/extra/wayland-sessions/*.desktop /usr/share/wayland-sessions/ 2>/dev/null || true
}

setup_hotspot_network() {
    log "Configurando Hotspot..."
    local eth=$(nmcli -t -f DEVICE,TYPE device status | grep ":ethernet" | head -n1 | cut -d: -f1)
    local wifi=$(nmcli -t -f DEVICE,TYPE device status | grep ":wifi" | head -n1 | cut -d: -f1)

    if [[ -n "$eth" && -n "$wifi" ]]; then
        echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-hotspot.conf >/dev/null
        sudo sysctl --system >/dev/null

        if command -v ufw &>/dev/null; then
            sudo ufw route allow in on "$wifi" out on "$eth"
            sudo ufw allow in on "$wifi" to any port 67 proto udp
            sudo ufw allow in on "$wifi" to any port 53
            sudo ufw --force enable
        fi

        nmcli con delete "Hotspot" 2>/dev/null || true
        nmcli con add type wifi ifname "$wifi" con-name "Hotspot" autoconnect no ssid "Hotspot" 802-11-wireless.mode ap 802-11-wireless-security.key-mgmt wpa-psk 802-11-wireless-security.psk "ThinkingRock123" 802-11-wireless-security.proto rsn 802-11-wireless-security.group ccmp 802-11-wireless-security.pairwise ccmp 802-11-wireless-security.pmf 0 ipv4.method shared
    else
        log "Advertencia: No se detectaron interfaces de Ethernet y Wifi necesarias para el Hotspot."
    fi
}

show_help() {
    echo "Uso: $0 [opción]"
    echo "Opciones modulares:"
    echo "  --full          Ejecución completa (por defecto)"
    echo "  --login         Configura solo el gestor de sesión (Ly/Greetd)"
    echo "  --dotfiles      Solo clona y aplica dotfiles"
    echo "  --gpu           Configura solo el toggle de GPU"
    echo "  --sudoers       Aplica reglas personalizadas de sudoers"
    echo "  --hotspot       Configura la red hotspot (solo laptop)"
    echo "  --help          Muestra este menú"
}

full_install() {
    clear
    echo "Instalador Base del Sistema"
    echo "------------------------------"

    ask_machine_type
    ask_de_profile
    ask_gpu_type
    ask_autoyes

    check_basics
    setup_custom_repo
    update_system_and_yay
    install_all_packages
    setup_dotfiles

    setup_sudoers
    setup_mpd_service
    setup_keyd_service
    setup_fish_shell
    service_install bluetooth

    if [[ "$machine_type" == "laptop" ]]; then
        setup_autocpufreq
    fi

    if [[ "$IS_PERSONAL" == "true" ]]; then
        log "Modo personal detectado: Instalando módulos privados..."
        setup_crucial_disk_fstab
        if [[ "$machine_type" == "laptop" ]]; then
            setup_hotspot_network
            setup_toggle_gpu
        fi
    fi

    setup_login

    log "¡Instalación completada!"
    if [[ "$autoyes" =~ ^[Yy]$ ]]; then
        reboot
    else
        read -p "¿Reiniciar ahora? (y/N): " -n 1 -r
        [[ $REPLY =~ ^[Yy]$ ]] && reboot
    fi
}

case "$1" in
--login)
    ask_machine_type
    ask_de_profile
    ask_autoyes
    setup_login
    ;;
--dotfiles)
    ask_machine_type
    setup_dotfiles
    ;;
--gpu)
    setup_toggle_gpu
    ;;
--sudoers)
    ask_machine_type
    setup_sudoers
    ;;
--hotspot)
    setup_hotspot_network
    ;;
--full | "")
    full_install
    ;;
--help | *)
    show_help
    exit 0
    ;;
esac
