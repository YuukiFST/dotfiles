#!/usr/bin/env bash
# Full Nix package update: herdr (bump flake input when a new tag exists),
# nixpkgs (ghostty and everything else) + rebuild. Run from a regular terminal
# (Ghostty/tty); the Cursor terminal has no sudo.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
NIX_DIR="$DOTFILES/nix"
FLAKE="$NIX_DIR/flake.nix"
REPO="ogulcancelik/herdr"

if [[ ! -f "$FLAKE" ]]; then
  echo "flake not found at $FLAKE" >&2
  exit 1
fi

bump_herdr() {
  local latest current
  # Latest v* tag (dereferenced refs excluded)
  latest="$(git ls-remote --tags --refs "https://github.com/$REPO" | awk -F/ '{print $NF}' | sed 's/^v//' | sort -V | tail -1)"
  if [[ -z "$latest" ]]; then
    echo "    (could not list herdr tags; skipping bump)" >&2
    return
  fi
  current="$(grep -oP 'github:ogulcancelik/herdr/v\K[0-9]+\.[0-9]+\.[0-9]+' "$FLAKE" || true)"
  if [[ -z "$current" ]]; then
    echo "    (herdr input does not match vX.Y.Z pattern; skipping bump)" >&2
    return
  fi
  if [[ "$current" == "$latest" ]]; then
    echo "    herdr already at latest version ($current)"
    return
  fi
  echo "    herdr $current -> $latest (bumping flake.nix input)"
  cp "$FLAKE" "$FLAKE.bak"
  # Replaces only the herdr input URL (pattern is unique in the flake).
  sed -i "s|github:ogulcancelik/herdr/v[0-9.]*|github:ogulcancelik/herdr/v$latest|" "$FLAKE"
  (cd "$NIX_DIR" && nix flake update herdr)
}

echo "==> herdr: checking latest tag"
bump_herdr

echo "==> nix flake update (nixpkgs -> ghostty; emacs-overlay; custom-packages)"
(cd "$NIX_DIR" && nix flake update) || {
  echo "flake update failed — flake.nix reverted from backup." >&2
  if [[ -f "$FLAKE.bak" ]]; then
    cp "$FLAKE.bak" "$FLAKE"
  fi
  exit 1
}

echo "==> nixos-rebuild switch (sudo)"
cd "$NIX_DIR"
exec sudo nixos-rebuild switch --flake ".#nixos"