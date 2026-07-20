#!/usr/bin/env bash
# Selector de categoría de wallpapers — lanza bgselector con la subcarpeta elegida
# Muestra via rofi las subcarpetas disponibles bajo WALL_BASE más dos
# opciones especiales:
#   ALL   → lanza bgselector con toda la biblioteca (búsqueda recursiva)
#   SCORE → lanza bgselector mostrando solo los fondos con mayor puntuación
#
# Las subcarpetas se descubren dinámicamente en tiempo de ejecución y se
# presentan en mayúsculas para uniformidad visual; el mapa DIR_MAP
# conserva el nombre real del directorio para pasárselo a bgselector.
#
# Seleccionar cualquier opción incrementa el score del fondo elegido en +1.

source "$HOME/.config/rofi/bin/dependencies/rofi-core.sh"

WALL_BASE="$HOME/Pictures/Wallpapers/0-god"
BGSELECTOR="$HOME/.config/rofi/bin/bgselector/bgselector"

rofi_cmd() {
    rofi_core -w "20ch" \
        -N \
        -kb-accept-alt "" \
        -kb-custom-1 "Shift+Return"
}

# Construye mapa NOMBRE_UPPER -> nombre_real para subcarpetas
declare -A DIR_MAP
while read -r d; do
    DIR_MAP["$(echo "$d" | tr '[:lower:]' '[:upper:]')"]="$d"
done < <(find "$WALL_BASE" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)

CHOICE=$(printf '%s\n' "ALL" "${!DIR_MAP[@]}" "SCORE" | rofi_cmd)
EXIT_CODE=$?

[[ -z "$CHOICE" ]] && exit 0

case "$CHOICE" in
"ALL")
    "$BGSELECTOR" "$WALL_BASE"
    ;;
"SCORE")
    "$BGSELECTOR" "$WALL_BASE" --top
    ;;
*)
    "$BGSELECTOR" "$WALL_BASE/${DIR_MAP[$CHOICE]}"
    ;;
esac
