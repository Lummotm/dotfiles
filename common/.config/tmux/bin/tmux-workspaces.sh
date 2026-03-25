#!/usr/bin/env bash
case "$1" in
open)
    # When creating a new workspace we try to insert in 1 to 9
    for n in $(seq 1 9); do
        tmux has-session -t "$n" 2>/dev/null || {
            tmux new-session -d -s "$n" -c "#{pane_current_path}"
            tmux switch-client -t "$n"
            exit 0
        }
    done
    # If full from 1-9 then its full (not viable to work on)
    tmux display-message " Workspaces full"
    ;;
close)
    # If there is at least one session can delete it
    # Check if the number of sessions listed greater than one
    if [ $(tmux list-sessions | wc -l) -gt 1 ]; then
        tmux switch-client -n
        tmux kill-session -t "#{session_name}"
        exit 0
    else
        tmux display-message " Last workspace"
    fi
    ;;
esac
