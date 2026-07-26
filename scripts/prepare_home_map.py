"""Regrade the home city-map background (character 2227) to graphite.

The deployed map ships in a flat light-grey that reads as legacy against the
dark-red client: pale landmass, red coastline glow, warm-white district labels.
This darkens the landmass to a moody graphite while leaving the red coast and
the labels intact - and, crucially, it recolours pixels in place without moving
any of them, so roads, coastlines and every fixed-coordinate location node stay
exactly where they were. The badges (SHOP / DEALERSHIP / HOME / ...) are drawn
by separate sprites on top of this bitmap, so they are untouched.

The original bitmap is read straight out of the base SWF's DefineBitsJPEG3 tag,
so there is no committed intermediate to drift out of date. build_polish_patch
then re-encodes the regraded result to a byte budget via replace_jpeg3.
"""
from __future__ import annotations

import colorsys
import io
import struct
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter

from swf_utils import ROOT

BASE = ROOT / "patches" / "main_client" / "main.dark-ui.current.swf"
OUT_DIR = ROOT / "assets" / "home" / "prepared"
OUT = OUT_DIR / "map_2227_graphite.png"

MAP_CHARACTER = 2227
DEFINE_BITS_JPEG3 = 35

# Night-map grade. The previous pass darkened the landmass but kept - and with
# RED_BOOST actually strengthened - the red coastal halo, plus the warm-yellow
# district labels. Those are the two things that read as legacy on this screen.
BACKGROUND = (9, 10, 12)        # #090A0C
ASPHALT = (35, 38, 41)          # #232629
ROAD_MAJOR = (75, 81, 90)       # #4B515A
ROAD_HIGH = (107, 114, 125)     # #6B727D
LABEL = (245, 247, 250)         # #F5F7FA
COAST = (216, 31, 38)           # #D81F26 - a line now, not a field
EDGE_WIDTH = 2
GLOW_WIDTH = 8
GLOW_ALPHA = 0.30
LABEL_PLATE = 3
LABEL_PLATE_ALPHA = 0.92
LABEL_PLATE_COLOUR = (10, 11, 13)


def extract_jpeg(character: int) -> Image.Image:
    """Decode the JPEG payload of a DefineBitsJPEG3 character from the base SWF."""
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
        if code == DEFINE_BITS_JPEG3:
            (found,) = struct.unpack_from("<H", data, pos + header)
            if found == character:
                (alpha_offset,) = struct.unpack_from("<I", data, pos + header + 2)
                jpeg = data[pos + header + 6: pos + header + 6 + alpha_offset]
                return Image.open(io.BytesIO(jpeg)).convert("RGB")
        pos += header + length
        if code == 0:
            break
    raise RuntimeError(f"DefineBitsJPEG3 {character} not found in {BASE}")


def regrade(source: Image.Image) -> Image.Image:
    """Recolour in place: night asphalt, neon coastline, readable white labels."""
    import numpy as np

    rgb = np.asarray(source, dtype=np.float32)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
    redness = r - np.maximum(g, b)

    raw = (lum >= 12) & (redness < 30)
    # The sea carries a faint reference grid whose lines clear that threshold.
    # Left in, every grid cell grows its own coastline. An opening deletes
    # anything thinner than the element while leaving the silhouette intact.
    raw_img = Image.fromarray((raw * 255).astype(np.uint8), "L")
    opened = raw_img.filter(ImageFilter.MinFilter(5)).filter(ImageFilter.MaxFilter(5))
    land = np.asarray(opened) > 127

    # Labels are found by BRIGHTNESS, not warmth: sampling shows only ~27% of
    # their bright pixels are red-biased - the glyph bodies are neutral white
    # with a warm fringe, so a warmth test keeps the fringe and drops the
    # letterforms. Not gated to land either: DIAMOND POINT's leading glyph
    # overhangs the shoreline into open water.
    label_region = (lum > 190) & (redness < 30)

    out = np.zeros_like(rgb)
    out[..., 0], out[..., 1], out[..., 2] = BACKGROUND

    lo, hi = 12.0, 200.0
    tt = np.clip((lum - lo) / (hi - lo), 0.0, 1.0)
    tt = (tt ** 1.9)[..., None]
    ramp_lo = np.array(ASPHALT, dtype=np.float32)
    ramp_mid = np.array(ROAD_MAJOR, dtype=np.float32)
    ramp_hi = np.array(ROAD_HIGH, dtype=np.float32)
    first = ramp_lo + (ramp_mid - ramp_lo) * np.clip(tt / 0.6, 0, 1)
    second = ramp_mid + (ramp_hi - ramp_mid) * np.clip((tt - 0.6) / 0.4, 0, 1)
    out[land] = np.where(tt < 0.6, first, second)[land]

    mask_img = Image.fromarray((land * 255).astype(np.uint8), "L")
    grown = mask_img.filter(ImageFilter.MaxFilter(EDGE_WIDTH * 2 + 1))
    ring = (np.asarray(grown, dtype=np.int16) - np.asarray(mask_img, dtype=np.int16)) > 0

    glow_img = mask_img.filter(ImageFilter.MaxFilter(GLOW_WIDTH * 2 + 1))
    glow_img = glow_img.filter(ImageFilter.GaussianBlur(GLOW_WIDTH * 0.6))
    glow = np.asarray(glow_img, dtype=np.float32) / 255.0
    glow = np.clip(glow - land.astype(np.float32), 0, 1) * GLOW_ALPHA
    coast = np.array(COAST, dtype=np.float32)
    out = out * (1 - glow[..., None]) + coast * glow[..., None]
    out[ring] = coast

    lab_img = Image.fromarray((label_region * 255).astype(np.uint8), "L")
    plate_img = lab_img.filter(ImageFilter.MaxFilter(LABEL_PLATE * 2 + 1))
    plate_img = plate_img.filter(ImageFilter.GaussianBlur(LABEL_PLATE * 0.5))
    plate = (np.asarray(plate_img, dtype=np.float32) / 255.0 * LABEL_PLATE_ALPHA)[..., None]
    out = out * (1 - plate) + np.array(LABEL_PLATE_COLOUR, dtype=np.float32) * plate

    cover = (np.clip((lum - 168.0) / 42.0, 0.0, 1.0) * label_region)[..., None]
    out = out * (1 - cover) + np.array(LABEL, dtype=np.float32) * cover

    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGB").convert("RGBA")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    original = extract_jpeg(MAP_CHARACTER)
    graded = regrade(original)
    graded.save(OUT, "PNG", optimize=True)
    print(f"home map: {graded.width}x{graded.height} regraded -> {OUT.name}")


if __name__ == "__main__":
    main()
