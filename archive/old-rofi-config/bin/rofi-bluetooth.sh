#!/usr/bin/env bash
#             __ _       _     _            _              _   _
#  _ __ ___  / _(_)     | |__ | |_   _  ___| |_ ___   ___ | |_| |__
# | '__/ _ \| |_| |_____| '_ \| | | | |/ _ \ __/ _ \ / _ \| __| '_ \
# | | | (_) |  _| |_____| |_) | | |_| |  __/ || (_) | (_) | |_| | | |
# |_|  \___/|_| |_|     |_.__/|_|\__,_|\___|\__\___/ \___/ \__|_| |_|
#
# Author: Nick Clyde (clydedroid)
#
# A script that generates a rofi menu that uses bluetoothctl to
# connect to bluetooth devices and display status info.
#
# Inspired by networkmanager-dmenu (https://github.com/firecat53/networkmanager-dmenu)
# Thanks to x70b1 (https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts/system-bluetooth-bluetoothctl)
#
# Depends on:
#   Arch repositories: rofi, bluez-utils (contains bluetoothctl), bc

source "$HOME/.config/rofi/bin/dependencies/rofi-core.sh"

divider="---------"
goback="Back"

rofi_cmd() {
    rofi_core -w "22ch" -mesg "Select an option:" -N -c 'textbox{padding: 5px;}'
}

bluetoothctl_workaround() {
    echo -e "$1\nquit" | bluetoothctl
}

power_on() {
    if bluetoothctl_workaround show | grep -q "Powered: yes"; then
        return 0
    else
        return 1
    fi
}

toggle_power() {
    if power_on; then
        bluetoothctl power off
        notify-send " Bluetooth" "Bluetooth apagado"
        show_menu
    else
        if rfkill list bluetooth | grep -q 'blocked: yes'; then
            rfkill unblock bluetooth && sleep 3
        fi
        bluetoothctl power on
        notify-send " Bluetooth" "Bluetooth encendido"
        show_menu
    fi
}

scan_on() {
    if bluetoothctl_workaround show | grep -q "Discovering: yes"; then
        echo "Scan: on"
        return 0
    else
        echo "Scan: off"
        return 1
    fi
}

toggle_scan() {
    if scan_on; then
        kill $(pgrep -f "bluetoothctl --timeout 5 scan on")
        bluetoothctl scan off
        show_menu
    else
        echo -e "'scan on'" | bluetoothctl
        echo "Scanning..."
        show_menu
    fi
}

pairable_on() {
    if bluetoothctl_workaround show | grep -q "Pairable: yes"; then
        echo "Pairable: on"
        return 0
    else
        echo "Pairable: off"
        return 1
    fi
}

toggle_pairable() {
    if pairable_on; then
        bluetoothctl pairable off
        show_menu
    else
        bluetoothctl pairable on
        show_menu
    fi
}

discoverable_on() {
    if bluetoothctl_workaround show | grep -q "Discoverable: yes"; then
        echo "Discoverable: on"
        return 0
    else
        echo "Discoverable: off"
        return 1
    fi
}

toggle_discoverable() {
    if discoverable_on; then
        bluetoothctl discoverable off
        show_menu
    else
        bluetoothctl discoverable on
        show_menu
    fi
}

device_connected() {
    device_info=$(bluetoothctl info "$1")
    if echo "$device_info" | grep -q "Connected: yes"; then
        return 0
    else
        return 1
    fi
}

toggle_connection() {
    if device_connected "$1"; then
        bluetoothctl disconnect "$1"
        notify-send " Bluetooth" "Desconectado de $(bluetoothctl info "$1" | grep "Alias" | cut -d ' ' -f 2-)"
    else
        bluetoothctl connect "$1"
        if device_connected "$1"; then
            notify-send " Bluetooth" "Conectado a $(bluetoothctl info "$1" | grep "Alias" | cut -d ' ' -f 2-)"
        else
            notify-send " Bluetooth" "Error al conectar"
            date=$(date "+%s")
            mkdir -p "$HOME/logs"
            journalctl --unit=bluetooth -n 50 >"logs/blueototh_error_$date.log"
        fi
    fi
    device_menu "$device"
}

