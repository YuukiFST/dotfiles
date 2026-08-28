#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"

STOW_PACKAGES=(
  ai-usagebar
  doom
  dunst
  fish
  ghostty
  gitconfig
  herdr
  i3
  nvim
  picom
  polybar
  rofi
  ssh
  tmux
  zsh
)

echo "==> Linkando dotfiles com GNU Stow"
cd "$DOTFILES"
for pkg in "${STOW_PACKAGES[@]}"; do
  echo "  stow $pkg"
  stow --target="$HOME" "$pkg"
done

echo "==> Instalando TPM (tmux plugin manager)"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  GIT_CONFIG_GLOBAL=/dev/null git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

echo "==> Instalando Doom Emacs"
if [ ! -d "$HOME/.config/emacs" ]; then
  GIT_CONFIG_GLOBAL=/dev/null git clone --depth 1 https://github.com/doomemacs/doomemacs.git "$HOME/.config/emacs"
fi
if [ -x "$HOME/.config/emacs/bin/doom" ] && command -v emacs >/dev/null 2>&1; then
  "$HOME/.config/emacs/bin/doom" install --force || true
  "$HOME/.config/emacs/bin/doom" sync || true
else
  echo "  (pule: doom install/sync depois do nixos-rebuild, quando emacs estiver no PATH)"
fi

echo "==> Pi (my-pi-setup + dmmulroy extensions + harness)"
if command -v npm >/dev/null 2>&1; then
  "$DOTFILES/scripts/setup-pi.sh"
else
  echo "  (pule: rode após nixos-rebuild quando nodejs estiver no PATH)"
fi

echo "==> Vesktop (Felix / minimal)"
"$DOTFILES/scripts/setup-vesktop.sh"

echo "==> Dotfiles prontos."
