"""Build the production bitmaps for the main header strip and its logo.

Two characters make up the header:

* 2003 - the 798x69 chrome strip (shape 2004).
* 2039 - the logo lockup (shape 2040), whose box is at stage x 78..343,
  y 6.8..80.8 and is moved 14px left by the build. It used to be blanked with
  a zero colour transform, so the logo
  had to be baked into the login background instead, where it could only appear
  on the login screen. `scripts/unhide_character.py` restores it, so the logo is
  back inside the chrome and shows on every screen that carries the strip.

The chrome comes from the *concept* header rather than `18_header_shell_blank`.
The blank shell is one continuous empty trough; the concept splits it into a
logo bay and a recessed right-hand panel with a red accent tick, and that
division is most of what makes the strip read as designed. Only the three baked
elements the SWF draws live - the logo, the version caption and the Discord /
Support control - are painted out.

The concept header is 1591x205 (aspect 7.8) and the strip is 798x69 (aspect
11.6), so mapping one onto the other squashes it vertically by 0.671 relative
to its horizontal scale. The logo is squashed by the same factor rather than
kept at its own aspect: it then matches the chrome it sits in, and lands at the
same proportions as the concept's own lockup.
"""
from __future__ import annotations

from PIL import Image, ImageFilter

from prepare_deployable_login_assets import SUPERSAMPLE, px, save_jpeg_to_budget
from swf_utils import ROOT

ELEMENTS = ROOT / "assets" / "telemetry_ui_v2" / "elements"
OUT_DIR = ROOT / "assets" / "header" / "prepared"

CONCEPT_HEADER = ELEMENTS / "01_header_complete.png"
BLANK_SHELL = ELEMENTS / "18_header_shell_blank.png"
REPOSITORY_LOGO = ELEMENTS / "00_logo_repository_original.png"

SIZE = (798, 69)
HEADER_BUDGET = 13_200

# Character 2039's box on stage, from shape 2040's bounds.
LOGO_SIZE = (265, 74)
LOGO_BUDGET = 18_000
# Vertical squash the concept picks up when 1591x205 is mapped to 798x69.
CONCEPT_SQUASH = (69 / 205) / (798 / 1591)
# Sits the lockup inside the strip. The character's box starts at stage y 6.8,
# which puts the "1320" glyphs hard against the chrome's top bezel; 8 bitmap px
# (4 stage px) down centres it in the bay and still clears the 69px lower edge.
LOGO_TOP_INSET = 8
# Soft dark halo behind the lockup, in stage pixels of blur, and how much of it
# survives (percent). It is painted into the *chrome*, not into the logo: as
# part of the logo it has to be carried by a smooth alpha ramp over most of a
# character with a tight byte allowance, and it cost more of that allowance
# than the lockup itself. The chrome is nearly flat and compresses for almost
# nothing, so the same gradient is close to free there.
HALO_RADIUS = 5
HALO_STRENGTH = 62
# Where the logo character's top-left corner lands inside the chrome bitmap.
# Shape 2004 starts at stage (1, 1.8); shape 2040, once moved, starts at
# (64, 6.8). Both are authored at SUPERSAMPLE.
HALO_ORIGIN = (63, 5)
# How far edge colour is pushed into the transparent margin, in stage pixels.
BLEED_RADIUS = 3

# Regions of the 1591x205 concept that carry baked content the SWF draws live.
LOGO_REGION = (130, 6, 732, 199)
VERSION_REGION = (1336, 36, 1534, 80)
SUPPORT_REGION = (1364, 80, 1534, 128)
# Clean panel of the same vertical gradient, copied across to cover the two
# text regions. The panel's gradient runs vertically, so a horizontal copy at
# the same rows is an exact match.
CLEAN_SOURCE_LEFT = 1000


def clear_region(image: Image.Image, region: tuple[int, int, int, int],
                 source: Image.Image | None = None) -> None:
    left, top, right, bottom = region
    if source is not None:
        image.paste(source.crop(region), (left, top))
        return
    width = right - left
    patch = image.crop((CLEAN_SOURCE_LEFT, top, CLEAN_SOURCE_LEFT + width, bottom))
    image.paste(patch, (left, top))


