#!/usr/bin/env bash
set -euo pipefail
class=$(xdotool getactivewindow getwindowclassname 2>/dev/null || echo "")
if [[ "$class" =~ [Gg]hostty|[Kk]itty|[Tt]mux|kitty|Alacritty|org.wezfurlong.wezterm ]]; then
  xdotool key ctrl+shift+x
else
  xdotool key ctrl+x
fi
