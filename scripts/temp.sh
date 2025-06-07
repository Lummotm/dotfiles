#! /bin/bash

if pgrep -f "waybar" >/dev/null; then
    echo "Running"
else
    echo "Stopped"
fi
