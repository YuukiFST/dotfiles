#!/usr/bin/env bash
# Aplica config do Vesktop (cópia direta — Vesktop cria arquivos reais, stow conflita).
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
SRC="$DOTFILES/vesktop/.config/vesktop"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/vesktop"

mkdir -p "$DEST/settings"

if [[ "${1:-}" == "--safe" ]]; then
  echo "==> Modo emergência: desabilitando QuickCSS"
  python3 - <<'PY'
import json
from pathlib import Path
p = Path.home() / ".config/vesktop/settings/settings.json"
data = json.loads(p.read_text()) if p.exists() else {}
data["useQuickCss"] = False
p.parent.mkdir(parents=True, exist_ok=True)
p.write_text(json.dumps(data, indent=2) + "\n")
print("useQuickCss = false em", p)
PY
  echo "Reabra o Vesktop."
  exit 0
fi

cp -f "$SRC/settings.json" "$DEST/settings.json"
cp -f "$SRC/settings/settings.json" "$DEST/settings/settings.json"
cp -f "$SRC/settings/quickCss.css" "$DEST/settings/quickCss.css"

echo "==> Vesktop atualizado: VOID-TERM lite"
echo "    Discord → Aparência → Onyx"
echo ""
echo "    Tela preta? Rode: $0 --safe"
echo "    Reinicie o Vesktop por completo."
