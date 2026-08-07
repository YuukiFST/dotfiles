#!/usr/bin/env python3
"""Shared helpers for Omarchy theme assets."""
from __future__ import annotations

import re
import struct
import urllib.error
import urllib.request
import zlib
from pathlib import Path

THEME_REPOS: dict[str, tuple[str, str]] = {
    "ash": ("bjarneo/omarchy-ash-theme", "main"),
    "batou": ("HANCORE-linux/omarchy-batou-theme", "main"),
    "black-arch": ("HANCORE-linux/omarchy-black-arch-theme", "main"),
    "hinterlands": ("HANCORE-linux/omarchy-hinterlands-theme", "main"),
    "latchdark": ("HANCORE-linux/omarchy-latchdark-theme", "main"),
    "solitude": ("HANCORE-linux/omarchy-solitude-theme", "main"),
    "event-horizon": ("oldjobobo/omarchy-event-horizon-theme", "master"),
    "mac-transparent": ("notzeman/Omarchy-Mac-Transparent-theme", "main"),
    "sakura": ("bjarneo/omarchy-sakura-theme", "main"),
    "azure-glow": ("Hydradevx/omarchy-azure-glow-theme", "main"),
    "anonymous": ("j4v3l/omarchy-anonymous-theme", "main"),
    "saga": ("HANCORE-linux/omarchy-saga-theme", "main"),
    "oxford": ("HANCORE-linux/omarchy-oxford-theme", "main"),
    "kanso": ("HANCORE-linux/omarchy-kanso-theme", "main"),
    "night-owl": ("janhesters/omarchy-night-owl-theme", "master"),
}

GTK_RULES = Path(__file__).resolve().parent / "data" / "gtk-rules.css"


def parse_colors(path: Path) -> dict[str, str]:
    colors: dict[str, str] = {}
    for line in path.read_text().splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        match = re.match(r'^(\w+)\s*=\s*"([^"]+)"', stripped)
        if match:
            colors[match.group(1)] = match.group(2)
    return colors


def hex_rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    if len(value) == 3:
        value = "".join(ch * 2 for ch in value)
    return int(value[0:2], 16), int(value[2:4], 16), int(value[4:6], 16)


def blend(a: tuple[int, int, int], b: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def write_png(path: Path, width: int, height: int, pixel_fn) -> None:
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        for x in range(width):
            raw.extend(pixel_fn(x, y))

    def chunk(tag: bytes, data: bytes) -> bytes:
        crc = zlib.crc32(tag + data) & 0xFFFFFFFF
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", crc)

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    compressed = zlib.compress(bytes(raw), 9)
    png = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", ihdr)
        + chunk(b"IDAT", compressed)
        + chunk(b"IEND", b"")
    )
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(png)


def generate_wallpaper(path: Path, background: str, accent: str, width: int = 1920, height: int = 1080) -> None:
    bg = hex_rgb(background)
    accent_rgb = hex_rgb(accent)
    mid = blend(bg, accent_rgb, 0.18)

    def pixel(x: int, y: int) -> bytes:
        t = y / max(height - 1, 1)
        color = blend(bg, mid, t)
        return bytes(color)

    write_png(path, width, height, pixel)


def aether_colors_lua(c: dict[str, str]) -> str:
    lighter = c.get("color8", c["color0"])
    selection = c.get("color8", c["color0"])
    lines = [
        "return {",
        f'  bg         = "{c["background"]}",',
        f'  dark_bg    = "{c["color0"]}",',
        f'  darker_bg  = "{c["color0"]}",',
        f'  lighter_bg = "{lighter}",',
        "",
        f'  fg         = "{c["foreground"]}",',
        f'  dark_fg    = "{c["color1"]}",',
        f'  light_fg   = "{c["color7"]}",',
        f'  bright_fg  = "{c["color15"]}",',
        f'  muted      = "{c["color3"]}",',
        "",
        f'  red        = "{c["color1"]}",',
        f'  yellow     = "{c["color3"]}",',
        f'  orange     = "{c["color5"]}",',
        f'  green      = "{c["color2"]}",',
        f'  cyan       = "{c["color6"]}",',
        f'  blue       = "{c["accent"]}",',
        f'  purple     = "{c["color5"]}",',
        f'  brown      = "{c["color1"]}",',
        "",
        f'  bright_red    = "{c["color9"]}",',
        f'  bright_yellow = "{c["color11"]}",',
        f'  bright_green  = "{c["color10"]}",',
        f'  bright_cyan   = "{c["color14"]}",',
        f'  bright_blue   = "{c["accent"]}",',
        f'  bright_purple = "{c["color13"]}",',
        "",
        f'  accent               = "{c["accent"]}",',
        f'  cursor               = "{c["cursor"]}",',
        f'  foreground           = "{c["foreground"]}",',
        f'  background           = "{c["background"]}",',
        f'  selection            = "{selection}",',
        f'  selection_foreground = "{c["selection_foreground"]}",',
        f'  selection_background = "{c["selection_background"]}",',
        "}",
    ]
    return "\n".join(lines) + "\n"


def chromium_rgb(colors: dict[str, str]) -> str:
    r, g, b = hex_rgb(colors["background"])
    return f"{r},{g},{b}"


