"""Restyle the shared dialog chrome in intro.swf and newuserform.swf.

Two elements carry the legacy skin across every popup and every step of the
create-account form: white input wells and silver pill buttons. Both are
recoloured rather than redrawn, so each bitmap keeps the exact silhouette its
shape expects - only the pixels inside change.

The wells are found by connected component rather than by hardcoded rectangles,
because several of them ship as one sheet (newuserform character 41 holds six
fields and two radio dots in a single 362x110 bitmap). Small components are
left alone, which is what keeps the radio dots white.
"""
from __future__ import annotations

from collections import deque

from PIL import Image, ImageFilter

# The theme already shipped in the main client.
WELL_TOP = (11, 13, 17)
WELL_BOTTOM = (20, 23, 28)
WELL_BORDER = (52, 54, 62)
WELL_SHADOW = (7, 8, 11)

PILL_TOP = (44, 44, 52)
PILL_BOTTOM = (21, 21, 26)
PILL_RING = (229, 66, 58)
PILL_HILITE = (61, 61, 72)

MIN_WELL_AREA = 400


def _components(mask, width: int, height: int):
    """Four-connected runs of True, as (pixels, bbox) pairs."""
    seen = bytearray(width * height)
    for start in range(width * height):
        if seen[start] or not mask[start]:
            continue
        queue = deque([start])
        seen[start] = 1
        pixels = []
        x0 = y0 = 1 << 30
        x1 = y1 = -1
        while queue:
            index = queue.popleft()
            x, y = index % width, index // width
            pixels.append((x, y))
            x0, y0 = min(x0, x), min(y0, y)
            x1, y1 = max(x1, x), max(y1, y)
            for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if 0 <= nx < width and 0 <= ny < height:
                    neighbour = ny * width + nx
                    if mask[neighbour] and not seen[neighbour]:
                        seen[neighbour] = 1
                        queue.append(neighbour)
        yield pixels, (x0, y0, x1, y1)


def darken_wells(image: Image.Image, threshold: int = 150,
                 min_area: int = MIN_WELL_AREA) -> tuple[Image.Image, int]:
    """Turn every bright field in a bitmap into a recessed dark well."""
    image = image.convert("RGBA")
    width, height = image.size
    source = image.load()
    mask = bytearray(width * height)
    for y in range(height):
        for x in range(width):
            r, g, b, a = source[x, y]
            if a > 200 and (r + g + b) / 3 > threshold:
                mask[y * width + x] = 1

    out = image.copy()
    pixels = out.load()
    wells = 0
    for component, (x0, y0, x1, y1) in _components(mask, width, height):
        if len(component) < min_area or (x1 - x0) < 20 or (y1 - y0) < 6:
            continue
        wells += 1
        span = max(1, y1 - y0)
        for x, y in component:
            t = (y - y0) / span
            fill = tuple(int(WELL_TOP[k] + (WELL_BOTTOM[k] - WELL_TOP[k]) * t)
                         for k in range(3))
            if x in (x0, x1) or y in (y0, y1):
                fill = WELL_BORDER
            elif y == y0 + 1:
                fill = WELL_SHADOW
            pixels[x, y] = fill + (source[x, y][3],)
    return out, wells


def carbon_pill(image: Image.Image, ring: int = 2) -> Image.Image:
    """Recolour a silver pill button to dark carbon with a red ring.

    The cap is found two ways, because the two files disagree about where the
    rounding lives. intro.swf ships the button cut out, so its alpha is the
    silhouette. newuserform.swf ships a fully opaque 97x43 rectangle with the
    pill painted into the pixels and black around it - there, alpha says
    "everything", and only brightness distinguishes cap from ground. Taking
    the mask from alpha in that case fills the whole rectangle and the button
    loses its rounded corners.

    The ring is the body minus an eroded copy of itself, rather than the pixels
    along the mask edge: these caps are antialiased, and an edge-walk traces
    that soft rim into a dotted outline. Eroding gives an even width that
    follows the curve.

    The white caption the SWF draws over these buttons is near invisible on the
    silver original; on carbon it reads properly, so the caption itself needs
    no patching.
    """
    image = image.convert("RGBA")
    width, height = image.size
    alpha = image.getchannel("A")
    cutout = alpha.getextrema()[0] < 250
    if cutout:
        body = alpha.point(lambda v: 255 if v > 128 else 0)
        # the antialiased rim joins the ring, so the outline does not fray
        fringe = alpha.point(lambda v: 255 if 0 < v <= 128 else 0).load()
    else:
        body = image.convert("L").point(lambda v: 255 if v > 90 else 0)
        fringe = None
    inner = body.filter(ImageFilter.MinFilter(ring * 2 + 1))

    bounds = body.getbbox()
    if bounds is None:
        return image
    top, bottom = bounds[1], bounds[3] - 1
    span = max(1, bottom - top)

    out = image.copy()
    pixels = out.load()
    solid, core, mask = body.load(), inner.load(), alpha.load()
    for y in range(height):
        t = (y - top) / span
        fill = tuple(int(PILL_TOP[k] + (PILL_BOTTOM[k] - PILL_TOP[k]) * t)
                     for k in range(3))
        for x in range(width):
            a = mask[x, y]
            if core[x, y]:
                pixels[x, y] = fill + (a,)
            elif solid[x, y] or (fringe is not None and fringe[x, y]):
                pixels[x, y] = PILL_RING + (a,)

    # one highlight row just inside the ring, so the cap reads as a raised
    # control rather than a flat swatch
    for x in range(width):
        for y in range(top, height):
            if core[x, y]:
                pixels[x, y] = PILL_HILITE + (mask[x, y],)
                break
    return out
