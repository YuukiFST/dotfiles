#!/usr/bin/env bash
# Toggle opacity on the focused window (opaque ⟷ default transparency).
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
I3_MSG="${I3_MSG:-/run/current-system/sw/bin/i3-msg}"
PYTHON3="${PYTHON3:-/run/current-system/sw/bin/python3}"
XPROP="${XPROP:-/run/current-system/sw/bin/xprop}"
PICOM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/picom"
PICOM_CONF="$PICOM_DIR/picom.conf"
STATE_FILE="$PICOM_DIR/opaque-ghostty.txt"
START_PICOM="$DOTFILES/scripts/start-picom.sh"

read -r winid class title < <("$I3_MSG" -t get_tree | "$PYTHON3" -c "
import json, sys

tree = json.load(sys.stdin)

def walk(node):
    if node.get('focused'):
        props = node.get('window_properties', {})
        return (
            node.get('window') or '',
            props.get('class', ''),
            (node.get('name') or '').replace('\n', ' '),
        )
    for child in node.get('nodes', []) + node.get('floating_nodes', []):
        found = walk(child)
        if found and found[0]:
            return found
    return ('', '', '')

winid, cls, title = walk(tree)
print(winid, cls, title)
")

[[ -n "$winid" && "$winid" != "None" ]] || exit 0

if [[ "$class" == "com.mitchellh.ghostty" ]]; then
  [[ -n "$title" ]] || exit 0

  mkdir -p "$PICOM_DIR"
  touch "$STATE_FILE"

  if grep -Fxq "$title" "$STATE_FILE"; then
    grep -Fxv "$title" "$STATE_FILE" > "${STATE_FILE}.tmp" || true
    mv "${STATE_FILE}.tmp" "$STATE_FILE"
  else
    printf '%s\n' "$title" >> "$STATE_FILE"
  fi

  "$PYTHON3" - "$STATE_FILE" "$PICOM_CONF" <<'PY'
import pathlib
import re
import sys

state_path = pathlib.Path(sys.argv[1])
config_path = pathlib.Path(sys.argv[2])
titles = [line.strip() for line in state_path.read_text().splitlines() if line.strip()]

rules = []
for title in titles:
    escaped = title.replace("\\", "\\\\").replace("'", "\\'")
    rules.append(
        f"  {{ match = \"class_g = 'com.mitchellh.ghostty' && name = '{escaped}'\"; opacity = 1.0; }},"
    )

block = "\n".join(rules)
config = config_path.read_text()
pattern = r"(# BEGIN OPAQUE_GHOSTTY\n).*?(# END OPAQUE_GHOSTTY)"
replacement = rf"\1{block}\n  \2" if block else r"\1\2"
updated, count = re.subn(pattern, replacement, config, count=1, flags=re.S)
if count != 1:
    raise SystemExit("picom.conf markers not found")

config_path.write_text(updated)
PY

  if [[ -x "$START_PICOM" ]]; then
    "$START_PICOM" >/dev/null 2>&1 || true
  fi
  exit 0
fi

hex_id=$(printf '0x%x' "$winid")

if "$XPROP" -id "$hex_id" _NET_WM_WINDOW_OPACITY 2>/dev/null | grep -q 'not found'; then
  "$XPROP" -id "$hex_id" -f _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY 0xffffffff
else
  "$XPROP" -id "$hex_id" -remove _NET_WM_WINDOW_OPACITY
fi