def gtk_css_header(c: dict[str, str]) -> str:
    accent = c.get("accent", c["color4"])
    lines = [
        f"    @define-color background     {c['background']};",
        f"    @define-color foreground     {c['foreground']};",
        f"    @define-color black          {c['color0']};",
        f"    @define-color red            {c['color1']};",
        f"    @define-color green          {c['color2']};",
        f"    @define-color yellow         {c['color3']};",
        f"    @define-color blue           {accent};",
        f"    @define-color magenta        {c['color5']};",
        f"    @define-color cyan           {c['color6']};",
        f"    @define-color white          {c['color7']};",
        f"    @define-color bright_black   {c['color8']};",
        f"    @define-color bright_red     {c['color9']};",
        f"    @define-color bright_green   {c['color10']};",
        f"    @define-color bright_yellow  {c['color11']};",
        f"    @define-color bright_blue    {c['color12']};",
        f"    @define-color bright_magenta {c['color13']};",
        f"    @define-color bright_cyan    {c['color14']};",
        f"    @define-color bright_white   {c['color15']};",
        "",
        "    @define-color accent_bg_color @blue;",
        "    @define-color accent_fg_color @background;",
        "    @define-color accent_color @cyan;",
        "",
        "    @define-color window_bg_color @background;",
        "    @define-color window_fg_color @foreground;",
        "",
        "    @define-color view_bg_color @black;",
        "    @define-color view_fg_color @foreground;",
        "    @define-color sidebar_bg_color @black;",
        "    @define-color sidebar_fg_color @foreground;",
        "    @define-color sidebar_backdrop_color @black;",
        "    @define-color sidebar_shade_color @black;",
        "",
        "    @define-color headerbar_bg_color @background;",
        "    @define-color headerbar_fg_color @foreground;",
        "    @define-color headerbar_backdrop_color @black;",
        "    @define-color headerbar_shade_color @black;",
        "    @define-color card_bg_color @background;",
        "    @define-color card_fg_color @foreground;",
        "",
        "    @define-color popover_bg_color @black;",
        "    @define-color popover_fg_color @foreground;",
        "",
        "    @define-color destructive_bg_color @red;",
        "    @define-color destructive_fg_color @background;",
        "",
        "    @define-color success_bg_color @green;",
        "    @define-color success_fg_color @background;",
        "",
        "    @define-color warning_bg_color @yellow;",
        "    @define-color warning_fg_color @background;",
        "",
        "    @define-color error_bg_color @red;",
        "    @define-color error_fg_color @background;",
        "",
        "    @define-color dialog_bg_color @background;",
        "    @define-color dialog_fg_color @foreground;",
        "",
        "    @define-color borders alpha(@foreground, 0.1);",
        "",
        "    @define-color theme_fg_color @foreground;",
        "    @define-color theme_text_color @foreground;",
        "    @define-color theme_bg_color @background;",
        "    @define-color theme_base_color @black;",
        "    @define-color theme_selected_bg_color @blue;",
        "    @define-color theme_selected_fg_color @background;",
        "    @define-color insensitive_bg_color @background;",
        "    @define-color insensitive_fg_color @bright_black;",
        "    @define-color insensitive_base_color @black;",
        "    @define-color theme_unfocused_fg_color @foreground;",
        "    @define-color theme_unfocused_text_color @foreground;",
        "    @define-color theme_unfocused_bg_color @background;",
        "    @define-color theme_unfocused_base_color @black;",
        "    @define-color theme_unfocused_selected_bg_color @blue;",
        "    @define-color theme_unfocused_selected_fg_color @background;",
        "    @define-color unfocused_insensitive_color @bright_black;",
        "    @define-color unfocused_borders alpha(@foreground, 0.1);",
        "    @define-color warning_color @yellow;",
        "    @define-color error_color @red;",
        "    @define-color success_color @green;",
        "    @define-color destructive_color @red;",
        "",
        "    @define-color content_view_bg @black;",
        "    @define-color text_view_bg @black;",
        "",
    ]
    return "\n".join(lines)


def generate_gtk_css(colors: dict[str, str]) -> str:
    rules = GTK_RULES.read_text() if GTK_RULES.is_file() else ""
    return gtk_css_header(colors) + "\n" + rules


def fetch_url(url: str) -> str | None:
    try:
        with urllib.request.urlopen(url, timeout=20) as response:
            return response.read().decode()
    except (urllib.error.URLError, TimeoutError):
        return None


def ensure_theme_extras(theme_dir: Path) -> None:
    colors_path = theme_dir / "colors.toml"
    if not colors_path.is_file():
        return

    colors = parse_colors(colors_path)
    gtk_path = theme_dir / "gtk.css"
    chromium_path = theme_dir / "chromium.theme"

    if not gtk_path.is_file():
        repo = THEME_REPOS.get(theme_dir.name)
        fetched = None
        if repo:
            slug, branch = repo
            fetched = fetch_url(
                f"https://raw.githubusercontent.com/{slug}/{branch}/gtk.css"
            )
        gtk_path.write_text(fetched if fetched else generate_gtk_css(colors))

    if not chromium_path.is_file():
        repo = THEME_REPOS.get(theme_dir.name)
        fetched = None
        if repo:
            slug, branch = repo
            fetched = fetch_url(
                f"https://raw.githubusercontent.com/{slug}/{branch}/chromium.theme"
            )
        chromium_path.write_text(
            fetched.strip() if fetched else chromium_rgb(colors)
        )


def dunst_block(c: dict[str, str]) -> str:
    urgent_bg = blend(hex_rgb(c["background"]), hex_rgb(c["color1"]), 0.35)
    urgent_fg = c["color15"]
    urgent_frame = c["color1"]
    return f"""[global]
    frame_color = "{c['accent']}"

[urgency_low]
    background = "{c['background']}"
    foreground = "{c['foreground']}"

[urgency_normal]
    background = "{c['background']}"
    foreground = "{c['foreground']}"

[urgency_critical]
    background = "#{urgent_bg[0]:02x}{urgent_bg[1]:02x}{urgent_bg[2]:02x}"
    foreground = "{urgent_fg}"
    frame_color = "{urgent_frame}"
"""
