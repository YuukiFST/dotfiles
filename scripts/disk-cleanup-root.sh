#!/usr/bin/env bash
# Root-only cleanup steps. Invoked via passwordless sudo (disk-cleanup-root).
set -euo pipefail

NIX_COLLECT_GARBAGE="${NIX_COLLECT_GARBAGE:-/run/current-system/sw/bin/nix-collect-garbage}"
NIX_STORE="${NIX_STORE:-/run/current-system/sw/bin/nix-store}"
JOURNALCTL="${JOURNALCTL:-/run/current-system/sw/bin/journalctl}"

"$NIX_COLLECT_GARBAGE" -d
"$NIX_STORE" --optimise
"$JOURNALCTL" --vacuum-time=7d
