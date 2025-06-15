#!/usr/bin/env bash
# Tomar input de rofi como filebrowser
selected_file="$1"
base="$HOME/Pictures/Wallpapers/rand-selected"

# Verificar que se pasó un archivo
if [ -z "$selected_file" ] || [ ! -f "$selected_file" ]; then
    echo "Error: No se proporcionó un archivo válido"
    exit 1
fi


# Ejecución en paralelo de swww, recarga de waybar y clonado de fondo
# Cambiar wallpaper con swww
{
    swww img "$selected_file" --transition-type grow --transition-step 60 --transition-fps 120
    sleep 2.5
    notify-send "Wallpaper cambiado" 
} &> /dev/null &

# Aplicar pywal SIN cambiar wallpaper y recargar waybar en background
{
    wal -i "$selected_file" -n
    pkill -SIGUSR2 waybar
    notify-send "Waybar recargado" 
} &> /dev/null &

# Clonar el fondo para otros usos (hyprlock y demás)
{
    rm -f "$base.png"
    ffmpeg -i "$selected_file" "$base.png" &> /dev/null
} &> /dev/null &

# Aumentar el orden de seleccion en base mtime de rofi como filebrowser
touch "$selected_file"
