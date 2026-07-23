#!/usr/bin/env bash
set -e

IS_PERSONAL=""
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

ask_autologin() {
    [[ -n "$use_autologin" ]] && return
    read -p "¿Deseas habilitar el autologin con Greetd? (y/N): " -n 1 -r use_autologin
    echo
}

ask_personal_modules() {
    [[ -n "$IS_PERSONAL" ]] && return
    read -p "¿Instalar módulos personales (disco Crucial X9, hotspot, GPU toggle)? (y/N): " -n 1 -r IS_PERSONAL
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
        zip expect bc libgit2 libmpdclient alsa-utils fd
        # Ntfs deppendencies
        ntfs-3g ntfsprogs curl
    )
    local PKG_USER_APPS=(
        neovim vlc vlc-plugin-ffmpeg mpd mpc rmpc yazi btop eza fzf zoxide
        sioyek-git mpd-mpris kitty npm zen-browser-bin yt-dlp keepassxc
        discord lazygit wikiman man-db man-pages arch-wiki-docs steam
        proton-ge-custom-bin protonplus heroic-games-launcher-bin calibre-bin
        udisks2 proton-vpn-gtk-app gimp atlauncher-bin obsidian-bin anki
        qpdf transmission-qt perl-image-exiftool imagemagick
        # Thumnails on nautilus
        xapp-mp3-thumbnailer nautilus
        # for the color picker
        yad gamemode gamescope lib32-gamemode
    )
    local PKG_NVIM_DEPS=(
        tree-sitter tree-sitter-c tree-sitter-cli tree-sitter-lua
        tree-sitter-markdown tree-sitter-query tree-sitter-vim tree-sitter-vimdoc
        python python-pip python-pillow gcc clang make cmake typst nodejs
    )
    local PKG_DE_GENERAL=(
        libxkbcommon-x11 libdecor rofi rofi-calc waybar awww cliphist keyd
        pywal nwg-look aurutils polkit-gnome tumbler gvfs-mtp sxiv hyprlock
        dunst gtk2 betterbird-bin wl-clipboard libnotify bluez-utils
        qrencode nm-connection-editor xorg-xrandr ddcutil
    )
    local PKG_LAPTOP=(brightnessctl auto-cpufreq)
    local PKG_NIRI=(niri xwayland-satellite xdg-desktop-portal-gnome)
    local PKG_HYPRLAND=(
        hyprland hyprcursor hyprgraphics hyprland-qt-support
        hyprlang hyprshot hyprsunset hyprwayland-scanner xdg-desktop-portal-hyprland
        hyprutils
    )
    local PKG_PRINTERS=(
        cups cups-pdf system-config-printer cups-pk-helper
        ghostscript gsfonts # Recomendado para que procese bien los PDFs al imprimir
    )
    local PKG_GPU=()

    if [[ "$gpu_type" == *"amd"* ]]; then
        PKG_GPU+=(amd-ucode mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon xf86-video-amdgpu linux-firmware-amdgpu)
    fi
    if [[ "$gpu_type" == *"intel"* ]]; then
        PKG_GPU+=(intel-ucode mesa lib32-mesa vulkan-intel lib32-vulkan-intel)
    fi
    if [[ "$gpu_type" == *"nvidia"* ]]; then
        # Using propietary drivers
        PKG_GPU+=(nvidia-580xx-dkms nvidia-580xx-settings nvidia-580xx-utils lib32-nvidia-580xx-utils egl-wayland)
    fi

    local ALL_PACKAGES=("${PKG_CORE[@]}" "${PKG_USER_APPS[@]}" "${PKG_NVIM_DEPS[@]}" "${PKG_DE_GENERAL[@]}" "${PKG_GPU[@]}" "${PKG_PRINTERS[@]}")

    if [[ "$machine_type" == "laptop" ]]; then ALL_PACKAGES+=("${PKG_LAPTOP[@]}"); fi
    if [[ "$de_profile" == "niri" ]]; then ALL_PACKAGES+=("${PKG_NIRI[@]}"); fi
    if [[ "$de_profile" == "hyprland" ]]; then ALL_PACKAGES+=("${PKG_HYPRLAND[@]}"); fi

    mapfile -t packages < <(printf '%s\n' "${ALL_PACKAGES[@]}" | sort -u)

    log "Validando disponibilidad de paquetes en los repositorios y AUR..."
    local valid_packages=()
    local missing_packages=()

    for pkg in "${packages[@]}"; do
        # Comprobamos silenciosamente si el paquete existe
        if yay -Si "$pkg" &>/dev/null; then
            valid_packages+=("$pkg")
        else
            missing_packages+=("$pkg")
            log "⚠️ ADVERTENCIA: No se encontró el paquete '$pkg'. Se omitirá de la instalación."
        fi
    done

    # Si hay paquetes perdidos, dejamos un bloque claro en el log para que los busques después
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        log "---------------------------------------------------"
        log "RESUMEN DE PAQUETES NO ENCONTRADOS (Revisión manual):"
        for missing in "${missing_packages[@]}"; do
            log " - $missing"
        done
        log "---------------------------------------------------"
    fi

    log "Instalando paquetes validados. Primero mediante pacman para mayor velocidad..."
    sudo pacman -S --needed --noconfirm "${valid_packages[@]}" 2>/dev/null || true

    log "Asegurando paquetes restantes y de AUR con yay..."
    set +e
    yay -S --needed --noconfirm "${valid_packages[@]}"
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

