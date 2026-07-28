"""Prepare the small chrome bitmaps that the login redesign still inherited
from the legacy skin.

Three controls survived the login overhaul untouched because they are not part
of the login console: the header's Support control (a silver Windows-style
gradient plate with an orange warning triangle), the credential help button
(a Windows-blue speech bubble) and the plate behind the right-hand tab.

The concept (`01_header_complete.png`) draws Support as a white Discord glyph
plus red italic underlined text directly on the black strip - no plate at all.
Replacing the bitmaps in place keeps every button live and clickable; only the
pixels change.

Resolution
----------
The Support control is assembled from three characters: a 113x19 plate (2022),
a 46x12 caption (2020) and an 18x16 icon (2021). Only the plate is painted by
a shape whose *outer* fill array carries the bitmap matrix, so only the plate
can be retuned to 2x by `patch_bitmap_scale.py` - the other two are declared by
inline style-change records mid-shape. So the whole control is drawn into the
plate at 2x and the other two characters are blanked. Same for the help button,
whose shape (1943) does carry its matrix in the outer array.
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from swf_utils import ROOT

TELEMETRY_ELEMENTS = ROOT / "assets" / "telemetry_ui_v2" / "elements"
CONCEPT_HEADER = TELEMETRY_ELEMENTS / "01_header_complete.png"
OUT_DIR = ROOT / "assets" / "polish" / "prepared"

# Art authored at this multiple of the character's native size; the matching
# shape fill matrices are divided by it in scripts/patch_bitmap_scale.py.
SUPERSAMPLE = 2

# Native sizes of the characters being replaced, read from the SWF. A bitmap
# keeps its aspect: the shapes that paint them carry a fill matrix scaled for
# exactly this many stage pixels.
SIZE_SUPPORT_PLATE = (113, 19)   # char 2022 - carries the whole control now
SIZE_SUPPORT_TEXT = (46, 12)     # char 2020 - blanked
SIZE_SUPPORT_ICON = (18, 16)     # char 2021 - blanked
SIZE_TAB_PLATE = (37, 18)        # char 2017 - blanked
SIZE_HELP = (21, 23)             # char 1942 - red circled "?"

# Where the pieces sit inside the plate, in plate-local stage pixels. The plate
# is moved right by MOVE_SUPPORT_X in build_polish_patch.py to sit under the
# version caption in the concept's recessed panel; the content is pushed to the
# plate's right-hand end for the same reason, so the pair right-aligns.
GLYPH_BOX = (42, 2, 60, 18)
CAPTION_LEFT = 65
CAPTION_BASELINE = 3
CAPTION_SIZE = 10.5
UNDERLINE_GAP = 1

# The Discord glyph sits at these coordinates in the 1591x205 concept header.
CONCEPT_GLYPH_BOX = (1381, 87, 1419, 115)

SUPPORT_RED = (228, 44, 44, 255)
HELP_RED = (212, 42, 42, 255)


def font(name: str, size: int) -> ImageFont.FreeTypeFont:
    for candidate in (name, "arial.ttf"):
        try:
            return ImageFont.truetype(f"C:/Windows/Fonts/{candidate}", size)
        except OSError:
            continue
    return ImageFont.load_default()


def blank(size: tuple[int, int]) -> Image.Image:
    return Image.new("RGBA", size, (0, 0, 0, 0))


def concept_glyph() -> Image.Image:
    """The concept's white Discord glyph, keyed off its black backing."""
    if not CONCEPT_HEADER.exists():
        raise RuntimeError(f"Missing concept header: {CONCEPT_HEADER}")
    glyph = Image.open(CONCEPT_HEADER).convert("RGBA").crop(CONCEPT_GLYPH_BOX)
    pixels = glyph.load()
    for y in range(glyph.height):
        for x in range(glyph.width):
            r, g, b, _ = pixels[x, y]
            # The glyph is white-on-black, so luminance is its own coverage
            # mask. Lift it back to full white afterwards: the concept render
            # dims it slightly and it reads grey against the strip otherwise.
            alpha = max(r, g, b)
            boost = min(255, round(alpha * 1.25))
            pixels[x, y] = (boost, boost, boost, alpha)
    return glyph


def make_support_plate() -> Image.Image:
    """The whole Support control: Discord glyph, red italic caption, underline."""
    scale = SUPERSAMPLE
    draw_at = 4  # extra oversampling for the text, collapsed back down below
    total = scale * draw_at
    canvas = Image.new(
        "RGBA",
        (SIZE_SUPPORT_PLATE[0] * total, SIZE_SUPPORT_PLATE[1] * total),
        (0, 0, 0, 0),
    )

    glyph = concept_glyph()
    box_w = (GLYPH_BOX[2] - GLYPH_BOX[0]) * total
    box_h = (GLYPH_BOX[3] - GLYPH_BOX[1]) * total
    fitted = min(box_w / glyph.width, box_h / glyph.height)
    glyph = glyph.resize((round(glyph.width * fitted), round(glyph.height * fitted)),
                         Image.Resampling.LANCZOS)
    canvas.alpha_composite(
        glyph,
        (GLYPH_BOX[0] * total + (box_w - glyph.width) // 2,
         GLYPH_BOX[1] * total + (box_h - glyph.height) // 2),
    )

    draw = ImageDraw.Draw(canvas)
    face = font("arialbi.ttf", round(CAPTION_SIZE * total))
    left = CAPTION_LEFT * total
    top = CAPTION_BASELINE * total
    draw.text((left, top), "Support", font=face, fill=SUPPORT_RED, anchor="la")
    right = draw.textbbox((left, top), "Support", font=face, anchor="la")[2]
    rule = top + round(CAPTION_SIZE * total) + UNDERLINE_GAP * total
    draw.line((left, rule, right, rule), fill=SUPPORT_RED, width=max(1, total // 3))

    return canvas.resize(
        (SIZE_SUPPORT_PLATE[0] * scale, SIZE_SUPPORT_PLATE[1] * scale),
        Image.Resampling.LANCZOS,
    )


def make_help_icon() -> Image.Image:
    """Red circled '?', replacing the Windows-blue speech bubble."""
    scale = SUPERSAMPLE
    draw_at = 8
    total = scale * draw_at
    canvas = Image.new("RGBA", (SIZE_HELP[0] * total, SIZE_HELP[1] * total),
                       (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)
    # The source bubble is 21x23 with a tail below; the circle uses the square
    # part so the glyph lands where the old bubble's head was.
    diameter = SIZE_HELP[0] * total
    inset = 1 * total
    draw.ellipse((inset, inset, diameter - inset, diameter - inset),
                 outline=HELP_RED, width=round(1.5 * total))
    face = font("arialbd.ttf", round(12.5 * total))
    draw.text((diameter // 2, diameter // 2), "?", font=face, fill=HELP_RED,
              anchor="mm")
    return canvas.resize((SIZE_HELP[0] * scale, SIZE_HELP[1] * scale),
                         Image.Resampling.LANCZOS)


BUILDERS = {
    "support_plate.png": make_support_plate,
    "support_text.png": lambda: blank(SIZE_SUPPORT_TEXT),
    "support_icon.png": lambda: blank(SIZE_SUPPORT_ICON),
    "tab_plate.png": lambda: blank(SIZE_TAB_PLATE),
    "help_icon.png": make_help_icon,
}


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for name, builder in BUILDERS.items():
        image = builder()
        path = OUT_DIR / name
        image.save(path, "PNG", optimize=True)
        print(f"{name}: {image.width}x{image.height}, bytes={path.stat().st_size:,}")


if __name__ == "__main__":
    main()
