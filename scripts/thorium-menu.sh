#!/usr/bin/env bash
# Polybar Thorium icon — pick copy-tabs vs open clipboard links.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
# shellcheck source=lib/polybar-rofi-card.sh
source "$DOTFILES/scripts/lib/polybar-rofi-card.sh"
COPY_TABS="$DOTFILES/scripts/copy-incognito-tabs.sh"
OPEN_LINKS="$DOTFILES/scripts/open-clipboard-links-incognito.py"

action="$(
  printf '%s\n' \
    "Copy Incognito Tab URLs" \
    "Open Clipboard Links in Incognito" |
    polybar_rofi_card 2 -p "Thorium"
)" || true

[[ -n "${action:-}" ]] || exit 0

case "$action" in
  "Copy Incognito Tab URLs")
    "$COPY_TABS"
    ;;
  "Open Clipboard Links in Incognito")
    python3 "$OPEN_LINKS"
    ;;
esac
