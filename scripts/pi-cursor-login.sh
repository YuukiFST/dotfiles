#!/usr/bin/env bash
# Configura Cursor API key + Composer 2.5 no Pi.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
PI_AGENT="${PI_AGENT:-$HOME/.pi/agent}"
PI_BIN="$PI_AGENT/node_modules/.bin/pi"

if [[ ! -x "$PI_BIN" ]]; then
  echo "==> Pi local não encontrado; rodando setup-pi.sh"
  "$DOTFILES/scripts/setup-pi.sh"
fi

if ! "$PI_BIN" list 2>/dev/null | grep -q 'pi-cursor-sdk'; then
  echo "==> Instalando pi-cursor-sdk"
  "$PI_BIN" install npm:pi-cursor-sdk
fi

# typebox é peer dependency do pi-cursor-sdk
if [[ -f "$PI_AGENT/npm/package.json" ]] && ! grep -q '"typebox"' "$PI_AGENT/npm/package.json"; then
  (cd "$PI_AGENT/npm" && npm install typebox)
fi

exec node "$DOTFILES/scripts/pi-cursor-login.mjs"
