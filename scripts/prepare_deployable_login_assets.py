"""Prepare fixed-size-safe login artwork for the embedded main.swf.

The stage is rebuilt from the `assets/telemetry_ui_v2` element pack against the
measurements of the approved concept render
(`assets/login/login_telemetry_exact_cars_v2.png`, 1608x978), mapped onto the
game's 800x600 stage.

Two things constrain the layout and are the reason this is not just a resize of
the concept:

1. The game's header is a live 798x69 strip (character 2003) drawn ON TOP of
   this background. The concept's header band is proportionally ~126px tall, so
   the concept cannot be mapped 1:1 — the hero band starts at 69, not 146.
2. The console's buttons and credential fields are live SWF objects. Anything
   baked in behind them ghosts through, so the console band gets the *blank*
   shell plus static text only, positioned to match the concept.

Art is authored at SUPERSAMPLE x so it survives the "showAll" upscale when the
window is maximised; scripts/patch_bitmap_scale.py divides the matching shape
fill matrices by the same factor.
"""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from swf_utils import ROOT

TELEMETRY_ROOT = ROOT / "assets" / "telemetry_ui_v2"
TELEMETRY_ELEMENTS = TELEMETRY_ROOT / "elements"
MANIFEST = TELEMETRY_ELEMENTS / "manifest.json"
OUT_DIR = ROOT / "assets" / "login" / "prepared"

STAGE_SIZE = (800, 600)
BITMAP_SIZE = (850, 650)
STAGE_OFFSET = (18, 14)

SUPERSAMPLE = 2


def px(value: float) -> int:
    """Logical stage pixels -> authored bitmap pixels."""
    return round(value * SUPERSAMPLE)


# Dropped from 108,000 when the logo moved into the header strip and the band
# behind that strip was flattened to black: the same picture now costs far less,
# so a smaller allowance still buys the same quality as before (48),
# and the freed bytes pay for the sharp header logo.
BACKGROUND_BUDGET = 91_500

# --- concept mapping -------------------------------------------------------
# The concept render is 1608x978. Multiply its coordinates by these to land on
# the 800x600 stage. Every console number below is derived this way, so the
# layout matches the approved design instead of being invented.
CONCEPT_SIZE = (1608, 978)
CONCEPT_X = STAGE_SIZE[0] / CONCEPT_SIZE[0]   # 0.4975
CONCEPT_Y = STAGE_SIZE[1] / CONCEPT_SIZE[1]   # 0.6135

# The live header strip covers this much of the stage and is opaque.
HEADER_RESERVED_HEIGHT = 69

# Console band, straight off the concept: source y 659..931, x 27..1583.
CONSOLE_TOP = 404
CONSOLE_BOTTOM = 571
CONSOLE_LEFT = 13
CONSOLE_RIGHT = 788

# Hero band. Filling the band's full height would crop ~28% of the scene's
# width and cut the outer Chevelle and Mustang in half; showing the scene at
# full width leaves a third of the band empty. 0.24 is the balance: a mild
# ~9%-per-side crop with the cars still whole, and the remainder carrying the
# garage backdrop rather than dead black.
HERO_BACKDROP_RATIO = 0.24
# How opaque the extended ceiling stays at the very top. Fading fully to black
# is what made the upper band read as an empty void instead of a room.
HERO_CEILING_MIN_ALPHA = 70

# The logo is no longer baked here. It lives in the header strip as character
# 2039 (see prepare_header_assets.py), which scripts/unhide_character.py brings
# back out of hiding — so it sits inside the chrome and appears on every screen
# that carries the strip, not just this one.

# --- console text ----------------------------------------------------------
# (x, y) pairs are stage pixels, mapped from the concept.
CONSOLE_DIVIDERS = (259, 420)
HEADING_DISCORD = (50, 419)
SUB_DISCORD = (77, 444)
HEADING_RACER = (295, 419)
SUB_RACER = (290, 444)
LABEL_RACER_NAME = (437, 421)
LABEL_PASSWORD = (437, 456)
WELL_LEFT = 533
WELL_RIGHT = 764
WELL_TOPS = (417, 452)
WELL_HEIGHT = 24
SECURE_NOTE = (34, 545)
RECOVERY_RIGHT = 765
RECOVERY_TOP = 545

