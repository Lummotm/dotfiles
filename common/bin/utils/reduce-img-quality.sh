#!/usr/bin/env bash

# Configuración
SOURCE_DIR="$HOME/Pictures/Wallpapers/0-god/"
OUTPUT_DIR="$HOME/temp/wallpapers_1080p-webp"
LOG_FILE="$HOME/temp/ffmpeg_conversion.log"

# Crear directorio de salida
mkdir -p "$OUTPUT_DIR"

find "$SOURCE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" -o -iname "*.gif" \) | while read -r img; do
    rel=$(realpath --relative-to="$SOURCE_DIR" "$img")
    img_name=$(basename "$img")
    extension="${img_name##*.}"
    extension_lc=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    target_dir="$OUTPUT_DIR/$(dirname "$rel")"
    mkdir -p "$target_dir"

    if [[ "$extension_lc" == "gif" ]]; then
        if [[ ! -f "$target_dir/$img_name" ]]; then
            echo "  -> Copiando GIF: $img_name"
            cp "$img" "$target_dir/"
        else
            echo "  -> Saltando (GIF ya existe): $img_name"
        fi
        continue
    fi

    if [[ "$extension_lc" =~ ^(jpe?g|png|webp|bmp)$ ]]; then
        target_name="${img_name%.*}.webp"
        target_path="$target_dir/$target_name"
        if [[ -f "$target_path" ]]; then
            echo "  -> Saltando (ya existe): $target_name"
            continue
        fi
        echo "  -> Procesando a WebP: $img_name ($rel)"
        ffmpeg -y -i "$img" -vf \
            "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" \
            -c:v libwebp -lossless 0 -compression_level 6 -q:v 80 \
            "$target_path" </dev/null &>>"$LOG_FILE"
    fi
done

echo "Revisa tus fondos en: $OUTPUT_DIR"
