#!/usr/bin/env bash
# Super+Ctrl+N — Thorium tools + NixOS admin (two-level menu: pick category,
# then Right/Enter opens the submenu; Left returns to the parent menu).
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
TERM_CMD="${TERMINAL:-ghostty}"
COPY_TABS="$DOTFILES/scripts/copy-incognito-tabs.sh"
OPEN_LINKS="$DOTFILES/scripts/open-clipboard-links-incognito.py"
DISK_NOTIFY="$DOTFILES/scripts/disk-startup-notify.sh"
DISK_CLEANUP="$DOTFILES/scripts/disk-cleanup.sh"

ACCEPT="Right,Control+j,Control+m,Return,KP_Enter"

# Show a rofi menu from stdin, return the selection (empty on Esc/cancel).
# Rofi 2.0 binds Right to kb-move-char-forward by default; unset it so Right
# can accept the highlighted row and open submenus.
pick() {
  local prompt="$1"
  rofi -dmenu -i -p "$prompt" \
    -kb-move-char-forward "" \
    -kb-accept-entry "$ACCEPT"
}

# Submenu: Right/Enter accepts; Left cancels and returns empty (go back).
pick_submenu() {
  local prompt="$1"
  rofi -dmenu -i -p "$prompt" \
    -kb-move-char-forward "" \
    -kb-move-char-back "" \
    -kb-cancel "Escape,Control+g,Control+bracketleft,Left" \
    -kb-accept-entry "$ACCEPT"
}

run_rebuild() {
  local script="$DOTFILES/scripts/nixos-rebuild.sh"
  "$TERM_CMD" --working-directory="$DOTFILES/nix" -e bash -c "
    $(printf '%q ' "$script" "$@")
    status=\$?
    echo
    if (( status == 0 )); then
      notify-send -a nixos 'NixOS' 'Rebuild complete' 2>/dev/null || true
    else
      notify-send -a nixos -u critical 'NixOS' \"Rebuild failed (exit \$status)\" 2>/dev/null || true
    fi
    read -r -p 'Press Enter to close...' _
  "
}

run_update_all() {
  "$TERM_CMD" --working-directory="$DOTFILES/nix" -e bash -c "
    $DOTFILES/scripts/nixos-update-all.sh
    status=\$?
    echo
    if (( status == 0 )); then
      notify-send -a nixos 'NixOS' 'Full update OK' 2>/dev/null || true
    else
      notify-send -a nixos -u critical 'NixOS' \"Update failed (exit \$status)\" 2>/dev/null || true
    fi
    read -r -p 'Press Enter to close...' _
  "
}

run_disk_cleanup() {
  local confirm
  confirm=$(
    printf '%s\n' "No, keep files" "Yes, clean now" |
      rofi -dmenu -i -p "Disk cleanup" \
        -mesg "Removes temp files, trash, caches (~/.cache), npm/pip, and old Nix/logs data.\nDoes not touch ~/.config, ~/Projects, or ~/.pi." \
        -select "No, keep files" 2>/dev/null || true
  )

  case "${confirm:-}" in
    "Yes, clean now")
      notify-send -a disk-startup-notify "Disk" "Starting cleanup…" 2>/dev/null || true
      "$DISK_CLEANUP" || true
      ;;
  esac
}

# --- Level 1: categories -----------------------------------------------------
while true; do
  category="$(printf '%s\n' "Thorium ▶" "NixOS ▶" | pick "Tools")" || break

  case "$category" in
    "Thorium ▶")
      action="$(printf '%s\n' \
        "Copy Incognito Tab URLs" \
        "Open Clipboard Links in Incognito" | pick_submenu "Thorium")" || true
      if [[ -z "${action:-}" ]]; then
        continue
      fi
      case "$action" in
        "Copy Incognito Tab URLs")
          "$COPY_TABS"
          ;;
        "Open Clipboard Links in Incognito")
          python3 "$OPEN_LINKS"
          ;;
      esac
      break
      ;;
    "NixOS ▶")
      action="$(printf '%s\n' \
        "Apply configuration (switch)" \
        "Apply + update flake" \
        "Update all (herdr + nixpkgs + rebuild)" \
        "Build only (no switch)" \
        "Disk usage (notification)" \
        "Clean disk now" | pick_submenu "NixOS")" || true
      if [[ -z "${action:-}" ]]; then
        continue
      fi
      case "$action" in
        "Apply configuration (switch)")
          notify-send -a nixos "NixOS" "Opening rebuild…" 2>/dev/null || true
          run_rebuild
          ;;
        "Apply + update flake")
          notify-send -a nixos "NixOS" "Updating flake + rebuild…" 2>/dev/null || true
          run_rebuild --pull
          ;;
        "Update all (herdr + nixpkgs + rebuild)")
          notify-send -a nixos "NixOS" "Full update starting…" 2>/dev/null || true
          run_update_all
          ;;
        "Build only (no switch)")
          notify-send -a nixos "NixOS" "Test build…" 2>/dev/null || true
          run_rebuild --build
          ;;
        "Disk usage (notification)")
          "$DISK_NOTIFY" || true
          ;;
        "Clean disk now")
          run_disk_cleanup
          ;;
      esac
      break
      ;;
    *) break ;;
  esac
done