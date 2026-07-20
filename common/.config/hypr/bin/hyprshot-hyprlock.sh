#!/usr/bin/env bash
set -euo pipefail

hyprlock &
sleep 1
/home/davidn/bin/ui/screenshot-full.sh
