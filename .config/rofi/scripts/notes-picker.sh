#!/usr/bin/env bash

notepath="$HOME/Documents/Obsidian/"

if [ -z "$ROFI_RETV" ] || [ "$ROFI_RETV" -eq 0 ]; then
    {
        echo " Nueva nota"
        fd -e md . "$notepath" -p | while read -r path; do
            basename "$path"
        done
    }
    exit 0
fi

# Acción: recuperar la ruta completa

selected="$1"
[ -z "$selected" ] && exit 1

if [ "$selected" = "Nueva nota" ]; then
    targetdir="$HOME/Documents/Obsidian/001 - inbox/"
    name="$(date +%F_%T | tr -d ':').md"
    fullpath="$targetdir/$name"
    setsid foot nvim "$fullpath" >/dev/null 2>&1 </dev/null &
    exit 0
else
    fullpath=$(fd -e md . "$notepath" -p | grep "/$selected$")
    setsid foot nvim "$fullpath" >/dev/null 2>&1 </dev/null &
fi
