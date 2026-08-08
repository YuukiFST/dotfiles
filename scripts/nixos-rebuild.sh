#!/usr/bin/env bash
# Rebuild NixOS from the dotfiles — no manual copy to /etc/nixos needed.
# Run from a regular terminal (Ghostty, tty); the Cursor terminal has no sudo.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
NIX_DIR="$DOTFILES/nix"
ACTION=switch
DO_PULL=false
DO_SYNC=false

usage() {
  cat <<'EOF'
Usage: nixos-rebuild.sh [options]

Rebuild directly from the flake in ~/Projects/dotfiles/nix (single source of truth).

Options:
  -b, --build       Build only (nixos-rebuild build)
  -t, --test        Test without applying (nixos-rebuild test)
      --boot        Activate on next boot (nixos-rebuild boot)
  -p, --pull        Update flake inputs first (nix flake update)
  -s, --sync        Also copy configs to /etc/nixos (legacy)
  -h, --help        Show this help

Examples:
  nixos-rebuild.sh           # switch (most common)
  nixos-rebuild.sh -p        # update inputs + switch
  nixos-rebuild.sh -b        # build only, no switch
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--build) ACTION=build ;;
    -t|--test) ACTION=test ;;
    --boot) ACTION=boot ;;
    -p|--pull) DO_PULL=true ;;
    -s|--sync) DO_SYNC=true ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Opção desconhecida: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [[ ! -f "$NIX_DIR/flake.nix" ]]; then
  echo "flake not found at $NIX_DIR" >&2
  exit 1
fi

if $DO_PULL; then
  echo "==> Updating flake inputs"
  (cd "$NIX_DIR" && nix flake update)
fi

if $DO_SYNC; then
  echo "==> Syncing $NIX_DIR -> /etc/nixos"
  sudo mkdir -p /etc/nixos
  for f in flake.nix flake.lock configuration.nix hardware-configuration.nix filesystems.nix; do
    if [[ -f "$NIX_DIR/$f" ]]; then
      sudo cp "$NIX_DIR/$f" "/etc/nixos/$f"
    fi
  done
fi

echo "==> nixos-rebuild $ACTION --flake $NIX_DIR#nixos"
cd "$NIX_DIR"
exec sudo nixos-rebuild "$ACTION" --flake ".#nixos"
