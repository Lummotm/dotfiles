#!/usr/bin/env bash
source "$HOME/.config/rofi/bin/dependencies/rofi-core.sh"

LOG_DIR="$HOME/logs"
LOG_FILE="$LOG_DIR/romount.log"
HIDE_MOUNTED="false"
NOTIFICATIONS="true"

LABEL_NTFS="CrucialX9"
LABEL_EXT4="CrucialX9_ext4"
TARGET_UUID=$(sudo blkid -o value -s UUID "$(sudo blkid -L "$LABEL_NTFS" 2>/dev/null)" 2>/dev/null || true)
TARGET_UUID_EXT4=$(sudo blkid -o value -s UUID "$(sudo blkid -L "$LABEL_EXT4" 2>/dev/null)" 2>/dev/null || true)
MOUNT_POINT_NTFS="$HOME/mnt/Crucial_X9"
MOUNT_POINT_EXT4="$HOME/mnt/Crucial_X9_ext4"
UDISKS_MEDIA="/run/media/$USER"

ICON_DRIVE="drive-harddisk"
ICON_MOUNTED="folder-open"
ICON_UNMOUNTED="media-eject"
ICON_ERROR="dialog-error"

[[ -d "$LOG_DIR" ]] || mkdir -p "$LOG_DIR"
echo "--- Session $(date) ---" >>"$LOG_FILE"

rofi_cmd() {
    rofi_core -w "38ch" -N -mesg "Select a disk to mount:" -c 'textbox{padding: 2px 5px;}'
}

log() {
    echo "[$(date '+%H:%M:%S')] $1" >>"$LOG_FILE"
}

notification() {
    [[ "$NOTIFICATIONS" == "true" && -x "$(command -v notify-send)" ]] || return
    local icon="${3:-$ICON_DRIVE}"
    notify-send -r 99 -t 2000 -u low "$1" "$2" -i "$icon"
}

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

        if [[ "$NAME" == loop* || "$NAME" == zram* ]]; then continue; fi
        if [[ "$MOUNTPOINT" == "/" || "$MOUNTPOINT" == "[SWAP]" ]]; then continue; fi
        if [[ "$MOUNTPOINT" == "/boot"* ]]; then continue; fi
        if [[ "$MOUNTPOINT" == "/home"* && "$MOUNTPOINT" != *"/mnt/"* ]]; then continue; fi

        local check_uuid
        check_uuid=$(lsblk -no UUID "/dev/$NAME" 2>/dev/null)
        if [[ "$check_uuid" == "$TARGET_UUID_EXT4" ]]; then continue; fi

        if [[ "$SIZE" == "1M" || "$SIZE" == "16M" || "$SIZE" == "200M" || "$SIZE" == "748M" || "$SIZE" == "529M" ]]; then continue; fi
        if [[ "$TYPE" == "disk" && -z "$FSTYPE" ]]; then continue; fi
        if [[ "$HIDE_MOUNTED" == "true" && -n "$MOUNTPOINT" ]]; then continue; fi

        [[ -z "$LABEL" ]] && LABEL="Unknown"
        local info_str="[${FSTYPE^^}] ${SIZE}"

        DEVICES_DEV+=("/dev/$NAME")
        DEVICES_LABEL+=("$LABEL")
        DEVICES_INFO+=("$info_str")
        DEVICES_MOUNT+=("$MOUNTPOINT")
    done <<<"$raw_output"
}

mount_crucial() {
    local device
    device=$(blkid -U "$TARGET_UUID")
    [[ -z "$device" ]] && log "ERROR: Crucial X9 no detectado" && return 1

    mkdir -p "$MOUNT_POINT_NTFS" "$MOUNT_POINT_EXT4"
    umount "$UDISKS_MEDIA/Crucial X9" 2>/dev/null

    log "Montando Crucial X9 completo..."
    if mount "$MOUNT_POINT_NTFS" 2>/dev/null; then
        mount "$MOUNT_POINT_EXT4" 2>/dev/null
        notification "Disco Montado" "Crucial X9 y Compatdata listos." "$ICON_MOUNTED"
        log "SUCCESS: Crucial X9 montado"
    else
        log "FALLO INICIAL: Crucial X9 (Posible NTFS sucio)"
        notification "Reparando..." "Detectado error en NTFS, ejecutando ntfsfix..." "$ICON_ERROR"

        sudo /usr/bin/ntfsfix -d "$device" >>"$LOG_FILE" 2>&1

        if mount "$MOUNT_POINT_NTFS" 2>/dev/null; then
            mount "$MOUNT_POINT_EXT4" 2>/dev/null
            notification "Disco Montado" "Reparado y combo montado con éxito" "$ICON_MOUNTED"
            log "SUCCESS: Crucial X9 montado tras ntfsfix"
        else
            notification "Error Crítico" "Fallo incluso tras ntfsfix" "$ICON_ERROR"
            log "ERROR: Fallo crítico al montar Crucial X9"
        fi
    fi
}

