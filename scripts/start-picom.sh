#!/usr/bin/env bash
# Garante que o picom (blur/transparência) está ativo no i3.
set -euo pipefail

config="${XDG_CONFIG_HOME:-$HOME/.config}/picom/picom.conf"
[[ -f "$config" ]] || exit 0

if pgrep -x picom >/dev/null; then
  pkill -x picom
  sleep 0.15
fi

picom -b --config "$config"
