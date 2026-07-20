#!/usr/bin/env python3
"""Bootstrap Omarchy theme directories from color palettes."""
from __future__ import annotations

import re
import sys
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPTS))
from theme_lib import aether_colors_lua

DOTFILES = Path(__file__).resolve().parents[1]
THEMES_DIR = DOTFILES / "themes"

THEMES: dict[str, dict[str, str]] = {
    "vantablack": {
        "url": "https://omarchytheme.com/themes/vantablack/",
        "background": "#000000",
        "foreground": "#ffffff",
        "accent": "#8d8d8d",
        "cursor": "#ffffff",
        "selection_background": "#ffffff",
        "selection_foreground": "#000000",
        "color0": "#404040",
        "color1": "#a4a4a4",
        "color2": "#b6b6b6",
        "color3": "#cecece",
        "color4": "#8d8d8d",
        "color5": "#9b9b9b",
        "color6": "#b0b0b0",
        "color7": "#ececec",
        "color8": "#5c5c5c",
        "color9": "#a4a4a4",
        "color10": "#b6b6b6",
        "color11": "#cecece",
        "color12": "#8d8d8d",
        "color13": "#9b9b9b",
        "color14": "#b0b0b0",
        "color15": "#ffffff",
    },
    "miasma-oldjobobo": {
        "url": "https://omarchytheme.com/themes/miasma-oldjobobo/",
        "background": "#222222",
        "foreground": "#c2c2b0",
        "accent": "#78824b",
        "cursor": "#c7c7c7",
        "selection_background": "#78824b",
        "selection_foreground": "#c2c2b0",
        "color0": "#666666",
        "color1": "#685742",
        "color2": "#5f875f",
        "color3": "#b36d43",
        "color4": "#78824b",
        "color5": "#bb7744",
        "color6": "#c9a554",
        "color7": "#d7c483",
        "color8": "#666666",
        "color9": "#685742",
        "color10": "#5f875f",
        "color11": "#b36d43",
        "color12": "#78824b",
        "color13": "#bb7744",
        "color14": "#c9a554",
        "color15": "#d7c483",
    },
    "solitude": {
        "url": "https://omarchytheme.com/themes/solitude/",
        "background": "#101315",
        "foreground": "#cacccc",
        "accent": "#798186",
        "cursor": "#cacccc",
        "selection_background": "#798186",
        "selection_foreground": "#101315",
        "color0": "#101315",
        "color1": "#565d60",
        "color2": "#9fa5a9",
        "color3": "#d9dbdc",
        "color4": "#798186",
        "color5": "#aeaeae",
        "color6": "#707070",
        "color7": "#cbc2be",
        "color8": "#4b4e55",
        "color9": "#de6145",
        "color10": "#343d41",
        "color11": "#c9c2b4",
        "color12": "#5d6367",
        "color13": "#9a9a9a",
        "color14": "#707070",
        "color15": "#a5aeb4",
    },
    "koyanagi": {
        "url": "https://omarchytheme.com/themes/koyanagi/",
        "background": "#1C1C1E",
        "foreground": "#FFFFFF",
        "accent": "#7A7A7A",
        "cursor": "#FFFFFF",
        "selection_background": "#808080",
        "selection_foreground": "#FFFFFF",
        "color0": "#1C1C1E",
        "color1": "#F2F2F2",
        "color2": "#FFDD80",
        "color3": "#6A6A6A",
        "color4": "#7A7A7A",
        "color5": "#8A8A8A",
        "color6": "#F2F2F2",
        "color7": "#F2F2F2",
        "color8": "#2C2C2E",
        "color9": "#F2F2F2",
        "color10": "#FFE9B3",
        "color11": "#A6A6A6",
        "color12": "#B8B8B8",
        "color13": "#CCCCCC",
        "color14": "#FFFFFF",
        "color15": "#FFFFFF",
    },
    "snow-black": {
        "url": "https://omarchytheme.com/themes/snow-black/",
        "background": "#000000",
        "foreground": "#FFFFFF",
        "accent": "#888888",
        "cursor": "#FFFFFF",
        "selection_background": "#FFFFFF",
        "selection_foreground": "#000000",
        "color0": "#000000",
        "color1": "#5F8787",
        "color2": "#DD9999",
        "color3": "#A06666",
        "color4": "#888888",
        "color5": "#999999",
        "color6": "#AAAAAA",
        "color7": "#C1C1C1",
        "color8": "#333333",
        "color9": "#5F8787",
        "color10": "#DD9999",
        "color11": "#A06666",
        "color12": "#888888",
        "color13": "#999999",
        "color14": "#AAAAAA",
        "color15": "#C1C1C1",
    },
    "nes": {
        "url": "https://omarchytheme.com/themes/nes/",
        "background": "#101010",
        "foreground": "#cecfc9",
        "accent": "#9a9d9a",
        "cursor": "#cecfc9",
        "selection_background": "#cecfc9",
        "selection_foreground": "#101010",
        "color0": "#000000",
        "color1": "#d93f37",
        "color2": "#9a9d9a",
        "color3": "#9a9d9a",
        "color4": "#9a9d9a",
        "color5": "#d93f37",
        "color6": "#9a9d9a",
        "color7": "#cecfc9",
        "color8": "#9a9d9a",
        "color9": "#da0f0f",
        "color10": "#cecfc9",
        "color11": "#cecfc9",
        "color12": "#cecfc9",
        "color13": "#da0f0f",
        "color14": "#cecfc9",
        "color15": "#ffffff",
    },
    "inkypinky": {
        "url": "https://omarchytheme.com/themes/inkypinky/",
        "background": "#13131D",
        "foreground": "#c8c8c8",
        "accent": "#7c7ca8",
        "cursor": "#c8c8c8",
        "selection_background": "#c8c8c8",
        "selection_foreground": "#13131D",
        "color0": "#13131D",
        "color1": "#EA90A8",
        "color2": "#a6b2c7",
        "color3": "#D18BA2",
        "color4": "#7c7ca8",
        "color5": "#9f859f",
        "color6": "#919ab7",
        "color7": "#a1a2a7",
        "color8": "#434353",
        "color9": "#f6bfce",
        "color10": "#d1d9e4",
        "color11": "#e3aebf",
        "color12": "#bcbcd4",
        "color13": "#bfadbf",
        "color14": "#d2d7e3",
        "color15": "#c8c8c8",
    },
}


