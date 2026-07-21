#!/usr/bin/env bash
# Copy all tab URLs from the focused Thorium incognito window to the clipboard.
set -euo pipefail

find_incognito_window() {
  for win in $(xdotool search --name -i thorium 2>/dev/null); do
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
  notify-send -a thorium -u critical "Thorium" "No incognito window found" 2>/dev/null || true
  exit 1
}

xdotool windowactivate --sync "$WIN"
sleep 0.3
xdotool key --window "$WIN" ctrl+1
sleep 0.2

urls=()
first=""
while true; do
  xdotool key --window "$WIN" ctrl+l ctrl+c
  sleep 0.15
  url=$(xclip -o -selection clipboard 2>/dev/null)
  [[ -z "$url" ]] && break
  [[ "$url" == "$first" ]] && break
  [[ -z "$first" ]] && first="$url"
  urls+=("$url")
  xdotool key --window "$WIN" ctrl+Tab
  sleep 0.15
done

if ((${#urls[@]} == 0)); then
  notify-send -a thorium -u critical "Thorium" "No URLs copied" 2>/dev/null || true
  exit 1
fi

printf '%s\n' "${urls[@]}" | tee /tmp/thorium-incognito-tabs.txt
printf '%s\n' "${urls[@]}" | xclip -selection clipboard
notify-send -a thorium "Thorium" "Copied ${#urls[@]} incognito tab URL(s)" 2>/dev/null || true
