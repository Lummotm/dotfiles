#!/usr/bin/env bash

# Limitar carga de batería
echo 80 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold >/dev/null
