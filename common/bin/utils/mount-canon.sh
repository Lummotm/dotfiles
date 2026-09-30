#!/usr/bin/env bash

LOG_FILE="$HOME/logs/mount_canon.log"
DEST_DIR="$HOME/Pictures/Cámara"
DEVICE="${1:-$(blkid -L "CANON_DC")}"

mkdir -p "$HOME/logs"
log() { echo "[$(date '+%H:%M:%S')] [CANON] $1" >>"$LOG_FILE"; }
notification() {
  [[ -x "$(command -v notify-send)" ]] && notify-send -r 99 -t 3500 -u low "$1" "$2" -i "${3:-camera-photo}"
}

[[ -z "$DEVICE" ]] && {
  log "ERROR: Tarjeta no detectada."
  notification "Error" "Tarjeta no detectada." "dialog-error"
  exit 1
}

MOUNT_POINT=$(lsblk -no MOUNTPOINT "$DEVICE")

# 1. Asegurar montaje
if [[ -z "$MOUNT_POINT" ]]; then
  log "Montando $DEVICE..."
  udisksctl mount -b "$DEVICE" >>"$LOG_FILE" 2>&1 || {
    notification "Error Crítico" "Fallo al montar." "dialog-error"
    exit 1
  }
  MOUNT_POINT=$(lsblk -no MOUNTPOINT "$DEVICE")
fi

# 2. Sincronización
if [[ -d "$MOUNT_POINT/DCIM" ]]; then
  mkdir -p "$DEST_DIR"
  notification "Sincronizando..." "Copiando a Pictures/Cámara..."

  if rsync -rthvu --no-perms -O --exclude="CANONMSC" "$MOUNT_POINT/DCIM/" "$DEST_DIR/" >>"$LOG_FILE" 2>&1; then
    log "SUCCESS: Sincronizado."
    notification "Completado" "Fotos actualizadas." "emblem-default"
  else
    log "ERROR: Fallo parcial en rsync."
    notification "Advertencia" "Errores al sincronizar. Revisa el log." "dialog-warning"
  fi
else
  log "WARNING: No se encontró DCIM."
  notification "Advertencia" "Carpeta DCIM ausente." "dialog-warning"
fi

# 3. Extracción
udisksctl unmount -b "$DEVICE" >>"$LOG_FILE" 2>&1 &&
  notification "Tarjeta Segura" "Puedes extraer la SD." "media-eject" ||
  notification "Error" "No extraer la tarjeta. Fallo de desmontaje." "dialog-error"
