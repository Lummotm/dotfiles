#!/usr/bin/env bash
set -euo pipefail

# --- Colores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Funciones de Utilidad ---
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[EXITO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[AVISO]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

validate_port() {
    if [[ ! $1 =~ ^[0-9]+$ ]] || [ $1 -lt 1 ] || [ $1 -gt 65535 ]; then
        return 1
    fi
    return 0
}

test_ssh_connection() {
    print_info "Probando conexión SSH..."
    # Intenta conectar y salir inmediatamente
    if ssh -p "$3" -o ConnectTimeout=10 -o BatchMode=yes "$1@$2" exit 2>/dev/null; then
        print_success "Conexión establecida"
        return 0
    else
        print_warning "No se pudo conectar automáticamente (quizás pida contraseña manual)."
        return 1
    fi
}

# --- Función de Clonación (Modo Installation) ---
clone_function() {
    local user=$1
    local ip=$2
    local port=$3
    local mode=$4
    local del_opt=$5
    local dirs=()

    # Pedir directorios
    while true; do
        read -p "Introduce directorio a clonar (ej: storage/music): " d
        # Limpiar barras iniciales/finales
        d=${d#/}
        d=${d%/}
        if [ -n "$d" ]; then dirs+=("$d"); fi

        read -p "¿Añadir otro? (s/n): " cont
        [[ ! "$cont" =~ ^[Ss] ]] && break
    done

    echo "Procesando: ${dirs[*]}"

    for dir in "${dirs[@]}"; do
        print_info "Sincronizando carpeta: $dir"

        # Rutas usando expansión de tilde (~) para compatibilidad con Termux
        local local_path=~/"$dir/"
        # Ruta remota relativa al home del usuario remoto (evita hardcodear /home/)
        local remote_path_rel="~/$dir/"

        if [[ "$mode" == "enviar" ]]; then
            # Verificar origen local
            if [ ! -d "$local_path" ]; then
                print_warning "Creando directorio local vacío: $local_path"
                mkdir -p "$local_path"
            fi

            # Crear remoto (usando ruta relativa ~/)
            ssh -p "$port" "$user@$ip" "mkdir -p \"$dir\"" 2>/dev/null

            # Rsync enviando a la ruta relativa remota
            rsync -avh --progress $del_opt -e "ssh -p $port" "$local_path" "$user@$ip:$remote_path_rel"

        elif [[ "$mode" == "recibir" ]]; then
            mkdir -p "$local_path"
            # Rsync recibiendo desde la ruta relativa remota
            rsync -avh --progress $del_opt -e "ssh -p $port" "$user@$ip:$remote_path_rel" "$local_path"
        fi
        echo
    done
}

# ==========================================
# BLOQUE PRINCIPAL
# ==========================================

echo "=== SINCRONIZADOR RSYNC (Termux Friendly) ==="
echo

# 1. Configuración SSH
print_info "Configuración:"
read -p "Usuario SSH: " remote_user
read -p "IP del servidor: " remote_ip

while true; do
    read -p "Puerto SSH (default 22): " remote_port
    remote_port=${remote_port:-22}
    if validate_port "$remote_port"; then break; fi
    print_error "Puerto inválido."
done

test_ssh_connection "$remote_user" "$remote_ip" "$remote_port"
echo

# 2. Modo Instalación vs Manual
mode_install="no"
read -p "¿Usar modo clonación múltiple (--installation)? (s/n): " resp
[[ "$resp" =~ ^[Ss] ]] && mode_install="si"

# 3. Dirección (Enviar/Recibir)
action=""
while [[ "$action" != "enviar" && "$action" != "recibir" ]]; do
    echo "  1) enviar  (Local -> Servidor)"
    echo "  2) recibir (Servidor -> Local)"
    read -p "Elige (enviar/recibir): " action
done

# 4. Opción Delete
del_opt=""
read -p "¿Borrar archivos destino que no estén en origen (--delete)? (s/n): " resp_del
[[ "$resp_del" =~ ^[Ss] ]] && del_opt="--delete" && print_warning "Modo DELETE activado"

echo

# ==========================================
# EJECUCIÓN
# ==========================================

if [[ "$mode_install" == "si" ]]; then
    clone_function "$remote_user" "$remote_ip" "$remote_port" "$action" "$del_opt"
else
    # Lógica Manual
    if [[ "$action" == "enviar" ]]; then
        print_info "MODO ENVIAR (Local -> Remoto)"

        # Bucle para asegurar que el origen existe
        local_full_path=""
        while true; do
            # Se muestra ~/ para indicar que es relativo al home
            echo -n "Carpeta/Archivo local (ej: downloads o storage/dcim): "
            read input_path

            input_path=${input_path#/} # Limpiar barra inicial

            # Expansión correcta para Termux: ~/"ruta"
            local_full_path=~/"$input_path"

            if [ -e "$local_full_path" ]; then
                print_success "Origen encontrado: $local_full_path"
                break
            else
                print_error "No existe '$local_full_path'. Revisa la ruta."
                echo
            fi
        done

        # Destino remoto
        read -p "Carpeta destino en servidor (ej: backups/): " remote_input
        remote_input=${remote_input#/}
        # Usamos ~/ para que el servidor resuelva su propio home
        remote_full_path="~/$remote_input"

        # Ejecutar
        print_info "Enviando a $remote_full_path ..."
        rsync -avh --progress $del_opt -e "ssh -p $remote_port" "$local_full_path" "$remote_user@$remote_ip:$remote_full_path"

    elif [[ "$action" == "recibir" ]]; then
        print_info "MODO RECIBIR (Remoto -> Local)"

        read -p "Carpeta origen en servidor (ej: documents/): " remote_input
        remote_input=${remote_input#/}
        # Usamos ~/ para el origen remoto
        remote_full_path="~/$remote_input"

        read -p "Carpeta destino local (ej: downloads/): " local_input
        local_input=${local_input#/}
        # Expansión correcta para Termux local
        local_full_path=~/"$local_input"

        # Crear carpeta local si no existe
        if [ ! -d "$local_full_path" ]; then
            print_warning "Creando directorio destino: $local_full_path"
            mkdir -p "$local_full_path"
        fi

        # Ejecutar
        print_info "Recibiendo desde $remote_full_path ..."
        rsync -avh --progress $del_opt -e "ssh -p $remote_port" "$remote_user@$remote_ip:$remote_full_path" "$local_full_path"
    fi
fi

echo
print_success "Proceso terminado."
