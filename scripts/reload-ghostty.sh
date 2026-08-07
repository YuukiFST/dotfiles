#!/usr/bin/env bash
# Recarrega o Ghostty para aplicar mudanças de tema sem abrir terminal novo.
set -euo pipefail

if ! command -v ghostty >/dev/null 2>&1; then
  exit 0
fi

mapfile -t pids < <(pgrep -x ghostty || true)
if ((${#pids[@]} == 0)); then
  exit 0
fi

if command -v systemctl >/dev/null 2>&1 \
  && systemctl --user is-active --quiet app-com.mitchellh.ghostty.service 2>/dev/null; then
  systemctl reload --user app-com.mitchellh.ghostty.service
  exit 0
fi

for pid in "${pids[@]}"; do
  kill -s USR2 "$pid" 2>/dev/null || true
done
