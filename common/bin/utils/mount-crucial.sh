#!/usr/bin/env bash

LOG_FILE="$HOME/logs/romount.log"
TARGET_UUID=$(sudo blkid -o value -s UUID "$(sudo blkid -L "CrucialX9" 2>/dev/null)" 2>/dev/null)
MOUNT_POINT_NTFS="$HOME/mnt/Crucial_X9"
MOUNT_POINT_EXT4="$HOME/mnt/Crucial_X9_ext4"

mkdir -p "$HOME/logs"
log() { echo "[$(date '+%H:%M:%S')] [CrucialX9] $1" >>"$LOG_FILE"; }
notification() {
  [[ -x "$(command -v notify-send)" ]] && notify-send -r 99 -t 2000 -u low "$1" "$2" -i "${3:-drive-harddisk}"
}

# --- LÓGICA DE DESMONTAJE ---
if mountpoint -q "$MOUNT_POINT_NTFS"; then
  log "Desmontando..."
  umount "$MOUNT_POINT_EXT4" "/run/media/$USER/Crucial X9" 2>/dev/null

  if umount "$MOUNT_POINT_NTFS" 2>/dev/null; then
    notification "Desmontado" "Crucial X9 extraído con éxito" "media-eject"
  else
    notification "Error" "Fallo al desmontar." "dialog-error"
  fi

# --- LÓGICA DE MONTAJE ---
else
  device=$(blkid -U "$TARGET_UUID")
  [[ -z "$device" ]] && {
    log "ERROR: Crucial X9 no detectado"
    exit 1
  }

  mkdir -p "$MOUNT_POINT_NTFS" "$MOUNT_POINT_EXT4"
  umount "/run/media/$USER/Crucial X9" 2>/dev/null # Limpiar automount

  # Intentar montar NTFS, aplicar ntfsfix como fallback si falla
  if ! mount "$MOUNT_POINT_NTFS" 2>/dev/null; then
    notification "Reparando..." "Ejecutando ntfsfix..." "dialog-error"
    sudo /usr/bin/ntfsfix -d "$device" >>"$LOG_FILE" 2>&1
    mount "$MOUNT_POINT_NTFS" 2>/dev/null || {
      notification "Error Crítico" "Fallo tras ntfsfix" "dialog-error"
      exit 1
    }
  fi

  # Montar EXT4 y finalizar configuración
  mount "$MOUNT_POINT_EXT4" 2>/dev/null
  python3 "$HOME/bin/utils/create-desktops"

  notification "Montado" "Crucial X9 listo." "folder-open"
  log "SUCCESS: Montaje completado"
fi
