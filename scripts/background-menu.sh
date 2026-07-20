#!/usr/bin/env bash
# Omarchy: Super+Ctrl+Space — wallpaper picker
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
THEME="$(cat "$STATE_DIR/current-theme" 2>/dev/null || echo ash)"
BG_DIR="$DOTFILES/themes/$THEME/backgrounds"

if [[ ! -d "$BG_DIR" ]]; then
  notify-send "Background" "Sem wallpapers em $BG_DIR" 2>/dev/null || true
  exit 1
fi

mapfile -t wallpapers < <(find "$BG_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) | sort)
if ((${#wallpapers[@]} == 0)); then
  notify-send "Background" "Nenhuma imagem em $BG_DIR" 2>/dev/null || true
  exit 1
fi

choices=()
for wp in "${wallpapers[@]}"; do
  choices+=("$(basename "$wp")")
done

choice="$(printf '%s\n' "${choices[@]}" | rofi -dmenu -i -p "Background ($THEME)")" || exit 0
[[ -n "$choice" ]] || exit 0

for wp in "${wallpapers[@]}"; do
  if [[ "$(basename "$wp")" == "$choice" ]]; then
    "$DOTFILES/scripts/set-wallpaper.sh" "$wp"
    STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
    echo "$wp" >"$STATE_DIR/wallpaper-$THEME"
    notify-send -a "dotfiles-theme" -u low "Wallpaper" "$THEME: $(basename "$wp")" 2>/dev/null || true
    exit 0
  fi
done
