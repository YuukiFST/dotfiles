#!/usr/bin/env bash
# Wrapper: prefer NixOS packaged disk-startup-notify; else run dotfiles source.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
SRC="$DOTFILES/nix/disk-startup-notify/src"

if command -v disk-startup-notify >/dev/null 2>&1; then
  exec disk-startup-notify "$@"
fi

export DISK_CLEANUP="${DISK_CLEANUP:-$DOTFILES/scripts/disk-cleanup.sh}"
exec bash "$SRC/disk-startup-notify.sh"