setup_audio() {
    log "Aplicando exclusión a discord en audio."
    local TARGET_DIR="/etc/pipewire/pipewire-pulse.d"
    sudo mkdir -p "$TARGET_DIR"
    sudo cp $HOME/dotfiles/extra/10-adjustQuirkRules.conf \
        "$TARGET_DIR"/10-adjustQuirkRules.conf
    systemctl --user restart pipewire pipewire-pulse wireplumber
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
    log "Configurando el gestor de sesión..."

    # Limpieza previa de servicios
    sudo systemctl disable ly.service ly@tty2.service greetd sddm getty@tty2.service 2>/dev/null || true
    sudo rm -f /etc/systemd/system/getty@tty1.service.d/autologin.conf 2>/dev/null
    sudo systemctl daemon-reload

    local toggle_script="$HOME/.config/niri/bin/niri_prop_toggle.py"
    local startup_kdl="$HOME/.config/niri/startup.kdl"
    local wm_name="$de_profile"
    local greetd_base="$HOME/dotfiles/extra/greetd"

    # 1. Instalar el wayland-launcher universal para Greetd y Ly
    if [ -f "$HOME/dotfiles/extra/bin/wayland-launcher" ]; then
        sudo cp "$HOME/dotfiles/extra/bin/wayland-launcher" "/usr/local/bin/wayland-launcher"
        sudo chmod 755 "/usr/local/bin/wayland-launcher"
    else
        log "Advertencia: No se encontró wayland-launcher en extra/bin/"
    fi

    # 2. Copiar sesiones .desktop (Para Ly, tanto en laptop como desktop)
    sudo mkdir -p /usr/share/wayland-sessions/
    sudo cp ~/dotfiles/extra/wayland-sessions/*.desktop /usr/share/wayland-sessions/ 2>/dev/null || true

    if [[ "$use_autologin" =~ ^[Yy]$ ]]; then
        log "Habilitando Autologin con Greetd y bloqueo inicial con hyprlock..."
        sudo pacman -S --needed --noconfirm greetd python hyprlock

        # No se porque hace exit aun con el true al lado
        set +e
        # Desabilitar tema de login que no sea el que queremos
        sudo systemctl disable getty@tty2.service || true
        sudo systemctl disable ly@tty2.service || true
        sudo pacman -Rns --noconfirm ly
        set -e

        # Determinamos qué toml usar según el entorno elegido
        local greetd_config="$greetd_base/${wm_name}.toml"

        if [ -f "$greetd_config" ]; then
            sudo mkdir -p /etc/greetd
            sudo cp "$greetd_config" /etc/greetd/config.toml
            sudo systemctl enable greetd.service
        else
            log "Error Crítico: No se encontró la configuración en $greetd_config"
        fi

    else
        log "Configurando Ly (Login manual)..."
        sudo pacman -S --needed --noconfirm ly python

        set +e
        sudo systemctl disable getty@tty2.service || true
        sudo systemctl disable greetd.service || true
        sudo systemctl enable ly@tty2.service
        sudo pacman -Rns --noconfirm greetd
        set -e

        # Copy new wayland session file to dir
        sudo cp "$HOME/dotfiles/extra/wayland-sessions/hyprland.desktop" /usr/share/wayland-sessions/hyprland.desktop
        sudo cp "$HOME/dotfiles/extra/wayland-sessions/niri.desktop" /usr/share/wayland-sessions/niri.desktop

        # log "Intentando desactivar hyprlock en el inicio del compositor para evitar doble login..."
        #
        # # Niri: Intentamos usar el script de python. Si falla o no existe, no pasa nada (|| true).
        # python "$toggle_script" "$startup_kdl" "spawn-at-startup" "hyprlock" 2>/dev/null || true

    fi
}

setup_printers() {
    log "Configurando el servicio de impresión (CUPS)..."

    # Habilitar e iniciar el demonio de CUPS
    service_install cups

    # Añadir tu usuario al grupo 'lp' (para acceso directo por USB)
    # y 'sys' (por si necesitas administrar impresoras sin sudo en localhost:631)
    sudo usermod -aG lp "$USER"
    sudo usermod -aG sys "$USER" 2>/dev/null || true

    log "Impresión configurada. Usa 'system-config-printer' para añadir la impresora USB."
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
            log "Error Crítico: fallos de sintaxis en custom-rules."
        fi
    fi

    if [[ "$machine_type" == "laptop" && -f "$HOME/dotfiles/extra/sudoers/laptop-rules" ]]; then
        if sudo visudo -cf "$HOME/dotfiles/extra/sudoers/laptop-rules" &>/dev/null; then
            sudo cp "$HOME/dotfiles/extra/sudoers/laptop-rules" /etc/sudoers.d/laptop-rules
            sudo chmod 440 /etc/sudoers.d/laptop-rules
        else
            log "Error Crítico: fallos de sintaxis en laptop-rules."
        fi
    fi
}

setup_crucial_disk_fstab() {
    log "Configurando Crucial X9 en fstab con candados de seguridad..."

    local LABEL_NTFS="CrucialX9"
    local LABEL_EXT4="CrucialX9_ext4"

    # Resolver UUIDs dinámicamente por label (no hardcodeados)
    local UUID_NTFS UUID_EXT4
    UUID_NTFS=$(sudo blkid -o value -s UUID "$(sudo blkid -L "$LABEL_NTFS" 2>/dev/null)" 2>/dev/null || true)
    UUID_EXT4=$(sudo blkid -o value -s UUID "$(sudo blkid -L "$LABEL_EXT4" 2>/dev/null)" 2>/dev/null || true)

    if [[ -z "$UUID_NTFS" && -z "$UUID_EXT4" ]]; then
        log "Advertencia: Disco Crucial X9 no detectado (ninguna partición encontrada). Saltando configuración de fstab."
        return
    fi
    if [[ -z "$UUID_NTFS" ]]; then
        log "Advertencia: Partición NTFS del Crucial X9 (label: $LABEL_NTFS) no detectada. Se omitirá."
    fi
    if [[ -z "$UUID_EXT4" ]]; then
        log "Advertencia: Partición ext4 del Crucial X9 (label: $LABEL_EXT4) no detectada. Se omitirá."
    fi

    local MOUNT_NTFS="/home/$USER/mnt/Crucial_X9"
    local MOUNT_EXT4="/home/$USER/mnt/Crucial_X9_ext4"

    # Verificamos si ambas particiones ya están en fstab
    if grep -q "$UUID_NTFS" /etc/fstab && grep -q "$UUID_EXT4" /etc/fstab; then
        log "Las particiones del Crucial X9 ya existen en fstab. Verificando candados..."
        [ -d "$MOUNT_NTFS" ] && sudo chattr +i "$MOUNT_NTFS" 2>/dev/null
        [ -d "$MOUNT_EXT4" ] && sudo chattr +i "$MOUNT_EXT4" 2>/dev/null
        return
    fi

    log "Añadiendo Crucial X9 a fstab..."

    # Preparación del directorio base
    mkdir -p "/home/$USER/mnt"
    sudo chown -R "$USER:$USER" "/home/$USER/mnt"

    # Partición NTFS
    if [[ -n "$UUID_NTFS" ]] && ! grep -q "$UUID_NTFS" /etc/fstab; then
        [ -d "$MOUNT_NTFS" ] && sudo chattr -i "$MOUNT_NTFS" 2>/dev/null
        mkdir -p "$MOUNT_NTFS"
        sudo chown "$USER:$USER" "$MOUNT_NTFS"
        sudo chattr +i "$MOUNT_NTFS"

        echo -e "\n# Crucial X9 (Steam & Backups - NTFS)\nUUID=$UUID_NTFS $MOUNT_NTFS ntfs3 user,noauto,uid=1000,gid=1000,exec,rw,nofail,prealloc,discard,windows_names,noatime 0 0" | sudo tee -a /etc/fstab >/dev/null
    fi

    # Partición ext4
    if [[ -n "$UUID_EXT4" ]] && ! grep -q "$UUID_EXT4" /etc/fstab; then
        [ -d "$MOUNT_EXT4" ] && sudo chattr -i "$MOUNT_EXT4" 2>/dev/null
        mkdir -p "$MOUNT_EXT4"
        sudo chown "$USER:$USER" "$MOUNT_EXT4"
        sudo chattr +i "$MOUNT_EXT4"

        echo -e "# Crucial X9 (Proton compatdata - ext4)\nUUID=$UUID_EXT4 $MOUNT_EXT4 ext4 user,noauto,rw,exec,nofail 0 2" | sudo tee -a /etc/fstab >/dev/null
    fi

    sudo systemctl daemon-reload
    log "fstab actualizado para el Crucial X9. Candados de seguridad aplicados."
}

setup_sysctl_gaming() {
    log "Optimizando sysctl para gaming (vm.max_map_count)..."
    local src="$HOME/dotfiles/extra/80-gamecompatibility.conf"
    if [ -f "$src" ]; then
        sudo cp "$src" /etc/sysctl.d/80-gamecompatibility.conf
        sudo sysctl --system >/dev/null
    else
        log "Advertencia: No se encontró 80-gamecompatibility.conf en extra/"
    fi
}

setup_toggle_gpu() {
    log "Configurando scripts de GPU (Solo Laptop)..."

    # Copiamos solo los scripts individuales
    sudo cp ~/dotfiles/extra/bin/gpu-check /usr/local/bin/gpu-check 2>/dev/null || true
    sudo cp ~/dotfiles/extra/bin/gpu-toggle /usr/local/bin/gpu-toggle 2>/dev/null || true
    sudo chmod 755 /usr/local/bin/gpu-check /usr/local/bin/gpu-toggle 2>/dev/null || true

    # Aplicamos reglas de Sudoers exclusivas de la GPU
    if [ -f "$HOME/dotfiles/extra/sudoers/gpu-rules" ]; then
        if sudo visudo -cf "$HOME/dotfiles/extra/sudoers/gpu-rules" &>/dev/null; then
            sudo cp "$HOME/dotfiles/extra/sudoers/gpu-rules" /etc/sudoers.d/gpu-rules
            sudo chmod 440 /etc/sudoers.d/gpu-rules
        fi
    fi
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
    fi
}

show_help() {
    echo "Uso: $0 [opción]"
    echo "Opciones modulares:"
    echo "  --full          Ejecución completa (por defecto)"
    echo "  --login         Configura solo el gestor de sesión (Ly/Greetd)"
    echo "  --dotfiles      Solo clona y aplica dotfiles"
    echo "  --gpu           Configura solo el toggle de GPU"
    echo "  --printers      Instala y configura CUPS y utilidades"
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
    setup_sysctl_gaming

    setup_sudoers
    setup_audio
    setup_mpd_service
    setup_keyd_service
    setup_printers
    setup_fish_shell
    service_install bluetooth

    if [[ "$machine_type" == "laptop" ]]; then
        setup_autocpufreq
    fi

    ask_personal_modules
    if [[ "$IS_PERSONAL" =~ ^[Yy]$ ]]; then
        log "Módulos personales activados por el usuario..."
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
    ask_autologin
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
--printers)
    setup_printers
    ;;
--full | "")
    full_install
    ;;
--help | *)
    show_help
    exit 0
    ;;
esac
