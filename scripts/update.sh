#!/usr/bin/env bash
# Check Pi core, Pi extensions, herdr, and ghostty (nixpkgs); update only what is outdated.
# Rebuilds NixOS once if the flake changed. Run from Ghostty/tty (sudo for rebuild).
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
PI_AGENT="${PI_AGENT:-$HOME/.pi/agent}"
PI_BIN="$PI_AGENT/node_modules/.bin/pi"
NIX_DIR="$DOTFILES/nix"
FLAKE="$NIX_DIR/flake.nix"
HERDR_REPO="ogulcancelik/herdr"

ANY_CHANGE=0
NIX_REBUILD=0

skip() {
  echo "    $1: já atualizado"
}

mark_changed() {
  ANY_CHANGE=1
}

pi_core_needs_update() {
  [[ -f "$PI_AGENT/package.json" ]] || return 1
  (
    cd "$PI_AGENT"
    npm outdated --json \
      @earendil-works/pi-coding-agent \
      @earendil-works/pi-ai \
      @earendil-works/pi-tui 2>/dev/null || true
  ) | grep -q '"current"'
}

update_pi_core() {
  echo "==> Pi core: npm update"
  (
    cd "$PI_AGENT"
    npm install \
      @earendil-works/pi-coding-agent@latest \
      @earendil-works/pi-ai@latest \
      @earendil-works/pi-tui@latest
  )
  if [[ -x "$PI_BIN" ]]; then
    echo "    pi $("$PI_BIN" --version)"
    if [[ -d "$PI_AGENT/node_modules/node_modules" ]]; then
      echo "    aviso: nested node_modules detectado — veja CLAUDE.md em ~/.pi/agent" >&2
    else
      echo "    OK: no nested node_modules"
    fi
  else
    echo "    erro: pi não encontrado em $PI_BIN" >&2
    return 1
  fi
  mark_changed
}

pi_extensions_needs_update() {
  local repo branch upstream local_rev

  for repo in "$PI_AGENT"/git/*/*; do
    [[ -d "$repo/.git" ]] || continue
    git -C "$repo" fetch --depth 1 origin 2>/dev/null || continue
    branch="$(git -C "$repo" symbolic-ref --short HEAD 2>/dev/null || echo main)"
    upstream="$(git -C "$repo" rev-parse "origin/$branch" 2>/dev/null || true)"
    local_rev="$(git -C "$repo" rev-parse HEAD)"
    if [[ -n "$upstream" && "$local_rev" != "$upstream" ]]; then
      return 0
    fi
  done

  if [[ -f "$PI_AGENT/npm/package.json" ]]; then
    if (
      cd "$PI_AGENT/npm"
      npm outdated --json 2>/dev/null || true
    ) | grep -q '"current"'; then
      return 0
    fi
  fi

  return 1
}

update_pi_extensions() {
  if [[ ! -x "$PI_BIN" ]]; then
    echo "    pi não encontrado em $PI_BIN — rode setup-pi.sh primeiro" >&2
    return 1
  fi
  echo "==> Pi extensions: pi update --extensions"
  "$PI_BIN" update --extensions --no-approve
  mark_changed
}

herdr_latest_tag() {
  git ls-remote --tags --refs "https://github.com/$HERDR_REPO" \
    | awk -F/ '{print $NF}' \
    | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' \
    | sed 's/^v//' \
    | sort -V \
    | tail -1
}

herdr_current_version() {
  grep -oP 'github:ogulcancelik/herdr/v\K[0-9]+\.[0-9]+\.[0-9]+' "$FLAKE" 2>/dev/null || true
}

bump_herdr() {
  local latest="$1" current="$2"
  echo "==> herdr: $current -> $latest"
  cp "$FLAKE" "$FLAKE.bak"
  sed -i "s|github:ogulcancelik/herdr/v[0-9.]*|github:ogulcancelik/herdr/v$latest|" "$FLAKE"
  (cd "$NIX_DIR" && nix flake update herdr)
  NIX_REBUILD=1
  mark_changed
}

update_nixpkgs_if_needed() {
  local lock="$NIX_DIR/flake.lock"
  local before after

  before="$(sha256sum "$lock" | cut -d' ' -f1)"
  if ! (cd "$NIX_DIR" && nix flake update nixpkgs >/dev/null 2>&1); then
    echo "    ghostty/nixpkgs: flake update falhou" >&2
    return 1
  fi
  after="$(sha256sum "$lock" | cut -d' ' -f1)"
  if [[ "$before" != "$after" ]]; then
    echo "==> ghostty/nixpkgs: flake.lock atualizado"
    NIX_REBUILD=1
    mark_changed
  else
    skip "ghostty (nixpkgs)"
  fi
}

if [[ ! -f "$FLAKE" ]]; then
  echo "flake not found at $FLAKE" >&2
  exit 1
fi

echo "==> Verificando atualizações (Pi, extensions, herdr, ghostty)"
echo

echo "-- Pi core"
if [[ ! -f "$PI_AGENT/package.json" ]]; then
  echo "    pi não instalado — rode setup-pi.sh primeiro" >&2
elif pi_core_needs_update; then
  update_pi_core
else
  skip "Pi core"
fi

echo "-- Pi extensions"
if [[ ! -x "$PI_BIN" ]]; then
  skip "Pi extensions (pi ausente)"
elif pi_extensions_needs_update; then
  update_pi_extensions
else
  skip "Pi extensions"
fi

echo "-- herdr"
herdr_latest="$(herdr_latest_tag)"
herdr_current="$(herdr_current_version)"
if [[ -z "$herdr_latest" ]]; then
  echo "    herdr: não foi possível listar tags (pulando)" >&2
elif [[ -z "$herdr_current" ]]; then
  echo "    herdr: input no flake.nix não reconhecido (pulando)" >&2
elif [[ "$herdr_current" == "$herdr_latest" ]]; then
  skip "herdr ($herdr_current)"
else
  bump_herdr "$herdr_latest" "$herdr_current"
fi

echo "-- ghostty (nixpkgs)"
update_nixpkgs_if_needed

if (( NIX_REBUILD )); then
  echo
  echo "==> nixos-rebuild switch (sudo)"
  if ! (cd "$NIX_DIR" && sudo nixos-rebuild switch --flake ".#nixos"); then
    echo "    rebuild falhou — rode de um terminal com sudo (Ghostty)" >&2
    exit 1
  fi
fi

echo
if (( ANY_CHANGE )); then
  echo "Atualização concluída."
  if [[ -x "$PI_BIN" ]]; then
    echo "Reabra o pi se core ou extensions mudaram."
  fi
else
  echo "Nada para atualizar."
fi
