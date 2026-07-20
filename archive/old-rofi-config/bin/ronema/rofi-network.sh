#!/usr/bin/env bash
# From https://github.com/P3rf/rofi-network-manager fixed to match my style
# The biggest changes are the caching and the way to change listing with rofi_core

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$HOME/.config/rofi/bin/dependencies/rofi-core.sh"

rofi_cmd() {
    rofi_core -N \
        -mesg "Select an option:" \
        -c 'listview { lines: 8; fixed-height: false; } textbox { horizontal-align: 0.5; padding: 5px; }' \
        -w "45ch" \
        "$@"
}

WIRELESS_INTERFACES=()
WIRELESS_INTERFACES_PRODUCT=()
WLAN_INT=0
WIRED_INTERFACES=()
WIRED_INTERFACES_PRODUCT=()
HOTSPOT_SSID="Hotspot"
HOTSPOT_PASSWORD="ThinkingRock123"
HOTSPOT_CON_NAME="Hotspot"
CACHE_FILE="/tmp/ronema_devices_cache"
WIFI_CACHE_FILE="/tmp/ronema_wifi_cache"
CACHE_TTL=30
CONFIG_LOADED=0

log() {
    echo "[$(date '+%H:%M:%S')] $1"
    echo "[$(date '+%H:%M:%S')] $1" >>"/tmp/ronema.log"
}

function get_device_info_cached() {
    local cache_age

    if [[ -f "$CACHE_FILE" ]]; then
        cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
        if [[ $cache_age -lt $CACHE_TTL ]]; then
            log "Using cached device info (age: ${cache_age}s)"
            source "$CACHE_FILE"
            return
        fi
    fi

    log "Getting fresh device info"
    get_device_info_fresh
    save_device_cache
}

