#!/usr/bin/env bash

AC_ADAPTER_STATE=$(cat /sys/class/power_supply/AC0/online)

if [ "$AC_ADAPTER_STATE" = "0" ]; then
    bash /home/davidn/scripts/power/gpu-toggle.sh off
    exit 0
else
    exit 0
fi
