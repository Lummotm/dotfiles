#!/usr/bin/env bash

ROFI_THEME="$HOME/.config/rofi/default.rasi"

rofi_core() {
    local width="60ch"
    local prompt=""
    local show_icons="false"
    local mode="dmenu"
    local extra_css=""
    local hide_inputbar="false"
    local rofi_args=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -w | --width)
            width="$2"
            shift 2
            ;;
        -p | --prompt)
            prompt="$2"
            shift 2
            ;;
        -i | --icons)
            show_icons="true"
            shift 1
            ;;
        -m | --mode)
            mode="$2"
            shift 2
            ;;
        -c | --css)
            extra_css="$2"
            shift 2
            ;;
        -N | --no-input)
            hide_inputbar="true"
            shift 1
            ;;
        --)
            shift
            rofi_args+=("$@")
            break
            ;;
        *)
            rofi_args+=("$1")
            shift 1
            ;;
        esac
    done

    local theme_str="window { width: $width; }"

    if [[ "$hide_inputbar" == "true" ]]; then
        theme_str+=" inputbar { enabled: false; }"
    elif [[ -n "$prompt" ]]; then
        theme_str+=" prompt { enabled: true; } textbox-prompt-colon { enabled: true;  } entry { cursor-width: 1px; }"
    fi

    if [[ "$show_icons" == "true" ]]; then
        theme_str+=" configuration { show-icons: true; } element-icon { enabled: true; margin: 0 10px 0 0; }"
    fi

    if [[ -n "$extra_css" ]]; then
        theme_str+=" $extra_css"
    fi

    local cmd=(rofi -theme "$ROFI_THEME" -theme-str "$theme_str" -i)

    if [[ "$mode" == "dmenu" ]]; then
        cmd+=(-dmenu)
    else
        cmd+=(-show "$mode")
    fi

    if [[ -n "$prompt" ]]; then
        cmd+=(-p "$prompt")
    fi

    "${cmd[@]}" "${rofi_args[@]}"
}
