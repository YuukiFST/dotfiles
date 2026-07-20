#!/usr/bin/env bash
# Define wallpaper e força o compositor a redesenhar o root.
set -euo pipefail

WALLPAPER="${1:?usage: set-wallpaper.sh <image>}"
DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"

export DISPLAY="${DISPLAY:-:0}"

if ! command -v feh >/dev/null 2>&1; then
  echo "set-wallpaper: feh não encontrado" >&2
  exit 1
fi

if [[ ! -f "$WALLPAPER" ]]; then
  echo "set-wallpaper: arquivo não existe: $WALLPAPER" >&2
  exit 1
fi

feh --bg-fill "$WALLPAPER"

if [[ -x "$DOTFILES/scripts/start-picom.sh" ]]; then
  "$DOTFILES/scripts/start-picom.sh" >/dev/null 2>&1 || true
fi
