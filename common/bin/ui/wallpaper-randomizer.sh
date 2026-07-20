#!/usr/bin/env bash

WALL_BASE="$HOME/Pictures/Wallpapers/0-god"
DEFAULT_DIR="$WALL_BASE"
SCORE_FILE="$HOME/Pictures/Wallpapers/scores.txt"
MIN_SCORE=2

MODE="dir"
TARGET_DIR="$DEFAULT_DIR"

if [[ "${1:-}" == "--score" ]]; then
    if [[ ! -f "$SCORE_FILE" ]]; then
        echo "Error: No existe el archivo de puntuaciones en $SCORE_FILE"
        exit 1
    fi
    MODE="score"
elif [[ -n "${1:-}" ]]; then
    if [[ ! -d "$1" ]]; then
        echo "Error: '$1' no es un directorio válido."
        exit 1
    fi
    TARGET_DIR="$1"
fi

RANDOM_WALLPAPER=""

if [[ "$MODE" == "score" ]]; then
    # Intenta filtrar primero por los que superan o igualan el MIN_SCORE
    SELECTED_NAME=$(awk -F= -v min="$MIN_SCORE" '$2 >= min { for(i=0; i<$2; i++) print $1 }' "$SCORE_FILE" | shuf -n 1)

    # Si no encuentra ninguno, usa la lista completa (cualquiera con score)
    if [[ -z "$SELECTED_NAME" ]]; then
        SELECTED_NAME=$(awk -F= '{ for(i=0; i<$2; i++) print $1 }' "$SCORE_FILE" | shuf -n 1)
    fi

    if [[ -z "$SELECTED_NAME" ]]; then
        echo "Error: El archivo de puntuaciones está vacío."
        exit 1
    fi

    # SELECTED_NAME es ahora un stem sin extensión; busca cualquier extensión de imagen
    RANDOM_WALLPAPER=$(find "$WALL_BASE" -type f \( -iname "$SELECTED_NAME.jpg" -o -iname "$SELECTED_NAME.jpeg" -o -iname "$SELECTED_NAME.png" -o -iname "$SELECTED_NAME.webp" -o -iname "$SELECTED_NAME.gif" \) | head -1)
else
    mapfile -t DIRS < <(find "$TARGET_DIR" -type d)
    CLEAN_DIRS=()

    for dir in "${DIRS[@]}"; do
        if [[ "${dir,,}" =~ "phone" ]] || [[ "${dir,,}" =~ "zip" ]]; then
            continue
        fi
        CLEAN_DIRS+=("$dir")
    done

    FILES=()
    for dir in "${CLEAN_DIRS[@]}"; do
        mapfile -t TMP < <(find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \))
        FILES+=("${TMP[@]}")
    done

    if [[ ${#FILES[@]} -eq 0 ]]; then
        echo "Error: No se encontraron imágenes."
        exit 1
    fi

    RANDOM_WALLPAPER=$(printf "%s\n" "${FILES[@]}" | shuf -n 1)
fi

if [[ -n "$RANDOM_WALLPAPER" && -f "$RANDOM_WALLPAPER" ]]; then
    "$HOME/bin/ui/wallpaper-handler.sh" "$RANDOM_WALLPAPER"
else
    echo "Error: No se pudo encontrar el wallpaper."
    exit 1
fi
