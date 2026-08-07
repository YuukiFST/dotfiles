#!/usr/bin/env python3
"""Apply GTK, browser, and live app theming from an Omarchy theme directory."""
from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPTS))

from theme_lib import ensure_theme_extras, hex_rgb, parse_colors


def run(cmd: list[str]) -> None:
    subprocess.run(cmd, check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def apply_gsettings() -> None:
    if not shutil.which("gsettings"):
        return
    run(["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", "Adwaita-dark"])
    run(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", "prefer-dark"])


def install_gtk_css(gtk_css: Path, home: Path) -> None:
    for sub in ("gtk-3.0", "gtk-4.0"):
        target_dir = home / ".config" / sub
        target_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(gtk_css, target_dir / "gtk.css")


def browser_hex(chromium_theme: Path) -> str:
    if chromium_theme.is_file():
        raw = chromium_theme.read_text().strip()
        if "," in raw and not raw.startswith("#"):
            parts = [int(part.strip()) for part in raw.split(",")[:3]]
            return "#%02x%02x%02x" % tuple(parts)
        if raw.startswith("#"):
            return raw
    return "#1c2027"


def apply_browser_color(chromium_theme: Path) -> None:
    hex_color = browser_hex(chromium_theme)
    payload = json.dumps(
        {"BrowserThemeColor": hex_color, "BrowserColorScheme": "device"},
        separators=(",", ":"),
    )
    home = Path.home()
    policy_dirs = [
        home / ".config/thorium/policies/managed",
        home / ".config/chromium/policies/managed",
        Path("/etc/chromium/policies/managed"),
        Path("/etc/thorium/policies/managed"),
    ]
    for policy_dir in policy_dirs:
        try:
            policy_dir.mkdir(parents=True, exist_ok=True)
            (policy_dir / "color.json").write_text(payload + "\n")
        except OSError:
            continue

    for browser in ("thorium", "chromium", "google-chrome-stable", "google-chrome"):
        if shutil.which(browser):
            run([browser, "--refresh-platform-policy", "--no-startup-window"])


def herdr_theme_block(colors: dict[str, str]) -> str:
    return f"""[theme]
name = "terminal"
auto_switch = false

[theme.custom]
panel_bg = "{colors['background']}"
accent = "{colors['accent']}"
red = "{colors['color1']}"
green = "{colors['color2']}"
yellow = "{colors['color3']}\""""


def patch_herdr_theme(config_path: Path, colors: dict[str, str]) -> None:
    if not config_path.is_file():
        return
    lines = config_path.read_text().splitlines()
    block = herdr_theme_block(colors)
    out: list[str] = []
    i = 0
    replaced = False
    while i < len(lines):
        if lines[i].strip() == "[theme]":
            while i < len(lines):
                i += 1
                if i >= len(lines):
                    break
                section = lines[i].strip()
                if section.startswith("[") and not section.startswith("[theme"):
                    break
            out.append(block)
            replaced = True
            continue
        out.append(lines[i])
        i += 1
    if not replaced:
        if out and out[-1].strip():
            out.append("")
        out.append(block)
    config_path.write_text("\n".join(out).rstrip() + "\n")


def apply_herdr_theme(colors: dict[str, str], dotfiles: Path) -> None:
    paths = {
        Path.home() / ".config/herdr/config.toml",
        dotfiles / "herdr/.config/herdr/config.toml",
    }
    for path in paths:
        patch_herdr_theme(path, colors)
    if shutil.which("herdr"):
        run(["herdr", "server", "reload-config"])


def signal_nvim_revision(state_dir: Path) -> None:
    state_dir.mkdir(parents=True, exist_ok=True)
    (state_dir / "theme-revision").write_text(str(os.getpid()) + "\n")
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    if not runtime or not shutil.which("nvim"):
        return
    nvim_dir = Path(runtime) / "nvim"
    if not nvim_dir.is_dir():
        return
    expr = 'luaeval(\'require("me.theme").apply()\')'
    for sock in nvim_dir.iterdir():
        if sock.is_socket():
            run(["nvim", "--server", str(sock), "--remote-expr", expr])


def main() -> None:
    if len(sys.argv) < 2:
        raise SystemExit(f"usage: {sys.argv[0]} <theme-dir>")

    theme_dir = Path(sys.argv[1]).resolve()
    if not theme_dir.is_dir():
        raise SystemExit(f"Not a theme directory: {theme_dir}")

    ensure_theme_extras(theme_dir)
    colors_path = theme_dir / "colors.toml"
    colors = parse_colors(colors_path) if colors_path.is_file() else {}
    gtk_css = theme_dir / "gtk.css"
    chromium_theme = theme_dir / "chromium.theme"
    if gtk_css.is_file():
        install_gtk_css(gtk_css, Path.home())
        apply_gsettings()

    apply_browser_color(chromium_theme)
    if colors:
        dotfiles = Path(sys.argv[2]).resolve() if len(sys.argv) > 2 else theme_dir.parents[1]
        apply_herdr_theme(colors, dotfiles)
    state_dir = Path(
        os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))
    ) / "dotfiles"
    signal_nvim_revision(state_dir)
    print(f"Applied system theme extras: {theme_dir.name}")


if __name__ == "__main__":
    main()
