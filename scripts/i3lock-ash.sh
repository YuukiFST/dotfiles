#!/usr/bin/env bash
# Lock screen visível no tema Ash.

xset dpms force on 2>/dev/null || true
xset s reset 2>/dev/null || true

exec i3lock-color --nofork \
  -c 121212 \
  -e \
  --indicator \
  --ring-color=626262 \
  --keyhl-color=e0e0e0 \
  --line-color=626262 \
  --inside-color=121212 \
  --insidever-color=383838 \
  --insidewrong-color=383838 \
  --ringver-color=626262 \
  --ringwrong-color=9e9e9e \
  --verif-color=e0e0e0 \
  --wrong-color=9e9e9e \
  --separator-color=e0e0e0 \
  --time-color=8a8a8a \
  --date-color=8a8a8a \
  --layout-color=e0e0e0 \
  --pass-media-keys \
  --pass-screen-keys \
  --pass-volume-keys
