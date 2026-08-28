#!/usr/bin/env bash
# Small rofi "card" under the polybar click (not the centered launcher).
# shellcheck shell=bash

polybar_rofi_card() {
  local lines="${1:-8}"
  local x=24
  local y=32
  local w=380
  local mouse

  shift || true

  if mouse=$(xdotool getmouselocation --shell 2>/dev/null); then
    # shellcheck disable=SC2086
    eval "$mouse"
    x="${X:-24}"
  fi

  rofi -dmenu -i \
    -hover-select \
    -me-select-entry '' \
    -me-accept-entry MousePrimary \
    -theme-str "window { location: northwest; anchor: northeast; x-offset: ${x}px; y-offset: ${y}px; width: ${w}px; }" \
    -theme-str "inputbar { enabled: false; }" \
    -theme-str "mainbox { children: [ \"listview\" ]; spacing: 0px; padding: 6px; }" \
    -theme-str "listview { lines: ${lines}; fixed-height: false; }" \
    -kb-move-char-forward "" \
    -kb-move-char-back "" \
    -kb-cancel "Escape,Control+g,Control+bracketleft,Left" \
    -kb-accept-entry "Right,Control+j,Control+m,Return,KP_Enter" \
    "$@"
}

polybar_rofi_card_mesg() {
  local lines="${1:-4}"
  local x=24
  local y=32
  local w=420
  local mouse

  shift || true

  if mouse=$(xdotool getmouselocation --shell 2>/dev/null); then
    # shellcheck disable=SC2086
    eval "$mouse"
    x="${X:-24}"
  fi

  rofi -dmenu -i \
    -hover-select \
    -me-select-entry '' \
    -me-accept-entry MousePrimary \
    -theme-str "window { location: northwest; anchor: northeast; x-offset: ${x}px; y-offset: ${y}px; width: ${w}px; }" \
    -theme-str "inputbar { enabled: false; }" \
    -theme-str "mainbox { children: [ \"message\", \"listview\" ]; spacing: 8px; padding: 8px; }" \
    -theme-str "listview { lines: ${lines}; fixed-height: false; }" \
    -kb-move-char-forward "" \
    -kb-move-char-back "" \
    -kb-cancel "Escape,Control+g,Control+bracketleft,Left" \
    -kb-accept-entry "Right,Control+j,Control+m,Return,KP_Enter" \
    "$@"
}
