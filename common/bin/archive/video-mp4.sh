#!/usr/bin/env bash

file="$1"
filename=$(basename "$file")
filename="${filename%.*}"
dir=$(dirname "$file")
output="$dir/$filename.mp4"

ffmpeg -i "$file" -c:v copy -c:a aac -b:a 192k "$output"
