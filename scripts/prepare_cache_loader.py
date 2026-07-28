"""Dark-theme the cache-download progress bar (classes.Frame.assetLoader).

This is the first screen the client shows - "Checking for new updates ..." with
a progress bar - and it still ships the legacy skin: character 1967 is the
progress TRACK, a near-white #FBFBFB slab 426x22 that is by far the brightest
thing on an otherwise black screen.

`dark_ui_loader.py` described this retheme but was only ever wired into
`apply_dark_ui.py`, a pipeline `build_polish_patch` does not run - so the track
has been shipping white the whole time. This module draws the replacement
directly so the polish build can swap it like any other budgeted bitmap.

The track keeps its exact 426x22 dimensions, so the shape that paints it needs
no change (see the fill-matrix rule: art lands where the shape's translate
says, not where the placement does).
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

from swf_utils import ROOT

OUT = ROOT / "assets" / "polish" / "prepared"

TRACK_W, TRACK_H = 426, 22

WELL_TOP = (9, 10, 13)
WELL_BOTTOM = (18, 20, 25)
RIM = (48, 51, 58)
RIM_LIGHT = (64, 68, 78)


def build_track() -> Image.Image:
    """A recessed dark well: dark at the top edge, lifting slightly to the base."""
    image = Image.new("RGBA", (TRACK_W, TRACK_H), (0, 0, 0, 255))
    pixels = image.load()
    for y in range(TRACK_H):
        t = y / (TRACK_H - 1)
        colour = tuple(int(WELL_TOP[k] + (WELL_BOTTOM[k] - WELL_TOP[k]) * t)
                       for k in range(3))
        for x in range(TRACK_W):
            pixels[x, y] = colour + (255,)

    draw = ImageDraw.Draw(image)
    # 1px rim, brighter along the bottom so the well reads as sunk rather than
    # as a flat black bar against the black screen behind it
    draw.rectangle((0, 0, TRACK_W - 1, TRACK_H - 1), outline=RIM + (255,))
    draw.line((1, TRACK_H - 1, TRACK_W - 2, TRACK_H - 1), fill=RIM_LIGHT + (255,))
    return image


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / "cache_loader_track.png"
    build_track().save(path, "PNG", optimize=True)
    print(f"cache loader track -> {path}")


if __name__ == "__main__":
    main()
