#!/usr/bin/env bash
source "$HOME/bin/pickers/dependencies/core.sh"

rofi_cmd() {
    rofi_core -w "25%" "$@"
}
get_volume_icon() {
    local VOLUME=$1
    local DEVICE=$2
    if [[ $DEVICE == "sink" ]]; then
        if ((VOLUME == 0)); then
            echo " "
        elif ((VOLUME <= 40)); then
            echo " "
        elif ((VOLUME > 40)); then
            echo " "
        fi
    else
        if ((VOLUME == 0)); then
            echo "󰍭"
        else
            echo "󰍬"
        fi
    fi
}

send_volume_notification() {
    local VOLUME=$1
    local DEVICE=$2
    local ICON
    ICON=$(get_volume_icon "$VOLUME" "$DEVICE")
    notify-send "$ICON  $VOLUME%" -t 2000
}

send_device_change_notification() {
    local TYPE=$1
    local NAME=$2

    local ICON
    if [ "$TYPE" = "Output" ]; then
        ICON="󰓃"
    else
        ICON=""
    fi

    notify-send "$ICON  $NAME" -t 2000
}

extract_descriptions() {
    awk -F': ' '/Description:/ {print $2}'
}

extract_id_by_description() {
    awk -v desc="$1" -F': ' '
        /Name:/ {
            name = $2
        }
        /Description:/ {
            if ($2 == desc) {
                print name
                exit
            }
        }'
}

extract_description_by_id() {
    awk -v name="$1" -F': ' '
        /Name:/ {
            current_name = $2
        }
        /Description:/ && current_name == name {
            print $2
            exit
        }'
}

extract_volume_percentage() {
    awk -F'/' '{print $2}' | tr -d ' %' | head -n 1
}

list_all_devices() {
    local TYPE=$1
    if [[ "$TYPE" == "sources" ]]; then
        pactl list "$TYPE" | extract_descriptions | grep -v "Monitor of"
    else
        pactl list "$TYPE" | extract_descriptions
    fi
}

get_device_id_by_description() {
    pactl list "$1" | extract_id_by_description "$2"
}

get_device_description_by_id() {
    pactl list "$1" | extract_description_by_id "$2"
}

get_default_device_id() {
    case "$1" in
    sinks) pactl get-default-sink ;;
    sources) pactl get-default-source ;;
    esac
}

get_default_device_volume() {
    case "$1" in
    sinks) pactl get-sink-volume "$(pactl get-default-sink)" | extract_volume_percentage ;;
    sources) pactl get-source-volume "$(pactl get-default-source)" | extract_volume_percentage ;;
    esac
}

get_default_device_description() {
    local DEVICE_ID
    DEVICE_ID=$(get_default_device_id "$1")
    get_device_description_by_id "$1" "$DEVICE_ID"
}

change_audio_device() {
    local TYPE=$1
    local PROMPT=$2
    local PACTL_COMMAND=$3
    local SELECTED_DESC
    local DEVICE_ID

    SELECTED_DESC=$(list_all_devices "$TYPE" | rofi_cmd -p "$PROMPT")

    if [ -n "$SELECTED_DESC" ]; then
        DEVICE_ID=$(get_device_id_by_description "$TYPE" "$SELECTED_DESC")
        [ -n "$DEVICE_ID" ] && pactl "$PACTL_COMMAND" "$DEVICE_ID"

        echo "$SELECTED_DESC"
    fi
}

adjust_device_volume() {
    local PROMPT=$1
    local DEVICE_TYPE=$2

    local VOL_OPTIONS
    VOL_OPTIONS=$(printf "%s\n" {0..100..10})

    local NEW_VOLUME
    NEW_VOLUME=$(echo "$VOL_OPTIONS" | rofi_cmd -p "$PROMPT")

    if [ -n "$NEW_VOLUME" ]; then
        NEW_VOLUME=$(echo "$NEW_VOLUME" | tr -d '%')

        pactl set-"$DEVICE_TYPE"-volume "@DEFAULT_${DEVICE_TYPE^^}@" "${NEW_VOLUME}%"

        local CURRENT_VOLUME
        CURRENT_VOLUME=$(get_default_device_volume "${DEVICE_TYPE}s")
        send_volume_notification "$CURRENT_VOLUME" "$DEVICE_TYPE"
    fi
}

