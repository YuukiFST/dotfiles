#!/usr/bin/env bash
# Super+K — lista de atalhos
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
HOTKEYS_FILE="$DOTFILES/i3/.config/i3/hotkeys.txt"

if [[ ! -f "$HOTKEYS_FILE" ]]; then
  notify-send "Hotkeys" "Arquivo não encontrado: $HOTKEYS_FILE" 2>/dev/null || true
  exit 1
fi

rofi -dmenu -i -p "Hotkeys" <"$HOTKEYS_FILE"
