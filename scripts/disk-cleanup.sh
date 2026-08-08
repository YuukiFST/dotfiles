#!/usr/bin/env bash
# Wrapper: prefer NixOS packaged disk-cleanup; else run dotfiles source (pre-rebuild).
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
SRC="$DOTFILES/nix/disk-startup-notify/src"

if command -v disk-cleanup >/dev/null 2>&1; then
  exec disk-cleanup "$@"
fi

export DISK_CLEANUP_MOUNT="${DISK_CLEANUP_MOUNT:-/}"
export DISK_CLEANUP_ROOT="${DISK_CLEANUP_ROOT:-$SRC/disk-cleanup-root.sh}"
exec bash "$SRC/disk-cleanup.sh" "$@"
