"""Recolour the NIM conversation bezel (char 2224) from silver to dark carbon.

The PM view's silver 'TV bezel' with a white centre is the last legacy element
in the NIM window - everything else drawn behind it is already dark. This keeps
the bezel's exact outer silhouette (taken from the original's alpha, so it drops
into the same shape 2225 fill with no matrix change) and repaints it: a dark
carbon frame, a dark recessed inner window, a red accent under the label, and a
light 'NIM' wordmark. Stays 229x210 DefineBitsJPEG3 (replace_jpeg3 keeps the
alpha), so nothing structural changes.
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from swf_utils import ROOT

SRC = ROOT / "assets" / "nim" / "bezel_2224_orig.png"   # exported original (silhouette source)
OUT_DIR = ROOT / "assets" / "nim" / "prepared"
OUT = OUT_DIR / "nim_bezel_2224.png"

W, H = 229, 210
FRAME_HI = (34, 38, 44)
FRAME_LO = (18, 21, 25)
INNER = (11, 13, 16)
RED = (229, 66, 54)
LABEL = (210, 215, 222)


def _font(size):
    for face in ("framd.ttf", "arialbd.ttf"):
        try:
            return ImageFont.truetype(f"C:/Windows/Fonts/{face}", size)
        except OSError:
            continue
    return ImageFont.load_default()


def build() -> Image.Image:
    orig = Image.open(SRC).convert("RGBA")
    silhouette = orig.getchannel("A")   # exact outer rounded shape (corners transparent)

    # Dark carbon body, vertical gradient, clipped to the original silhouette.
    body = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    bpx = body.load()
    for y in range(H):
        t = y / (H - 1)
        col = tuple(int(FRAME_HI[k] + (FRAME_LO[k] - FRAME_HI[k]) * t) for k in range(3))
        for x in range(W):
            bpx[x, y] = col + (255,)
    body.putalpha(silhouette)

    d = ImageDraw.Draw(body)
    # Recessed inner window: dark, below the label band, inset from the frame.
    ix0, iy0, ix1, iy1 = 16, 40, W - 16, H - 15
    d.rounded_rectangle((ix0, iy0, ix1, iy1), radius=6, fill=INNER + (255,))
    # Thin inner top highlight + red accent under the label band.
    d.line((ix0 + 2, iy0 - 3, ix1 - 2, iy0 - 3), fill=RED + (255,), width=2)
    # Subtle red edge along the very top of the frame.
    d.line((14, 6, W - 14, 6), fill=(RED[0], RED[1], RED[2], 90), width=1)

    # 'NIM' wordmark, centred in the top frame band.
    font = _font(20)
    text = "NIM"
    tb = d.textbbox((0, 0), text, font=font)
    tx = (W - (tb[2] - tb[0])) / 2 - tb[0]
    d.text((tx + 1, 12 + 1), text, font=font, fill=(0, 0, 0, 160))
    d.text((tx, 12), text, font=font, fill=LABEL + (255,))
    return body


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    build().save(OUT, "PNG", optimize=True)
    print(f"nim bezel -> {OUT}")


if __name__ == "__main__":
    main()
