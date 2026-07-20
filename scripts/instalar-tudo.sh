#!/usr/bin/env bash
# Rode este script num terminal NORMAL do sistema (Konsole, Ghostty, tty).
# O terminal do Cursor nao consegue usar sudo.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"

echo "=== Instalacao NixOS + dotfiles (bashbunni + Ghostty + Herdr) ==="
"$DOTFILES/scripts/setup-nixos.sh"

echo ""
echo "=== Doom Emacs (apos emacs instalado) ==="
if command -v emacs >/dev/null 2>&1; then
  "$HOME/.config/emacs/bin/doom" install --force || true
  "$HOME/.config/emacs/bin/doom" sync || true
fi

echo ""
echo "=== Plugins tmux ==="
if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" || true
fi

echo ""
echo "=== Pi harness (my-harness-config) ==="
if command -v pi >/dev/null 2>&1; then
  "$DOTFILES/scripts/setup-pi-harness.sh"
else
  echo "  (pule: pi ainda não no PATH — rode scripts/setup-pi-harness.sh depois do rebuild)"
fi

echo ""
echo "=== Concluido! Faca logout e entre na sessao i3. ==="
