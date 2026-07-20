#!/usr/bin/env bash

ORIGINAL="#[fg=colour4]#{?pane_in_mode,COPY ,}#{?client_prefix,PREFIX ,}#{?window_zoomed_flag,ZOOM ,}#[fg=colour8]#h "

case "$1" in
on)
    tmux switch-client -T resize_mode
    tmux set-option -g status-right "#[fg=colour4,bold]SIZE #[fg=colour8]#h "
    tmux refresh-client -S
    ;;
off)
    tmux set-option -g status-right "$ORIGINAL"
    tmux refresh-client -S
    ;;
esac
