"""Restyle the stock race-HUD instruments in rc.swf to carbon and red.

Scope is decided by the placement map, not by how a bitmap looks. `rc.swf`'s
cluster sprite (144 / 145) has two frames: frame 1 is the stock instrument set,
frame 2 swaps in sprite 138 - ten purchasable tachometer skins plus the bezel,
needle and shift-light art shared between them. Anything reachable from 138 is
inventory somebody paid for and is left alone. What this module restyles is the
stock tach face and needle, which appear only on frame 1, plus the two small
pointers that belong to them.

The boost and NOS sub-gauges are deliberately NOT touched. They look like white
dials in an image viewer, but they are only ~6% opaque: there is no face at all,
just light ticks, numerals and a red arc floating on transparency. That already
suits a dark HUD, and "inverting" them turns the markings dark and renders them
nearly invisible over the track.

The stock tach has the same hollow middle. Unlike the sub-gauges it reads as
unfinished next to the purchasable skins, which all have solid faces - so it
gets a smoked one rather than an opaque one, dark enough to look like an
instrument while still showing the track through it.
"""
from __future__ import annotations

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

FACE_CENTRE = (26, 27, 32)
FACE_EDGE = (14, 15, 18)

# Brightness -> colour for a red-hot instrument light. The top stop is
# deliberately near-white: a glow with no hot core reads as flat paint.
GLOW_RAMP = (
    (0.00, (26, 2, 1)),
    (0.35, (150, 16, 8)),
    (0.65, (255, 56, 35)),
    (0.88, (255, 140, 110)),
    (1.00, (255, 226, 214)),
)

# The boost and NOS pointers are only ~30px long, so nearly all of their
# pixels sit at the top of the brightness range. Run through GLOW_RAMP they
# land almost entirely in the hot-core stop and come out white. This ramp
# holds the hot stop back so they stay legibly red at that size.
POINTER_RAMP = (
    (0.00, (26, 2, 1)),
    (0.40, (170, 20, 10)),
    (0.78, (255, 56, 35)),
    (1.00, (255, 122, 92)),
)


def _cyan_weight(rgb: np.ndarray) -> np.ndarray:
    """How cyan each pixel is, 0..1.

    Cyan here means green and blue both above red - the glass ring, the needle
    and the small sub-gauge pointers are all lit that way. Weighting by the gap
    rather than thresholding keeps the antialiased edges and the soft outer
    glow from banding when they are recoloured.
    """
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    gap = np.minimum(g, b) - r
    return np.clip(gap / 90.0, 0, 1)


def _ramp(level: np.ndarray, stops) -> np.ndarray:
    positions = [stop for stop, _ in stops]
    out = np.empty(level.shape + (3,), dtype=float)
    for channel in range(3):
        out[..., channel] = np.interp(
            level, positions, [colour[channel] for _, colour in stops])
    return out


def cyan_to_red(image: Image.Image, full: bool = False,
                stops=GLOW_RAMP) -> Image.Image:
    """Swap the cyan lighting for the accent red.

    Scaling one red by each pixel's brightness is what makes a converted glow
    look dull: these lights have a near-white hot core - the needle's brightest
    415 pixels average (207, 253, 247) - and multiplying a saturated red by
    that just yields the same saturated red, so the core vanishes and the whole
    needle flattens. Mapping brightness through a ramp instead keeps the
    incandescent structure: deep red in the falloff, accent red through the
    body, near-white at the core.

    `full` replaces every visible pixel rather than weighting by how cyan it
    is. The needles are nothing but glow, so they take it; the tach must not,
    or its white numerals would be recoloured along with the ring.
    """
    source = np.asarray(image.convert("RGBA")).astype(float)
    rgb, alpha = source[..., :3], source[..., 3:]

    level = rgb.max(axis=2) / 255.0
    target = _ramp(level, stops)
    weight = (np.ones_like(level) if full else _cyan_weight(rgb))[..., None]
    out = rgb * (1 - weight) + target * weight
    return Image.fromarray(
        np.concatenate([np.clip(out, 0, 255), alpha], axis=2).astype(np.uint8),
        "RGBA")


def add_face(image: Image.Image, inset: int = 6, blur: float = 2.0,
             opacity: int = 205) -> Image.Image:
    """Fill a rimmed gauge's hollow middle with a smoked dark face.

    The disc is sized from the art's own opaque bounds and dropped *behind* the
    original, so every numeral, tick and highlight survives untouched. It stays
    short of fully opaque so the track still reads through the instrument.
    """
    image = image.convert("RGBA")
    width, height = image.size
    bounds = image.getchannel("A").point(lambda v: 255 if v > 24 else 0).getbbox()
    if bounds is None:
        return image
    x0, y0, x1, y1 = bounds
    cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
    radius = min(x1 - x0, y1 - y0) / 2 - inset

    face = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(face)
    steps = max(1, int(radius))
    for step in range(steps, 0, -1):
        t = step / steps
        colour = tuple(int(FACE_CENTRE[k] + (FACE_EDGE[k] - FACE_CENTRE[k]) * t)
                       for k in range(3))
        draw.ellipse((cx - t * radius, cy - t * radius,
                      cx + t * radius, cy + t * radius),
                     fill=colour + (opacity,))
    face = face.filter(ImageFilter.GaussianBlur(blur))
    face.alpha_composite(image)
    return face
