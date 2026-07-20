#!/usr/bin/env bash
# Pi: my-pi-setup (config + extensions) + dmmulroy extensions. Sem skills desses repos.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
PI_AGENT="${PI_AGENT:-$HOME/.pi/agent}"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-pi-setup"

MY_PI_SETUP_REPO="${MY_PI_SETUP_REPO:-https://github.com/davis7dotsh/my-pi-setup.git}"
DMMULROY_REPO="${DMMULROY_REPO:-https://github.com/dmmulroy/.dotfiles.git}"

clone_or_pull() {
  local dir="$1" repo="$2"
  if [[ -d "$dir/.git" ]]; then
    git -C "$dir" fetch --depth 1 origin
    local branch
    branch="$(git -C "$dir" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')"
    branch="${branch:-main}"
    git -C "$dir" checkout "$branch"
    git -C "$dir" pull --ff-only origin "$branch"
  else
    mkdir -p "$(dirname "$dir")"
    GIT_CONFIG_GLOBAL=/dev/null git clone --depth 1 "$repo" "$dir"
  fi
}

sparse_clone_dmmulroy() {
  local dir="$1"
  if [[ -d "$dir/.git" ]]; then
    git -C "$dir" fetch --depth 1 origin
    git -C "$dir" checkout main 2>/dev/null || git -C "$dir" checkout master
    git -C "$dir" pull --ff-only
  else
    mkdir -p "$(dirname "$dir")"
    GIT_CONFIG_GLOBAL=/dev/null git clone --depth 1 --filter=blob:none --sparse "$DMMULROY_REPO" "$dir"
    git -C "$dir" sparse-checkout set home/.pi/agent/extensions
  fi
}

if ! command -v npm >/dev/null 2>&1; then
  echo "npm não está no PATH — rode nixos-rebuild primeiro (nodejs)" >&2
  exit 1
fi

mkdir -p "$PI_AGENT" "$CACHE"

echo "==> Pi: my-pi-setup (sem skills)"
MY_PI_DIR="$CACHE/my-pi-setup"
clone_or_pull "$MY_PI_DIR" "$MY_PI_SETUP_REPO"

rsync -a \
  --exclude '.git/' \
  --exclude 'node_modules/' \
  --exclude 'skills/' \
  --exclude 'AGENTS.md' \
  --exclude 'README.md' \
  --exclude 'SETUP.md' \
  --exclude 'assets/' \
  --exclude 'auth.json' \
  "$MY_PI_DIR/" "$PI_AGENT/"

echo "==> Pi: extensions dmmulroy"
DMMULROY_DIR="$CACHE/dmmulroy-dotfiles"
sparse_clone_dmmulroy "$DMMULROY_DIR"

rsync -a "$DMMULROY_DIR/home/.pi/agent/extensions/" "$PI_AGENT/extensions/"
curl -fsSL "https://raw.githubusercontent.com/dmmulroy/.dotfiles/main/home/.pi/agent/cloak.json" \
  -o "$PI_AGENT/cloak.json" 2>/dev/null || true

echo "==> Pi: settings.json"
HARNESS_CONFIG="${HARNESS_CONFIG:-$HOME/Projects/my-harness-config}"
PI_SETTINGS_SEED="$HARNESS_CONFIG/pi/settings.json"
python3 - "$PI_AGENT/settings.json" "$PI_SETTINGS_SEED" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
seed_path = Path(sys.argv[2])
settings: dict = {}
if path.exists():
    settings = json.loads(path.read_text())

if seed_path.exists():
    seed = json.loads(seed_path.read_text())
    for key in ("theme", "defaultProvider", "defaultModel", "enabledModels", "defaultThinkingLevel"):
        if key in seed:
            settings[key] = seed[key]
    desired_packages = seed.get("packages", [])
else:
    settings["theme"] = "github-dark-default"
    desired_packages = [
        "npm:@ff-labs/pi-fff",
        "npm:pi-cursor-sdk",
        "npm:pi-codex-goal",
        "npm:@howaboua/pi-cache-hit-predictor",
        {
            "source": "npm:pine-of-glass",
            "extensions": ["+extensions/pi-contextimate"],
        },
        "git:github.com/DietrichGebert/ponytail",
    ]
    settings["defaultProvider"] = "cursor"
    settings["defaultModel"] = "composer-2.5"
    settings["enabledModels"] = [
        "composer-2.5",
        "deepseek-v4-flash-free",
        "mimo-v2.5-free",
    ]

packages: list = []
seen: set[str] = set()
for pkg in desired_packages:
    key = pkg if isinstance(pkg, str) else pkg["source"]
    if key in seen:
        continue
    seen.add(key)
    packages.append(pkg)
settings["packages"] = packages

path.write_text(json.dumps(settings, indent=2) + "\n")
PY

echo "==> Pi: disable heavy extensions (token budget)"
DISABLED_DIR="$PI_AGENT/extensions-disabled"
mkdir -p "$DISABLED_DIR"
for ext in file-search firecrawl-search workflows subagents; do
  src="$PI_AGENT/extensions/$ext"
  dest="$DISABLED_DIR/$ext"
  if [[ -d "$src" ]]; then
    rm -rf "$dest"
    mv "$src" "$dest"
    echo "    disabled $ext"
  fi
done

if [[ ! -f "$PI_AGENT/.env" && -f "$PI_AGENT/.env.example" ]]; then
  echo "    (opcional) Firecrawl: cp $PI_AGENT/.env.example $PI_AGENT/.env"
fi

echo "==> Pi: npm install (agent + extensions)"
(cd "$PI_AGENT" && npm install)

for pkg in "$PI_AGENT"/extensions/*/package.json; do
  [[ -f "$pkg" ]] || continue
  ext_dir="$(dirname "$pkg")"
  [[ -d "$ext_dir" ]] || continue
  echo "    npm install em $(basename "$ext_dir")"
  (cd "$ext_dir" && npm install)
done

PI_BIN="$PI_AGENT/node_modules/.bin/pi"
chmod +x "$DOTFILES/scripts/pi.sh"
mkdir -p "$HOME/.local/bin"
ln -sf "$DOTFILES/scripts/pi.sh" "$HOME/.local/bin/pi"

if [[ -x "$PI_BIN" ]]; then
  echo "    pi $( "$PI_BIN" --version ) em $PI_BIN"
  for pkg in npm:@ff-labs/pi-fff npm:pi-cursor-sdk npm:pi-codex-goal npm:@howaboua/pi-cache-hit-predictor npm:pine-of-glass git:github.com/DietrichGebert/ponytail; do
    if "$PI_BIN" install "$pkg" 2>/dev/null; then
      echo "    $pkg instalado"
    fi
  done
  if [[ -d "$PI_AGENT/npm" ]]; then
    (cd "$PI_AGENT/npm" && npm install typebox 2>/dev/null) || true
  fi
else
  echo "    aviso: pi local não encontrado após npm install" >&2
fi

echo "==> Pi: harness (AGENTS.md + skills do my-harness-config)"
"$DOTFILES/scripts/setup-pi-harness.sh"

echo "==> Pi pronto."
echo "    Use: $DOTFILES/scripts/pi.sh  (0.80+; FFF override + lean tools)"
echo "    fish já prioriza esse binário no PATH após setup-dotfiles."
echo "    Cursor Composer 2.5: $DOTFILES/scripts/pi-cursor-login.sh"
