#!/usr/bin/env bash
source "$HOME/.config/rofi/bin/dependencies/rofi-core.sh"

rofi_cmd() {
    rofi_core -w "15%" "$@"
}

get_brightness_icon() {
    local BRIGHTNESS=$1
    if ((BRIGHTNESS <= 10)); then
        echo ""
    elif ((BRIGHTNESS <= 20)); then
        echo ""
    elif ((BRIGHTNESS <= 30)); then
        echo ""
    elif ((BRIGHTNESS <= 40)); then
        echo ""
    elif ((BRIGHTNESS <= 50)); then
        echo ""
    elif ((BRIGHTNESS <= 60)); then
        echo ""
    elif ((BRIGHTNESS <= 70)); then
        echo ""
    elif ((BRIGHTNESS <= 85)); then
        echo ""
    else
        echo ""
    fi
}

send_brightness_notification() {
    local BRIGHTNESS=$1
    local ICON
    ICON=$(get_brightness_icon "$BRIGHTNESS")
    notify-send "$ICON  $BRIGHTNESS%" -t 1500
}

get_active_devices() {
    # Lee el JSON de Niri y extrae los nombres de los monitores
    # que tienen una configuración lógica asignada (están activos/enabled)
    niri msg --json outputs | jq -r 'to_entries[] | select(.value.logical != null) | .key'
}

get_brightness() {
    # Leemos los dispositivos activos
    local DEVICES
    readarray -t DEVICES <<<"$(get_active_devices)"

    # Para la visualización en el menú, tomamos el brillo del primer dispositivo activo
    local FIRST_DEVICE="${DEVICES[0]}"

    if [[ "$FIRST_DEVICE" == eDP* ]]; then
        brightnessctl -m | cut -d',' -f4 | tr -d '%'
    else
        ddcutil getvcp 10 2>/dev/null | grep -oP 'current value =\s*\K[0-9]+' | head -1
    fi
}

set_brightness() {
    local NEW_BRIGHTNESS=$1
    local DEVICES
    readarray -t DEVICES <<<"$(get_active_devices)"

    # Clampear límites
    if ((NEW_BRIGHTNESS > 100)); then NEW_BRIGHTNESS=100; fi
    if ((NEW_BRIGHTNESS < 0)); then NEW_BRIGHTNESS=0; fi

    # Aplicamos secuencialmente a cada monitor habilitado
    for DEVICE in "${DEVICES[@]}"; do
        if [[ -z "$DEVICE" ]]; then continue; fi

        if [[ "$DEVICE" == eDP* ]]; then
            # Es la pantalla del portátil
            brightnessctl s "${NEW_BRIGHTNESS}%"
        else
            # Es un monitor externo
            ddcutil setvcp 10 "$NEW_BRIGHTNESS"
        fi
    done
}

adjust_brightness() {
    local PROMPT=$1
    local BRIGHTNESS_OPTIONS
    BRIGHTNESS_OPTIONS=$(printf "%s\n" {0..100..5})

    local NEW_BRIGHTNESS
    NEW_BRIGHTNESS=$(echo "$BRIGHTNESS_OPTIONS" | rofi_cmd -p "$PROMPT")

    if [ -n "$NEW_BRIGHTNESS" ]; then
        NEW_BRIGHTNESS=$(echo "$NEW_BRIGHTNESS" | tr -d '%')
        set_brightness "$NEW_BRIGHTNESS"
        send_brightness_notification "$NEW_BRIGHTNESS"
    fi
}

increase_brightness() {
    local CURRENT
    CURRENT=$(get_brightness)
    local NEW=$((CURRENT + 5))

    set_brightness "$NEW"
    send_brightness_notification "$NEW"
}

decrease_brightness() {
    local CURRENT
    CURRENT=$(get_brightness)
    local NEW=$((CURRENT - 5))

    set_brightness "$NEW"
    send_brightness_notification "$NEW"
}

menu() {
    local CURRENT_BRIGHTNESS
    local ACTIVE_DEVICES
    local MENU_TEXT
    local CHOICE

    CURRENT_BRIGHTNESS=$(get_brightness)
    # Formatea los dispositivos (ej: "eDP-1, HDMI-A-1") para mostrarlos en el menú
    ACTIVE_DEVICES=$(get_active_devices | paste -sd, -)

    MENU_TEXT=$(printf "Devices: %s\nBrightness: %s%%\nIncrease Brightness (+5%%)\nDecrease Brightness (-5%%)" \
        "$ACTIVE_DEVICES" "$CURRENT_BRIGHTNESS")

    CHOICE=$(echo -e "$MENU_TEXT" | rofi_cmd -mesg "Brightness Manager" -N -c 'textbox{horizontal-align: 0.5; padding: 5px;}')

    case "$CHOICE" in
    "Brightness:"*)
        adjust_brightness "Nivel exacto:"
        ;;
    "Increase"*)
        increase_brightness
        ;;
    "Decrease"*)
        decrease_brightness
        ;;
    esac
}

menu
