#!/usr/bin/env bash
# Super+Ctrl+N — Thorium tools + NixOS admin.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
TERM_CMD="${TERMINAL:-ghostty}"
COPY_TABS="$DOTFILES/scripts/copy-incognito-tabs.sh"
OPEN_LINKS="$DOTFILES/scripts/open-clipboard-links-incognito.py"
DISK_NOTIFY="$DOTFILES/scripts/disk-startup-notify.sh"
DISK_CLEANUP="$DOTFILES/scripts/disk-cleanup.sh"

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

choice=$(printf '%s\n' \
  "Thorium · Copy Incognito Tab URLs" \
  "Thorium · Open Clipboard Links in Incognito" \
  "────────────" \
  "NixOS · Apply configuration (switch)" \
  "NixOS · Apply + update flake" \
  "NixOS · Build only (no switch)" \
  "NixOS · Disk usage (notification)" \
  "NixOS · Clean disk now" \
  "Cancel" | rofi -dmenu -i -p "Tools") || exit 0

case "${choice:-Cancel}" in
  "Thorium · Copy Incognito Tab URLs")
    "$COPY_TABS"
    ;;
  "Thorium · Open Clipboard Links in Incognito")
    python3 "$OPEN_LINKS"
    ;;
  "NixOS · Apply configuration (switch)")
    notify-send -a nixos "NixOS" "Opening rebuild…" 2>/dev/null || true
    run_rebuild
    ;;
  "NixOS · Apply + update flake")
    notify-send -a nixos "NixOS" "Updating flake + rebuild…" 2>/dev/null || true
    run_rebuild --pull
    ;;
  "NixOS · Build only (no switch)")
    notify-send -a nixos "NixOS" "Test build…" 2>/dev/null || true
    run_rebuild --build
    ;;
  "NixOS · Disk usage (notification)")
    "$DISK_NOTIFY" || true
    ;;
  "NixOS · Clean disk now")
    run_disk_cleanup
    ;;
  *) ;;
esac
