#!/usr/bin/env bash
source "$HOME/bin/pickers/dependencies/core.sh"

LOG_DIR="$HOME/logs"
LOG_FILE="$LOG_DIR/rofi_mount.log"
HIDE_MOUNTED="false"
NOTIFICATIONS="true"
UDISKS_MEDIA="/run/media/$USER"

[[ -d "$LOG_DIR" ]] || mkdir -p "$LOG_DIR"
echo "--- Session $(date) ---" >>"$LOG_FILE"

rofi_cmd() {
  rofi_core -w "38ch" -N -mesg "Select a disk to mount:" -c 'textbox{padding: 2px 5px;}' "$@"
}

log() { echo "[$(date '+%H:%M:%S')] $1" >>"$LOG_FILE"; }

notification() {
  [[ "$NOTIFICATIONS" == "true" && -x "$(command -v notify-send)" ]] || return
  notify-send -r 99 -t 2000 -u low "$1" "$2" -i "${3:-drive-harddisk}"
}

handle_generic_mount() {
  local device="$1"

  if mountpoint -q "$(lsblk -no MOUNTPOINT "$device")"; then
    udisksctl unmount -b "$device"
    notification "Disco Desmontado" "$device extraído con éxito" "media-eject"
    find "$HOME/mnt/" -maxdepth 1 -type l -delete 2>/dev/null
  else
    udisksctl mount -b "$device"
    notification "Disco Montado" "$device listo." "folder-open"
    find "$HOME/mnt/" -maxdepth 1 -type l -delete 2>/dev/null
    ln -s "$UDISKS_MEDIA"/* "$HOME/mnt/" 2>/dev/null
  fi
}

selection_action() {
  [[ -z "$SELECTION" ]] && exit 0

  case "$SELECTION" in
  "Scan Devices" | *"No devices found"*) rofi_menu ;;
  "Show All") HIDE_MOUNTED="false" && rofi_menu ;;
  "Hide Mounted") HIDE_MOUNTED="true" && rofi_menu ;;
  "--mount-crucial" | *"CrucialX9"*) "$HOME/bin/utils/mount-crucial.sh" ;;
  *"CANON_DC"*) "$HOME/bin/utils/mount-canon.sh" ;;
  *) handle_generic_mount "/dev/$(echo "$SELECTION" | sed -n 's/.*(\(.*\)).*/\1/p')" ;;
  esac
}

rofi_menu() {
  local options=""

  while read -r line; do
    eval "$line" # Extrae NAME, LABEL, SIZE, MOUNTPOINT, TYPE, FSTYPE

    # 1. Ignorar el disco interno (nvme0n1), RAM virtual (zram) y dispositivos loop
    # 2. Ignorar la partición secundaria del CrucialX9
    [[ "$NAME" =~ ^(loop|zram|nvme0n1) || "$LABEL" == "CrucialX9_ext4" ]] && continue

    # Ignorar discos base sin formato de archivo que no se pueden montar directamente
    [[ "$TYPE" == "disk" && -z "$FSTYPE" ]] && continue

    # Aplicar el filtro de "Hide Mounted"
    [[ "$HIDE_MOUNTED" == "true" && -n "$MOUNTPOINT" ]] && continue

    [[ -z "$LABEL" ]] && LABEL="Unknown"
    local prefix=$([[ -n "$MOUNTPOINT" ]] && echo "Mounted: " || echo "")

    options+="${prefix}${LABEL} (${NAME})   [${FSTYPE^^}] ${SIZE}\n"
  done <<<"$(lsblk -P -n -o NAME,LABEL,SIZE,MOUNTPOINT,TYPE,FSTYPE)"

  [[ -z "$options" ]] && options="No devices found\n"

  local toggle_txt=$([[ "$HIDE_MOUNTED" == "true" ]] && echo "Show All" || echo "Hide Mounted")
  options+="\nScan Devices\n${toggle_txt}"

  SELECTION="${1:-$(echo -e "$options" | rofi_cmd)}"
  selection_action
}

rofi_menu "$1"
