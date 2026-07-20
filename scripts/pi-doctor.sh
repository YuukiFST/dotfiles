#!/usr/bin/env bash
set -euo pipefail

PI_LOCAL="$HOME/.pi/agent/node_modules/.bin/pi"
PI_NIX="$(command -v pi 2>/dev/null || true)"

echo "=== Pi doctor ==="
echo "pi local:  ${PI_LOCAL}"
if [[ -x "$PI_LOCAL" ]]; then
  echo "  version: $("$PI_LOCAL" --version)"
else
  echo "  ERRO: não instalado — rode ~/Projects/dotfiles/scripts/setup-pi.sh"
fi

echo "pi no PATH: ${PI_NIX:-não encontrado}"
if [[ -n "$PI_NIX" && "$PI_NIX" != "$PI_LOCAL" ]]; then
  echo "  version: $( "$PI_NIX" --version 2>/dev/null || echo '?' )"
  echo "  aviso: outro pi no PATH (use ~/.local/bin/pi ou função fish)"
fi

echo "shell:     ${SHELL:-?}"
if [[ "${SHELL:-}}" == *fish* ]]; then
  fish -ic 'type -q pi; and type pi | head -1; or echo "  fish: comando pi não definido"'
fi

echo "extensions com node_modules:"
count=0
for d in "$HOME/.pi/agent/extensions"/*/; do
  [[ -f "${d}package.json" ]] || continue
  name=$(basename "$d")
  if [[ -d "${d}node_modules" ]]; then
    echo "  ok  $name"
    count=$((count + 1))
  else
    echo "  FALTA npm install  $name"
  fi
done
echo "  ($count com deps instaladas)"

echo "packages npm (settings.json):"
if [[ -x "$PI_LOCAL" ]]; then
  "$PI_LOCAL" list 2>/dev/null || true
fi

has_cursor_key=false
if [[ -f "$HOME/.pi/agent/auth.json" ]]; then
  has_cursor_key=$(python3 -c "
import json
d=json.load(open('$HOME/.pi/agent/auth.json'))
c=d.get('cursor',{})
print('true' if c.get('type')=='api_key' and c.get('key') else 'false')
" 2>/dev/null || echo false)
fi
echo "cursor api key (auth.json): $has_cursor_key"
if [[ -n "${CURSOR_API_KEY:-}" ]]; then
  echo "CURSOR_API_KEY env: set"
else
  # shellcheck disable=SC1091
  source "$HOME/Projects/dotfiles/scripts/pi-cursor-env.sh" 2>/dev/null || true
  if [[ -n "${CURSOR_API_KEY:-}" ]]; then
    echo "CURSOR_API_KEY env: loaded via pi-cursor-env.sh"
  else
    echo "CURSOR_API_KEY env: unset"
  fi
fi
if [[ "$has_cursor_key" != "true" ]]; then
  echo "  rode: ~/Projects/dotfiles/scripts/pi-cursor-login.sh"
  echo "  (Composer 2.5 usa pi-cursor-sdk + API key do dashboard Cursor)"
elif [[ -z "${CURSOR_API_KEY:-}" ]]; then
  echo "  aviso: rode pi via ~/.local/bin/pi ou scripts/pi.sh (não node_modules/.bin/pi)"
fi

echo ""
echo "pi wrapper:"
if [[ -x "$HOME/.local/bin/pi" ]]; then
  readlink -f "$HOME/.local/bin/pi"
else
  echo "  FALTA symlink — rode setup-pi.sh"
fi
