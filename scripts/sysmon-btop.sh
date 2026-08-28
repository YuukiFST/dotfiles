#!/usr/bin/env bash
set -euo pipefail
TERM_CMD="${TERMINAL:-ghostty}"
exec "$TERM_CMD" -e btop
