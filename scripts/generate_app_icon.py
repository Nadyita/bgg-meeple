#!/usr/bin/env python3
"""Generate launcher icon assets from the SVG master."""

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SVG_PATH = ROOT / "assets" / "icon" / "app_icon.svg"
PNG_DIR = ROOT / "assets" / "icon"
PNG_SIZE = 1024
LINUX_ICON_SIZES = [16, 22, 24, 32, 48, 64, 96, 128, 256, 512]


def _run_inkscape(output: Path, width: int, height: int) -> int:
    result = subprocess.run(
        [
            "inkscape",
            "--export-type=png",
            f"--export-filename={output}",
            f"--export-width={width}",
            f"--export-height={height}",
            str(SVG_PATH),
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        print(f"Inkscape failed: {result.stderr}", file=sys.stderr)
    return result.returncode


def main() -> int:
    if not SVG_PATH.exists():
        print(f"Source SVG not found: {SVG_PATH}", file=sys.stderr)
        return 1

    PNG_DIR.mkdir(parents=True, exist_ok=True)

    master_png = PNG_DIR / "app_icon.png"
    if _run_inkscape(master_png, PNG_SIZE, PNG_SIZE) != 0:
        return 1
    print(f"Generated {master_png} ({PNG_SIZE}x{PNG_SIZE})")

    linux_icons_dir = ROOT / "linux" / "runner" / "resources" / "icons"
    for size in LINUX_ICON_SIZES:
        sized_dir = linux_icons_dir / f"{size}x{size}" / "apps"
        sized_dir.mkdir(parents=True, exist_ok=True)
        sized_png = sized_dir / "com.bggmeeple.bgg_meeple.png"
        if _run_inkscape(sized_png, size, size) != 0:
            return 1
        print(f"Generated {sized_png} ({size}x{size})")

    return 0


if __name__ == "__main__":
    sys.exit(main())
