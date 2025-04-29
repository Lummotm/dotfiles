#!/bin/bash

# Directorios
WALLPAPERS_DIR="$HOME/Pictures/Wallpapers/wall-randomizer"
DESTINATION="$HOME/Pictures/Wallpapers/hyprpaper-wall.png"

# Listar todos los fondos
wallpapers=($(find "$WALLPAPERS_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \)))

# Verificar si hay fondos
if [ ${#wallpapers[@]} -eq 0 ]; then
    notify-send "Error" "No se encontraron fondos de pantalla"
    exit 1
fi


# Recargar tema previo a ejecución
xrdb -merge ~/.Xresources

# Mostrar selector con sxiv
selected=$(sxiv -g 800x600+560+240 -b -t -o "${wallpapers[@]}")

# Aplicar el fondo seleccionado si hay selección
if [ -n "$selected" ]; then
    # Matar hyprpaper
    killall -SIGKILL hyprpaper 2>/dev/null || true
    
    # Copiar el fondo seleccionado
    cp "$selected" "$DESTINATION"
    
    # Verificar copia
    if [ ! -f "$DESTINATION" ]; then
        notify-send "Error" "No se pudo copiar el fondo de pantalla"
        exit 1
    fi
    
    # Iniciar hyprpaper
    /usr/bin/hyprpaper >/dev/null 2>&1 &
    
    notify-send "Fondo cambiado" "$(basename "$selected")"
fi
