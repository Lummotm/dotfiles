#!/usr/bin/env bash
source "$HOME/.config/rofi/bin/dependencies/rofi-core.sh"

LOG_DIR="$HOME/logs"
LOG_FILE="$LOG_DIR/romount.log"
HIDE_MOUNTED="false"
NOTIFICATIONS="true"

ICON_DRIVE="drive-harddisk"
ICON_MOUNTED="folder-open"
ICON_UNMOUNTED="media-eject"
ICON_ERROR="dialog-error"

[[ -d "$LOG_DIR" ]] || mkdir -p "$LOG_DIR"
echo "--- Session $(date) ---" >>"$LOG_FILE"

# Wrapper para estandarizar el diseño de Rofi (sin markup-rows)
rofi_cmd() {
    rofi_core -w "38ch" -N -mesg "Select a disk to mount:" -c 'textbox{padding: 2px 5px;}'
}

# Logging con timestamp
log() {
    echo "[$(date '+%H:%M:%S')] $1" >>"$LOG_FILE"
}

# Notificaciones de escritorio condicionales
notification() {
    [[ "$NOTIFICATIONS" == "true" && -x "$(command -v notify-send)" ]] || return
    local icon="${3:-$ICON_DRIVE}"
    notify-send -r 99 -t 2000 -u low "$1" "$2" -i "$icon"
}

# Obtiene y filtra dispositivos de bloque disponibles
get_drives_fresh() {
    DEVICES_DEV=()
    DEVICES_LABEL=()
    DEVICES_INFO=()
    DEVICES_MOUNT=()

    local raw_output
    raw_output=$(lsblk -P -n -o NAME,LABEL,SIZE,MOUNTPOINT,TYPE,FSTYPE)

    while read -r line; do
        local NAME="" LABEL="" SIZE="" MOUNTPOINT="" TYPE="" FSTYPE=""
        eval "$line"

        # Ignora dispositivos virtuales y particiones de sistema
        if [[ "$NAME" == loop* || "$NAME" == zram* ]]; then continue; fi
        if [[ "$MOUNTPOINT" == "/" || "$MOUNTPOINT" == "[SWAP]" ]]; then continue; fi
        if [[ "$MOUNTPOINT" == "/boot"* ]]; then continue; fi
        if [[ "$MOUNTPOINT" == "/home"* && "$MOUNTPOINT" != *"/mnt/"* ]]; then continue; fi

        # Ignora particiones EFI/Recovery por tamaño y discos base sin sistema de archivos
        if [[ "$SIZE" == "1M" || "$SIZE" == "16M" || "$SIZE" == "200M" || "$SIZE" == "748M" || "$SIZE" == "529M" ]]; then continue; fi
        if [[ "$TYPE" == "disk" && -z "$FSTYPE" ]]; then continue; fi

        # Respeta el toggle de ocultar dispositivos montados
        if [[ "$HIDE_MOUNTED" == "true" && -n "$MOUNTPOINT" ]]; then continue; fi

        [[ -z "$LABEL" ]] && LABEL="Unknown"
        local info_str="[${FSTYPE^^}] ${SIZE}"

        DEVICES_DEV+=("/dev/$NAME")
        DEVICES_LABEL+=("$LABEL")
        DEVICES_INFO+=("$info_str")
        DEVICES_MOUNT+=("$MOUNTPOINT")

    done <<<"$raw_output"
}

# Monta el dispositivo y extrae la ruta del punto de montaje
mount_device() {
    local dev="$1"
    notification "Mounting..." "$dev"

    local output
    output=$(udisksctl mount -b "$dev" 2>&1)
    local status=$?

    # Fallback: Intenta reparar NTFS si falla por estar marcado como "sucio" por Windows
    if [[ $status -ne 0 ]]; then
        local fstype=$(lsblk -no FSTYPE "$dev")
        if [[ "$fstype" == *"ntfs"* || "$fstype" == "fuseblk" ]]; then
            log "REPAIR ATTEMPT: $dev (NTFS detected)"
            notification "NTFS Error" "Attempting repair..." "$ICON_ERROR"

            sudo /usr/bin/ntfsfix -d "$dev" >>"$LOG_FILE" 2>&1
            output=$(udisksctl mount -b "$dev" 2>&1)
            status=$?
        fi
    fi

    if [[ $status -eq 0 ]]; then
        local mountpoint=$(echo "$output" | grep -oP "at \K.*" | sed 's/\.$//')

        # Crea symlink en ~/mnt para evitar espacios problemáticos en la terminal
        if [[ "$mountpoint" == *" "* ]]; then
            local link_name="${mountpoint##*/}"
            link_name="${link_name// /_}"
            local link_dir="$HOME/mnt"
            local link_path="$link_dir/$link_name"

            [[ -d "$link_dir" ]] || mkdir -p "$link_dir"

            if ln -snf "$mountpoint" "$link_path"; then
                log "LINK SUCCESS: $link_path -> $mountpoint"
                mountpoint="$link_path"
            else
                log "LINK ERROR: Failed to create symlink at $link_path"
            fi
        fi

        log "MOUNTED: $dev -> $mountpoint"
        notification "Mounted" "$mountpoint" "$ICON_MOUNTED"
    else
        log "ERROR MOUNT: $dev -> $output"
        notification "Error" "Check logs" "$ICON_ERROR"
    fi
}

