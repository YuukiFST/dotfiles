#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
NIX_DIR="$DOTFILES/nix"

echo "==> Instalando configuração NixOS em /etc/nixos"
sudo mkdir -p /etc/nixos
sudo cp "$NIX_DIR/flake.nix" "$NIX_DIR/configuration.nix" "$NIX_DIR/hardware-configuration.nix" /etc/nixos/
if [ -f "$NIX_DIR/flake.lock" ]; then
  sudo cp "$NIX_DIR/flake.lock" /etc/nixos/
fi

echo "==> Aplicando sistema (primeira vez pode demorar bastante)"
"$DOTFILES/scripts/nixos-rebuild.sh" --sync

echo "==> Configurando dotfiles (stow, doom, tmux tpm)"
"$DOTFILES/scripts/setup-dotfiles.sh"

echo ""
echo "Pronto! Faça logout e escolha a sessão i3 no LightDM."
echo ""
echo "Atalhos i3:"
echo "  Super+Return       -> Ghostty (terminal)"
echo "  Super+\`            -> Ghostty + Herdr"
echo "  Super+Shift+Return -> Thorium AVX2"
echo "  Super+F            -> Fullscreen"
echo "  Super+Shift+F      -> Nautilus (arquivos)"
echo "  Super+Q            -> Fechar janela"
echo "  Super+D            -> Rofi"
echo "  F1                 -> Emacs (Doom)"
echo "  fish: ta           -> herdr"
echo ""
echo "Depois de polir (Thorium, Zen Browser, etc.), edite nix/configuration.nix"
