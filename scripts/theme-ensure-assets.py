#!/usr/bin/env python3
"""Generate per-theme assets (wallpaper, nvim colors) from colors.toml."""
from __future__ import annotations

import sys
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPTS))

from theme_lib import aether_colors_lua, generate_wallpaper, parse_colors

DOTFILES = Path(__file__).resolve().parents[1]
THEMES_DIR = DOTFILES / "themes"
NVIM_COLORS_DIR = DOTFILES / "nvim/.config/nvim/lua/themes/colors"
IMAGE_SUFFIXES = {".jpg", ".jpeg", ".png", ".webp"}


def has_wallpaper(theme_dir: Path) -> bool:
    bg_dir = theme_dir / "backgrounds"
    if not bg_dir.is_dir():
        return False
    return any(p.suffix.lower() in IMAGE_SUFFIXES for p in bg_dir.iterdir() if p.is_file())


def ensure_theme(theme_dir: Path) -> None:
    colors_path = theme_dir / "colors.toml"
    if not colors_path.is_file():
        return

    colors = parse_colors(colors_path)
    required = ["background", "foreground", "accent", *[f"color{i}" for i in range(16)]]
    missing = [key for key in required if key not in colors]
    if missing:
        raise SystemExit(f"{colors_path}: missing {', '.join(missing)}")

    (theme_dir / "aether.lua").write_text(aether_colors_lua(colors))
    NVIM_COLORS_DIR.mkdir(parents=True, exist_ok=True)
    (NVIM_COLORS_DIR / f"{theme_dir.name}.lua").write_text(aether_colors_lua(colors))

    if not has_wallpaper(theme_dir):
        wallpaper = theme_dir / "backgrounds" / "wallpaper.png"
        generate_wallpaper(wallpaper, colors["background"], colors["accent"])
        print(f"  wallpaper: {wallpaper.relative_to(DOTFILES)}")


def main() -> None:
    if len(sys.argv) > 1:
        targets = [Path(arg).resolve() for arg in sys.argv[1:]]
    else:
        targets = sorted(p for p in THEMES_DIR.iterdir() if p.is_dir())

    for theme_dir in targets:
        if not theme_dir.is_dir():
            raise SystemExit(f"Not a theme directory: {theme_dir}")
        ensure_theme(theme_dir)
        print(f"  assets ok: {theme_dir.name}")


if __name__ == "__main__":
    main()
