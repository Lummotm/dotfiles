#!/usr/bin/env bash
set -euo pipefail

SYS_BATTERY_PATH=""
for bat in /sys/class/power_supply/BAT*; do
    if [[ -d "$bat" ]]; then
        SYS_BATTERY_PATH="$bat"
        break
    fi
done

get_weather() {
    local CACHE_FILE="/tmp/weather.cache"
    local NOW
    NOW=$(date +%s)
    local CACHE_TIME=0
    local DIFF=999999

    if [[ -f "$CACHE_FILE" ]]; then
        CACHE_TIME=$(stat -c %Y "$CACHE_FILE")
        DIFF=$((NOW - CACHE_TIME))
    fi

    if [[ ! -f "$CACHE_FILE" ]] || ((DIFF > 1800)); then
        local CURRENT_CITY
        CURRENT_CITY=$(curl -s --max-time 1 https://ipinfo.io/city || echo "")

        local NEW_WEATHER
        NEW_WEATHER=$(curl -s --max-time 2 "https://wttr.in/${CURRENT_CITY}?format=%t+%c" 2>/dev/null || echo "")

        if [[ -n "$NEW_WEATHER" ]]; then
            echo "$NEW_WEATHER" | xargs >"$CACHE_FILE"
        else
            if [[ -f "$CACHE_FILE" ]] && ((DIFF < 43200)); then
                touch "$CACHE_FILE"
            else
                rm -f "$CACHE_FILE"
            fi
        fi
    fi

    if [[ -f "$CACHE_FILE" ]]; then
        cat "$CACHE_FILE"
    else
        echo ""
    fi
}

get_kb_lng() {
    $HOME/.config/niri/bin/get-kb-lang-niri.sh 2>&1 || true
}

# Lee todos los datos de upower en una sola llamada y los cachea en variables globales.
# Evita las 6 invocaciones de upower que había antes (upower -e + upower -i × 3).
_init_battery() {
    if [[ -z "$SYS_BATTERY_PATH" ]]; then
        BATTERY_PATH=""
        UPOWER_CACHE=""
        return
    fi

    local BAT_NAME
    BAT_NAME=$(basename "$SYS_BATTERY_PATH")

    BATTERY_PATH=$(upower -e | grep "$BAT_NAME" | head -n 1)
    if [[ -z "$BATTERY_PATH" ]]; then
        BATTERY_PATH=$(upower -e | grep BAT | head -n 1)
    fi

    if [[ -n "$BATTERY_PATH" ]]; then
        # Una sola llamada; el resultado se reutiliza en todas las funciones
        UPOWER_CACHE=$(upower -i "$BATTERY_PATH")
    else
        UPOWER_CACHE=""
    fi
}

get_info() {
    local INFO_REQUIRED="$1"
    if [[ -z "${UPOWER_CACHE:-}" ]]; then
        echo ""
        return
    fi
    echo "$UPOWER_CACHE" | grep "$INFO_REQUIRED" | cut -d: -f2 | tr -d ' '
}

battery_info() {
    get_info percentage
}

time_left_info() {
    local BATTERY_NOW_PCT
    BATTERY_NOW_PCT=$(get_info percentage | tr -d '%')

    local CHARGE_LIMIT_PERCENT
    CHARGE_LIMIT_PERCENT=$(cat "$SYS_BATTERY_PATH/charge_control_end_threshold" 2>/dev/null || echo 100)

    if [[ "$BATTERY_STATE" != "discharging" ]] && [[ -n "$BATTERY_NOW_PCT" ]] && [ "$BATTERY_NOW_PCT" -ge "$CHARGE_LIMIT_PERCENT" ]; then
        printf ""
        return
    fi

    if [[ "$BATTERY_STATE" == "full" ]]; then
        printf ""
        return
    fi

    local ENERGY_NOW
    ENERGY_NOW=$(cat "$SYS_BATTERY_PATH/energy_now")

    local POWER_NOW
    POWER_NOW=$(cat "$SYS_BATTERY_PATH/power_now")

    if [[ $POWER_NOW != "0" ]]; then
        local TIME_LEFT

        if [[ $BATTERY_STATE == "discharging" ]]; then
            TIME_LEFT=$(echo "scale=4; $ENERGY_NOW / $POWER_NOW" | bc)
        else
            local ENERGY_FULL
            ENERGY_FULL=$(cat "$SYS_BATTERY_PATH/energy_full")
            TIME_LEFT=$(echo "scale=4; ($ENERGY_FULL*($CHARGE_LIMIT_PERCENT/100) - $ENERGY_NOW) / $POWER_NOW" | bc)
        fi

        local HOURS DECIMAL_PART MINUTES
        HOURS=$(echo "$TIME_LEFT / 1" | bc)
        DECIMAL_PART=$(echo "$TIME_LEFT - $HOURS" | bc)
        MINUTES=$(echo "$DECIMAL_PART * 60 / 1" | bc)

        if [[ $HOURS == "0" ]]; then
            printf "%0.0fm" "$MINUTES"
        else
            printf "%sh %02dm" "$HOURS" "$MINUTES"
        fi
    else
        printf ""
    fi
}

get_bluetooth_data() {
    local DEV_LINE
    DEV_LINE=$(bluetoothctl devices Connected | head -n 1)

    if [[ -n "$DEV_LINE" ]]; then
        local NAME MAC OBJ_PATH BATT
        NAME=$(echo "$DEV_LINE" | cut -d ' ' -f 3-)
        MAC=$(echo "$DEV_LINE" | awk '{print $2}')
        OBJ_PATH="/org/bluez/hci0/dev_${MAC//:/_}"
        BATT=$(busctl get-property org.bluez "$OBJ_PATH" org.bluez.Battery1 Percentage 2>/dev/null | awk '{print $2}' || echo "")

        if [[ -n "$BATT" ]] && [[ -n "$NAME" ]]; then
            echo "$NAME  󰁹 $BATT%"
        elif [[ -n "$NAME" ]]; then
            echo "$NAME"
        fi
    fi
}

get_cpu_usage() {
    local cpu_info user nice system idle iowait irq softirq total active
    cpu_info=$(grep '^cpu ' /proc/stat)
    read -r _ user nice system idle iowait irq softirq _ <<<"$cpu_info"
    total=$((user + nice + system + idle + iowait + irq + softirq))
    active=$((user + nice + system + irq + softirq))
    printf "%d%%" "$((active * 100 / total))"
}

get_ram_usage() {
    local mem_info total available used
    mem_info=$(grep -E 'MemTotal:|MemAvailable:' /proc/meminfo)
    total=$(echo "$mem_info" | grep 'MemTotal:' | awk '{print $2}')
    available=$(echo "$mem_info" | grep 'MemAvailable:' | awk '{print $2}')
    used=$((total - available))
    printf "%dMB (%d%%)" "$((used / 1024))" "$((used * 100 / total))"
}

get_disk_usage() {
    local TARGET="${1:-/}"
    df -h "$TARGET" 2>/dev/null | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}'
}