unmount_crucial() {
    log "Desmontando Crucial X9 completo..."
    umount "$MOUNT_POINT_EXT4" 2>/dev/null
    umount "$UDISKS_MEDIA/Crucial X9" 2>/dev/null

    if umount "$MOUNT_POINT_NTFS" 2>/dev/null; then
        notification "Disco Desmontado" "Crucial X9 extraído con éxito" "$ICON_UNMOUNTED"
        log "SUCCESS: Crucial X9 desmontado"
    else
        notification "Error" "No se pudo desmontar el almacenamiento principal." "$ICON_ERROR"
        log "ERROR: Fallo al desmontar Crucial X9"
    fi
}

toggle_generic_device() {
    local device="$1"
    local current_mnt fstype mount_output mount_status

    current_mnt=$(lsblk -no MOUNTPOINT "$device")

    # SI YA ESTÁ MONTADO: Desmontamos y borramos su symlink
    if [[ -n "$current_mnt" ]]; then
        if udisksctl unmount -b "$device" 2>/dev/null; then
            log "UNMOUNTED: $device"
            notification "Disco Desmontado" "$device extraído con éxito" "$ICON_UNMOUNTED"
            rm -f "$HOME/mnt/$(basename "$current_mnt")"
        else
            log "ERROR UNMOUNT: $device"
            notification "Error" "No se pudo desmontar $device." "$ICON_ERROR"
        fi
        return
    fi

    # SI ESTÁ DESMONTADO: Procedemos a montar con contramedida NTFS
    mount_output=$(udisksctl mount -b "$device" 2>&1)
    mount_status=$?

    if [ $mount_status -ne 0 ]; then
        fstype=$(lsblk -no FSTYPE "$device")
        if [[ "$fstype" == "ntfs" ]]; then
            log "FALLO INICIAL: $device ($fstype sucio). Ejecutando ntfsfix..."
            notification "Reparando..." "Detectado error en NTFS, ejecutando ntfsfix..." "$ICON_ERROR"

            sudo /usr/bin/ntfsfix -d "$device" >>"$LOG_FILE" 2>&1
            mount_output=$(udisksctl mount -b "$device" 2>&1)
            mount_status=$?
        fi
    fi

    # Comprobamos el resultado final del montaje
    if [ $mount_status -eq 0 ]; then
        current_mnt=$(lsblk -no MOUNTPOINT "$device")
        log "SUCCESS: $device montado en $current_mnt"
        notification "Disco Montado" "$device listo." "$ICON_MOUNTED"

        mkdir -p "$HOME/mnt/"
        ln -sfn "$current_mnt" "$HOME/mnt/$(basename "$current_mnt")"
    else
        log "ERROR CRÍTICO al montar $device. Código: $mount_status"
        log "DETALLE: $mount_output"

        local clean_err=$(echo "$mount_output" | tr '\n' ' ' | cut -c1-60)
        notification "Fallo de Montaje" "$clean_err..." "$ICON_ERROR"
    fi
}

selection_action() {
    [[ -z "$SELECTION" ]] && exit 0

    case "$SELECTION" in
    "Scan Devices") rofi_menu ;;
    "Show All") HIDE_MOUNTED="false" && rofi_menu ;;
    "Hide Mounted") HIDE_MOUNTED="true" && rofi_menu ;;
    *"No devices found"*) rofi_menu ;;
    "--mount-crucial")
        if mountpoint -q "$MOUNT_POINT_NTFS"; then
            log "INFO: Crucial X9 ya montado, nada que hacer."
        else
            mount_crucial
        fi
        ;;
    *)
        local dev_name=$(echo "$SELECTION" | sed -n 's/.*(\(.*\)).*/\1/p')
        local device="/dev/$dev_name"
        local current_uuid=$(lsblk -no UUID "$device")

        if [[ "$current_uuid" == "$TARGET_UUID" ]]; then
            if mountpoint -q "$MOUNT_POINT_NTFS"; then
                unmount_crucial
            else
                mount_crucial
            fi
        else
            toggle_generic_device "$device"
        fi
        ;;
    esac
}

rofi_menu() {
    get_drives_fresh
    local options=""
    local i=0

    for dev in "${DEVICES_DEV[@]}"; do
        local label="${DEVICES_LABEL[$i]}"
        local info="${DEVICES_INFO[$i]}"
        local mnt="${DEVICES_MOUNT[$i]}"
        local dev_name="${dev#/dev/}"

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

    if [[ -n "$1" ]]; then
        SELECTION="$1"
    else
        SELECTION=$(echo -e "$options" | rofi_cmd)
    fi
    selection_action
}

rofi_menu "$1"
