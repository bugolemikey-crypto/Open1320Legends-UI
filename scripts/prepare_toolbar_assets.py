"""Draw the header dock bar - NIM, Email, Viewer and Support - as one family.

The four tabs shipped in the legacy skin as glossy Windows-XP plates with
desktop icons baked into them: three different heights, three different bevels,
and a Support control that was a silver gradient plate with an orange warning
triangle. Docked side by side by `sortDockTabs` they read as four buttons
borrowed from four different programs.

Every tab here is the same object: a PANEL_HEIGHT-tall recessed panel in the
dark theme's surface colours, a hairline border, an accent rule along the
bottom, a flat 9px glyph and a letter-spaced uppercase label. The panels are
drawn at a per-tab inset (`header_layout.TABS`) so that once the build nudges
each placement vertically they line up on one baseline, which is the thing the
old bar could never do - its bitmaps are 24, 22 and 19 pixels tall and their
placements disagreed by another six.

NIM ships twice: `hilite` is a separate character (2007) that `pmButton` shows
over the normal art to flash the tab when a private message arrives, so it is
the same panel lit on the accent.

Art is authored at SUPERSAMPLE and the shapes' bitmap fill matrices are divided
to match in `build_polish_patch.py`; the game runs `showAll`, so a 1:1 bitmap
is magnified with nothing in reserve when the window is maximised.
"""
from __future__ import annotations

from PIL import Image, ImageDraw, ImageFilter, ImageFont

import header_layout
from swf_utils import ROOT

OUT = ROOT / "assets" / "header" / "prepared"
ELEMENTS = ROOT / "assets" / "telemetry_ui_v2" / "elements"
CONCEPT_HEADER = ELEMENTS / "01_header_complete.png"

SUPERSAMPLE = 2
# Text and glyphs are drawn this much larger again and resampled down; at 8.4px
# a stroke is under a pixel wide and rasterising it directly loses it.
OVERSAMPLE = 4

# Dark theme surfaces, from DARK_UI_THEME.md.
PANEL_TOP_RGB = (35, 42, 46)
PANEL_BOTTOM_RGB = (18, 22, 26)
BORDER_RGB = (51, 59, 67)
HIGHLIGHT_RGB = (60, 68, 76)
LABEL_RGB = (200, 208, 218)
GLYPH_RGB = (138, 147, 158)
ACCENT_RGB = (255, 56, 35)

# The lit state: same panel, accent border and rule, white label.
LIT_TOP_RGB = (46, 22, 22)
LIT_BOTTOM_RGB = (24, 12, 13)
LIT_LABEL_RGB = (255, 255, 255)

RADIUS = 2
LABEL_SIZE = 8.4
LABEL_TRACKING = 0.55
GLYPH_SIZE = 9
GLYPH_GAP = 4

# The Discord glyph in the 1591x205 concept header, keyed off its black backing.
CONCEPT_GLYPH_BOX = (1381, 87, 1419, 115)


def px(value: float) -> int:
    return round(value * SUPERSAMPLE)


def font(size: float) -> ImageFont.FreeTypeFont:
    for name in ("arialbd.ttf", "arial.ttf"):
        try:
            return ImageFont.truetype(f"C:/Windows/Fonts/{name}", round(size))
        except OSError:
            continue
    return ImageFont.load_default()


def blank(size: tuple[int, int]) -> Image.Image:
    return Image.new("RGBA", (px(size[0]), px(size[1])), (0, 0, 0, 0))