BUTTONS = {
    "btn_discord": {"size": (174, 29), "budget": 4_200, "source": "09_button_discord.png"},
    "btn_create": {"size": (172, 29), "budget": 4_200, "source": "10_button_create_account.png"},
    "btn_login": {"size": (172, 29), "budget": 4_200, "source": "11_button_login.png"},
}


def save_jpeg_to_budget(image: Image.Image, path: Path, budget: int) -> int:
    # Chroma subsampling is chosen against the authored resolution, not by
    # taste. At 1x, 4:2:0 halves chroma below stage resolution and smears the
    # highlights on the cars. At 2x, 4:2:0 still leaves chroma at the old 1x
    # full-chroma resolution while freeing a large share of the budget for
    # luma, which carries the edges and the baked console text.
    subsampling = 2 if SUPERSAMPLE >= 2 else 0
    low, high, best = 4, 95, None
    while low <= high:
        quality = (low + high) // 2
        image.save(path, "JPEG", quality=quality, optimize=True,
                   progressive=False, subsampling=subsampling)
        if path.stat().st_size <= budget:
            best = quality
            low = quality + 1
        else:
            high = quality - 1
    if best is None:
        best = 1
    image.save(path, "JPEG", quality=best, optimize=True,
               progressive=False, subsampling=subsampling)
    if path.stat().st_size > budget:
        raise RuntimeError(f"Could not fit {path.name} within {budget:,} bytes")
    return best


def load_manifest() -> dict:
    if not MANIFEST.exists():
        raise SystemExit(f"Missing element manifest: {MANIFEST}")
    return json.loads(MANIFEST.read_text(encoding="utf-8"))


def load_element(name: str) -> Image.Image:
    path = TELEMETRY_ELEMENTS / f"{name}.png"
    if not path.exists():
        raise SystemExit(f"Missing telemetry element: {path}")
    return Image.open(path).convert("RGBA")


def font(name: str, size: float) -> ImageFont.FreeTypeFont:
    """Load a Windows face at supersampled size, falling back gracefully."""
    for candidate in (name, "arial.ttf"):
        try:
            return ImageFont.truetype(f"C:/Windows/Fonts/{candidate}", px(size))
        except OSError:
            continue
    return ImageFont.load_default()


def place(stage: Image.Image, element: Image.Image,
          box: tuple[float, float, float, float]) -> None:
    left, top, right, bottom = (px(v) for v in box)
    resized = element.resize((right - left, bottom - top), Image.Resampling.LANCZOS)
    stage.alpha_composite(resized, (left, top))