def colors_toml(c: dict[str, str]) -> str:
    keys = [
        "accent", "cursor", "foreground", "background",
        "selection_foreground", "selection_background",
        *[f"color{i}" for i in range(16)],
    ]
    lines = [f'{key} = "{c[key]}"' for key in keys]
    return "\n".join(lines) + "\n"


def btop_theme(name: str, c: dict[str, str]) -> str:
    inactive = c.get("color8", c["color1"])
    selected_bg = c.get("color8", c["color0"])
    return f"""# Btop {name} Theme

theme_color[background]="{c['background']}"
theme_color[foreground]="{c['foreground']}"
theme_color[inactive_fg]="{inactive}"
theme_color[selected_bg]="{selected_bg}"
theme_color[selected_fg]="{c['foreground']}"
theme_color[highlight_bg]="{c['accent']}"
theme_color[highlight_fg]="{c['foreground']}"
theme_color[gradient_color1]="{c['color1']}"
theme_color[gradient_color2]="{c['color3']}"

theme[main_bg]=""
theme[main_fg]="{c['foreground']}"
theme[title]="{c['foreground']}"
theme[hi_fg]="{c['foreground']}"
theme[selected_bg]="{selected_bg}"
theme[selected_fg]="{c['foreground']}"
theme[inactive_fg]="{inactive}"
theme[proc_misc]="{c['accent']}"
theme[cpu_box]="{c['accent']}"
theme[mem_box]="{c['accent']}"
theme[net_box]="{c['accent']}"
theme[proc_box]="{c['accent']}"
theme[div_line]="{c['accent']}"
theme[temp_start]="{c['color1']}"
theme[temp_mid]="{c['color3']}"
theme[temp_end]="{c['foreground']}"
theme[cpu_start]="{c['color1']}"
theme[cpu_mid]="{c['color3']}"
theme[cpu_end]="{c['foreground']}"
theme[free_start]="{c['color1']}"
theme[free_mid]="{c['color3']}"
theme[free_end]="{c['foreground']}"
theme[cached_start]="{c['color1']}"
theme[cached_mid]="{c['color3']}"
theme[cached_end]="{c['foreground']}"
theme[available_start]="{c['color1']}"
theme[available_mid]="{c['color3']}"
theme[available_end]="{c['foreground']}"
theme[used_start]="{c['color1']}"
theme[used_mid]="{c['color3']}"
theme[used_end]="{c['foreground']}"
theme[download_start]="{c['color1']}"
theme[download_mid]="{c['color3']}"
theme[download_end]="{c['foreground']}"
theme[upload_start]="{c['color1']}"
theme[upload_mid]="{c['color3']}"
theme[upload_end]="{c['foreground']}"
"""


