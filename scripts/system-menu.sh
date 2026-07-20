#!/usr/bin/env bash
# Omarchy: Super+Alt+Space / Super+Escape — system menu
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"

choice=$(printf '%s\n' \
  "Lock" \
  "Suspend" \
  "Reboot" \
  "Shutdown" \
  "Logout" \
  "Cancel" | rofi -dmenu -i -p "System")

case "${choice:-Cancel}" in
  Lock) "$DOTFILES/scripts/i3lock-ash.sh" ;;
  Suspend) systemctl suspend ;;
  Reboot) systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
  Logout) i3-msg exit ;;
  *) ;;
esac
