#!/usr/bin/env bash
# Define 165 Hz no monitor principal conectado (DisplayPort).
set -euo pipefail

mode="1920x1080"
rate="165"

output=$(xrandr --query | awk '/ connected/{print $1; exit}')
if [ -z "${output:-}" ]; then
  exit 0
fi

if xrandr --query | awk -v out="$output" -v m="$mode" '
  $0 ~ "^" out " connected" { found=1 }
  found && $1 == m { print; exit }
' | grep -q "$rate"; then
  xrandr --output "$output" --mode "$mode" --rate "$rate" --primary
fi
