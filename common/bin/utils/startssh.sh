#!/bin/bash
set -euo pipefail

# Este script configura y muestra los comandos para conectar por SSH solo en la red local.
# Detecta automáticamente entre 'ufw' y 'firewall-cmd'.

# --- Configuración inicial del servicio SSH ---

echo "Iniciando el servicio OpenSSH (sshd)..."
# Usamos 'sudo' aquí para pedir la contraseña una sola vez al principio
sudo systemctl start sshd

# --- Configuración del Firewall ---

echo "Detectando y configurando el firewall..."

if command -v ufw >/dev/null 2>&1; then
    # Opción 1: UFW (Común en Ubuntu/Debian)
    echo "Detectado 'ufw'. Abriendo puerto 22..."
    sudo ufw allow 22/tcp
    echo "Puerto 22 abierto en ufw."

elif command -v firewall-cmd >/dev/null 2>&1; then
    # Opción 2: firewall-cmd (Común en RHEL/Fedora/CentOS)
    echo "Detectado 'firewall-cmd'. Abriendo puerto 22..."
    # Esta regla es temporal (se pierde al reiniciar), igual que en tu script original
    sudo firewall-cmd --add-port=22/tcp
    echo "Puerto 22 abierto en firewall-cmd (temporalmente)."

else
    # Caso de advertencia: No se encontró ninguno
    echo "---"
    echo "⚠️ ADVERTENCIA: No se encontró 'ufw' ni 'firewall-cmd'."
    echo "No se pudo configurar el firewall automáticamente."
    echo "Deberás abrir el puerto 22 manualmente."
    echo "---"
    # No salimos del script, ya que mostrar la IP sigue siendo útil
fi

# --- Obtener y mostrar información de conexión ---

# Obtener el nombre del usuario actual
USER=$(whoami)

# Obtener la dirección IP local (la primera que encuentre que no sea loopback)
LOCAL_IP=$(ip a | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d'/' -f1 | head -n 1)

# Verificar si se obtuvo la IP local
if [ -z "$LOCAL_IP" ]; then
    echo "---"
    echo "❌ No se pudo obtener la dirección IP local."
    echo "Asegúrate de que tu equipo esté conectado a una red (Wi-Fi o cable)."
    echo "---"
    exit 1
fi

# Mostrar la información en un formato claro
echo "---"
echo "✅ Aquí tienes el comando para conectar por SSH a este equipo:"
echo ""
echo "Conexión local (dentro de tu misma red):"
echo "  ssh $USER@$LOCAL_IP"
echo "---"
