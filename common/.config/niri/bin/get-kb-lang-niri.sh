#!/usr/bin/env bash

niri_socket=(/run/user/1000/niri*)
if ! [[ -e "${niri_socket[0]}" ]]; then
    echo ""
    exit 0
fi

niri msg --json event-stream &>/tmp/event-stream &
pkill $!

data=$(cat /tmp/event-stream)
json_name=".KeyboardLayoutsChanged.keyboard_layouts.names"
mapfile -t arr < <(echo "$data" | jq -r "$json_name" | grep -v "null")

json_idx=".KeyboardLayoutsChanged.keyboard_layouts.current_idx"
current_idx=$(echo $data | jq -r "$json_idx" | grep -v "null")
current_idx=$((current_idx + 1))

if [ -n "$current_idx" ]; then
    current=${arr[$current_idx]}
    current=$(echo "$current" | cut -d"," -f1 | tr -d '"' | xargs)
fi

case "$1" in
*"waybar"*)
    case "$current" in
    *"Spanish"*)
        echo "ES"
        ;;
    *"US"*)
        echo "US"
        ;;
    *) ;;
    esac
    ;;
*)
    echo "${current}"
    ;;
esac
