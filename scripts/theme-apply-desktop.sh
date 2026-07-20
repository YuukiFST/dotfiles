#!/usr/bin/env python3
"""Apply Omarchy theme colors to i3, polybar, rofi, ghostty, and dunst dotfiles."""
from __future__ import annotations

import re
import sys
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPTS))
from theme_lib import dunst_block


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


def replace_block(text: str, begin: str, end: str, body: str) -> str:
    pattern = re.compile(
        re.escape(begin) + r".*?" + re.escape(end),
        re.DOTALL,
    )
    replacement = f"{begin}\n{body}\n{end}"
    if not pattern.search(text):
        raise SystemExit(f"Marker block not found: {begin} ... {end}")
    return pattern.sub(replacement, text, count=1)


def rofi_palette(c: dict[str, str]) -> str:
    bg_alt = c.get("color8", c["background"])
    return f"""* {{
    background:     {c['background']};
    background-alt: {bg_alt};
    foreground:     {c['foreground']};
    selected:       {c['accent']};
    active:         {c['accent']};
    urgent:         {c['color3']};
    alternate-urgent: {bg_alt};
    disabled:       {c['color1']};
}}

window {{
    location:         center;
    anchor:           center;
    fullscreen:       false;
    width:            600px;
    x-offset:         0px;
    y-offset:         0px;
    enabled:          true;
    margin:           0px;
    padding:          0px;
    border:           2px;
    border-radius:    0px;
    border-color:     @selected;
    background-color: @background;
    cursor:           "default";
}}

mainbox {{
    enabled:  true;
    spacing:  10px;
    margin:   0px;
    padding:  10px;
    children: [ "inputbar", "listview" ];
    background-color: transparent;
}}

inputbar {{
    enabled:  true;
    spacing:  0px;
    margin:   0px;
    padding:  6px 10px;
    children: [ "prompt", "textbox-prompt-colon", "entry" ];
    background-color: @background-alt;
    text-color:       @foreground;
}}

prompt {{
    enabled: true;
    padding: 0px 8px 0px 0px;
    background-color: inherit;
    text-color:       @foreground;
}}

textbox-prompt-colon {{
    expand:     false;
    str:        ":";
    background-color: inherit;
    text-color:       @disabled;
}}

entry {{
    enabled: true;
    padding: 0px;
    background-color: inherit;
    text-color:       @foreground;
    cursor:   text;
}}

listview {{
    enabled:      true;
    columns:      1;
    lines:        8;
    cycle:        true;
    dynamic:      true;
    scrollbar:    false;
    layout:       vertical;
    reverse:      false;
    fixed-height: true;
    fixed-width:  false;
    spacing:      4px;
    margin:       0px;
    padding:      4px 0px;
    background-color: transparent;
    text-color:       @foreground;
    cursor:   "default";
}}

element {{
    enabled:  true;
    spacing:  10px;
    margin:   0px;
    padding:  6px 10px;
    border:   0px;
    border-radius: 0px;
    background-color: transparent;
    text-color:       @foreground;
    cursor:   pointer;
}}

element normal.normal {{
    background-color: transparent;
    text-color:       @foreground;
}}

element normal.urgent {{
    background-color: @alternate-urgent;
    text-color:       @urgent;
}}

element normal.active {{
    background-color: @active;
    text-color:       @foreground;
}}

element selected.normal {{
    background-color: @selected;
    text-color:       @foreground;
}}

element selected.urgent {{
    background-color: @urgent;
    text-color:       @background;
}}

element selected.active {{
    background-color: @active;
    text-color:       @foreground;
}}

element-icon {{
    background-color: transparent;
    text-color:       inherit;
    size:             1.2em;
    cursor:           inherit;
}}

element-text {{
    background-color: transparent;
    text-color:       inherit;
    highlight:        inherit;
    cursor:           inherit;
    vertical-align:   0.5;
    horizontal-align: 0.0;
}}

message {{
    enabled:  true;
    margin:   0px;
    padding:  0px;
    border:   0px;
    background-color: transparent;
    text-color:       @foreground;
}}

textbox {{
    padding:  8px;
    background-color: @background-alt;
    text-color:       @foreground;
    vertical-align:   0.5;
    horizontal-align: 0.0;
    highlight:        none;
    blink:            true;
    markup:           true;
}}

error-message {{
    padding:          10px;
    border:           2px;
    border-radius:    0px;
    border-color:     @urgent;
    background-color: @background;
    text-color:       @urgent;
}}
"""


def polybar_colors(c: dict[str, str], theme_name: str, url: str) -> str:
    return f"""[colors]
# {theme_name} — {url}

background = {c['background']}
foreground = {c['foreground']}
red        = {c['color1']}
bloodofmyenemies = {c['accent']}
green      = {c['color2']}
yellow     = {c['color3']}
blue       = {c['accent']}
purple     = {c['color1']}
cyan       = {c['color6']}
orange     = {c['color3']}
pink       = {c['color3']}
grey       = {c['color1']}"""


