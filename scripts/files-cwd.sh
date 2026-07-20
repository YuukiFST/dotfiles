#!/usr/bin/env bash
# Omarchy: Super+Shift+Alt+F — file manager in terminal cwd
set -euo pipefail

cwd="${PWD}"
if [ -n "${STY:-}" ] || [ -n "${TMUX:-}" ]; then
  :
fi

# herdr/ghostty: use focused terminal cwd if available via proc
pid=$(xdotool getwindowfocus getwindowpid 2>/dev/null || true)
if [ -n "${pid:-}" ]; then
  term_cwd=$(readlink -f "/proc/$pid/cwd" 2>/dev/null || true)
  if [ -n "${term_cwd:-}" ] && [ -d "$term_cwd" ]; then
    cwd="$term_cwd"
  fi
fi

nautilus "$cwd" &
