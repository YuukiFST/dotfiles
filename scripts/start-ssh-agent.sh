#!/usr/bin/env bash
# Load SSH key into the agent once per graphical session (gpg-agent SSH or ssh-agent).
set -euo pipefail

KEY="${HOME}/.ssh/id_ed25519"

if [ ! -f "$KEY" ]; then
  exit 0
fi

if ssh-add -l >/dev/null 2>&1; then
  exit 0
fi

ssh-add "$KEY" </dev/null 2>/dev/null || true