device_paired() {
    device_info=$(bluetoothctl info "$1")
    if echo "$device_info" | grep -q "Paired: yes"; then
        echo "Paired: yes"
        return 0
    else
        echo "Paired: no"
        return 1
    fi
}

toggle_paired() {
    if device_paired "$1"; then
        bluetoothctl remove "$1"
        device_menu "$device"
    else
        bluetoothctl pair "$1"
        device_menu "$device"
    fi
}

device_trusted() {
    device_info=$(bluetoothctl info "$1")
    if echo "$device_info" | grep -q "Trusted: yes"; then
        echo "Trusted: yes"
        return 0
    else
        echo "Trusted: no"
        return 1
    fi
}

toggle_trust() {
    if device_trusted "$1"; then
        bluetoothctl untrust "$1"
        device_menu "$device"
    else
        bluetoothctl trust "$1"
        device_menu "$device"
    fi
}

print_status() {
    if power_on; then
        printf ''

        paired_devices_cmd="devices Paired"
        if (($(echo "$(bluetoothctl version | cut -d ' ' -f 2) < 5.65" | bc -l))); then
            paired_devices_cmd="paired-devices"
        fi

        mapfile -t paired_devices < <(bluetoothctl $paired_devices_cmd | grep Device | cut -d ' ' -f 2)
        counter=0

        for device in "${paired_devices[@]}"; do
            if device_connected "$device"; then
                device_alias=$(bluetoothctl info "$device" | grep "Alias" | cut -d ' ' -f 2-)

                if [ $counter -gt 0 ]; then
                    printf ", %s" "$device_alias"
                else
                    printf " %s" "$device_alias"
                fi

                ((counter++))
            fi
        done
        printf "\n"
    else
        echo ""
    fi
}

device_menu() {
    device=$1

    device_name=$(echo "$device" | cut -d ' ' -f 3-)
    mac=$(echo "$device" | cut -d ' ' -f 2)

    if device_connected "$mac"; then
        connected="Connected: yes"
    else
        connected="Connected: no"
    fi
    paired=$(device_paired "$mac")
    trusted=$(device_trusted "$mac")
    options="$connected\n$paired\n$trusted\n$divider\n$goback\nExit"

    chosen="$(echo -e "$options" | rofi_cmd "$device_name")"

    case "$chosen" in
    "" | "$divider")
        echo "No option chosen."
        ;;
    "$connected")
        toggle_connection "$mac"
        ;;
    "$paired")
        toggle_paired "$mac"
        ;;
    "$trusted")
        toggle_trust "$mac"
        ;;
    "$goback")
        show_menu
        ;;
    esac
}

show_menu() {
    if power_on; then
        power="Power: on"

        devices=$(bluetoothctl_workaround devices | grep Device | cut -d ' ' -f 3-)

        scan=$(scan_on)
        pairable=$(pairable_on)
        discoverable=$(discoverable_on)

        options="$devices\n$divider\n$power\n$scan\n$pairable\n$discoverable\nExit"
    else
        power="Power: off"
        options="$power\nExit"
    fi

    chosen="$(echo -e "$options" | rofi_cmd)"

    case "$chosen" in
    "" | "$divider")
        echo "No option chosen."
        ;;
    "$power")
        toggle_power
        ;;
    "$scan")
        toggle_scan
        ;;
    "$discoverable")
        toggle_discoverable
        ;;
    "$pairable")
        toggle_pairable
        ;;
    *)
        device=$(bluetoothctl devices | grep "$chosen")
        if [[ $device ]]; then device_menu "$device"; fi
        ;;
    esac
}

case "$1" in
--status)
    print_status
    ;;
*)
    show_menu
    ;;
esac
