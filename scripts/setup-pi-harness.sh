#!/usr/bin/env bash
# Aplica https://github.com/YuukiFST/my-harness-config ao pi (skills + AGENTS.md).
# No NixOS o binário vem de pi-coding-agent no nix; só sincroniza config.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
HARNESS_CONFIG="${HARNESS_CONFIG:-$HOME/Projects/my-harness-config}"
HARNESS_REPO="${HARNESS_REPO:-https://github.com/YuukiFST/my-harness-config.git}"

if ! command -v pi >/dev/null 2>&1; then
  echo "pi não está no PATH — rode nixos-rebuild primeiro (pi-coding-agent)" >&2
  exit 1
fi

echo "==> Harness config para pi"
if [ ! -d "$HARNESS_CONFIG/.git" ]; then
  echo "  clonando $HARNESS_REPO"
  GIT_CONFIG_GLOBAL=/dev/null git clone "$HARNESS_REPO" "$HARNESS_CONFIG"
else
  echo "  atualizando $HARNESS_CONFIG"
  git -C "$HARNESS_CONFIG" fetch origin
  branch="$(git -C "$HARNESS_CONFIG" remote show origin 2>/dev/null | sed -n '/HEAD branch/s/.*: //p')"
  branch="${branch:-main}"
  if ! git -C "$HARNESS_CONFIG" pull --ff-only origin "$branch"; then
    echo "    aviso: my-harness-config divergiu do remoto — usando cópia local" >&2
    echo "    para atualizar: cd $HARNESS_CONFIG && git pull --rebase" >&2
  fi
fi

bash "$HARNESS_CONFIG/scripts/sync-config.sh" pi

echo "    AGENTS.md → $HOME/.pi/agent/AGENTS.md"
echo "    skills    → $HOME/.agents/skills/ (my-harness-config)"
