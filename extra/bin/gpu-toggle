#!/usr/bin/env bash

# Buscamos bus de manera dinamica
GPUBUS=$(lspci -D | grep -i "NVIDIA" | awk 'NR==1 {print $1}')

if [ -z "$GPUBUS" ]; then
    echo "Error: No se ha detectado ninguna GPU NVIDIA."
    exit 1
fi

NVIDIA_DEV="/dev/nvidia0"
LOGFILE="/tmp/gpu-toggle.log"

case "$1" in
off)
    echo "$(date): --- Starting NVIDIA GPU power off ---" >>"$LOGFILE"
    systemctl stop nvidia-powerd 2>>"$LOGFILE"
    pkill -f nvidia-powerd

    # No entramos en race conditions
    sleep 1

    for i in {1..3}; do
        if modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia 2>>"$LOGFILE"; then
            echo "$(date): Módulos descargados al intento $i" >>"$LOGFILE"
            break
        fi
        sleep 0.5
    done

    if lsof "$NVIDIA_DEV" >/dev/null 2>&1; then
        echo "$(date): FAILED: GPU en uso por:" >>"$LOGFILE"
        lsof "$NVIDIA_DEV" >>"$LOGFILE"
        exit 1
    fi

    echo 1 >"/sys/bus/pci/devices/$GPUBUS/remove"
    echo "$(date): PCI disconnection finished." >>"$LOGFILE"
    ;;
on)
    echo "$(date): --- Reactivating NVIDIA GPU ---" >>"$LOGFILE"
    echo "Reactivating NVIDIA GPU..."
    echo 1 >/sys/bus/pci/rescan
    modprobe nvidia nvidia_modeset nvidia_drm nvidia_uvm
    systemctl start nvidia-powerd 2>/dev/null
    ;;
*)
    echo "Usage: $0 {on|off}"
    exit 1
    ;;
esac
