#!/usr/bin/env bash
# Omarchy: Super+Ctrl+Shift+Space — theme picker
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
CURRENT="$(cat "$STATE_DIR/current-theme" 2>/dev/null || echo ash)"

mapfile -t themes < <(find "$DOTFILES/themes" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
if ((${#themes[@]} == 0)); then
  notify-send "Temas" "Nenhum tema em $DOTFILES/themes/" 2>/dev/null || true
  exit 1
fi

choices=()
for theme in "${themes[@]}"; do
  if [[ "$theme" == "$CURRENT" ]]; then
    choices+=("→ $theme")
  else
    choices+=("$theme")
  fi
done

choice="$(printf '%s\n' "${choices[@]}" | rofi -dmenu -i -p "Theme")" || exit 0
choice="${choice#→ }"
choice="$(echo "$choice" | xargs)"

[[ -n "$choice" ]] || exit 0

if [[ ! -d "$DOTFILES/themes/$choice" ]]; then
  notify-send -a "dotfiles-theme" -u critical "Tema inválido" "$choice" 2>/dev/null || true
  exit 1
fi

"$DOTFILES/scripts/apply-theme.sh" "$choice"
