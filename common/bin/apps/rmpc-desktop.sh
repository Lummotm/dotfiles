#!/usr/bin/env bash
pkill -f "kitty.*rmpc"
rmpc rescan
rmpc update
kitty --title "rmpc" rmpc
