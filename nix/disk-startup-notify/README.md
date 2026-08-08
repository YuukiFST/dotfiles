# disk-startup-notify

Disk usage notification on graphical login with optional safe cleanup.

**Source of truth:** `nix/disk-startup-notify/` inside this dotfiles repo.
There is no separate repository required for NixOS install.

## Features

- Dunst notification on login with current disk usage
- Rofi menu to start cleanup or dismiss
- Per-step progress notifications (what is being cleaned, skipped, or empty)
- Final summary with before/after usage and space freed

## NixOS module

Enabled in `nix/configuration.nix`:

```nix
services.disk-startup-notify = {
  enable = true;
  cleanupUser = "your-user";
};
```

Add to i3 startup (`i3/.config/i3/config`):

```
exec --no-startup-id disk-startup-notify
```

After changes, rebuild:

```bash
./scripts/nixos-rebuild.sh
```

## Scripts layout

| Path | Role |
|------|------|
| `nix/disk-startup-notify/src/*.sh` | Canonical implementation (embedded in Nix packages) |
| `scripts/disk-*.sh` | Thin wrappers: use system packages when available, else source tree |

## Sudo

System cleanup (Nix garbage collection, store optimise, journal vacuum) runs via a single passwordless sudo rule for `disk-cleanup-root`.