list_sink_inputs() {
    pactl list sink-inputs | awk '
        /Sink Input #/ {id=$3}
        /application.name =/ {
            gsub(/"/, "", $3); 
            print id ": " $3
        }'
}

adjust_app_volume() {
    local APP_ID=$1
    local APP_NAME=$2

    local VOL_OPTIONS
    VOL_OPTIONS=$(printf "%s\n" {0..100..10})

    local NEW_VOL
    NEW_VOL=$(echo "$VOL_OPTIONS" | rofi_cmd -p "Volumen para $APP_NAME:")

    if [ -n "$NEW_VOL" ]; then
        NEW_VOL=$(echo "$NEW_VOL" | tr -d '%')
        pactl set-sink-input-volume "$APP_ID" "${NEW_VOL}%"
        notify-send "Audio" "$APP_NAME ajustado al $NEW_VOL%" -t 1500
    fi
}

menu() {
    local OUTPUT_DESC
    local INPUT_DESC
    local OUTPUT_VOL
    local INPUT_VOL
    local MENU_TEXT
    local CHOICE
    local CURRENT_VOLUME

    OUTPUT_DESC=$(get_default_device_description sinks)
    INPUT_DESC=$(get_default_device_description sources)
    OUTPUT_VOL=$(get_default_device_volume sinks)
    INPUT_VOL=$(get_default_device_volume sources)

    MENU_TEXT=$(printf "Output device:\t %s\nInput device:\t %s\nOutput Volume:\t %s%%\nInput Volume:\t %s%%\nApps:\t\t Gestionar volumen de apps" \
        "$OUTPUT_DESC" "$INPUT_DESC" "$OUTPUT_VOL" "$INPUT_VOL")

    CHOICE=$(echo "$MENU_TEXT" | rofi_cmd -mesg "Audio Manager" -N -c 'textbox{horizontal-align: 0.5; padding: 5px;}')

    local SELECTED_DEVICE_NAME

    case "$CHOICE" in
    "Output device:"*)
        pactl set-sink-mute @DEFAULT_SINK@ false
        SELECTED_DEVICE_NAME=$(change_audio_device sinks "Select Output:" set-default-sink)

        if [ -n "$SELECTED_DEVICE_NAME" ]; then
            send_device_change_notification "Output" "$SELECTED_DEVICE_NAME"
            CURRENT_VOLUME=$(get_default_device_volume sinks)
            send_volume_notification "$CURRENT_VOLUME" sink
        fi
        ;;
    "Input device:"*)
        pactl set-source-mute @DEFAULT_SOURCE@ false
        SELECTED_DEVICE_NAME=$(change_audio_device sources "Select Input:" set-default-source)

        if [ -n "$SELECTED_DEVICE_NAME" ]; then
            send_device_change_notification "Input" "$SELECTED_DEVICE_NAME"
        fi
        ;;
    "Output Volume:"*)
        pactl set-sink-mute @DEFAULT_SINK@ false
        adjust_device_volume "Type wanted output volume:" sink
        ;;
    "Input Volume:"*)
        pactl set-source-mute @DEFAULT_SOURCE@ false
        adjust_device_volume "Type wanted input volume:" source
        ;;
    "Apps:"*)
        local APP_SELECTION
        APP_SELECTION=$(list_sink_inputs | rofi_cmd -p "Seleccionar Aplicación:")

        if [ -n "$APP_SELECTION" ]; then
            local SELECTED_APP_ID=$(echo "$APP_SELECTION" | cut -d':' -f1 | tr -d ' #')
            local SELECTED_APP_NAME=$(echo "$APP_SELECTION" | cut -d':' -f2- | sed 's/^ //')

            adjust_app_volume "$SELECTED_APP_ID" "$SELECTED_APP_NAME"
        fi
        ;;
    esac
}

menu