get_network_status() {
    for eth in /sys/class/net/e*; do
        if [[ -f "$eth/operstate" ]] && [[ "$(cat "$eth/operstate")" == "up" ]]; then
            echo "ETH|Ethernet"
            return
        fi
    done

    for wlan in /sys/class/net/w*; do
        local iface SSID
        iface=$(basename "$wlan")
        SSID=$(iw dev "$iface" link 2>/dev/null | grep SSID | cut -d: -f2 | xargs || true)
        if [[ -n "$SSID" ]]; then
            echo "WIFI|$SSID"
            return
        fi
    done
}

# ── Archivos temporales para resultados paralelos ──────────────────────────────
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Lanzamos en paralelo las llamadas lentas (I/O de red, dbus, scripts externos)
get_bluetooth_data >"$TMP_DIR/bt" &
get_network_status >"$TMP_DIR/net" &
get_kb_lng >"$TMP_DIR/kb" &
get_weather >"$TMP_DIR/weather" &

# Mientras esperamos, ejecutamos lo que es puramente local (instantáneo)
_init_battery # una sola llamada a upower
HOUR=$(date +"%H:%M")
DAY=$(date +"%d-%m-%y")
CPU_USAGE=$(get_cpu_usage)
RAM_USAGE=$(get_ram_usage)
DISK_USAGE=$(get_disk_usage /)
DISK_HOME_USAGE=$(get_disk_usage /home)

# Ahora recogemos los trabajos en background
wait

BT_DATA=$(cat "$TMP_DIR/bt")
NET_INFO=$(cat "$TMP_DIR/net")
KEYBOARD_LNG=$(cat "$TMP_DIR/kb")
WEATHER_DATA=$(cat "$TMP_DIR/weather")

