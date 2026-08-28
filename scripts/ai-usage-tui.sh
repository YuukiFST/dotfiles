#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.nix-profile/bin:/run/current-system/sw/bin:$HOME/.cargo/bin:$PATH"
TERM_CMD="${TERMINAL:-ghostty}"
bin="$(command -v ai-usagebar-tui || true)"
if [[ -z "$bin" && -x "$HOME/.nix-profile/bin/ai-usagebar-tui" ]]; then
  bin="$HOME/.nix-profile/bin/ai-usagebar-tui"
fi
if [[ -z "$bin" && -x "$HOME/.cargo/bin/ai-usagebar-tui" ]]; then
  bin="$HOME/.cargo/bin/ai-usagebar-tui"
fi
if [[ -z "$bin" ]]; then
  notify-send -u critical "AI usage" "ai-usagebar-tui not installed" 2>/dev/null || true
  exit 1
fi
exec "$TERM_CMD" -e "$bin"
