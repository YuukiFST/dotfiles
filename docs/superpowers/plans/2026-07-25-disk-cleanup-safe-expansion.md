# Disk cleanup safe expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add regenerable Gradle/Go/Cargo/uv/yarn/pnpm cleanup steps to `disk-cleanup.sh` without changing existing behavior.

**Architecture:** Reuse existing `clean_user_dir` and `clean_user_cache_cmd` helpers. Insert new calls after npm/pip and before `run_root_cleanup` in both the dotfiles script and the Nix package source so they stay in sync.

**Tech Stack:** Bash, existing notify helpers, Nix package that embeds `nix/disk-startup-notify/src/disk-cleanup.sh`.

## Global Constraints

- Improvements only: do not reorder, remove, or alter existing cleanup steps (`/tmp`, `/var/tmp`, trash, `~/.cache`, npm, pip, root cleanup).
- Keep `/tmp` and `/var/tmp` full wipe as today.
- Do not touch `~/.config`, `~/.pi`, `~/.android/avd`, `~/.cursor/projects`, or project trees.
- Do not delete entire `~/.gradle` or `~/.cargo` roots (preserve config files).
- Do not edit `disk-cleanup-root.sh`.
- No TDD / no new test frameworks; verification is `bash -n` plus a logical sync check between the two script copies.
- Commits: Conventional Commits in English; author `YuukiFST <faustoyuuki@gmail.com>` via `git-safe-commit` (already confirmed this session).

---

## File map

| File | Role |
|------|------|
| `scripts/disk-cleanup.sh` | Runnable cleanup from Super+Ctrl+N / nixos-menu |
| `nix/disk-startup-notify/src/disk-cleanup.sh` | Source embedded into Nix `disk-cleanup` package |
| Spec (read-only): `docs/superpowers/specs/2026-07-25-disk-cleanup-safe-expansion-design.md` | Requirements |

---

### Task 1: Add regenerable cache steps to `scripts/disk-cleanup.sh`

**Files:**
- Modify: `scripts/disk-cleanup.sh` (insert after `clean_user_cache_cmd "pip cache" pip cache purge`, before `run_root_cleanup || true`)

**Interfaces:**
- Consumes: existing `clean_user_dir`, `clean_user_cache_cmd`, `$HOME_DIR`
- Produces: same helpers; new cleanup calls only

- [ ] **Step 1: Insert the new block**

Replace this exact region:

```bash
clean_user_cache_cmd "npm cache" npm cache clean --force
clean_user_cache_cmd "pip cache" pip cache purge
run_root_cleanup || true
```

with:

```bash
clean_user_cache_cmd "npm cache" npm cache clean --force
clean_user_cache_cmd "pip cache" pip cache purge

# Regenerable build caches (safe; next build re-downloads)
clean_user_dir "Gradle caches" "$HOME_DIR/.gradle/caches"
clean_user_dir "Gradle daemon" "$HOME_DIR/.gradle/daemon"
clean_user_dir "Gradle tmp" "$HOME_DIR/.gradle/.tmp"
clean_user_dir "Gradle JDKs" "$HOME_DIR/.gradle/jdks"
clean_user_dir "Gradle wrapper" "$HOME_DIR/.gradle/wrapper"
clean_user_cache_cmd "Go build cache" go clean -cache
clean_user_dir "Cargo registry cache" "$HOME_DIR/.cargo/registry/cache"
clean_user_dir "Cargo registry src" "$HOME_DIR/.cargo/registry/src"
clean_user_dir "Cargo git db" "$HOME_DIR/.cargo/git/db"
clean_user_dir "Cargo git checkouts" "$HOME_DIR/.cargo/git/checkouts"
clean_user_cache_cmd "uv cache" uv cache clean
clean_user_cache_cmd "yarn cache" yarn cache clean
clean_user_cache_cmd "pnpm store" pnpm store prune

run_root_cleanup || true
```

Do not change any lines above the npm/pip block or below `run_root_cleanup`.

- [ ] **Step 2: Syntax-check**

Run:

```bash
bash -n /home/yuuki/Projects/dotfiles/scripts/disk-cleanup.sh
```

Expected: exit 0, no output.

- [ ] **Step 3: Commit**

```bash
cd /home/yuuki/Projects/dotfiles
git add scripts/disk-cleanup.sh
git-safe-commit --author "YuukiFST <faustoyuuki@gmail.com>" -m "$(cat <<'EOF'
feat(disk-cleanup): clear regenerable gradle/go/cargo/uv caches

Free large rebuildable caches without touching configs, AVDs, or pi/cursor data.

EOF
)"
```

---

### Task 2: Mirror the same steps into the Nix package source

**Files:**
- Modify: `nix/disk-startup-notify/src/disk-cleanup.sh` (same insertion point; this file uses `${HOME}` not `$HOME_DIR`)

**Interfaces:**
- Consumes: existing `clean_user_dir`, `clean_user_cache_cmd`, `${HOME}`
- Produces: package source matching the runnable script’s new steps

- [ ] **Step 1: Insert the mirrored block**

Replace this exact region:

