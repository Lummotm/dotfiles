#!/usr/bin/env bash

until pactl info &>/dev/null; do
    sleep 0.5
done

# Altavoz laptop
SPEAKER="alsa_output.pci-0000_04_00.6.analog-stereo"

pactl set-sink-mute "$SPEAKER" true

pactl set-sink-volume "$SPEAKER" 0%

notify-send "Altavoces Internos" "Silenciados y volumen a 0%" -i audio-volume-muted -t 2000
