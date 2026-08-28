# dotfiles

Personal NixOS system config and GNU Stow dotfiles for an i3 desktop.

## Setup

**NixOS (full install):**

```sh
git clone <repo> ~/Projects/dotfiles
cd ~/Projects/dotfiles
./scripts/setup-nixos.sh
```

Copies `nix/` to `/etc/nixos`, rebuilds, then stows dotfiles.

**Dotfiles only (already on NixOS or another distro):**

```sh
./scripts/setup-dotfiles.sh
```

## NixOS

System config lives in `nix/`. Edit `nix/configuration.nix`, then rebuild:

- Polybar: Thorium and Nix icons (rebuild, disk cleanup, updates)
- or `./scripts/nixos-rebuild.sh`

Disk cleanup and login notifications are built into this repo under `nix/disk-startup-notify/` (no extra clone needed).

## Stow packages

`ai-usagebar`, `doom`, `fish`, `ghostty`, `gitconfig`, `herdr`, `i3`, `nvim`, `picom`, `polybar`, `rofi`, `ssh`, `tmux`, `zsh`

Each package mirrors `$HOME` layout (e.g. `i3/.config/i3/` → `~/.config/i3/`).

## Stack

i3, Ghostty, Thorium, Doom Emacs, Neovim, Rofi, Polybar, Picom

## Shortcuts

| Key | Action |
|-----|--------|
| `Super+Return` | Terminal |
| `Super+Space` | App launcher |
| `Super+K` | Hotkey list |
| `F1` | Emacs |

Full list: `i3/.config/i3/hotkeys.txt` or `Super+K`.

## Scripts

Utility scripts in `scripts/` — themes, capture, clipboard, pi harness, Thorium incognito tools.
