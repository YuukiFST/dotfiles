#!/usr/bin/env python3
"""Shared helpers for Omarchy theme assets."""
from __future__ import annotations

import re
import struct
import zlib
from pathlib import Path


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
