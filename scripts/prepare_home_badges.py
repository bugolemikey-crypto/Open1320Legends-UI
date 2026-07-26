"""Retheme the home-map node badges by grading the game's own art.

An earlier pass redrew these from scratch and the hand-drawn glyphs read as
amateur next to the polished originals. This instead keeps each badge's original
professional glyph and only regrades it: the coloured disc (red, and the three
off-palette gold / silver / blue ones) is desaturated and auto-levelled to a
uniform dark graphite, the glyph is held bright, and a crisp red rim ring ties
it to the theme. Because it only recolours pixels in place, every glyph stays
exactly as the artists drew it, and the bitmap keeps its dimensions so nothing
on the map moves.

The originals are read straight out of the base SWF's DefineBitsJPEG3 tags
(image + zlib alpha), so there is no committed intermediate to drift. The shapes
that paint them are DefineShape (v1), which red-renders Lossless2, so the graded
result ships back as JPEG3 - and a desaturated, smoothly-graded disc encodes
clean at the original ~2KB budget.
"""
from __future__ import annotations

import io
import struct
import zlib
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

from swf_utils import ROOT

BASE = ROOT / "patches" / "main_client" / "main.dark-ui.current.swf"
OUT_DIR = ROOT / "assets" / "home" / "prepared"

# badge character id -> its original size is read from the bitmap itself
BADGES = {
    2252: "dealership", 2256: "racetrack", 2260: "shop", 2264: "teamhq",
    2268: "home", 2272: "impound", 2276: "usedcars", 2280: "news",
}

DISC_DARK = 28      # where the disc body lands after levelling
GLYPH_HI = 238      # where the glyph highlight lands
RED = (232, 44, 34)


def extract_jpeg3(character: int) -> Image.Image:
    """Decode a DefineBitsJPEG3 (image + zlib alpha) to RGBA from the base SWF."""
    data = BASE.read_bytes()
    pos = 8
    pos += (5 + 4 * (data[pos] >> 3) + 7) // 8
    pos += 4
    while pos < len(data) - 1:
        (code_len,) = struct.unpack_from("<H", data, pos)
        code, length = code_len >> 6, code_len & 0x3F
        header = 2
        if length == 0x3F:
            (length,) = struct.unpack_from("<I", data, pos + 2)
            header = 6
        if code == 35 and length >= 2:
            (found,) = struct.unpack_from("<H", data, pos + header)
            if found == character:
                (alpha_off,) = struct.unpack_from("<I", data, pos + header + 2)
                jpeg = data[pos + header + 6: pos + header + 6 + alpha_off]
                rgb = Image.open(io.BytesIO(jpeg)).convert("RGB")
                alpha_bytes = zlib.decompress(data[pos + header + 6 + alpha_off:
                                                    pos + header + length])
                alpha = Image.frombytes("L", rgb.size, alpha_bytes)
                rgb.putalpha(alpha)
                return rgb
        pos += header + length
        if code == 0:
            break
    raise RuntimeError(f"DefineBitsJPEG3 {character} not found in {BASE}")


def regrade(im: Image.Image) -> Image.Image:
    """Desaturate + auto-level the disc to uniform graphite; add a red rim."""
    im = im.convert("RGBA")
    alpha = im.getchannel("A")
    w, h = im.size
    lum = np.asarray(im.convert("L"), dtype=np.float32)
    inside = np.asarray(alpha) > 40
    vals = lum[inside]
    lo = float(np.percentile(vals, 58))   # disc body
    hi = float(np.percentile(vals, 99))   # glyph highlight
    if hi <= lo:
        hi = lo + 1
    out = (lum - lo) / (hi - lo) * (GLYPH_HI - DISC_DARK) + DISC_DARK
    out = np.clip(out, 8, 255).astype("uint8")
    grey = Image.fromarray(out)
    graded = Image.merge("RGBA", (grey, grey,
                                  grey.point(lambda v: min(255, int(v * 1.04))), alpha))
    # crisp red rim ring, clipped to the disc's own alpha
    cx, cy, r = w / 2, h / 2, min(w, h) / 2 - 1
    rim = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(rim).ellipse((cx - r, cy - r, cx + r, cy + r),
                                outline=RED + (255,), width=max(2, int(min(w, h) * 0.075)))
    rim = rim.filter(ImageFilter.GaussianBlur(min(w, h) * 0.010))
    rim.putalpha(ImageChops.multiply(rim.getchannel("A"), alpha))
    graded.alpha_composite(rim)
    return graded


# --- action buttons -------------------------------------------------------
# These are labels, not glyphs, so they are drawn rather than graded: a dark
# graphite plate with a red edge and the console's Franklin Gothic italic, to
# retire the purple leaderboard and the dated daily-challenge bevel.
BSS = 8
DARK_HI, DARK_LO, WHITE = (32, 34, 39), (12, 13, 15), (238, 240, 243)
BUTTONS = {2285: "LEADERBOARD", 2289: "DAILY CHALLENGE"}


def make_button(label: str, size=(163, 61)) -> Image.Image:
    w, h = size[0] * BSS, size[1] * BSS
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = ImageDraw.Draw(im)
    r = h * 0.22
    body = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    bpx = body.load()
    for y in range(h):
        t = y / h
        col = tuple(int(DARK_HI[k] + (DARK_LO[k] - DARK_HI[k]) * t) for k in range(3))
        for x in range(w):
            bpx[x, y] = col + (255,)
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w - 1, h - 1), radius=r, fill=255)
    im.paste(body, (0, 0), mask)
    px.rounded_rectangle((BSS, BSS, w - BSS, h - BSS), radius=r,
                         outline=RED + (255,), width=int(BSS * 1.6))
    px.rounded_rectangle((int(BSS * 4), int(BSS * 3), w - int(BSS * 4), int(h * 0.42)),
                         radius=r * 0.7, fill=(255, 255, 255, 12))
    im = im.resize(size, Image.Resampling.LANCZOS)
    for face in ("framdit.ttf", "arialbd.ttf"):
        try:
            font = ImageFont.truetype(f"C:/Windows/Fonts/{face}", 19)
            break
        except OSError:
            continue
    else:
        font = ImageFont.load_default()
    p = ImageDraw.Draw(im)
    tb = p.textbbox((0, 0), label, font=font)
    tx = (size[0] - (tb[2] - tb[0])) / 2 - tb[0]
    ty = (size[1] - (tb[3] - tb[1])) / 2 - tb[1]
    p.text((tx + 1, ty + 1), label, font=font, fill=(0, 0, 0, 200))
    p.text((tx, ty), label, font=font, fill=WHITE)
    return im.filter(ImageFilter.GaussianBlur(0.3))


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for cid in BADGES:
        graded = regrade(extract_jpeg3(cid))
        graded.save(OUT_DIR / f"badge_{cid}.png", "PNG", optimize=True)
    for cid, label in BUTTONS.items():
        make_button(label).save(OUT_DIR / f"button_{cid}.png", "PNG", optimize=True)
    print(f"home badges regraded ({len(BADGES)}) + {len(BUTTONS)} buttons -> {OUT_DIR}")


if __name__ == "__main__":
    main()
