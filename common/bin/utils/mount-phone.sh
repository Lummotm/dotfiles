#!/usr/bin/env bash

echo "Configurando túnel ADB..."
adb forward tcp:8022 tcp:8022

mkdir -p ~/mnt/movil_termux

fusermount -u ~/mnt/movil_termux 2>/dev/null

echo "Montando sistema de archivos..."
sshfs -p 8022 u0_a308@localhost:/data/data/com.termux/files/home ~/mnt/movil_termux \
    -o follow_symlinks,uid=$(id -u),gid=$(id -g)

if [ $? -eq 0 ]; then
    echo "Móvil montado en ~/mnt/movil_termux"
else
    echo "Error al montar. Revisa si sshd está corriendo en Termux."
fi