def i3_colors(c: dict[str, str], theme_name: str, url: str) -> str:
    inactive = c.get("color8", c["color1"])
    return f"""# {theme_name} — {url}
client.focused          {c['accent']} {c['accent']} {c['foreground']} {c['accent']}   {c['accent']}
client.focused_inactive {inactive} {inactive} {c['foreground']} {inactive}   {inactive}
client.unfocused        {c['background']} {c['background']} {c['color1']} {c['background']}   {c['background']}
client.urgent           {inactive} {c['color3']} {c['background']} {c['color3']}   {c['color3']}
client.placeholder      {c['background']} {c['background']} {c['color1']} {c['background']}   {c['background']}
client.background       {c['background']}

font pango:monospace 8

bar {{
  i3bar_command $HOME/.config/polybar/launch.sh
  status_command i3status
  colors {{
    background {c['background']}
    statusline {c['foreground']}
    separator  {c['accent']}
    focused_workspace  {c['accent']} {c['accent']} {c['foreground']}
    active_workspace   {c['background']} {inactive} {c['foreground']}
    inactive_workspace {c['background']} {c['background']} {c['color1']}
    urgent_workspace   {c['color3']} {c['color3']} {c['background']}
    binding_mode       {c['color3']} {c['color3']} {c['background']}
  }}
}}"""


def ghostty_colors(c: dict[str, str], theme_name: str, url: str) -> str:
    lines = [
        f"# {theme_name} — {url}",
        f"background = {c['background']}",
        f"foreground = {c['foreground']}",
        f"cursor-color = {c['cursor']}",
        f"selection-background = {c['selection_background']}",
        f"selection-foreground = {c['selection_foreground']}",
    ]
    for i in range(16):
        lines.append(f"palette = {i}={c[f'color{i}']}")
    return "\n".join(lines)


def patch_polybar(config_path: Path, colors_block: str) -> None:
    text = config_path.read_text()
    pattern = re.compile(r"\[colors\].*?(?=\n\[)", re.DOTALL)
    if not pattern.search(text):
        raise SystemExit(f"Could not find [colors] in {config_path}")
    text = pattern.sub(colors_block + "\n\n", text, count=1)
    config_path.write_text(text)


def patch_ghostty(config_path: Path, colors_block: str) -> None:
    text = config_path.read_text()
    text = replace_block(text, "# BEGIN THEME_COLORS", "# END THEME_COLORS", colors_block)
    config_path.write_text(text)


def patch_i3(config_path: Path, colors_block: str) -> None:
    text = config_path.read_text()
    text = replace_block(text, "# BEGIN THEME_COLORS", "# END THEME_COLORS", colors_block)
    config_path.write_text(text)


def dunst_colors(c: dict[str, str]) -> str:
    return dunst_block(c)


def patch_dunst(config_path: Path, colors_block: str) -> None:
    text = config_path.read_text()
    text = replace_block(text, "# BEGIN THEME_COLORS", "# END THEME_COLORS", colors_block)
    config_path.write_text(text)


def patch_rofi_config(config_path: Path, theme_name: str) -> None:
    text = config_path.read_text()
    text = re.sub(r'@theme\s+"[^"]+"', f'@theme "{theme_name}"', text)
    config_path.write_text(text)


def main() -> None:
    if len(sys.argv) < 3:
        raise SystemExit(f"usage: {sys.argv[0]} <theme-dir> <dotfiles-root> [--rofi-only]")

    theme_dir = Path(sys.argv[1]).resolve()
    dotfiles = Path(sys.argv[2]).resolve()
    rofi_only = len(sys.argv) > 3 and sys.argv[3] == "--rofi-only"
    theme_name = theme_dir.name
    colors_path = theme_dir / "colors.toml"
    meta_path = theme_dir / "meta.env"

    if not colors_path.is_file():
        raise SystemExit(f"Missing {colors_path}")

    colors = parse_colors(colors_path)
    required = [
        "background", "foreground", "accent", "cursor",
        "selection_background", "selection_foreground",
        *[f"color{i}" for i in range(16)],
    ]
    missing = [key for key in required if key not in colors]
    if missing:
        raise SystemExit(f"colors.toml missing keys: {', '.join(missing)}")

    theme_url = "https://omarchytheme.com/themes/"
    if meta_path.is_file():
        for line in meta_path.read_text().splitlines():
            if line.startswith("url="):
                theme_url = line.split("=", 1)[1].strip()

    rofi_dir = dotfiles / "rofi/.config/rofi"
    rofi_dir.mkdir(parents=True, exist_ok=True)
    (rofi_dir / f"{theme_name}.rasi").write_text(rofi_palette(colors))

    if rofi_only:
        print(f"Generated rofi theme: {theme_name}")
        return

    patch_rofi_config(rofi_dir / "config.rasi", theme_name)
    patch_polybar(
        dotfiles / "polybar/.config/polybar/config",
        polybar_colors(colors, theme_name, theme_url),
    )
    patch_ghostty(
        dotfiles / "ghostty/.config/ghostty/config",
        ghostty_colors(colors, theme_name, theme_url),
    )
    patch_i3(
        dotfiles / "i3/.config/i3/config",
        i3_colors(colors, theme_name, theme_url),
    )
    dunst_path = dotfiles / "dunst/.config/dunst/dunstrc"
    if dunst_path.is_file():
        patch_dunst(dunst_path, dunst_colors(colors))

    print(f"Applied desktop colors for theme: {theme_name}")


if __name__ == "__main__":
    main()