function get_device_info_fresh() {
    WIRELESS_INTERFACES=()
    WIRED_INTERFACES=()
    WIRELESS_INTERFACES_PRODUCT=()
    WIRED_INTERFACES_PRODUCT=()

    local device_list
    device_list=$(nmcli -t -f DEVICE,TYPE device status)

    while IFS=':' read -r device type _; do
        case "$type" in
        "wifi")
            WIRELESS_INTERFACES+=("$device")
            ;;
        "ethernet")
            WIRED_INTERFACES+=("$device")
            ;;
        esac
    done <<<"$device_list"

    if [[ ${#WIRELESS_INTERFACES[@]} -gt 0 ]]; then
        for device in "${WIRELESS_INTERFACES[@]}"; do
            local product
            product=$(nmcli -t -f general.product device show "$device" 2>/dev/null | cut -d: -f2)
            WIRELESS_INTERFACES_PRODUCT+=("${product:-Unknown}")
        done
    fi

    if [[ ${#WIRED_INTERFACES[@]} -gt 0 ]]; then
        for device in "${WIRED_INTERFACES[@]}"; do
            local product
            product=$(nmcli -t -f general.product device show "$device" 2>/dev/null | cut -d: -f2)
            WIRED_INTERFACES_PRODUCT+=("${product:-Unknown}")
        done
    fi
}

function save_device_cache() {
    cat >"$CACHE_FILE" <<EOF
WIRELESS_INTERFACES=($(printf "'%s' " "${WIRELESS_INTERFACES[@]}"))
WIRED_INTERFACES=($(printf "'%s' " "${WIRED_INTERFACES[@]}"))
WIRELESS_INTERFACES_PRODUCT=($(printf "'%s' " "${WIRELESS_INTERFACES_PRODUCT[@]}"))
WIRED_INTERFACES_PRODUCT=($(printf "'%s' " "${WIRED_INTERFACES_PRODUCT[@]}"))
EOF
}

function get_wifi_list_cached() {
    if [[ -f "$WIFI_CACHE_FILE" ]]; then
        local cache_age
        cache_age=$(($(date +%s) - $(stat -c %Y "$WIFI_CACHE_FILE" 2>/dev/null || echo 0)))
        log "Using cached WiFi list (age: ${cache_age}s)"
        WIFI_LIST=$(cat "$WIFI_CACHE_FILE")
    else
        log "WiFi cache empty. Use 'Scan' to populate."
        WIFI_LIST=""
    fi

    wifi_list
}

function lazy_load_config() {
    [[ $CONFIG_LOADED -eq 1 ]] && return

    source "$DIR/ronema.conf" || source "$HOME/.config/rofi/bin/ronema-config/ronema.conf" || {
        log "Error: Could not load configuration"
        exit 1
    }

    source "$DIR/languages/${LANGUAGE}.lang" || source "$HOME/.config/rofi/bin/ronema-config/languages/${LANGUAGE}.lang" || {
        log "Error: Could not load language file"
        exit 1
    }

    { [[ -d "$DIR/icons" ]] && ICON_DIR="$DIR/icons"; } || { [[ -d "$HOME/.config/rofi/bin/ronema-config/icons" ]] && ICON_DIR="$HOME/.config/rofi/bin/ronema-config/icons"; } || {
        log "Error: Could not find icons directory"
        exit 1
    }

    CONFIG_LOADED=1
    log "Configuration loaded successfully"
}

function initialization() {
    log "Starting ronema"
    lazy_load_config
    get_device_info_cached
    wireless_interface_state
}

function notification() {
    [[ "$NOTIFICATIONS" == "true" && -x "$(command -v notify-send)" ]] || return

    local ICON=""
    [[ $NOTIFICATIONS_ICONS == true ]] && ICON="-i $ICON_DIR/$3"

    local TITLE="${1//-t [0-9] /}"
    TITLE="${TITLE//-t [0-9] /}"

    notify-send -r 5 -t 1000 -u low "$TITLE" "$2" $ICON
}

function wireless_interface_state() {
    [[ ${#WIRELESS_INTERFACES[@]} -eq "0" ]] && return

    local device_status
    device_status=$(nmcli -t -f DEVICE,STATE,CONNECTION device status | grep "^${WIRELESS_INTERFACES[WLAN_INT]}:")

    if [[ -n "$device_status" ]]; then
        IFS=':' read -r device state connection <<<"$device_status"
        WIFI_CON_STATE="$state"
        ACTIVE_SSID="$connection"
        [[ -z "$ACTIVE_SSID" ]] && ACTIVE_SSID="--"
    else
        WIFI_CON_STATE="unavailable"
        ACTIVE_SSID="--"
    fi

    if [[ "$WIFI_CON_STATE" == "unavailable" ]]; then
        WIFI_LIST="${SELECTION_WIFI_DISABLED}"
        WIFI_SWITCH="${SELECTION_PREFIX}${SELECTION_WIFI_ON}"
        OPTIONS="${WIFI_LIST}\n${WIFI_SWITCH}\n${SELECTION_PREFIX}${SELECTION_SCAN}\n"
    elif [[ "$WIFI_CON_STATE" =~ "connected" ]]; then
        PROMPT=${WIRELESS_INTERFACES_PRODUCT[WLAN_INT]}[${WIRELESS_INTERFACES[WLAN_INT]}]
        get_wifi_list_cached
        [[ "$ACTIVE_SSID" == "--" ]] && WIFI_SWITCH="${SELECTION_PREFIX}${SELECTION_SCAN}\n${SELECTION_PREFIX}${SELECTION_MANUAL_HIDDEN}\n${SELECTION_PREFIX}${SELECTION_WIFI_OFF}" || WIFI_SWITCH="${SELECTION_PREFIX}${SELECTION_SCAN}\n${SELECTION_PREFIX}${SELECTION_DISCONECT}\n${SELECTION_PREFIX}${SELECTION_MANUAL_HIDDEN}\n${SELECTION_PREFIX}${SELECTION_WIFI_OFF}"
        OPTIONS="${WIFI_LIST}\n${WIFI_SWITCH}\n"
    fi
}

function ethernet_interface_state() {
    [[ ${#WIRED_INTERFACES[@]} -eq "0" ]] && return

    WIRED_CON_STATE=$(nmcli -t -f DEVICE,STATE device status | grep "^${WIRED_INTERFACES[0]}:" | cut -d: -f2)

    case "$WIRED_CON_STATE" in
    "disconnected") WIRED_SWITCH="${SELECTION_PREFIX}${SELECTION_ETH_ON}" ;;
    "connected") WIRED_SWITCH="${SELECTION_PREFIX}${SELECTION_ETH_OFF}" ;;
    "unavailable") WIRED_SWITCH="${SELECTION_ETH_UNAVAILBLE}" ;;
    "connecting") WIRED_SWITCH="${SELECTION_ETH_INITIALIZING}" ;;
    *) WIRED_SWITCH="${SELECTION_ETH_UNAVAILBLE}" ;;
    esac

    OPTIONS="${OPTIONS}${WIRED_SWITCH}\n"
}

function rofi_menu() {
    OPTIONS=""
    [[ -n "$WIFI_LIST" ]] && OPTIONS="${OPTIONS}${WIFI_LIST}\n"
    OPTIONS="${OPTIONS}\n"
    OPTIONS="${OPTIONS}${SELECTION_PREFIX}${SELECTION_SCAN}\n"

    if [[ "$WIFI_CON_STATE" =~ "connected" ]] && [[ "$ACTIVE_SSID" != "--" ]]; then
        OPTIONS="${OPTIONS}${SELECTION_PREFIX}${SELECTION_DISCONECT}\n"
    fi

    if nmcli -t -f NAME connection show --active | grep -qFx "$HOTSPOT_CON_NAME"; then
        HOTSPOT_LABEL="${SELECTION_PREFIX}${SELECTION_HOTSPOT} [ON]"
    else
        HOTSPOT_LABEL="${SELECTION_PREFIX}${SELECTION_HOTSPOT} [OFF]"
    fi
    OPTIONS="${OPTIONS}${HOTSPOT_LABEL}\n"

    if [[ "$WIFI_CON_STATE" == "unavailable" ]] || [[ "$WIFI_CON_STATE" == "disabled" ]]; then
        OPTIONS="${OPTIONS}${SELECTION_PREFIX}${SELECTION_WIFI_ON}\n"
    else
        OPTIONS="${OPTIONS}${SELECTION_PREFIX}${SELECTION_WIFI_OFF}\n"
    fi

    if [[ ${#WIRELESS_INTERFACES[@]} -gt "1" ]]; then
        OPTIONS="${OPTIONS}${SELECTION_PREFIX}${SELECTION_CHANGE_WIFI_INTERFACE}\n"
    fi

    OPTIONS="${OPTIONS}${SELECTION_PREFIX}${SELECTION_MORE_OPTIONS}"

    SELECTION=$(echo -e "$OPTIONS" | rofi_cmd -a 0)

    SSID=$(echo "$SELECTION" | sed 's/^* //' | awk -F'  +' '{print $1}')
    selection_action
}

function change_wireless_interface() {
    { [[ ${#WIRELESS_INTERFACES[@]} -eq "2" ]] && { [[ $WLAN_INT -eq "0" ]] && WLAN_INT=1 || WLAN_INT=0; }; } || {
        LIST_WLAN_INT=""
        for i in "${!WIRELESS_INTERFACES[@]}"; do LIST_WLAN_INT=("${LIST_WLAN_INT[@]}${WIRELESS_INTERFACES_PRODUCT[$i]}[${WIRELESS_INTERFACES[$i]}]\n"); done
        LIST_WLAN_INT[-1]=${LIST_WLAN_INT[-1]::-2}

        CHANGE_WLAN_INT=$(echo -e "${LIST_WLAN_INT[@]}" | rofi_cmd)

        for i in "${!WIRELESS_INTERFACES[@]}"; do [[ $CHANGE_WLAN_INT == "${WIRELESS_INTERFACES_PRODUCT[$i]}[${WIRELESS_INTERFACES[$i]}]" ]] && WLAN_INT=$i && break; done
    }
    wireless_interface_state
    rofi_menu
}

function scan() {
    log "Scanning available wifi connections"
    [[ "$WIFI_CON_STATE" =~ "unavailable" ]] && change_wifi_state "${NOTIFICATION_WIFI_TILE}" "${NOTIFICATION_WIFI_ENABLE}" "on" "wifi-on.svg" && sleep 2
    notification "-t 0 ${NOTIFICATION_WIFI_TILE}" "${NOTIFICATION_WIFI_SCANNING}" "scanning.svg"
    WIFI_LIST=$(nmcli --fields SSID,SECURITY,BARS device wifi list ifname "${WIRELESS_INTERFACES[WLAN_INT]}" --rescan yes)
    echo "$WIFI_LIST" >"$WIFI_CACHE_FILE"
    wifi_list
    wireless_interface_state
    notification "-t 1 ${NOTIFICATION_WIFI_TILE}" "${NOTIFICATION_WIFI_SCANNING}" "scanning.svg"
    rofi_menu
}

function wifi_list() {
    local header_line
    header_line=$(echo -e "$WIFI_LIST" | head -n 1)

    local body_lines
    body_lines=$(echo -e "$WIFI_LIST" | tail -n +2)

    local clean_body
    clean_body=$(echo -e "$body_lines" | awk -F'  +' '!seen[$1]++ && $1!="--" {print}')

    local formatted_body
    formatted_body="$clean_body"
    [[ $ASCII_OUT == "true" ]] && formatted_body=$(echo -e "$formatted_body" | sed 's/\(..*\)\*\{4,4\}/\1▂▄▆█/g' | sed 's/\(..*\)\*\{3,3\}/\1▂▄▆_/g' | sed 's/\(..*\)\*\{2,2\}/\1▂▄__/g' | sed 's/\(..*\)\*\{1,1\}/\1▂___/g')
    [[ $CHANGE_BARS == "true" ]] && formatted_body=$(echo -e "$formatted_body" | sed 's/\(.*\)▂▄▆█/\1'$SIGNAL_STRENGTH_4'/' | sed 's/\(.*\)▂▄▆_/\1'$SIGNAL_STRENGTH_3'/' | sed 's/\(.*\)▂▄__/\1'$SIGNAL_STRENGTH_2'/' | sed 's/\(.*\)▂___/\1'$SIGNAL_STRENGTH_1'/' | sed 's/\(.*\)____/\1'$SIGNAL_STRENGTH_0'/')

    local active_line=""
    local other_lines=""
    if [[ -n "$ACTIVE_SSID" && "$ACTIVE_SSID" != "--" ]]; then
        active_line=$(echo -e "$formatted_body" | awk -v active_ssid="$ACTIVE_SSID" 'BEGIN{FS="  +"; OFS=FS} $1 == active_ssid')
        other_lines=$(echo -e "$formatted_body" | awk -v active_ssid="$ACTIVE_SSID" 'BEGIN{FS="  +"; OFS=FS} $1 != active_ssid')

        if [[ -n "$active_line" ]]; then
            active_line="* ${active_line}"
        fi
    else
        other_lines="$formatted_body"
    fi

    WIFI_LIST=$(echo -e "${header_line}\n${active_line}\n${other_lines}" | sed '/^$/d')
}

function change_wifi_state() {
    notification "$1" "$2" "$4"
    nmcli radio wifi "$3"
}

function change_wired_state() {
    notification "$1" "$2" "$5"
    nmcli device "$3" "$4"
}

function net_restart() {
    notification "$1" "$2" "restart.svg"
    nmcli networking off && sleep 3 && nmcli networking on
}

function disconnect() {
    ACTIVE_SSID=$(nmcli -t -f GENERAL.CONNECTION dev show "${WIRELESS_INTERFACES[WLAN_INT]}" | cut -d ':' -f2)
    notification "$1" "${NOTIFICATION_WIFI_DISCONNECTED} '$ACTIVE_SSID'" "wifi-off.svg"
    nmcli con down id "$ACTIVE_SSID"
}

function check_wifi_connected() {
    [[ "$(nmcli device status | grep "^${WIRELESS_INTERFACES[WLAN_INT]}." | awk '{print $3}')" == "connected" ]] && disconnect "${NOTIFICATION_WIFI_TILE_TERMINATED}"
}

function connect() {
    check_wifi_connected
    notification "-t 0 Wi-Fi" "${NOTIFICATION_WIFI_CONNECTING} $1" "wait.svg"

    if nmcli dev wifi con "$1" password "$2" ifname "${WIRELESS_INTERFACES[WLAN_INT]}" &>/dev/null; then
        notification "${NOTIFICATION_WIFI_TILE_CONNECTION_OK}" "${NOTIFICATION_WIFI_CONNECTED} '$1'" "wifi-on.svg"
    else
        notification "${NOTIFICATION_WIFI_TILE_CONNECTION_ERROR}" "${NOTIFICATION_WIFI_ERROR}" "alert.svg"
    fi
}

function enter_passwword() {
    PROMPT="${PROMPT_PASSWORD}"
    PASS=$(echo "$PASSWORD_ENTER" | rofi_core -c 'listview { lines: 8; fixed-height: false; } textbox { horizontal-align: 0.5; padding: 5px; }' -w "45ch" -p "$PROMPT" -password)
}

function enter_ssid() {
    PROMPT="${PROMPT_SSID}"
    SSID=$(rofi_cmd -p "$PROMPT")
}

function stored_connection() {
    check_wifi_connected
    notification "-t 0 Wi-Fi" "${NOTIFICATION_WIFI_CONNECTING} $1" "wait.svg"

    if nmcli con up "$1" ifname "${WIRELESS_INTERFACES[WLAN_INT]}" &>/dev/null; then
        notification "${NOTIFICATION_WIFI_TILE_CONNECTION_OK}" "${NOTIFICATION_WIFI_CONNECTED} '$1'" "wifi-on.svg"
    else
        notification "${NOTIFICATION_WIFI_TILE_CONNECTION_ERROR}" "${NOTIFICATION_WIFI_ERROR}" "alert.svg"
    fi
}

function ssid_manual() {
    enter_ssid
    [[ -n $SSID ]] && {
        enter_passwword
        { [[ -n "$PASS" ]] && [[ "$PASS" != "$PASSWORD_ENTER" ]] && connect "$SSID" "$PASS"; } || stored_connection "$SSID"
    }
}

function ssid_hidden() {
    enter_ssid
    [[ -n $SSID ]] && {
        enter_passwword && check_wifi_connected
        [[ -n "$PASS" ]] && [[ "$PASS" != "$PASSWORD_ENTER" ]] && {
            nmcli con add type wifi con-name "$SSID" ssid "$SSID" ifname "${WIRELESS_INTERFACES[WLAN_INT]}"
            nmcli con modify "$SSID" wifi-sec.key-mgmt wpa-psk
            nmcli con modify "$SSID" wifi-sec.psk "$PASS"
        } || [[ $(nmcli -g NAME con show | grep -c "$SSID") -eq "0" ]] && nmcli con add type wifi con-name "$SSID" ssid "$SSID" ifname "${WIRELESS_INTERFACES[WLAN_INT]}"
        notification "-t 0 ${NOTIFICATION_WIFI_TILE}" "${NOTIFICATION_WIFI_CONNECTING} $SSID" "wait.svg"

        if nmcli con up id "$SSID" &>/dev/null; then
            notification "${NOTIFICATION_WIFI_TILE_CONNECTION_OK}" "${NOTIFICATION_WIFI_CONNECTED} '$SSID'"
        else
            notification "${NOTIFICATION_WIFI_TILE_CONNECTION_ERROR}" "${NOTIFICATION_WIFI_ERROR}" "alert.svg"
        fi
    }
}

function interface_status() {
    local -n INTERFACES=$1 && local -n INTERFACES_PRODUCT=$2
    for i in "${!INTERFACES[@]}"; do
        CON_STATE=$(nmcli device status | grep "^${INTERFACES[$i]}." | awk '{print $3}')
        INT_NAME=${INTERFACES_PRODUCT[$i]}[${INTERFACES[$i]}]
        [[ "$CON_STATE" == "connected" ]] && STATUS="$INT_NAME:\n\t$(nmcli -t -f GENERAL.CONNECTION dev show "${INTERFACES[$i]}" | awk -F '[:]' '{print $2}') ~ $(nmcli -t -f IP4.ADDRESS dev show "${INTERFACES[$i]}" | awk -F '[:/]' '{print $2}')" || STATUS="$INT_NAME: ${CON_STATE^}"
        echo -e "${STATUS}"
    done
}

function status() {
    OPTIONS=""
    [[ ${#WIRED_INTERFACES[@]} -ne "0" ]] && ETH_STATUS="$(interface_status WIRED_INTERFACES WIRED_INTERFACES_PRODUCT)" && OPTIONS="${OPTIONS}${ETH_STATUS}"
    [[ ${#WIRELESS_INTERFACES[@]} -ne "0" ]] && WLAN_STATUS="$(interface_status WIRELESS_INTERFACES WIRELESS_INTERFACES_PRODUCT)" && { [[ -n ${OPTIONS} ]] && OPTIONS="${OPTIONS}\n${WLAN_STATUS}" || OPTIONS="${OPTIONS}${WLAN_STATUS}"; }

    echo -e "$OPTIONS" | rofi_cmd -c "mainbox{children:[listview];}"
}

function share_pass() {
    SSID=$(nmcli dev wifi show-password | grep -oP '(?<=SSID: ).*' | head -1)
    PASSWORD=$(nmcli dev wifi show-password | grep -oP '(?<=Password: ).*' | head -1)

    local label_pass="Password: ${PASSWORD}"
    OPTIONS="SSID: ${SSID}\n${label_pass}"

    [[ -x "$(command -v qrencode)" ]] && OPTIONS="${OPTIONS}\n${SELECTION_PREFIX}${SELECTION_QRCODE}"

    SELECTION=$(echo -e "$OPTIONS" | rofi_cmd -a -1 -c "mainbox{children:[listview];}")

    if [[ "$SELECTION" == "$label_pass" ]]; then
        if [[ -x "$(command -v wl-copy)" ]]; then
            echo -n "$PASSWORD" | wl-copy
            notification "Ronema" "Password copied to clipboard!" "edit-copy.svg"
        else
            notification "Error" "wl-copy not found. Please install wayland-utils." "alert.svg"
        fi
    fi

    selection_action
}

function gen_qrcode() {
    : "${QRCODE_DIR:="/tmp/"}"
    : "${QRCODE_LOCATION:=0}"

    local DIRECTIONS=("center" "northwest" "north" "northeast" "east" "southeast" "south" "southwest" "west")
    local TMP_SSID="${SSID// /_}"
    local QR_PATH="${QRCODE_DIR}${TMP_SSID}.png"

    if [[ ! -e "$QR_PATH" ]]; then
        local SEC=$(nmcli dev wifi show-password | grep -oP '(?<=Security: ).*' | head -1)
        qrencode -t png -o "$QR_PATH" -l H -s 25 -m 2 --dpi=192 "WIFI:S:$SSID;T:${SEC:-WPA};P:$PASSWORD;;"
    fi

    # Fix for the QR code
    rofi_core -w "400px" -c "window { location: ${DIRECTIONS[$QRCODE_LOCATION]}; border-radius: 15px; height: 400px; background-color: transparent; background-image: url(\"$QR_PATH\", both); } mainbox { enabled: false; } inputbar { enabled: false; } listview { enabled: false; }"
}

function manual_hidden() {
    OPTIONS="${SELECTION_PREFIX}${SELECTION_MANUAL}\n${SELECTION_PREFIX}${SELECTION_HIDDEN}"
    SELECTION=$(echo -e "$OPTIONS" | rofi_cmd -c "mainbox{children:[listview];}")
    selection_action
}

function hotspot_management() {
    if nmcli -t -f NAME connection show --active | grep -qFx "$HOTSPOT_CON_NAME"; then
        log "Check Hotspot: '$HOTSPOT_CON_NAME' está ACTIVO. Mostrando opción OFF."
        OPTIONS="${SELECTION_PREFIX}${SELECTION_HOTSPOT_OFF}"
    else
        log "Check Hotspot: '$HOTSPOT_CON_NAME' NO está activo. Mostrando opción ON."
        OPTIONS="${SELECTION_PREFIX}${SELECTION_HOTSPOT_ON}"
    fi

    SELECTION=$(echo -e "$OPTIONS" | rofi_cmd -c "mainbox {children:[listview];}")
    selection_action
}

function create_hotspot() {
    log "Connection not found. Creating $HOTSPOT_CON_NAME..."
    notification "-t 0 ${NOTIFICATION_HOTSPOT_TITLE}" "${NOTIFICATION_HOTSPOT_CREATING}" "wifi-on.svg"

    nmcli con add type wifi ifname "${WIRELESS_INTERFACES[WLAN_INT]}" con-name "$HOTSPOT_CON_NAME" autoconnect no ssid "$HOTSPOT_SSID" \
        802-11-wireless.mode ap \
        802-11-wireless-security.key-mgmt wpa-psk \
        802-11-wireless-security.psk "$HOTSPOT_PASSWORD" \
        802-11-wireless-security.proto rsn \
        802-11-wireless-security.group ccmp \
        802-11-wireless-security.pairwise ccmp \
        802-11-wireless-security.pmf 0 \
        ipv4.method shared
}

function activate_hotspot() {
    if ! nmcli con show "$HOTSPOT_CON_NAME" &>/dev/null; then
        create_hotspot
    fi

    notification "-t 0 ${NOTIFICATION_HOTSPOT_TITLE}" "${NOTIFICATION_HOTSPOT_ACTIVATING}" "wifi-on.svg"

    if nmcli con up "$HOTSPOT_CON_NAME"; then
        notification "${NOTIFICATION_HOTSPOT_TITLE_OK}" "${NOTIFICATION_HOTSPOT_ACTIVATED}" "wifi-on.svg"
    else
        notification "${NOTIFICATION_HOTSPOT_TITLE_ERROR}" "${NOTIFICATION_HOTSPOT_ERROR}" "alert.svg"
    fi
}

function deactivate_hotspot() {
    notification "${NOTIFICATION_HOTSPOT_TITLE}" "${NOTIFICATION_HOTSPOT_DEACTIVATING}" "wifi-off.svg"
    nmcli con down "$HOTSPOT_CON_NAME"
    notification "${NOTIFICATION_HOTSPOT_TITLE}" "${NOTIFICATION_HOTSPOT_DEACTIVATED}" "wifi-off.svg"
}

function more_options() {
    OPTIONS=""
    [[ "$WIFI_CON_STATE" == "connected" ]] && OPTIONS="${SELECTION_PREFIX}${SELECTION_SHARE}\n"
    OPTIONS="${OPTIONS}${SELECTION_PREFIX}${SELECTION_STATUS}\n${SELECTION_PREFIX}${SELECTION_RESTAT_NETWORK}"
    OPTIONS="${OPTIONS}\n${SELECTION_PREFIX}${SELECTION_HOTSPOT}"

    [[ -x "$(command -v nm-connection-editor)" ]] && OPTIONS="${OPTIONS}\n${SELECTION_PREFIX}${SELECTION_OPEN_EDITOR}"

    SELECTION=$(echo -e "$OPTIONS" | rofi_cmd -c "mainbox {children:[listview];}")
    selection_action
}

function selection_action() {
    case "$SELECTION" in
    "${SELECTION_PREFIX}${SELECTION_DISCONECT}") disconnect "${NOTIFICATION_WIFI_TILE_TERMINATED}" ;;
    "${SELECTION_PREFIX}${SELECTION_SCAN}") scan ;;
    "${SELECTION_PREFIX}${SELECTION_STATUS}") status ;;
    "${SELECTION_PREFIX}${SELECTION_SHARE}") share_pass ;;
    "${SELECTION_PREFIX}${SELECTION_MANUAL_HIDDEN}") manual_hidden ;;
    "${SELECTION_PREFIX}${SELECTION_MANUAL}") ssid_manual ;;
    "${SELECTION_PREFIX}${SELECTION_HIDDEN}") ssid_hidden ;;
    "${SELECTION_PREFIX}${SELECTION_WIFI_ON}") change_wifi_state "${NOTIFICATION_WIFI_TILE}" "${NOTIFICATION_WIFI_ENABLE}" "on" "wifi-on.svg" ;;
    "${SELECTION_PREFIX}${SELECTION_WIFI_OFF}") change_wifi_state "${NOTIFICATION_WIFI_TILE}" "${NOTIFICATION_WIFI_DISABLE}" "off" "wifi-off.svg" ;;
    "${SELECTION_PREFIX}${SELECTION_ETH_OFF}") change_wired_state "${NOTIFICATION_WIRED_TITLE}" "${NOTIFICATION_WIRED_DISBALE}" "disconnect" "${WIRED_INTERFACES}" "wired-off.svg" ;;
    "${SELECTION_PREFIX}${SELECTION_ETH_ON}") change_wired_state "${NOTIFICATION_WIRED_TITLE}" "${NOTIFICATION_WIRED_ENABLE}" "connect" "${WIRED_INTERFACES}" "wired-on.svg" ;;
    "${SELECTION_WIFI_DISABLED}") main ;;
    "${SELECTION_ETH_UNAVAILBLE}") main ;;
    "${SELECTION_ETH_INITIALIZING}") main ;;
    "${SELECTION_PREFIX}${SELECTION_CHANGE_WIFI_INTERFACE}") change_wireless_interface ;;
    "${SELECTION_PREFIX}${SELECTION_RESTAT_NETWORK}") net_restart "${NOTIFICATION_NETWORK_TITLE}" "${NOTIFICATION_NETWORK_RESTART}" ;;
    "${SELECTION_PREFIX}${SELECTION_QRCODE}") gen_qrcode ;;
    "${SELECTION_PREFIX}${SELECTION_MORE_OPTIONS}") more_options ;;
    "${SELECTION_PREFIX}${SELECTION_OPEN_EDITOR}") nm-connection-editor ;;
    "${SELECTION_PREFIX}${SELECTION_HOTSPOT} [ON]") deactivate_hotspot ;;
    "${SELECTION_PREFIX}${SELECTION_HOTSPOT} [OFF]") activate_hotspot ;;
    "${SELECTION_PREFIX}${SELECTION_HOTSPOT_CREATE}") create_hotspot ;;
    *)
        [[ -n "$SELECTION" ]] && [[ "$WIFI_LIST" =~ .*"$SELECTION".* ]] && {
            [[ "$SSID" == "*" ]] && SSID=$(echo "$SELECTION" | sed "s/\s\{2,\}/\|/g " | awk -F "|" '{print $3}')
            { [[ "$ACTIVE_SSID" == "$SSID" ]] && nmcli con up "$SSID" ifname "${WIRELESS_INTERFACES[WLAN_INT]}"; } || {
                [[ "$SELECTION" =~ "WPA2" ]] || [[ "$SELECTION" =~ "WEP" ]] && enter_passwword
                { [[ -n "$PASS" ]] && [[ "$PASS" != "$PASSWORD_ENTER" ]] && connect "$SSID" "$PASS"; } || stored_connection "$SSID"
            }
        }
        ;;
    esac
}

function main() {
    if [[ "$1" == "--cache" ]]; then
        # Solo cargar config y refrescar archivos temporales
        lazy_load_config
        get_device_info_fresh
        save_device_cache
        # Escaneo silencioso de redes WiFi
        WIFI_LIST=$(nmcli --fields SSID,SECURITY,BARS device wifi list --rescan yes)
        echo "$WIFI_LIST" >"$WIFI_CACHE_FILE"
        log "Caché actualizada mediante --cache"
        exit 0
    fi

    initialization && rofi_menu
}

main "$@"

main
