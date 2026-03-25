#!/usr/bin/env bash
set -euo pipefail

SERVICE_STATUS=$(systemctl is-active cups.service)

is_afirmative() {
    local input=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    [[ "$input" == "y" || "$input" == "s" || "$input" == "yes" || "$input" == "si" ]]
}

# if [[ "$SERVICE_STATUS" != "active" ]]; then
#     echo "[+] Starting Cups Service"
#     sudo systemctl start cups.service
# fi

loop=true

while $loop; do
    read -p "¿Conoces el directorio completo del archivo a imprimir?(s/n): " temp
    if ! is_afirmative "$temp"; then
        echo "Buscando archivos en ~/Documents, ~/Downloads/, ~/Pictures/"
        archivo=$(find ~/Documents/ ~/Downloads/ ~/Pictures/ -type f |
            fzf --preview 'bash -c "
            case \"{}\" in
                *.pdf) pdftotext \"{}\" - | head -n 40 ;;
                *.txt|*.md) head -n 40 \"{}\" ;;
                *) echo Sin preview ;;
            esac
            "')
    fi

    read -p "¿Blanco y negro?(s/n) " byn
    if is_afirmative "$byn"; then
        echo "Hola todo feten esto es blanco y negro"
    else
        echo "esto no es blanco y negro"
    fi
done
