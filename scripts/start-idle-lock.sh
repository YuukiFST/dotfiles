#!/usr/bin/env bash
# Inicia bloqueio automático (10 min) e trava antes de suspend.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
LOCKER="$DOTFILES/scripts/i3lock-ash.sh"

# DPMS off: monitor stays on. Screensaver on+noblank: xautolock needs the
# MIT-SCREEN-SAVER idle timer; "xset s off" breaks idle detection.
xset -dpms 2>/dev/null || true
xset s on 2>/dev/null || true
xset s noblank 2>/dev/null || true

if ! command -v xautolock >/dev/null 2>&1; then
  notify-send "Idle lock" "Instale xautolock: nixos-rebuild switch" 2>/dev/null || true
  exit 1
fi

if ! pgrep -x xautolock >/dev/null 2>&1; then
  xautolock -time 10 -locker "$LOCKER" -detectsleep -notify 0 &
fi

if ! pgrep -f 'xss-lock.*i3lock-ash' >/dev/null 2>&1; then
  xss-lock --ignore-sleep --transfer-sleep-lock -- "$LOCKER" &
fi
