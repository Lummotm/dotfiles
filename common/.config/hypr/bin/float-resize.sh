#!/usr/bin/env bash
set -euo pipefail

hyprctl dispatch togglefloating
hyprctl dispatch resizeactive exact 1200 700
hyprctl dispatch centerwindow