# ── Construcción del string ────────────────────────────────────────────────────
C_BLUE="#89b4fa"
C_SKY="#89dceb"
C_GREEN="#a6e3a1"
C_YELLOW="#f9e2af"
C_GRAY="#6c7086"
C_MAUVE="#cba6f7"

SEP="<span color='$C_GRAY'>|</span>"

######## HORA
GENERAL_STRING="<span color='$C_BLUE' weight='bold'>󰥔</span> $HOUR  $SEP $DAY"

####### BATERIA
if [[ -n "$SYS_BATTERY_PATH" ]] && [[ -n "${UPOWER_CACHE:-}" ]]; then
    BATTERY_STATE=$(get_info state)
    TIME_LEFT_STRING=$(time_left_info)
    BATTERY_STRING=$(battery_info)

    BATT_LINE="\n<span color='$C_GREEN' weight='bold'>󰁹</span> $BATTERY_STRING"

    if [[ -n "$TIME_LEFT_STRING" ]]; then
        local_icon=""
        [[ $BATTERY_STATE == "discharging" ]] && local_icon=" "
        BATT_LINE="$BATT_LINE    $SEP <span color='$C_GRAY'>${local_icon}$TIME_LEFT_STRING</span>"
    fi

    GENERAL_STRING="${GENERAL_STRING}${BATT_LINE}"
fi

####### TIEMPO
if [[ -n "$WEATHER_DATA" ]]; then
    GENERAL_STRING="${GENERAL_STRING}\n<span color='$C_SKY' weight='bold'></span> $WEATHER_DATA"
fi

####### TECLADO
if [[ -n "$KEYBOARD_LNG" ]]; then
    GENERAL_STRING="${GENERAL_STRING}\n<span color='$C_YELLOW' weight='bold'>󰌌</span> $KEYBOARD_LNG"
fi

####### INTERNET
if [[ -n "$NET_INFO" ]]; then
    NET_TYPE=$(echo "$NET_INFO" | cut -d'|' -f1)
    NET_NAME=$(echo "$NET_INFO" | cut -d'|' -f2)
    ICON="󰖩"
    [[ "$NET_TYPE" == "ETH" ]] && ICON="󰈀"
    GENERAL_STRING="${GENERAL_STRING}\n<span color='$C_MAUVE' weight='bold'>$ICON</span> $NET_NAME"
fi

####### BLUETOOTH
if [[ -n "$BT_DATA" ]]; then
    GENERAL_STRING="${GENERAL_STRING}\n<span color='$C_MAUVE' weight='bold'></span> $BT_DATA"
fi

####### CPU
if [[ -n "$CPU_USAGE" ]]; then
    GENERAL_STRING="${GENERAL_STRING}\n<span color='$C_GREEN' weight='bold'>󰻠</span> $CPU_USAGE"
fi

####### RAM
if [[ -n "$RAM_USAGE" ]]; then
    GENERAL_STRING="${GENERAL_STRING}\n<span color='$C_YELLOW' weight='bold'>󰍛</span> $RAM_USAGE"
fi

####### DISCO
if [[ -n "$DISK_USAGE" ]]; then
    GENERAL_STRING="${GENERAL_STRING}\n<span color='$C_SKY' weight='bold'>󰋊</span>  / $DISK_USAGE"
fi

if [[ -n "$DISK_HOME_USAGE" ]]; then
    GENERAL_STRING="${GENERAL_STRING}\n<span color='$C_SKY' weight='bold'>󰋊</span>  ~ $DISK_HOME_USAGE"
fi

GENERAL_STRING="<span font_family='monospace'>$GENERAL_STRING</span>"

CUTE_STRINGS=(
    "           <(￣︶￣)>         "
    "         °˖✧◝(⁰▿⁰)◜✧˖°        "
    "      °˖✧◝(￣︶￣)◜✧˖°     "
    "           (つ✧ω✧)つ          "
    "          (つ°ヮ°)つ          "
    "            (^◔ᴥ◔^)           "
    'ヾ(・ω・`)ノヾ(´・ω・)ノ'
)
CUTE_STRING=${CUTE_STRINGS[$((RANDOM % ${#CUTE_STRINGS[@]}))]}

case "${1:-notify}" in
"rofi") echo -e "$GENERAL_STRING" ;;
*) notify-send "$CUTE_STRING" "$GENERAL_STRING" -t 3000 -r 999 ;;
esac
