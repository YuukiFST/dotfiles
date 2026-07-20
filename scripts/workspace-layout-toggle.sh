#!/usr/bin/env bash
# Omarchy: Super+L — toggle workspace layout (dwindle ↔ tabbed; i3 não tem scrolling)
set -euo pipefail

layout=$(i3-msg -t get_tree | python3 -c "
import json, sys
tree = json.load(sys.stdin)

def walk(node):
    if node.get('type') == 'workspace' and node.get('focused'):
        return node.get('layout')
    for child in node.get('nodes', []) + node.get('floating_nodes', []):
        found = walk(child)
        if found:
            return found

print(walk(tree) or 'splith')
")

if [[ "$layout" == "tabbed" ]]; then
  i3-msg layout splith
  notify-send -u low "Layout: splith"
else
  i3-msg layout tabbed
  notify-send -u low "Layout: tabbed"
fi
