#!/usr/bin/env bash
# Root-only cleanup steps. Invoked via passwordless sudo (disk-cleanup-root).
set -euo pipefail

NIX_COLLECT_GARBAGE="${NIX_COLLECT_GARBAGE:-nix-collect-garbage}"
NIX_STORE="${NIX_STORE:-nix-store}"
JOURNALCTL="${JOURNALCTL:-journalctl}"

"$NIX_COLLECT_GARBAGE" -d
"$NIX_STORE" --optimise
"$JOURNALCTL" --vacuum-time=7d
