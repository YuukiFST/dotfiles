#!/usr/bin/env bash
# Omarchy: Super+O — pop window (float, resize, pin)
set -euo pipefail

mark="omarchy_pop"
has_mark=$(i3-msg -t get_tree | python3 -c "
import json, sys
mark = sys.argv[1]
tree = json.load(sys.stdin)

def walk(node):
    if node.get('focused'):
        return mark in (node.get('marks') or [])
    for child in node.get('nodes', []) + node.get('floating_nodes', []):
        if walk(child):
            return True
    return False

print('yes' if walk(tree) else 'no')
" "$mark")

if [[ "$has_mark" == yes ]]; then
  i3-msg "[con_mark=$mark] floating disable, sticky disable, unmark $mark, layout toggle split"
else
  i3-msg "mark --add $mark, floating enable, sticky enable, resize set 1300 900, move position center"
fi
