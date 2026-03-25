#!/usr/bin/env bash

case "$1" in
on)
    tmux switch-client -T resize_mode
    tmux set-option @mode_indicator_custom_prompt "SIZE"
    tmux set-option @mode_indicator_custom_mode_style "bg=default,fg=#f6c177"
    tmux refresh-client -S
    ;;
off)
    tmux set-option -u @mode_indicator_custom_prompt
    tmux set-option -u @mode_indicator_custom_mode_style
    tmux refresh-client -S
    ;;
esac
