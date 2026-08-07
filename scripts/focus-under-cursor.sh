#!/usr/bin/env bash
# Foca a janela i3 sob o cursor do mouse (comportamento Omarchy/Hyprland follow_mouse).
set -euo pipefail

focus_i3_window() {
  local wid=$1
  [[ -n "$wid" && "$wid" != "0" ]] || return 1
  i3-msg "[id=$wid] focus" >/dev/null 2>&1
}

eval "$(xdotool getmouselocation --shell)"
mx=$X
my=$Y

# WINDOW do getmouselocation é o client que o i3 conhece (não widget filho).
focus_i3_window "$WINDOW" && exit 0

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
    focus_i3_window "$wid" && exit 0
  fi
done
