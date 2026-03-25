#!/usr/bin/env bash

AC_ADAPTER_STATE=$(cat /sys/class/power_supply/{AC*,ADP*}/online 2>/dev/null | head -n 1)

if [ -z "$AC_ADAPTER_STATE" ]; then
    AC_ADAPTER_STATE="0"
fi

if [ "$AC_ADAPTER_STATE" = "0" ]; then
    echo "AC adapter is unplugged. Turning off the NVIDIA GPU to save power."
    sudo gpu-toggle off
else
    echo "AC adapter is plugged. Turning on the NVIDIA GPU."
    sudo gpu-toggle on
fi
