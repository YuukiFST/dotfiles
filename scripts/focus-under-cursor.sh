#!/usr/bin/env bash
# Foca a janela i3 sob o cursor do mouse (comportamento Omarchy/Hyprland follow_mouse).
set -euo pipefail

eval "$(xdotool getmouselocation --shell)"
mx=$X
my=$Y

mapfile -t windows < <(xdotool search --onlyvisible "" 2>/dev/null | tac)
for wid in "${windows[@]}"; do
  geo=$(xdotool getwindowgeometry --shell "$wid" 2>/dev/null) || continue
  wx= wy= ww= wh=
  while IFS= read -r line; do
    case "$line" in
      X=*) wx=${line#X=} ;;
      Y=*) wy=${line#Y=} ;;
      WIDTH=*) ww=${line#WIDTH=} ;;
      HEIGHT=*) wh=${line#HEIGHT=} ;;
    esac
  done <<<"$geo"

  [[ -n "$wx" && -n "$wy" && -n "$ww" && -n "$wh" ]] || continue

  if (( mx >= wx && mx < wx + ww && my >= wy && my < wy + wh )); then
    i3-msg "[id=$wid] focus" >/dev/null
    exit 0
  fi
done
