#!/usr/bin/env bash
# Ação na janela sob o cursor (sem precisar clicar antes).
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
action="${1:?usage: window-under-cursor.sh kill|fullscreen|fullscreen-global}"

"$DOTFILES/scripts/focus-under-cursor.sh" || true

case "$action" in
  kill) i3-msg kill >/dev/null ;;
  fullscreen) i3-msg fullscreen toggle >/dev/null ;;
  fullscreen-global) i3-msg fullscreen toggle global >/dev/null ;;
  *)
    echo "ação desconhecida: $action" >&2
    exit 1
    ;;
esac
