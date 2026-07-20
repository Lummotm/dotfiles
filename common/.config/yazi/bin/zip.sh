#!/usr/bin/env bash

set -euo pipefail

# Recibe el archivo/carpeta desde Yazi
selected="$1"

# Fallback al directorio actual si no hay selección
if [ -z "$selected" ]; then
    selected="$PWD"
fi

name="$(basename "$selected")"
# Timestamp Unix para evitar colisiones de nombres
zip_path="/tmp/${name}_$(date +%s).zip"

if [ -d "$selected" ]; then
    # Entra al directorio para evitar rutas absolutas dentro del ZIP
    if (cd "$selected" && zip -r "$zip_path" . >/dev/null); then
        # Copia como URI para pegar fácilmente en gestores de archivos o navegadores
        echo "file://$zip_path" | wl-copy -t text/uri-list
        echo "Directorio '$name' comprimido y copiado al portapapeles: $zip_path"
    else
        echo "Error: No se pudo crear el archivo ZIP del directorio"
        exit 1
    fi
elif [ -f "$selected" ]; then
    # -j ignora la estructura de directorios al comprimir un archivo individual
    if zip -j "$zip_path" "$selected" >/dev/null; then
        echo "file://$zip_path" | wl-copy -t text/uri-list
        echo "Archivo '$name' comprimido y copiado al portapapeles: $zip_path"
    else
        echo "Error: No se pudo crear el archivo ZIP del archivo"
        exit 1
    fi
else
    echo "Error: '$selected' no es un archivo o directorio válido"
    exit 1
fi
