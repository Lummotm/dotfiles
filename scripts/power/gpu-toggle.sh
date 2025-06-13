#!/usr/bin/env bash
# Archivo: ~/bin/gpu-toggle
# Uso: gpu-toggle on    → enciende la RTX
#      gpu-toggle off   → apaga la RTX (si no está en uso)

GPUBUS="0000:01:00.0"
NVIDIA_DEV="/dev/nvidia0"

case "$1" in
  off)
    if lsof "$NVIDIA_DEV" &>/dev/null; then
      echo "⚠️  La GPU NVIDIA está en uso. No se puede apagar."
      lsof "$NVIDIA_DEV"
      exit 1
    fi
    echo "🔌 Apagando GPU NVIDIA..."
    sudo modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia 2>/dev/null
    echo 1 | sudo tee /sys/bus/pci/devices/$GPUBUS/remove
    ;;
  on)
    echo "⚡ Reactivando GPU NVIDIA..."
    echo 1 | sudo tee /sys/bus/pci/rescan
    sudo modprobe nvidia nvidia_modeset nvidia_drm nvidia_uvm
    ;;
  *)
    echo "Uso: $0 {on|off}"
    exit 1
    ;;
esac