def neovim_lua(name: str, c: dict[str, str]) -> str:
  title = name.replace("-", " ").title()
  return f"""return {{
  {{
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {{
      colors = {{
        bg         = "{c['background']}",
        dark_bg    = "{c['color0']}",
        darker_bg  = "{c['color0']}",
        lighter_bg = "{c.get('color8', c['color0'])}",

        fg         = "{c['foreground']}",
        dark_fg    = "{c['color1']}",
        light_fg   = "{c['color7']}",
        bright_fg  = "{c['color15']}",
        muted      = "{c['color3']}",

        red        = "{c['color1']}",
        yellow     = "{c['color3']}",
        orange     = "{c['color5']}",
        green      = "{c['color2']}",
        cyan       = "{c['color6']}",
        blue       = "{c['accent']}",
        purple     = "{c['color5']}",
        brown      = "{c['color1']}",

        bright_red    = "{c['color9']}",
        bright_yellow = "{c['color11']}",
        bright_green  = "{c['color10']}",
        bright_cyan   = "{c['color14']}",
        bright_blue   = "{c['accent']}",
        bright_purple = "{c['color13']}",

        accent               = "{c['accent']}",
        cursor               = "{c['cursor']}",
        foreground           = "{c['foreground']}",
        background           = "{c['background']}",
        selection            = "{c.get('color8', c['color0'])}",
        selection_foreground = "{c['selection_foreground']}",
        selection_background = "{c['selection_background']}",
      }},
    }},
    config = function(_, opts)
      require("aether").setup(opts)
      vim.cmd.colorscheme("aether")
      require("aether.hotreload").setup()
    end,
  }},
  {{
    "LazyVim/LazyVim",
    opts = {{
      colorscheme = "aether",
    }},
  }},
}}
"""


def write_theme(name: str, data: dict[str, str]) -> None:
    theme_dir = THEMES_DIR / name
    theme_dir.mkdir(parents=True, exist_ok=True)
    colors = {k: v for k, v in data.items() if k != "url"}
    (theme_dir / "colors.toml").write_text(colors_toml(colors))
    (theme_dir / "meta.env").write_text(f"url={data['url']}\n")
    (theme_dir / "icons.theme").write_text("Yaru-grey\n")
    (theme_dir / "btop.theme").write_text(btop_theme(name, colors))
    (theme_dir / "neovim.lua").write_text(neovim_lua(name, colors))
    (theme_dir / "aether.lua").write_text(aether_colors_lua(colors))
    print(f"  {name}")


def main() -> None:
    names = sys.argv[1:] or list(THEMES)
    print("Bootstrapping themes:")
    for name in names:
        if name not in THEMES:
            raise SystemExit(f"Unknown theme: {name}")
        write_theme(name, THEMES[name])

    desktop = DOTFILES / "scripts/theme-apply-desktop.sh"
    for name in names:
        import subprocess

        subprocess.run(
            [sys.executable, str(desktop), str(THEMES_DIR / name), str(DOTFILES), "--rofi-only"],
            check=True,
        )


if __name__ == "__main__":
    main()
