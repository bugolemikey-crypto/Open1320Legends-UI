"""Draw what the header strip will look like, from the art the build ships.

`header_layout` says both this and `build_polish_patch` read its coordinates so
the preview cannot drift from the build - but this half was never written, so
the only way to see the dock was to launch the client and sign in. This renders
it from the *built* SWF, so what you are looking at is the bytes that ship, not
the source PNGs the build might or might not have picked up.

    python scripts/preview_header.py [--swf patches/main_client/main.polish.swf]
                                     [--out exports/header_preview.png]

The dock is dynamic: `classes.Control.sortDockTabs` right-anchors whichever
tabs are currently docked against `tabRight._x` and stacks them leftwards, one
pixel apart, so a tab only appears once its panel is minimised. The preview
draws the full four-tab run - every panel docked - because that is the case
that has to fit inside the recessed panel.
"""
from __future__ import annotations

import argparse
import io
import struct
import sys
import zlib
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))

import header_layout
from replace_jpeg3 import iter_tags
from swf_utils import ROOT

DEFINE_BITS_JPEG3 = 35
DEFINE_BITS_LOSSLESS2 = 36

# Stage geometry. Shape 2004, the chrome strip, lands at stage x 1..799,
# y 1.8..70.8 - see header_layout's module docstring.
STRIP_ORIGIN = (1.0, 1.8)
STRIP_SIZE = (798, 69)

# Character ids of the art this draws, and the scale each was authored at.
CHROME = 2003
# The logo bitmap, whose placement the build un-blanks and moves MOVE_LOGO_X
# left. The chrome's logo bay is empty art, so without this the preview shows a
# hole where the lockup goes.
LOGO = 2039
LOGO_SIZE = (265, 74)
TAB_CHARACTERS = {
    "support": 2022,
    "nim": 2005,
    "email": 2014,
    "viewer": 2011,
}
# Left-to-right, which is the reverse of the order the panels were docked in.
DOCK_ORDER = ("support", "nim", "email", "viewer")

SUPERSAMPLE = 2


def _decode_jpeg3(body: bytes) -> Image.Image:
    _, alpha_offset = struct.unpack_from("<HI", body, 0)
    jpeg = body[6:6 + alpha_offset]
    packed = body[6 + alpha_offset:]
    image = Image.open(io.BytesIO(jpeg)).convert("RGBA")
    if packed:
        raw = zlib.decompress(packed)
        width, height = image.size
        alpha = Image.frombytes("L", image.size, raw[:width * height])
        image.putalpha(alpha)
    return image


def _decode_lossless2(body: bytes) -> Image.Image:
    _, fmt, width, height = struct.unpack_from("<HBHH", body, 0)
    if fmt != 5:
        raise RuntimeError(f"unsupported Lossless2 format {fmt}")
    raw = zlib.decompress(body[7:])
    # Stored ARGB, premultiplied by the alpha channel.
    image = Image.frombytes("RGBA", (width, height), raw[:width * height * 4])
    a, r, g, b = image.split()
    return Image.merge("RGBA", (r, g, b, a))


def read_characters(swf: Path, wanted: set[int]) -> dict[int, Image.Image]:
    data = swf.read_bytes()
    found: dict[int, Image.Image] = {}
    for pos, header, code, length in iter_tags(data):
        if code not in (DEFINE_BITS_JPEG3, DEFINE_BITS_LOSSLESS2) or length < 2:
            continue
        (character,) = struct.unpack_from("<H", data, pos + header)
        if character not in wanted or character in found:
            continue
        body = data[pos + header:pos + header + length]
        found[character] = (_decode_jpeg3(body) if code == DEFINE_BITS_JPEG3
                            else _decode_lossless2(body))
    missing = wanted - set(found)
    if missing:
        raise RuntimeError(f"characters not found in {swf.name}: {sorted(missing)}")
    return found


def render(swf: Path, scale: int = SUPERSAMPLE) -> Image.Image:
    art = read_characters(swf, {CHROME, LOGO, *TAB_CHARACTERS.values()})

    canvas = Image.new("RGBA", (800 * scale, 80 * scale), (8, 9, 11, 255))
    strip = art[CHROME].convert("RGBA")
    strip = strip.resize((STRIP_SIZE[0] * scale, STRIP_SIZE[1] * scale),
                         Image.LANCZOS)
    canvas.alpha_composite(strip, (int(STRIP_ORIGIN[0] * scale),
                                   int(STRIP_ORIGIN[1] * scale)))

    logo = art[LOGO].convert("RGBA").resize(
        (LOGO_SIZE[0] * scale, LOGO_SIZE[1] * scale), Image.LANCZOS)
    canvas.alpha_composite(logo, (int(header_layout.LOGO_ORIGIN[0] * scale),
                                  int(header_layout.LOGO_ORIGIN[1] * scale)))

    # sortDockTabs lays the run out right-to-left from the anchor, by _width,
    # one pixel apart. Walk it in that direction so the arithmetic matches.
    x = header_layout.ANCHOR_TARGET_X
    placed: list[tuple[str, float, float]] = []
    for name in reversed(DOCK_ORDER):
        (width, _height), inset, _top = header_layout.TABS[name]
        x = x - width - 1
        top = header_layout.PANEL_TOP - inset
        placed.append((name, x, top))

    for name, left, top in placed:
        tab = art[TAB_CHARACTERS[name]].convert("RGBA")
        (width, height), _inset, _top = header_layout.TABS[name]
        tab = tab.resize((width * scale, height * scale), Image.LANCZOS)
        canvas.alpha_composite(tab, (int(round(left * scale)),
                                     int(round(top * scale))))

    return canvas


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--swf", type=Path,
                        default=ROOT / "patches" / "main_client" / "main.polish.swf")
    parser.add_argument("--out", type=Path,
                        default=ROOT / "exports" / "header_preview.png")
    parser.add_argument("--scale", type=int, default=SUPERSAMPLE)
    args = parser.parse_args()

    if not args.swf.exists():
        raise SystemExit(f"ERROR: no such SWF: {args.swf}")
    image = render(args.swf, args.scale)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    image.save(args.out)
    print(f"Header preview: {args.out} ({image.width}x{image.height}, "
          f"{args.scale}x) from {args.swf.name}")


if __name__ == "__main__":
    main()
