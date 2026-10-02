#!/usr/bin/env bash
source "$HOME/bin/pickers/dependencies/core.sh"

LOG_FILE="$HOME/logs/mount_canon.log"
DEST_DIR="$HOME/Pictures/Cámara"
DEVICE="$(blkid -L "CANON_DC")"
FLAG="$1"

mkdir -p "$HOME/logs"
log() { echo "[$(date '+%H:%M:%S')] [CANON] $1" >>"$LOG_FILE"; }
notification() {
  [[ -x "$(command -v notify-send)" ]] && notify-send -r 99 -t 3500 -u low "$1" "$2" -i "${3:-camera-photo}"
}

rofi_cmd() {
  rofi_core -w "38ch" -N -mesg "Acción para CANON_DC:" -c 'textbox{padding: 2px 5px;}'
}

[[ -z "$DEVICE" ]] && {
  log "ERROR: Tarjeta no detectada."
  notification "Error" "Tarjeta no detectada." "dialog-error"
  exit 1
}

# Comprobamos el estado actual antes de mostrar el menú
MOUNT_POINT=$(lsblk -no MOUNTPOINT "$DEVICE")

if [[ -n "$MOUNT_POINT" ]]; then
  MENU_OPTIONS="Sincronizar y Extraer\nSolo Desmontar"
else
  MENU_OPTIONS="Sincronizar y Extraer\nSolo Montar"
fi

# Mostrar rofi
if [[ $FLAG == "--mount-copy" ]]; then
  ACTION="Sincronizar y Extraer"
else
  ACTION=$(echo -e "$MENU_OPTIONS" | rofi_cmd)
  [[ -z "$ACTION" ]] && exit 0
fi

# Lógica según la acción seleccionada
if [[ "$ACTION" == "Solo Montar" ]]; then
  log "Montando $DEVICE en modo manual..."
  udisksctl mount -b "$DEVICE" >>"$LOG_FILE" 2>&1 || {
    notification "Error Crítico" "Fallo al montar." "dialog-error"
    exit 1
  }
  log "SUCCESS: Tarjeta montada."
  notification "Montado" "Tarjeta lista para uso manual." "folder-open"
  exit 0
fi

if [[ "$ACTION" == "Solo Desmontar" ]]; then
  log "Desmontando $DEVICE en modo manual..."
  udisksctl unmount -b "$DEVICE" >>"$LOG_FILE" 2>&1 &&
    notification "Tarjeta Segura" "Puedes extraer la SD." "media-eject" ||
    notification "Error" "Fallo de desmontaje." "dialog-error"
  exit 0
fi

if [[ "$ACTION" == "Sincronizar y Extraer" ]]; then
  # 1. Asegurar montaje si no estaba montada
  if [[ -z "$MOUNT_POINT" ]]; then
    log "Montando $DEVICE para sincronización..."
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
fi
