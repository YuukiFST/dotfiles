#!/usr/bin/env bash
# Cursor plan usage for polybar. OpenCode Go if OPENCODE_GO_API_KEY is set.
# OpenCode free has no remaining-quota API (IP/day server-side).
set -euo pipefail

export PATH="$HOME/.nix-profile/bin:/run/current-system/sw/bin:$HOME/.cargo/bin:$PATH"

find_bin() {
  local p
  for p in \
    "$(command -v ai-usagebar 2>/dev/null || true)" \
    "$HOME/.nix-profile/bin/ai-usagebar" \
    /run/current-system/sw/bin/ai-usagebar \
    "$HOME/.cargo/bin/ai-usagebar"; do
    if [[ -n "$p" && -x "$p" ]]; then
      printf '%s' "$p"
      return 0
    fi
  done
  return 1
}

plain_from_json() {
  python3 -c '
import json, re, sys
raw = sys.stdin.read()
try:
    data = json.loads(raw)
except json.JSONDecodeError:
    print(re.sub(r"<[^>]+>", "", raw).strip())
    raise SystemExit(0)
text = data.get("text") or ""
print(re.sub(r"<[^>]+>", "", text).strip())
'
}

print_line() {
  local vendor="$1"
  local fmt="$2"
  local bin="$3"
  local out
  out=$("$bin" --vendor "$vendor" --format "$fmt" 2>/dev/null || true)
  [[ -n "$out" ]] || return 1
  printf '%s' "$out" | plain_from_json
}

if ! bin=$(find_bin); then
  printf '󰣇 —\n'
  exit 0
fi

cursor_fmt='󰣇 {plan} {cursor_auto_pct}%/{cursor_api_pct}%'
if [[ -n "${OPENCODE_GO_API_KEY:-}" ]]; then
  oc=$(print_line opencode-go '{vendor_short} {session_pct}%' "$bin" || true)
  cur=$(print_line cursor "$cursor_fmt" "$bin" || printf '󰣇 ?')
  if [[ -n "${oc:-}" ]]; then
    printf '%s  %s\n' "$cur" "$oc"
  else
    printf '%s\n' "$cur"
  fi
else
  print_line cursor "$cursor_fmt" "$bin" || printf '󰣇 ?\n'
fi