def place_hero(stage: Image.Image, element: Image.Image, top: float, bottom: float) -> None:
    """Fill the hero band with the car scene, cropping the sides, not the floor.

    The concept's hero crop is 1600x422 (aspect 3.79) but the band left over
    once the 69px live header is reserved is much squarer. Fitting by width
    left a third of the band as dead black above the cars; fitting by height
    would crop the outer two cars off the stage. Instead the source is cropped
    horizontally to the band's aspect — keeping full car height — and a slim
    backdrop strip is extended above it, matching the concept's own proportion.
    """
    band_height = (bottom - top) * (1 - HERO_BACKDROP_RATIO)
    car_top = bottom - band_height
    width, height = px(STAGE_SIZE[0]), px(band_height)

    target_aspect = width / height
    crop_width = min(element.width, round(element.height * target_aspect))
    inset = (element.width - crop_width) // 2
    cropped = element.crop((inset, 0, inset + crop_width, element.height))
    scaled = cropped.resize((width, height), Image.Resampling.LANCZOS)

    fill_height = px(car_top) - px(top)
    if fill_height > 0:
        # Extend the scene's own dark ceiling upward and ramp it into black, so
        # the strip above the cars reads as the same garage rather than a band
        # of flat black.
        ceiling = scaled.crop((0, 0, width, min(px(6), height)))
        ceiling = ceiling.resize((width, fill_height), Image.Resampling.LANCZOS)
        ramp = Image.linear_gradient("L").resize((width, fill_height),
                                                 Image.Resampling.BILINEAR)
        span = 255 - HERO_CEILING_MIN_ALPHA
        ceiling.putalpha(ramp.point(lambda v: HERO_CEILING_MIN_ALPHA + v * span // 255))
        stage.alpha_composite(ceiling, (0, px(top)))
    stage.alpha_composite(scaled, (0, px(car_top)))


def draw_padlock(stage: Image.Image, anchor: tuple[float, float]) -> None:
    """Draw the concept's closed padlock to the left of "Secure Connection".

    A bare rounded rectangle - what this used to be - reads as an unchecked
    checkbox at 8px, which inverts the meaning of the line it labels. The lock
    is drawn on its own oversampled canvas so the shackle stays a clean arc
    once it is scaled down to roughly 8x9 stage pixels.
    """
    oversample = 4
    body_w, body_h = 8.0, 5.5
    shackle_h = 3.5
    width = round(body_w * SUPERSAMPLE * oversample)
    height = round((body_h + shackle_h) * SUPERSAMPLE * oversample)
    tile = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    pen = ImageDraw.Draw(tile)
    stroke = max(1, round(SUPERSAMPLE * oversample * 0.9))
    metal = (168, 171, 177, 255)

    shackle_inset = width * 0.24
    shackle_box = (shackle_inset, stroke // 2,
                   width - shackle_inset, height * 0.62)
    pen.arc(shackle_box, start=180, end=360, fill=metal, width=stroke)
    body_top = round(height * (shackle_h / (body_h + shackle_h)))
    pen.rounded_rectangle((0, body_top, width - 1, height - 1),
                          radius=stroke, fill=metal)
    keyhole = width * 0.13
    centre_x, centre_y = width / 2, body_top + (height - body_top) * 0.42
    pen.ellipse((centre_x - keyhole, centre_y - keyhole,
                 centre_x + keyhole, centre_y + keyhole),
                fill=(12, 13, 15, 255))

    target = (round(body_w * SUPERSAMPLE),
              round((body_h + shackle_h) * SUPERSAMPLE))
    stage.alpha_composite(
        tile.resize(target, Image.Resampling.LANCZOS),
        (px(anchor[0] - 11), px(anchor[1] - 1)),
    )


def draw_console(stage: Image.Image) -> None:
    """Draw the console's static text, matching the concept's typography.

    Only non-interactive art is drawn. The Discord / Create Account / Login
    buttons, both credential fields and the help button stay live SWF objects,
    so the shell is left empty everywhere they land.
    """
    draw = ImageDraw.Draw(stage)
    heading_font = font("arialbi.ttf", 13)    # concept headings are bold italic
    sub_font = font("ariali.ttf", 9.5)        # subtitles are italic
    label_font = font("arialbd.ttf", 9.5)     # field labels are upright bold
    note_font = font("ariali.ttf", 8)

    def text(pos: tuple[float, float], value: str, face, fill, anchor: str = "la") -> None:
        draw.text((px(pos[0]), px(pos[1])), value, font=face, fill=fill, anchor=anchor)

    # Column dividers. They stop short of the console's rounded corners and
    # clear every live button: btnFBConnect ends at 237, btnCreateAccount at
    # 406, btnStart starts at 438.
    for divider_x in CONSOLE_DIVIDERS:
        draw.line(
            (px(divider_x), px(CONSOLE_TOP + 8), px(divider_x), px(CONSOLE_BOTTOM - 8)),
            fill=(58, 60, 64), width=SUPERSAMPLE,
        )

    text(HEADING_DISCORD, "CONNECT WITH DISCORD", heading_font, (236, 238, 241))
    text(SUB_DISCORD, "Secure and fast login", sub_font, (146, 149, 155))
    text(HEADING_RACER, "NEW RACER?", heading_font, (236, 238, 241))
    text(SUB_RACER, "Create your account", sub_font, (146, 149, 155))
    text(LABEL_RACER_NAME, "RACER NAME", label_font, (222, 224, 228))
    text(LABEL_PASSWORD, "PASSWORD", label_font, (222, 224, 228))

    # Credential wells. The live fields are placed to sit inside these; see
    # ui_layout.json, which is derived from the same concept coordinates.
    for well_top in WELL_TOPS:
        draw.rounded_rectangle(
            (px(WELL_LEFT), px(well_top), px(WELL_RIGHT), px(well_top + WELL_HEIGHT)),
            radius=px(3), fill=(9, 10, 12), outline=(70, 73, 79), width=SUPERSAMPLE,
        )

    # Footer row, both italic in the concept.
    draw_padlock(stage, SECURE_NOTE)
    text(SECURE_NOTE, "Secure Connection", note_font, (162, 165, 171))
    text((RECOVERY_RIGHT, RECOVERY_TOP), "Forgot password?", sub_font,
         (198, 201, 207), anchor="ra")


def make_stage(manifest: dict) -> Image.Image:
    """Composite the stage from the approved element layers, at SUPERSAMPLE x."""
    del manifest  # geometry now comes from the concept mapping, not the crops
    stage = Image.new("RGBA", (px(STAGE_SIZE[0]), px(STAGE_SIZE[1])), (0, 0, 0, 255))

    place_hero(stage, load_element("04_car_hero_complete"),
               HEADER_RESERVED_HEIGHT, CONSOLE_TOP)

    # Illuminated trim along the top edge of the console band.
    trim = load_element("16_red_edge_trim")
    place(stage, trim, (CONSOLE_LEFT + 2, CONSOLE_TOP - 6, CONSOLE_RIGHT - 2, CONSOLE_TOP))

    # Blank shell, so no baked labels/wells/buttons ghost behind live controls.
    place(stage, load_element("19_console_shell_blank"),
          (CONSOLE_LEFT, CONSOLE_TOP, CONSOLE_RIGHT, CONSOLE_BOTTOM))

    draw_console(stage)

    # The live header strip is opaque and covers the top of this bitmap, so
    # whatever lands under it is never seen but still costs JPEG bits. Flatten
    # it, and spend the freed budget on the hero band instead.
    stage.paste((0, 0, 0, 255),
                (0, 0, stage.width, px(HEADER_RESERVED_HEIGHT)))
    return stage.convert("RGB")


def make_button(size: tuple[int, int], source_name: str) -> Image.Image:
    """Fit the approved action art into its SWF bitmap.

    The bitmap's aspect (roughly 6:1) does not match the concept art, but the
    display matrix in ui_layout.json stretches it back out non-uniformly, so a
    plain resize here is what produces the correct proportions on stage.
    """
    source = TELEMETRY_ELEMENTS / source_name
    if not source.exists():
        raise RuntimeError(f"Missing telemetry button: {source}")
    crop = Image.open(source).convert("RGB").resize(
        (px(size[0]), px(size[1])), Image.Resampling.LANCZOS
    )
    # Shift the legacy blue/steel controls into the maroon racing palette while
    # retaining the original white glyphs and readable contrast.
    maroon = Image.new("RGB", crop.size, (112, 8, 20))
    return Image.blend(crop, maroon, 0.32)


def extend_into_bitmap(stage: Image.Image) -> Image.Image:
    # The legacy shape can expose the entire 850x650 bitmap even though the
    # intended stage is only 800x600. Keep all pixels outside that stage solid
    # black so artwork cannot bleed into the host application's frame.
    bitmap = Image.new("RGB", (px(BITMAP_SIZE[0]), px(BITMAP_SIZE[1])), (0, 0, 0))
    bitmap.paste(stage, (px(STAGE_OFFSET[0]), px(STAGE_OFFSET[1])))
    return bitmap


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    manifest = load_manifest()

    stage = make_stage(manifest)
    stage.save(OUT_DIR / "login_stage_800x600.png", "PNG", optimize=True)
    bitmap = extend_into_bitmap(stage)
    bitmap.save(OUT_DIR / "login_bitmap_850x650_preview.png", "PNG", optimize=True)
    quality = save_jpeg_to_budget(bitmap, OUT_DIR / "login_bitmap_850x650.jpg",
                                  BACKGROUND_BUDGET)
    # Filenames keep their logical stage dimensions so the build script's paths
    # stay stable; the pixel dimensions are SUPERSAMPLE x those numbers.
    print(f"background: {bitmap.width}x{bitmap.height} ({SUPERSAMPLE}x), "
          f"quality={quality}, "
          f"bytes={(OUT_DIR / 'login_bitmap_850x650.jpg').stat().st_size:,}")

    # Remove the legacy warning triangle while preserving the password-
    # recovery button symbol and its click target.
    Image.new("RGBA", (15, 15), (0, 0, 0, 0)).save(
        OUT_DIR / "forgot_icon_15x15.png", "PNG", optimize=True
    )

    for name, config in BUTTONS.items():
        crop = make_button(config["size"], config["source"])
        preview = OUT_DIR / f"{name}_{config['size'][0]}x{config['size'][1]}.png"
        crop.save(preview, "PNG", optimize=True)
        jpeg = preview.with_suffix(".jpg")
        quality = save_jpeg_to_budget(crop, jpeg, config["budget"])
        print(f"{name}: {crop.width}x{crop.height} ({SUPERSAMPLE}x), "
              f"quality={quality}, bytes={jpeg.stat().st_size:,}")


if __name__ == "__main__":
    main()
