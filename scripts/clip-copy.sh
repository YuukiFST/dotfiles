#!/usr/bin/env bash
set -euo pipefail
class=$(xdotool getactivewindow getwindowclassname 2>/dev/null || echo "")
if [[ "$class" =~ [Gg]hostty|[Kk]itty|[Tt]mux|kitty|Alacritty|org.wezfurlong.wezterm ]]; then
  xdotool key --clearmodifiers ctrl+shift+c
elif [[ "$class" == Emacs ]]; then
  # Doom/Evil: copia região ativa (M-w), não Ctrl+C.
  xdotool key --clearmodifiers alt+w
else
  xdotool key --clearmodifiers ctrl+c
fi
