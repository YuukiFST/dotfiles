#!/usr/bin/env bash
# Omarchy: Ctrl+Alt+Del — close all windows
set -euo pipefail
i3-msg '[class=".*"] kill' >/dev/null
