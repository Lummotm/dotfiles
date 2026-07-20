#!/usr/bin/env bash
set -euo pipefail

filename="cap-$(date '+%Y-%m-%d_%H-%M-%S').png"
output_dir=~/Pictures/Screenshots/
mkdir -p "$output_dir"

hyprshot -m region --output "$output_dir" --filename "$filename" --freeze
