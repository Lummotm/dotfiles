#!/usr/bin/env bash
pkill -f "kitty.*rmpc"
rmpc update
kitty --title "rmpc" rmpc
