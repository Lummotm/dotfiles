#!/usr/bin/env bash
set -euo pipefail

filename="cap-$(date '+%Y-%m-%d_%H-%M-%S').png"
output_dir=~/Pictures/Screenshots/
mkdir -p "$output_dir"

hyprshot -m output -m active --output "$output_dir" --filename "$filename"
