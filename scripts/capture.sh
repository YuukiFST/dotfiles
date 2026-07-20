#!/usr/bin/env bash
# Omarchy: Super+Ctrl+C — capture menu
set -euo pipefail

choice=$(printf '%s\n' \
  "Screenshot (region)" \
  "Screenshot (full screen)" \
  "Screenshot (window)" \
  "Cancel" | rofi -dmenu -i -p "Capture")

case "${choice:-Cancel}" in
  "Screenshot (region)") flameshot gui ;;
  "Screenshot (full screen)") flameshot screen -p -c ;;
  "Screenshot (window)") flameshot gui ;;
  *) ;;
esac