# Desmontaje seguro usando udisksctl
unmount_device() {
    local dev="$1"
    notification "Unmounting..." "$dev"

    local output
    output=$(udisksctl unmount -b "$dev" 2>&1)

    if [[ $? -eq 0 ]]; then
        log "UNMOUNTED: $dev"
        notification "Safe to remove" "$dev" "$ICON_UNMOUNTED"
    else
        log "ERROR UNMOUNT: $dev -> $output"
        notification "Error" "Check logs" "$ICON_ERROR"
    fi
}

# Genera la lista de opciones y lanza Rofi
rofi_menu() {
    get_drives_fresh

    local options=""
    local i=0

    for dev in "${DEVICES_DEV[@]}"; do
        local label="${DEVICES_LABEL[$i]}"
        local info="${DEVICES_INFO[$i]}"
        local mnt="${DEVICES_MOUNT[$i]}"
        local dev_name="${dev#/dev/}"

        # Texto plano sin formato Pango
        if [[ -n "$mnt" ]]; then
            options="${options}Mounted: ${label} (${dev_name}) ${info}\n"
        else
            options="${options}${label} (${dev_name})   ${info}\n"
        fi
        ((i++))
    done

    [[ -z "$options" ]] && options="No devices found\n"

    local toggle_txt
    [[ "$HIDE_MOUNTED" == "true" ]] && toggle_txt="Show All" || toggle_txt="Hide Mounted"

    options="${options}\nScan Devices\n${toggle_txt}"

    SELECTION=$(echo -e "$options" | rofi_cmd)

    selection_action
}

# Enruta la selección del menú hacia la función correspondiente
selection_action() {
    [[ -z "$SELECTION" ]] && exit 0

    case "$SELECTION" in
    "Scan Devices")
        rofi_menu
        ;;
    "Show All")
        HIDE_MOUNTED="false" && rofi_menu
        ;;
    "Hide Mounted")
        HIDE_MOUNTED="true" && rofi_menu
        ;;
    *"No devices found"*)
        rofi_menu
        ;;
    *)
        # Extrae el nombre del dispositivo (ej: sda2)
        local dev_name=$(echo "$SELECTION" | sed -n 's/.*(\(.*\)).*/\1/p')
        local device="/dev/$dev_name"

        # Datos de tu Crucial
        local target_uuid="D0668FA2668F87C4"
        local mount_point="$HOME/mnt/Crucial_X9"
        local current_uuid=$(lsblk -no UUID "$device")

        # Si es el Crucial X9
        # Caso especifico ya que tiene que tener permisos especificos fijados en el fstab
        if [[ "$current_uuid" == "$target_uuid" ]]; then
            mkdir -p "$mount_point"

            if mountpoint -q "$mount_point"; then
                log "Desmontando Crucial X9..."
                if umount "$mount_point"; then
                    notification "Disco Desmontado" "Crucial X9 extraído con éxito" "$ICON_UNMOUNTED"
                else
                    notification "Error" "No se pudo desmontar." "$ICON_ERROR"
                fi
            else
                log "Montando Crucial X9..."
                # Intentamos montar
                if ! mount "$mount_point" 2>/dev/null; then
                    log "FALLO INICIAL: Crucial X9 (Posible NTFS sucio)"
                    notification "Reparando..." "Detectado error en NTFS" "$ICON_ERROR"

                    sudo /usr/bin/ntfsfix -d "$device" >>"$LOG_FILE" 2>&1

                    # REINTENTO
                    if mount "$mount_point"; then
                        notification "Disco Montado" "Reparado y montado con éxito" "$ICON_MOUNTED"
                    else
                        notification "Error Crítico" "Fallo incluso tras ntfsfix" "$ICON_ERROR"
                    fi
                else
                    notification "Disco Montado" "Crucial X9 listo." "$ICON_MOUNTED"
                fi
            fi
            # ...
        else
            # Lógica normal de udisksctl para otros discos
            if mountpoint -q "$(lsblk -no MOUNTPOINT "$device")"; then
                udisksctl unmount -b "$device"
            else
                udisksctl mount -b "$device"
            fi
        fi
        ;;
    esac
}

rofi_menu
