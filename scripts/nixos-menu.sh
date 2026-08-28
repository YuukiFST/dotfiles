#!/usr/bin/env bash
# Polybar Nix icon — submenu: rebuilds, disk, updates.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
TERM_CMD="${TERMINAL:-ghostty}"
# shellcheck source=lib/polybar-rofi-card.sh
source "$DOTFILES/scripts/lib/polybar-rofi-card.sh"
DISK_NOTIFY="$(command -v disk-startup-notify 2>/dev/null || echo "$DOTFILES/scripts/disk-startup-notify.sh")"
DISK_CLEANUP="$(command -v disk-cleanup 2>/dev/null || echo "$DOTFILES/scripts/disk-cleanup.sh")"

pick_submenu() {
  polybar_rofi_card 6 -p "$1"
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

run_script() {
  local script="$1"
  local label="${2:-Update}"
  local workdir="${3:-$DOTFILES}"
  "$TERM_CMD" --working-directory="$workdir" -e bash -c "
    $(printf '%q' "$script")
    status=\$?
    echo
    if (( status == 0 )); then
      notify-send -a nixos '$label' 'OK' 2>/dev/null || true
    else
      notify-send -a nixos -u critical '$label' \"Failed (exit \$status)\" 2>/dev/null || true
    fi
    read -r -p 'Press Enter to close...' _
  "
}

run_disk_cleanup() {
  local confirm
  confirm=$(
    printf '%s\n' "No, keep files" "Yes, clean now" |
      polybar_rofi_card_mesg 2 -p "Disk cleanup" \
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

action="$(printf '%s\n' \
  "Apply configuration (switch)" \
  "Apply + update flake" \
  "Build only (no switch)" \
  "Disk usage (notification)" \
  "Clean disk now" \
  "Check for updates" | pick_submenu "NixOS")" || true

[[ -n "${action:-}" ]] || exit 0

case "$action" in
  "Apply configuration (switch)")
    notify-send -a nixos "NixOS" "Opening rebuild…" 2>/dev/null || true
    run_rebuild
    ;;
  "Apply + update flake")
    notify-send -a nixos "NixOS" "Updating flake + rebuild…" 2>/dev/null || true
    run_rebuild --pull
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
  "Check for updates")
    notify-send -a nixos "Updates" "Checking Pi, extensions, herdr, ghostty…" 2>/dev/null || true
    run_script "$DOTFILES/scripts/update.sh" "Updates" "$DOTFILES"
    ;;
esac
