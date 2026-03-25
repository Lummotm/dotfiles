#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo ""
    echo "Usecase: [--local|--remote] [--termux] [remoteUser] [remoteIP] [remotePort] dir1 dir2 ... dirN"
    echo ""
    echo "  --local:   Sincronizar desde local a remoto"
    echo "  --remote:  Sincronizar desde remoto a local"
    echo "  --termux:  (Opcional) Usar el path '~/storage/shared' en el remoto."
    echo "             Si se omite, se usa el path '~/' en el remoto."
    echo ""
    exit 1
}

localToRemote() {
    local user=$1
    local ip=$2
    local port=$3
    local base_path=$4
    shift 4

    for dir in "${@}"; do
        local clean_dir=${dir#/} # Elimina la barra inicial si existe
        local localDir="$HOME/$clean_dir"
        if ! [ -d "$localDir" ]; then
            echo "$localDir doesn't exist."
            echo "Fix to use the script."
            usage
        fi

        local remoteFullPath="$user@$ip:$base_path/$dir"
        echo "Sync: $localDir/ -> $remoteFullPath"
        rsync -avh -e "ssh -p $port" "$localDir/" "$remoteFullPath"
    done
}

remoteToLocal() {
    local user=$1
    local ip=$2
    local port=$3
    local base_path=$4
    shift 4

    for dir in "${@}"; do
        local clean_dir=${dir#/} # Elimina la barra inicial si existe
        local localDir="$HOME/$clean_dir"
        local remoteFullPath="$user@$ip:$base_path/$clean_dir"

        echo "Sync: $remoteFullPath/ -> $localDir"
        if ! rsync -avh -e "ssh -p $port" "$remoteFullPath/" "$localDir"; then
            echo "Error sincronizando $dir"
            echo "Revise que $remoteFullPath existe en el dispositivo remoto"
            usage
        fi
    done
}

if [ "$#" -lt 5 ]; then
    usage
fi

isTermux=false
usecase=""
declare -a positional_args=()

while [[ $# -gt 0 ]]; do
    case $1 in
    --local)
        usecase="local"
        shift
        ;;
    --remote)
        usecase="remote"
        shift
        ;;
    --termux)
        isTermux=true
        shift
        ;;
    -h | --help)
        usage
        ;;
    *)
        positional_args+=("$1")
        shift
        ;;
    esac
done

if [ -z "$usecase" ]; then
    echo "Error: Debes especificar --local o --remote."
    usage
fi

if [ "${#positional_args[@]}" -lt 4 ]; then
    echo "Error: Faltan argumentos: [remoteUser] [remoteIP] [remotePort] [dir1 ...]"
    usage
fi

remoteUser=${positional_args[0]}
remoteIP=${positional_args[1]}
remotePort=${positional_args[2]}
declare -a dirs=("${positional_args[@]:3}")

case $remotePort in
'' | *[!0-9]*)
    echo "Error: El puerto '$remotePort' no es un número."
    usage
    ;;
*) ;;
esac

if [ "$isTermux" = true ]; then
    remoteBasePath="~/storage/shared"
    echo "INFO: Modo Termux activado. Path remoto: $remoteBasePath"
else
    remoteBasePath="~/"
    echo "INFO: Modo estándar activado. Path remoto: $remoteBasePath"
fi

case $usecase in
remote)
    remoteToLocal "$remoteUser" "$remoteIP" "$remotePort" "$remoteBasePath" "${dirs[@]}"
    ;;
local)
    localToRemote "$remoteUser" "$remoteIP" "$remotePort" "$remoteBasePath" "${dirs[@]}"
    ;;
esac
