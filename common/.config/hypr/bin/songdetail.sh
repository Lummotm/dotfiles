#!/usr/bin/env bash
set -euo pipefail

artist=$(mpc current -f %artist% 2>/dev/null)
title=$(mpc current -f %title% 2>/dev/null)

[ -z "$artist$title" ] && exit 0

# Función para truncar por palabras inteligente
truncate_by_words() {
    local text="$1"
    local max_length=20 # Ajusta según tu espacio
    local tolerance=5   # Caracteres extra permitidos para completar palabra

    # Si el texto es más corto que el límite, devolverlo completo
    if [ ${#text} -le $max_length ]; then
        echo "$text"
        return
    fi

    # Convertir texto en array de palabras
    read -ra words <<<"$text"
    local result=""

    for word in "${words[@]}"; do
        # Calcular longitud si agregamos esta palabra
        if [ -z "$result" ]; then
            potential_result="$word"
        else
            potential_result="$result $word"
        fi

        # Si supera el límite básico
        if [ ${#potential_result} -gt $max_length ]; then
            # Pero está dentro de la tolerancia, incluir la palabra
            if [ ${#potential_result} -le $((max_length + tolerance)) ]; then
                result="$potential_result"
            fi
            break
        else
            result="$potential_result"
        fi
    done

    # Si aún es muy largo después de todo, truncar y agregar ...
    if [ ${#result} -gt $((max_length + tolerance)) ]; then
        echo "${result:0:$((max_length - 3))}..."
    elif [ ${#result} -lt ${#text} ]; then
        echo "$result..."
    else
        echo "$result"
    fi
}

case "$1" in
--title)
    truncate_by_words "$title"
    ;;
--artist)
    truncate_by_words "$artist"
    ;;
esac
