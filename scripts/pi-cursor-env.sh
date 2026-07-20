#!/usr/bin/env bash
# Export CURSOR_API_KEY from ~/.pi/agent/.env or auth.json for pi-cursor-sdk.
set -euo pipefail

PI_AGENT="${PI_AGENT:-$HOME/.pi/agent}"
PI_ENV_FILE="$PI_AGENT/.env"
PI_AUTH_JSON="$PI_AGENT/auth.json"

load_cursor_api_key() {
  if [[ -n "${CURSOR_API_KEY:-}" ]]; then
    printf '%s' "$CURSOR_API_KEY"
    return 0
  fi

  if [[ -f "$PI_ENV_FILE" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$PI_ENV_FILE"
    set +a
  fi

  if [[ -n "${CURSOR_API_KEY:-}" ]]; then
    printf '%s' "$CURSOR_API_KEY"
    return 0
  fi

  if [[ -f "$PI_AUTH_JSON" ]]; then
    python3 -c "
import json, sys
try:
    key = json.load(open(sys.argv[1], encoding='utf-8')).get('cursor', {}).get('key', '').strip()
    if key:
        print(key, end='')
except Exception:
    pass
" "$PI_AUTH_JSON" 2>/dev/null || true
  fi
}

case "${1:-}" in
  --print)
    load_cursor_api_key
    ;;
  *)
    key="$(load_cursor_api_key)"
    if [[ -n "$key" ]]; then
      export CURSOR_API_KEY="$key"
    fi
    ;;
esac
