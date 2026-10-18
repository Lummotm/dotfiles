#!/usr/bin/env bash
rmpc rescan
rmpc update
talis --start-minimized &
kitty --title "rmpc" rmpc
