# Disk cleanup safe expansion

Date: 2026-07-25

## Problem

`disk-cleanup.sh` (Super+Ctrl+N → Clean disk) already clears `/tmp`, `/var/tmp`, trash, `~/.cache`, npm/pip caches, and runs `disk-cleanup-root` (Nix GC + store optimise + journal vacuum).

On this machine the biggest regenerable user waste it still misses is `~/.gradle` (~5.3G), plus optional go/cargo/uv/yarn/pnpm caches when present.

Goal: free more disk with additive safe steps only — no behavior regressions on existing steps.

## Constraints

- Improvements only; keep every existing cleanup step and UX (lock, progress notifies, summary).
- Keep `/tmp` and `/var/tmp` full wipe as today.
- Do not touch `~/.config`, `~/.pi`, `~/.android/avd`, `~/.cursor/projects`, or project source trees.
- First post-clean Android/Kotlin build may be slower; that is accepted.
- Edit both the runnable script and the Nix package source so they stay in sync.

## Approach (chosen)

Expand the existing script with new `clean_user_dir` / `clean_user_cache_cmd` calls.

Rejected alternatives:

- Dry-run mode: extra code, low value for a manual hotkey.
- Per-target checkbox menu: overkill for a single cleanup action.

## Architecture

Two files must receive the same logical step list:

1. `scripts/disk-cleanup.sh` — used from dotfiles / nixos-menu without rebuild.
2. `nix/disk-startup-notify/src/disk-cleanup.sh` — packaged into the Nix `disk-cleanup` binary.

`disk-cleanup-root.sh` is unchanged.

Helpers already present (`clean_user_dir`, `clean_user_cache_cmd`) cover new targets; no new abstractions.

## New cleanup steps (additive, after existing user steps, before `run_root_cleanup`)

Order after current npm/pip:

1. Gradle regenerable dirs (each via `clean_user_dir`, skip if missing):
   - `$HOME/.gradle/caches`
   - `$HOME/.gradle/daemon`
   - `$HOME/.gradle/.tmp`
   - `$HOME/.gradle/jdks`
   - `$HOME/.gradle/wrapper`
2. Go: `clean_user_cache_cmd` with `go clean -cache` if `go` exists.
3. Cargo regenerable dirs (via `clean_user_dir`, skip if missing):
   - `$HOME/.cargo/registry/cache`
   - `$HOME/.cargo/registry/src`
   - `$HOME/.cargo/git/db`
   - `$HOME/.cargo/git/checkouts`
4. uv: `clean_user_cache_cmd` with `uv cache clean` if `uv` exists.
5. yarn: `clean_user_cache_cmd` with `yarn cache clean` if `yarn` exists.
6. pnpm: `clean_user_cache_cmd` with `pnpm store prune` if `pnpm` exists.

Do not delete entire `~/.gradle` or `~/.cargo` roots (keeps config files such as `gradle.properties` / `config.toml`).

## Explicit non-goals

- Browser / Electron / Cursor / Vesktop / Thorium config or cache under `~/.config`.
- `~/.pi/agent` (extensions, sessions, node_modules).
- Android AVDs under `~/.android/avd`.
- Changing `/tmp` policy, journal retention, or Nix GC flags.
- Dry-run, Baobab integration, or a multi-select cleanup UI.

## Error handling

Reuse existing patterns: missing dirs/commands are no-ops; failed cache commands notify "Skipped" and continue; root cleanup failure does not abort user cleanup.

## Testing

1. `bash -n` on both edited scripts.
2. Diff the new step blocks between `scripts/` and `nix/.../src/` — they must match logically.
3. Manual dry check: confirm each new path either exists and is listed in the script, or the step is guarded by existence/`command -v` (already true for helpers).
4. Optional live run only when the user triggers Clean disk; do not auto-run destructive cleanup during implementation.

## Success criteria

- Existing steps unchanged in order and behavior.
- New regenerable targets added as above in both script copies.
- `bash -n` passes on both files.
- No edits to `disk-cleanup-root`, hotkeys, or unrelated dotfiles.
