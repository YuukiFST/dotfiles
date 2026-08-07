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
    "event-horizon": {
        "url": "https://omarchytheme.com/themes/event-horizon/",
        "background": "#1c1e26",
        "foreground": "#fadad1",
        "accent": "#26bbd9",
        "cursor": "#fadad1",
        "selection_background": "#26bbd9",
        "selection_foreground": "#1c1e26",
        "color0": "#1c1e26",
        "color1": "#e95678",
        "color2": "#29d398",
        "color3": "#fab795",
        "color4": "#26bbd9",
        "color5": "#ee64ac",
        "color6": "#59e3e3",
        "color7": "#fadad1",
        "color8": "#6c6f93",
        "color9": "#ec6a88",
        "color10": "#3fdaa4",
        "color11": "#fbc3a7",
        "color12": "#3fc4de",
        "color13": "#f075b5",
        "color14": "#6be4e6",
        "color15": "#fadad1",
    },
    "mac-transparent": {
        "url": "https://omarchytheme.com/themes/mac-transparent/",
        "background": "#1a1b1e",
        "foreground": "#eaeaef",
        "accent": "#7ca5ff",
        "cursor": "#f2a0a0",
        "selection_background": "#b2c3ff",
        "selection_foreground": "#2b2d31",
        "color0": "#2b2d31",
        "color1": "#ef5d67",
        "color2": "#8edb73",
        "color3": "#f7c553",
        "color4": "#7ca5ff",
        "color5": "#e29ef3",
        "color6": "#7dd8d3",
        "color7": "#f8f8fa",
        "color8": "#505258",
        "color9": "#ff7680",
        "color10": "#a2ee8b",
        "color11": "#ffd86f",
        "color12": "#97b6ff",
        "color13": "#efb5f9",
        "color14": "#94e8e3",
        "color15": "#ffffff",
    },
    "sakura": {
        "url": "https://omarchytheme.com/themes/sakura/",
        "background": "#0d0509",
        "foreground": "#f0eaed",
        "accent": "#d9a56c",
        "cursor": "#f0eaed",
        "selection_background": "#f0eaed",
        "selection_foreground": "#0d0509",
        "color0": "#0d0509",
        "color1": "#e85f6f",
        "color2": "#f29b9a",
        "color3": "#d4a882",
        "color4": "#d9a56c",
        "color5": "#d1b399",
        "color6": "#e8c099",
        "color7": "#f0eaed",
        "color8": "#4a3c45",
        "color9": "#ff7a8a",
        "color10": "#ffb5b4",
        "color11": "#e6ba94",
        "color12": "#ebb97e",
        "color13": "#e3c5ab",
        "color14": "#fbd2ab",
        "color15": "#ffffff",
    },
    "azure-glow": {
        "url": "https://omarchytheme.com/themes/azure-glow/",
        "background": "#0a0f1a",
        "foreground": "#a8dfff",
        "accent": "#00aaff",
        "cursor": "#00ccff",
        "selection_background": "#123247",
        "selection_foreground": "#ffffff",
        "color0": "#0d1b26",
        "color1": "#0099cc",
        "color2": "#00e0b8",
        "color3": "#33ccff",
        "color4": "#00aaff",
        "color5": "#3399ff",
        "color6": "#66e0ff",
        "color7": "#cceeff",
        "color8": "#123247",
        "color9": "#33ccff",
        "color10": "#33ffdd",
        "color11": "#66ddff",
        "color12": "#33bbff",
        "color13": "#66b2ff",
        "color14": "#99eeff",
        "color15": "#ffffff",
    },
    "anonymous": {
        "url": "https://omarchytheme.com/themes/anonymous/",
        "background": "#000000",
        "foreground": "#FEFEFE",
        "accent": "#BDBDBD",
        "cursor": "#FEFEFE",
        "selection_background": "#2B2B2B",
        "selection_foreground": "#FEFEFE",
        "color0": "#000000",
        "color1": "#FEFEFE",
        "color2": "#BDBDBD",
        "color3": "#CFCFCF",
        "color4": "#BDBDBD",
        "color5": "#BDBDBD",
        "color6": "#BDBDBD",
        "color7": "#FEFEFE",
        "color8": "#1A1A1A",
        "color9": "#F5F5F5",
        "color10": "#BDBDBD",
        "color11": "#CFCFCF",
        "color12": "#BDBDBD",
        "color13": "#BDBDBD",
        "color14": "#BDBDBD",
        "color15": "#F5F5F5",
    },
    "saga": {
        "url": "https://omarchytheme.com/themes/saga/",
        "background": "#05080a",
        "foreground": "#fff6ff",
        "accent": "#b2fff3",
        "cursor": "#b2fff3",
        "selection_background": "#ffc2df",
        "selection_foreground": "#05080a",
        "color0": "#05080a",
        "color1": "#ff9fbc",
        "color2": "#baf7b5",
        "color3": "#fff6c3",
        "color4": "#b2fff3",
        "color5": "#dfbaff",
        "color6": "#ffc79b",
        "color7": "#f3ceff",
        "color8": "#4b4c4d",
        "color9": "#ffaecb",
        "color10": "#baf7b5",
        "color11": "#fff6c3",
        "color12": "#b2fff3",
        "color13": "#dfbaff",
        "color14": "#ffc79b",
        "color15": "#ffe1e1",
    },
    "oxford": {
        "url": "https://omarchytheme.com/themes/oxford/",
        "background": "#292b31",
        "foreground": "#d6d1c9",
        "accent": "#bda07f",
        "cursor": "#d6d1c9",
        "selection_background": "#bda07f",
        "selection_foreground": "#d6d1c9",
        "color0": "#292b31",
        "color1": "#dd5544",
        "color2": "#76856a",
        "color3": "#f3e9bd",
        "color4": "#bda07f",
        "color5": "#b7a593",
        "color6": "#9b907f",
        "color7": "#ffffff",
        "color8": "#646466",
        "color9": "#f28b7c",
        "color10": "#a8b49d",
        "color11": "#fff4d4",
        "color12": "#d8c3a5",
        "color13": "#b0a89d",
        "color14": "#c7c0b5",
        "color15": "#d6d1c9",
    },
    "kanso": {
        "url": "https://omarchytheme.com/themes/kanso/",
        "background": "#090E13",
        "foreground": "#C5C9C7",
        "accent": "#8ba4b0",
        "cursor": "#C5C9C7",
        "selection_background": "#393B44",
        "selection_foreground": "#C5C9C7",
        "color0": "#090E13",
        "color1": "#c4746e",
        "color2": "#8a9a7b",
        "color3": "#c4b28a",
        "color4": "#8ba4b0",
        "color5": "#a292a3",
        "color6": "#8ea4a2",
        "color7": "#c8c093",
        "color8": "#393B44",
        "color9": "#e46876",
        "color10": "#87a987",
        "color11": "#e6c384",
        "color12": "#7fb4ca",
        "color13": "#938aa9",
        "color14": "#7aa89f",
        "color15": "#A4A7A4",
    },
    "night-owl": {
        "url": "https://omarchytheme.com/themes/night-owl/",
        "background": "#011627",
        "foreground": "#d6deeb",
        "accent": "#82aaff",
        "cursor": "#80a4c2",
        "selection_background": "#1d3b53",
        "selection_foreground": "#ffffff",
        "color0": "#011627",
        "color1": "#ef5350",
        "color2": "#22da6e",
        "color3": "#c5e478",
        "color4": "#82aaff",
        "color5": "#c792ea",
        "color6": "#21c7a8",
        "color7": "#d6deeb",
        "color8": "#575656",
        "color9": "#ef5350",
        "color10": "#22da6e",
        "color11": "#ffeb95",
        "color12": "#82aaff",
        "color13": "#c792ea",
        "color14": "#7fdbca",
        "color15": "#ffffff",
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
