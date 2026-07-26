"""Recolour the home-screen 'Activate your Purchase' panel to dark carbon.

The orange gradient box (char 2231, 202x137) and its orange 'Activate' button
(2234, 59x29) are the last bright-legacy elements on the graphite home screen.
This rebuilds both on the dark theme while keeping the panel's exact silhouette
(from the original's alpha) and its coin/helmet icon (lifted from the original -
gold and red read fine on dark), and keeping the input well in the same spot so
the live activation-code field still lands over it. Stays JPEG3 at the original
dimensions, so the shapes that paint them need no change.
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from swf_utils import ROOT

SRC = ROOT / "assets" / "home" / "activate"
OUT = ROOT / "assets" / "home" / "prepared"

W, H = 202, 137
FRAME_HI = (36, 40, 46)
FRAME_LO = (18, 21, 25)
WELL = (12, 14, 17)
RED = (229, 66, 54)
TITLE = (236, 239, 243)
LABEL = (176, 182, 190)


def _font(path, size):
    for face in (path, "arialbd.ttf"):
        try:
            return ImageFont.truetype(f"C:/Windows/Fonts/{face}", size)
        except OSError:
            continue
    return ImageFont.load_default()


def build_panel() -> Image.Image:
    orig = Image.open(SRC / "orig_2231.png").convert("RGBA")
    silhouette = orig.getchannel("A")
    # dark vertical-gradient body clipped to the panel silhouette
    body = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    px = body.load()
    for y in range(H):
        t = y / (H - 1)
        col = tuple(int(FRAME_HI[k] + (FRAME_LO[k] - FRAME_HI[k]) * t) for k in range(3))
        for x in range(W):
            px[x, y] = col + (255,)
    body.putalpha(silhouette)
    d = ImageDraw.Draw(body)

    # reuse the coin/helmet icon from the original (top-left ~48x44)
    icon = orig.crop((4, 4, 52, 48))
    body.alpha_composite(icon, (8, 8))

    # title
    tf = _font("framdit.ttf", 15)
    d.text((60, 10), "Activate your", font=_font("segoeuiz.ttf", 11), fill=LABEL)
    d.text((60, 24), "PURCHASE!", font=tf, fill=TITLE)

    # activation-code label + dark input well (the live field overlays the well)
    d.text((14, 74), "ACTIVATION CODE", font=_font("framd.ttf", 9), fill=LABEL)
    d.rounded_rectangle((14, 90, W - 14, 112), radius=4, fill=WELL + (255,),
                        outline=(70, 74, 80, 255), width=1)
    # red accent along the panel's top edge
    d.line((10, 4, W - 10, 4), fill=RED + (255,), width=2)
    return body


def build_button() -> Image.Image:
    bw, bh = 59, 29
    orig = Image.open(SRC / "orig_2234.png").convert("RGBA")
    sil = orig.getchannel("A")
    im = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
    px = im.load()
    for y in range(bh):
        t = y / (bh - 1)
        col = tuple(int(FRAME_HI[k] + (FRAME_LO[k] - FRAME_HI[k]) * t) for k in range(3))
        for x in range(bw):
            px[x, y] = col + (255,)
    im.putalpha(sil)
    d = ImageDraw.Draw(im)
    # red edge just inside the silhouette
    d.rounded_rectangle((1, 1, bw - 2, bh - 2), radius=4, outline=RED + (255,), width=2)
    f = _font("framdit.ttf", 12)
    tb = d.textbbox((0, 0), "Activate", font=f)
    d.text(((bw - (tb[2] - tb[0])) / 2 - tb[0], (bh - (tb[3] - tb[1])) / 2 - tb[1]),
           "Activate", font=f, fill=TITLE)
    return im


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    build_panel().save(OUT / "activate_panel_2231.png", "PNG", optimize=True)
    build_button().save(OUT / "activate_button_2234.png", "PNG", optimize=True)
    print(f"activate panel + button -> {OUT}")


if __name__ == "__main__":
    main()
