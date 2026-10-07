#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Uso: $0 \"Nombre\" \"https://ejemplo.com\""
  exit 1
fi

NAME="$1"
URL="$2"

# 1. Extraer el dominio base (ej. 'https://www.netflix.com/games' -> 'www.netflix.com')
DOMAIN=$(echo "$URL" | awk -F[/:] '{print $4}')
[ -z "$DOMAIN" ] && DOMAIN=$(echo "$URL" | cut -d/ -f1)

# 2. Formatear nombres de archivo y rutas locales
SLUG=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
ICONS_DIR="$HOME/.local/share/icons/web-shortcuts"
ICON_PATH="$ICONS_DIR/$SLUG.ico"
DESKTOP_FILE="$HOME/.local/share/applications/zen-$SLUG.desktop"

mkdir -p "$ICONS_DIR"

# 3. Descargar el icono desde DuckDuckGo (falla silenciosamente si no hay red)
curl -sL "https://icons.duckduckgo.com/ip2/${DOMAIN}.ico" -o "$ICON_PATH"

# Verificar si se descargó un archivo válido; si está vacío, usar el icono de Zen
if [ ! -s "$ICON_PATH" ]; then
  ICON_PATH="zen-browser"
fi

# 4. Crear el archivo .desktop
cat <<EOF >"$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Type=Application
Name=$NAME
Exec=zen-browser "$URL"
Icon=$ICON_PATH
Terminal=false
Comment=Abrir $URL en Zen Browser
Categories=Network;WebBrowser;
EOF

chmod +x "$DESKTOP_FILE"

echo "Acceso directo creado:"
echo "  Desktop: $DESKTOP_FILE"
echo "  Icono:   $ICON_PATH"