def build_chrome(halo: Image.Image | None = None) -> Image.Image:
    for path in (CONCEPT_HEADER, BLANK_SHELL):
        if not path.exists():
            raise RuntimeError(f"Missing header element: {path}")
    concept = Image.open(CONCEPT_HEADER).convert("RGB")
    blank = Image.open(BLANK_SHELL).convert("RGB")
    if blank.size != concept.size:
        blank = blank.resize(concept.size, Image.Resampling.LANCZOS)

    # The logo bay is identical in both renders once the lockup is taken out,
    # so the blank shell supplies exact replacement pixels there.
    clear_region(concept, LOGO_REGION, blank)
    clear_region(concept, VERSION_REGION)
    clear_region(concept, SUPPORT_REGION)
    chrome = concept.resize((px(SIZE[0]), px(SIZE[1])), Image.Resampling.LANCZOS)
    if halo is not None:
        shade = Image.new("L", chrome.size, 0)
        shade.paste(
            halo.filter(ImageFilter.GaussianBlur(HALO_RADIUS * SUPERSAMPLE)),
            (px(HALO_ORIGIN[0]), px(HALO_ORIGIN[1])),
        )
        chrome = Image.composite(
            Image.new("RGB", chrome.size, (0, 0, 0)), chrome,
            shade.point(lambda v: v * HALO_STRENGTH // 100),
        )
    return chrome


def build_logo() -> Image.Image:
    """Logo lockup on transparency, squashed to match the chrome around it.

    Colour is bled outwards into the transparent margin. This ships as a
    DefineBitsJPEG3 - lossy RGB plus a separate alpha channel - and JPEG
    spreads whatever sits in the fully transparent pixels back across the edge
    as ringing, so the margin is filled with the nearest edge colour rather
    than left arbitrary.

    The dark halo that seats the lockup in its bay is painted into the chrome
    by `build_chrome`, not here; see HALO_RADIUS.
    """
    if not REPOSITORY_LOGO.exists():
        raise RuntimeError(f"Missing repository logo: {REPOSITORY_LOGO}")
    logo = Image.open(REPOSITORY_LOGO).convert("RGBA")
    canvas = Image.new("RGBA", (px(LOGO_SIZE[0]), px(LOGO_SIZE[1])), (0, 0, 0, 0))
    width = canvas.width
    height = round(width * logo.height / logo.width * CONCEPT_SQUASH)
    lockup = logo.resize((width, height), Image.Resampling.LANCZOS)
    canvas.alpha_composite(lockup, (0, LOGO_TOP_INSET))
    return bleed_edges(canvas)


def bleed_edges(image: Image.Image) -> Image.Image:
    """Push edge colour into the transparent margin, leaving alpha untouched.

    Only into a narrow band around the artwork. Bleeding across the whole
    canvas fills the empty margin with a soft gradient the JPEG then has to
    encode, which cost more of this character's byte allowance than the ringing
    it was there to prevent; beyond the band the margin stays flat black, which
    is nearly free.
    """
    alpha = image.getchannel("A")
    rgb = image.convert("RGB")
    blur = BLEED_RADIUS * SUPERSAMPLE
    spread = rgb.filter(ImageFilter.GaussianBlur(blur))
    covered = alpha.point(lambda v: 255 if v > 8 else 0)
    near = alpha.filter(ImageFilter.GaussianBlur(blur)).point(
        lambda v: 255 if v > 2 else 0
    )
    filled = Image.composite(rgb, spread, covered)
    filled = Image.composite(filled, Image.new("RGB", image.size, (0, 0, 0)), near)
    filled.putalpha(alpha)
    return filled


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    # The logo is built first: the chrome's halo is its own silhouette.
    logo = build_logo()
    chrome = build_chrome(halo=logo.getchannel("A"))
    chrome_png = OUT_DIR / "header_base_798x69.png"
    chrome_jpg = OUT_DIR / "header_base_798x69.jpg"
    chrome.save(chrome_png, "PNG", optimize=True)
    chrome_quality = save_jpeg_to_budget(chrome, chrome_jpg, HEADER_BUDGET)

    # The logo keeps its alpha: its box hangs about 11px below the 69px strip,
    # so a black-backed JPEG would stamp a rectangle over the artwork behind
    # the header. FFDec encodes the PNG's alpha into the DefineBitsJPEG3.
    logo_png = OUT_DIR / "header_logo_265x74.png"
    logo.save(logo_png, "PNG", optimize=True)

    print(
        f"header: {chrome.width}x{chrome.height} ({SUPERSAMPLE}x), "
        f"quality={chrome_quality}, bytes={chrome_jpg.stat().st_size:,}; "
        f"logo: {logo.width}x{logo.height} ({SUPERSAMPLE}x, squash "
        f"{CONCEPT_SQUASH:.3f}), bytes={logo_png.stat().st_size:,}"
    )


if __name__ == "__main__":
    main()