```bash
clean_user_cache_cmd "npm cache" npm cache clean --force
clean_user_cache_cmd "pip cache" pip cache purge
run_root_cleanup || true
```

with:

```bash
clean_user_cache_cmd "npm cache" npm cache clean --force
clean_user_cache_cmd "pip cache" pip cache purge

# Regenerable build caches (safe; next build re-downloads)
clean_user_dir "Gradle caches" "${HOME}/.gradle/caches"
clean_user_dir "Gradle daemon" "${HOME}/.gradle/daemon"
clean_user_dir "Gradle tmp" "${HOME}/.gradle/.tmp"
clean_user_dir "Gradle JDKs" "${HOME}/.gradle/jdks"
clean_user_dir "Gradle wrapper" "${HOME}/.gradle/wrapper"
clean_user_cache_cmd "Go build cache" go clean -cache
clean_user_dir "Cargo registry cache" "${HOME}/.cargo/registry/cache"
clean_user_dir "Cargo registry src" "${HOME}/.cargo/registry/src"
clean_user_dir "Cargo git db" "${HOME}/.cargo/git/db"
clean_user_dir "Cargo git checkouts" "${HOME}/.cargo/git/checkouts"
clean_user_cache_cmd "uv cache" uv cache clean
clean_user_cache_cmd "yarn cache" yarn cache clean
clean_user_cache_cmd "pnpm store" pnpm store prune

run_root_cleanup || true
```

Note: use `${HOME}` here (this file does not define `HOME_DIR`).

- [ ] **Step 2: Syntax-check**

Run:

```bash
bash -n /home/yuuki/Projects/dotfiles/nix/disk-startup-notify/src/disk-cleanup.sh
```

Expected: exit 0, no output.

- [ ] **Step 3: Sync check**

Run:

```bash
cd /home/yuuki/Projects/dotfiles
# Both files must contain the same new labels:
for label in "Gradle caches" "Gradle daemon" "Gradle tmp" "Gradle JDKs" "Gradle wrapper" \
  "Go build cache" "Cargo registry cache" "Cargo registry src" "Cargo git db" \
  "Cargo git checkouts" "uv cache" "yarn cache" "pnpm store"
do
  rg -F "$label" scripts/disk-cleanup.sh nix/disk-startup-notify/src/disk-cleanup.sh >/dev/null \
    || { echo "MISSING: $label"; exit 1; }
done
echo OK
```

Expected: `OK`

- [ ] **Step 4: Commit**

```bash
cd /home/yuuki/Projects/dotfiles
git add nix/disk-startup-notify/src/disk-cleanup.sh
git-safe-commit --author "YuukiFST <faustoyuuki@gmail.com>" -m "$(cat <<'EOF'
feat(disk-cleanup): mirror regenerable cache steps in Nix source

Keep packaged disk-cleanup in sync with the dotfiles script.

EOF
)"
```

---

### Task 3: Final verification (no live destructive run)

**Files:** none (read-only checks)

- [ ] **Step 1: Confirm existing steps still present in both files**

Run:

```bash
cd /home/yuuki/Projects/dotfiles
for f in scripts/disk-cleanup.sh nix/disk-startup-notify/src/disk-cleanup.sh; do
  rg -n 'Temp files \(/tmp\)|Temp files \(/var/tmp\)|Trash"|App caches|npm cache|pip cache|run_root_cleanup' "$f"
done
```

Expected: each file shows `/tmp`, `/var/tmp`, Trash, App caches, npm, pip, and `run_root_cleanup`.

- [ ] **Step 2: Confirm out-of-scope paths are absent**

Run:

```bash
cd /home/yuuki/Projects/dotfiles
rg -n '\.pi|\.android|\.cursor|\.config/thorium|\.config/Cursor|\.config/vesktop' \
  scripts/disk-cleanup.sh nix/disk-startup-notify/src/disk-cleanup.sh \
  && echo 'FAIL: out-of-scope path referenced' && exit 1 \
  || echo 'OK: no out-of-scope paths'
```

Expected: `OK: no out-of-scope paths`

- [ ] **Step 3: Stop**

Do **not** run the cleanup live unless the user asks. After Nix rebuild (optional, user-driven), the packaged binary picks up Task 2; until then Super+Ctrl+N via `scripts/disk-cleanup.sh` already has Task 1.

---

## Spec coverage self-review

| Spec requirement | Task |
|------------------|------|
| Keep existing steps /tmp, trash, cache, npm, pip, root | Task 1–3 (unchanged + verification) |
| Add Gradle caches/daemon/.tmp/jdks/wrapper | Task 1–2 |
| Add go/cargo/uv/yarn/pnpm | Task 1–2 |
| Both script copies | Task 1 + Task 2 |
| No root script / no dry-run / no UI | Out of scope (no tasks) |
| `bash -n` verification | Task 1 Step 2, Task 2 Step 2 |
| No live destructive run during implement | Task 3 Step 3 |

No placeholders. No TDD (project rule). Home var differs intentionally: `$HOME_DIR` in scripts/, `${HOME}` in nix src.
