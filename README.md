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

- `Super+Ctrl+N` → Tools menu (NixOS rebuild, disk cleanup, Thorium scripts)
- or `./scripts/nixos-rebuild.sh`

## Stow packages

`doom`, `fish`, `ghostty`, `gitconfig`, `herdr`, `i3`, `nvim`, `picom`, `polybar`, `rofi`, `ssh`, `tmux`, `zsh`

Each package mirrors `$HOME` layout (e.g. `i3/.config/i3/` → `~/.config/i3/`).

## Stack

i3, Ghostty, Thorium, Doom Emacs, Neovim, Rofi, Polybar, Picom

## Shortcuts

| Key | Action |
|-----|--------|
| `Super+Return` | Terminal |
| `Super+Space` | App launcher |
| `Super+Ctrl+N` | Tools (Thorium + NixOS) |
| `Super+K` | Hotkey list |
| `F1` | Emacs |

Full list: `i3/.config/i3/hotkeys.txt` or `Super+K`.

## Scripts

Utility scripts in `scripts/` — themes, capture, clipboard, pi harness, Thorium incognito tools.
