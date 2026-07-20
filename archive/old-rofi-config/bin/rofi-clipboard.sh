#!/usr/bin/env bash
source "$HOME/.config/rofi/bin/dependencies/rofi-core.sh"

cliphist list | rofi_core | cliphist decode | wl-copy
