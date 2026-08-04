#!/usr/bin/env bash
source "$HOME/bin/pickers/dependencies/core.sh"

cliphist list | rofi_core | cliphist decode | wl-copy
