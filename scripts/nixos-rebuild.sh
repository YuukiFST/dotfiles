#!/usr/bin/env bash
# Rebuild NixOS a partir dos dotfiles — sem copiar manualmente para /etc/nixos.
# Rode num terminal normal (Ghostty, tty); o terminal do Cursor não tem sudo.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
NIX_DIR="$DOTFILES/nix"
ACTION=switch
DO_PULL=false
DO_SYNC=false

usage() {
  cat <<'EOF'
Uso: nixos-rebuild.sh [opções]

Rebuild direto do flake em ~/Projects/dotfiles/nix (fonte única da verdade).

Opções:
  -b, --build       Só compila (nixos-rebuild build)
  -t, --test        Testa sem aplicar (nixos-rebuild test)
      --boot        Ativa no próximo boot (nixos-rebuild boot)
  -p, --pull        Atualiza flake inputs antes (nix flake update)
  -s, --sync        Também copia configs para /etc/nixos (legado)
  -h, --help        Mostra esta ajuda

Exemplos:
  nixos-rebuild.sh           # switch (o mais comum)
  nixos-rebuild.sh -p        # update inputs + switch
  nixos-rebuild.sh -b        # só build, sem aplicar
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
  echo "flake não encontrado em $NIX_DIR" >&2
  exit 1
fi

if $DO_PULL; then
  echo "==> Atualizando flake inputs"
  (cd "$NIX_DIR" && nix flake update)
fi

if $DO_SYNC; then
  echo "==> Sincronizando $NIX_DIR -> /etc/nixos"
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
