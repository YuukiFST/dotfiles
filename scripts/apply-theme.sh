#!/usr/bin/env bash
# Aplica um tema (wallpaper, GTK, btop, i3, polybar, rofi, ghostty, dunst, neovim).
# Uso: apply-theme.sh [nome] [wallpaper]
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/Projects/dotfiles}"
STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles"
THEME="${1:-}"
WALLPAPER="${2:-}"
PREVIOUS_THEME=""

notify_theme() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "dotfiles-theme" "$@"
  fi
}

on_error() {
  local code=$?
  notify_theme -u critical "Falha ao aplicar tema" "${THEME:-desconhecido} (código $code)"
  echo "apply-theme: falhou (código $code)" >&2
  exit "$code"
}
trap on_error ERR

if [[ -z "$THEME" ]]; then
  THEME="$(cat "$STATE_DIR/current-theme" 2>/dev/null || echo ash)"
fi

THEME_DIR="$DOTFILES/themes/$THEME"
if [[ ! -d "$THEME_DIR" ]]; then
  notify_theme -u critical "Tema não encontrado" "$THEME"
  echo "Tema não encontrado: $THEME ($THEME_DIR)" >&2
  trap - ERR
  exit 1
fi

PREVIOUS_THEME="$(cat "$STATE_DIR/current-theme" 2>/dev/null || true)"
mkdir -p "$STATE_DIR"
echo "$THEME" >"$STATE_DIR/current-theme"

export DISPLAY="${DISPLAY:-:0}"

python3 "$DOTFILES/scripts/theme-ensure-assets.py" "$THEME_DIR" >/dev/null

THEME_WP_STATE="$STATE_DIR/wallpaper-$THEME"

# Wallpaper: explícito > salvo deste tema > primeiro do tema
if [[ -z "$WALLPAPER" && -f "$THEME_WP_STATE" ]]; then
  saved="$(cat "$THEME_WP_STATE")"
  if [[ -f "$saved" ]]; then
    WALLPAPER="$saved"
  fi
fi

if [[ -z "$WALLPAPER" && -d "$THEME_DIR/backgrounds" ]]; then
  WALLPAPER="$(find "$THEME_DIR/backgrounds" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) | sort | head -1)"
fi

if [[ -n "${WALLPAPER:-}" && -f "${WALLPAPER:-}" ]]; then
  "$DOTFILES/scripts/set-wallpaper.sh" "$WALLPAPER"
  echo "$WALLPAPER" >"$THEME_WP_STATE"
fi

if command -v gsettings >/dev/null 2>&1 && [[ -f "$THEME_DIR/icons.theme" ]]; then
  gtk_theme="$(tr -d '[:space:]' <"$THEME_DIR/icons.theme")"
  gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme "$gtk_theme" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
fi

if [[ -f "$THEME_DIR/btop.theme" ]]; then
  mkdir -p "$HOME/.config/btop/themes"
  cp -f "$THEME_DIR/btop.theme" "$HOME/.config/btop/themes/${THEME}.theme"
  if [[ -f "$HOME/.config/btop/btop.conf" ]]; then
    if grep -q '^theme = ' "$HOME/.config/btop/btop.conf"; then
      sed -i "s/^theme = .*/theme = $THEME/" "$HOME/.config/btop/btop.conf"
    else
      printf '\ntheme = %s\n' "$THEME" >>"$HOME/.config/btop/btop.conf"
    fi
  fi
fi

if [[ -f "$THEME_DIR/aether.lua" ]]; then
  mkdir -p "$HOME/.config/nvim/lua/themes/colors"
  cp -f "$THEME_DIR/aether.lua" "$HOME/.config/nvim/lua/themes/colors/${THEME}.lua"
fi

if [[ -f "$THEME_DIR/neovim.lua" ]]; then
  mkdir -p "$HOME/.config/nvim/lua/themes"
  cp -f "$THEME_DIR/neovim.lua" "$HOME/.config/nvim/lua/themes/${THEME}.lua"
fi

if [[ -f "$DOTFILES/scripts/theme-apply-desktop.sh" && -f "$THEME_DIR/colors.toml" ]]; then
  python3 "$DOTFILES/scripts/theme-apply-desktop.sh" "$THEME_DIR" "$DOTFILES"
fi

if [[ -f "$DOTFILES/scripts/theme-apply-system.py" && -f "$THEME_DIR/colors.toml" ]]; then
  python3 "$DOTFILES/scripts/theme-apply-system.py" "$THEME_DIR" "$DOTFILES"
fi

sleep 0.1
"$DOTFILES/scripts/reload-ghostty.sh" || true

if [[ -x "$DOTFILES/scripts/start-picom.sh" ]]; then
  "$DOTFILES/scripts/start-picom.sh" >/dev/null 2>&1 || true
fi

POLYBAR_LAUNCH="${XDG_CONFIG_HOME:-$HOME/.config}/polybar/launch.sh"
if command -v polybar-msg >/dev/null 2>&1; then
  polybar-msg cmd restart >/dev/null 2>&1 || "$POLYBAR_LAUNCH" >/dev/null 2>&1 &
else
  [[ -x "$POLYBAR_LAUNCH" ]] && "$POLYBAR_LAUNCH" >/dev/null 2>&1 &
fi

if command -v i3-msg >/dev/null 2>&1; then
  i3-msg reload >/dev/null 2>&1 || true
  # Garante que barra e bordas pegam o bloco de cores novo.
  sleep 0.15
  i3-msg reload >/dev/null 2>&1 || true
fi

if command -v dunst >/dev/null 2>&1; then
  pkill dunst 2>/dev/null || true
  dunst &
  sleep 0.2
fi

trap - ERR

wp_label="sem wallpaper"
if [[ -n "${WALLPAPER:-}" && -f "${WALLPAPER:-}" ]]; then
  wp_label="$(basename "$WALLPAPER")"
fi

status="aplicado"
if [[ -n "$PREVIOUS_THEME" && "$PREVIOUS_THEME" == "$THEME" ]]; then
  status="reaplicado"
fi

echo "apply-theme: $status '$THEME' (wallpaper: $wp_label)"
