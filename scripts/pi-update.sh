#!/usr/bin/env bash
# Atualiza pi instalado via npm em ~/.pi/agent (pi update não funciona nesse modo).
set -euo pipefail

PI_AGENT="${PI_AGENT:-$HOME/.pi/agent}"
PI_BIN="$PI_AGENT/node_modules/.bin/pi"

if [[ ! -f "$PI_AGENT/package.json" ]]; then
  echo "Rode primeiro: ~/Projects/dotfiles/scripts/setup-pi.sh" >&2
  exit 1
fi

echo "==> Pi: npm update (~/.pi/agent)"
(
  cd "$PI_AGENT"
  npm install \
    @earendil-works/pi-coding-agent@latest \
    @earendil-works/pi-ai@latest \
    @earendil-works/pi-tui@latest
)

for pkg in "$PI_AGENT"/extensions/*/package.json; do
  ext_dir="$(dirname "$pkg")"
  echo "    npm update em $(basename "$ext_dir")"
  (cd "$ext_dir" && npm update 2>/dev/null || npm install)
done

if [[ -x "$PI_BIN" ]]; then
  echo "==> Pi atualizado: $("$PI_BIN" --version)"
  "$PI_BIN" update --extensions 2>/dev/null || true
else
  echo "aviso: binário pi não encontrado em $PI_BIN" >&2
fi

echo "Reabra o pi."
