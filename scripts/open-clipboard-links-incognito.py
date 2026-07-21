#!/usr/bin/env python3
"""Open clipboard links in a new Thorium incognito window."""

import os
import shutil
import subprocess
import sys

THORIUM_PATHS = [
    r"C:\Users\Administrator\AppData\Local\Thorium\Application\thorium.exe",
    os.path.expanduser(r"~\AppData\Local\Thorium\Application\thorium.exe"),
    r"C:\Program Files\Thorium\Application\thorium.exe",
    r"C:\Program Files (x86)\Thorium\Application\thorium.exe",
    "thorium-browser",
    "thorium",
    "/usr/bin/thorium-browser",
    "/usr/local/bin/thorium-browser",
    os.path.expanduser("~/.local/bin/thorium-browser"),
    "/opt/thorium/thorium-browser",
    "/opt/thorium-browser/thorium-browser",
]


def find_thorium():
    for path in THORIUM_PATHS:
        expanded = os.path.expandvars(os.path.expanduser(path))
        if shutil.which(expanded) or os.path.isfile(expanded):
            return expanded
    return None


def get_clipboard():
    try:
        if sys.platform.startswith("win"):
            return subprocess.check_output(
                "powershell Get-Clipboard", shell=True
            ).decode()

        try:
            return subprocess.check_output(
                "xclip -selection clipboard -o", shell=True
            ).decode()
        except subprocess.CalledProcessError:
            return subprocess.check_output(
                "xsel --clipboard --output", shell=True
            ).decode()
    except (subprocess.CalledProcessError, OSError):
        return ""


def main():
    links = [line.strip() for line in get_clipboard().splitlines() if line.strip()]
    if not links:
        return

    normalized = []
    for link in links:
        if not link.startswith(("http://", "https://")):
            link = "https://" + link
        normalized.append(link)

    thorium = find_thorium()
    if not thorium:
        return

    subprocess.Popen([thorium, "--incognito", *normalized])


if __name__ == "__main__":
    main()