def panel(width: int, lit: bool) -> Image.Image:
    """The tab body: gradient fill, hairline border, accent rule underneath."""
    height = header_layout.PANEL_HEIGHT
    image = Image.new("RGBA", (px(width), px(height)), (0, 0, 0, 0))

    top, bottom = ((LIT_TOP_RGB, LIT_BOTTOM_RGB) if lit
                   else (PANEL_TOP_RGB, PANEL_BOTTOM_RGB))
    gradient = Image.new("RGB", (1, image.height))
    for y in range(image.height):
        blend = y / max(1, image.height - 1)
        gradient.putpixel((0, y), tuple(
            round(a + (b - a) * blend) for a, b in zip(top, bottom)
        ))
    gradient = gradient.resize(image.size)

    mask = Image.new("L", image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, image.width - 1, image.height - 1), radius=px(RADIUS), fill=255)
    image.paste(gradient, (0, 0), mask)

    draw = ImageDraw.Draw(image)
    border = ACCENT_RGB + (200,) if lit else BORDER_RGB + (255,)
    draw.rounded_rectangle((0, 0, image.width - 1, image.height - 1),
                           radius=px(RADIUS), outline=border, width=SUPERSAMPLE // 2 or 1)
    # A single lit row just inside the top edge stops the gradient reading flat.
    draw.line((px(RADIUS), SUPERSAMPLE, image.width - 1 - px(RADIUS), SUPERSAMPLE),
              fill=HIGHLIGHT_RGB + (110,), width=SUPERSAMPLE // 2 or 1)
    # The accent rule: the one element every tab shares, so the run reads as a
    # bar rather than as four separate buttons.
    rule = image.height - 1 - SUPERSAMPLE
    draw.line((px(RADIUS + 1), rule, image.width - 1 - px(RADIUS + 1), rule),
              fill=ACCENT_RGB + (255 if lit else 150,), width=SUPERSAMPLE)
    return image


def glow(image: Image.Image) -> Image.Image:
    """Bloom the accent outwards, for the NIM alert state."""
    bloom = Image.new("RGBA", image.size, ACCENT_RGB + (255,))
    bloom.putalpha(image.getchannel("A")
                   .filter(ImageFilter.GaussianBlur(px(1.5)))
                   .point(lambda v: v * 55 // 100))
    bloom.alpha_composite(image)
    return bloom


def glyph_chat(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int],
               colour: tuple[int, int, int]) -> None:
    left, top, right, bottom = box
    body = bottom - (bottom - top) // 4
    draw.rounded_rectangle((left, top, right, body), radius=(body - top) // 3,
                           fill=colour + (255,))
    draw.polygon([(left + (right - left) // 4, body),
                  (left + (right - left) // 2, bottom),
                  (left + (right - left) // 2, body)], fill=colour + (255,))


def glyph_mail(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int],
               colour: tuple[int, int, int]) -> None:
    left, top, right, bottom = box
    inset = (bottom - top) // 8
    top, bottom = top + inset, bottom - inset
    stroke = max(1, (right - left) // 9)
    draw.rectangle((left, top, right, bottom), outline=colour + (255,), width=stroke)
    middle = (left + right) // 2
    draw.line((left, top, middle, (top + bottom) // 2 + stroke),
              fill=colour + (255,), width=stroke)
    draw.line((middle, (top + bottom) // 2 + stroke, right, top),
              fill=colour + (255,), width=stroke)


def glyph_eye(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int],
              colour: tuple[int, int, int]) -> None:
    left, top, right, bottom = box
    middle = (top + bottom) // 2
    stroke = max(1, (right - left) // 9)
    # A lens, not a circle: two thirds as tall as it is wide reads as an eye at
    # nine pixels, where an outlined circle reads as a button.
    lens = (right - left) // 3
    draw.ellipse((left, middle - lens, right, middle + lens),
                 outline=colour + (255,), width=stroke)
    radius = (right - left) // 6
    draw.ellipse(((left + right) // 2 - radius, middle - radius,
                  (left + right) // 2 + radius, middle + radius),
                 fill=colour + (255,))


def glyph_discord(canvas: Image.Image, box: tuple[int, int, int, int],
                  colour: tuple[int, int, int]) -> None:
    """The concept header's Discord mark, recoloured onto the tab palette."""
    if not CONCEPT_HEADER.exists():
        raise RuntimeError(f"Missing concept header: {CONCEPT_HEADER}")
    mark = Image.open(CONCEPT_HEADER).convert("RGB").crop(CONCEPT_GLYPH_BOX)
    # White on black, so luminance is its own coverage mask.
    alpha = mark.convert("L").point(lambda v: min(255, round(v * 1.35)))
    left, top, right, bottom = box
    fitted = min((right - left) / alpha.width, (bottom - top) / alpha.height)
    size = (max(1, round(alpha.width * fitted)), max(1, round(alpha.height * fitted)))
    alpha = alpha.resize(size, Image.Resampling.LANCZOS)
    tinted = Image.new("RGBA", size, colour + (255,))
    tinted.putalpha(alpha)
    canvas.alpha_composite(tinted, (left + (right - left - size[0]) // 2,
                                    top + (bottom - top - size[1]) // 2))


VECTOR_GLYPHS = {"chat": glyph_chat, "mail": glyph_mail, "eye": glyph_eye}


def tracked_width(face: ImageFont.FreeTypeFont, label: str, tracking: float) -> float:
    return sum(face.getlength(c) for c in label) + tracking * max(0, len(label) - 1)


def content(width: int, label: str, kind: str, lit: bool) -> Image.Image:
    """Glyph and label, drawn oversampled and resolved down onto the panel."""
    scale = SUPERSAMPLE * OVERSAMPLE
    canvas = Image.new("RGBA", (width * scale, header_layout.PANEL_HEIGHT * scale),
                       (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)
    face = font(LABEL_SIZE * scale)
    tracking = LABEL_TRACKING * scale

    text_width = tracked_width(face, label, tracking)
    glyph_width = GLYPH_SIZE * scale
    left = round((canvas.width - (glyph_width + GLYPH_GAP * scale + text_width)) / 2)
    middle = canvas.height // 2

    box = (left, middle - glyph_width // 2, left + glyph_width, middle + glyph_width // 2)
    if kind == "discord":
        glyph_discord(canvas, box, LIT_LABEL_RGB if lit else LABEL_RGB)
    else:
        VECTOR_GLYPHS[kind](draw, box, ACCENT_RGB if lit else GLYPH_RGB)

    cursor = left + glyph_width + GLYPH_GAP * scale
    fill = (LIT_LABEL_RGB if lit else LABEL_RGB) + (255,)
    for character in label:
        draw.text((cursor, middle), character, font=face, fill=fill, anchor="lm")
        cursor += face.getlength(character) + tracking

    return canvas.resize((px(width), px(header_layout.PANEL_HEIGHT)),
                         Image.Resampling.LANCZOS)


def tab(name: str, label: str, kind: str, lit: bool = False) -> Image.Image:
    size, inset, _ = header_layout.TABS[name]
    image = blank(size)
    body = panel(size[0], lit)
    body.alpha_composite(content(size[0], label, kind, lit))
    if lit:
        body = glow(body)
    image.alpha_composite(body, (0, px(inset)))
    return image


BUILDERS = {
    "toolbar_nim_67x24.png": lambda: tab("nim", "NIM", "chat"),
    "toolbar_nim_hilite_67x24.png": lambda: tab("nim", "NIM", "chat", lit=True),
    "toolbar_email_80x22.png": lambda: tab("email", "EMAIL", "mail"),
    "toolbar_viewer_86x22.png": lambda: tab("viewer", "VIEWER", "eye"),
    # 20 tall, not 19: the bitmap has to match shape 2023's bounds. See
    # header_layout.TABS. The panel sits at inset 0 and the last row is blank.
    "toolbar_support_113x20.png": lambda: tab("support", "SUPPORT", "discord"),
}


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for filename, builder in BUILDERS.items():
        image = builder()
        path = OUT / filename
        image.save(path, "PNG", optimize=True)
        print(f"{filename}: {image.width}x{image.height} ({SUPERSAMPLE}x), "
              f"bytes={path.stat().st_size:,}")


if __name__ == "__main__":
    main()
