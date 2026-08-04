#!/usr/bin/env bash

DEPENDENCY="$1"
if [[ -z "$DEPENDENCY" ]]; then
    noitfy-send "Can't check empty string"
    exit 0
fi

INNER_CMD="echo '------------------------------------------' \
           echo 'Instalando $DEPENDENCY' \
           echo '------------------------------------------' \
           yay -S $DEPENDENCY"

setsid kitty --title="dep-install" -e bash -c "$INNER_CMD" >/dev/null 2>&1 </dev/null &
