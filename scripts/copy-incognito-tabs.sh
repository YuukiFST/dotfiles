#!/usr/bin/env bash
# Copy all tab URLs from the focused Thorium incognito window to the clipboard.
set -euo pipefail

find_incognito_window() {
  # xdotool search has no -i flag (fails silently, matches nothing); it is already case-insensitive.
  for win in $(xdotool search --name thorium 2>/dev/null); do
    title=$(xdotool getwindowname "$win" 2>/dev/null)
    [[ -z "$title" ]] && continue
    if echo "$title" | grep -qiE 'incognito|anônimo|anonimo'; then
      echo "$win"
      return 0
    fi
  done
  return 1
}

WIN=$(find_incognito_window) || {
  notify-send -a thorium -u critical "Thorium" "No incognito window found (incognito tab must be on its start page)" 2>/dev/null || true
  exit 1
}

xdotool windowactivate --sync "$WIN"
sleep 0.3
# Thorium ignores synthetic XSendEvent keys (xdotool key --window); use XTEST on the focused window instead.
xdotool key ctrl+1
sleep 0.2

urls=()
first=""
# Tab-switch takes ~200ms; too fast and ctrl+l copies the previous tab's omnibox.
while true; do
  xdotool key ctrl+l
  sleep 0.1
  xdotool key ctrl+c
  sleep 0.2
  url=$(xclip -o -selection clipboard 2>/dev/null)
  [[ -z "$url" ]] && break
  [[ "$url" == "$first" ]] && break
  [[ -z "$first" ]] && first="$url"
  urls+=("$url")
  xdotool key ctrl+Tab
  sleep 0.35
done

# Drop chrome://newtab noise and consecutive duplicates from tab-switch races.
declare -a clean=()
last=""
for u in "${urls[@]}"; do
  [[ "$u" == chrome://* ]] && continue
  [[ "$last" == "$u" ]] && continue
  last="$u"
  clean+=("$u")
done
urls=("${clean[@]}")

if ((${#urls[@]} == 0)); then
  notify-send -a thorium -u critical "Thorium" "No URLs copied" 2>/dev/null || true
  exit 1
fi

printf '%s\n' "${urls[@]}" | tee /tmp/thorium-incognito-tabs.txt
# Single-line chat inputs strip newlines; space-separated stays readable anywhere.
{ IFS=' '; printf '%s\n' "${urls[*]}"; } | xclip -selection clipboard
notify-send -a thorium "Thorium" "Copied ${#urls[@]} incognito tab URL(s)" 2>/dev/null || true
