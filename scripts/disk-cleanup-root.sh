#!/usr/bin/env bash
# Wrapper: prefer NixOS packaged disk-cleanup-root; else run dotfiles source.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
SRC="$DOTFILES/nix/disk-startup-notify/src"

if command -v disk-cleanup-root >/dev/null 2>&1; then
  exec disk-cleanup-root "$@"
fi

export NIX_COLLECT_GARBAGE="${NIX_COLLECT_GARBAGE:-/run/current-system/sw/bin/nix-collect-garbage}"
export NIX_STORE="${NIX_STORE:-/run/current-system/sw/bin/nix-store}"
export JOURNALCTL="${JOURNALCTL:-/run/current-system/sw/bin/journalctl}"
exec bash "$SRC/disk-cleanup-root.sh"
