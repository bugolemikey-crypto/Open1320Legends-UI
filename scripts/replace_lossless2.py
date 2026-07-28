"""Replace a bitmap character with a DefineBitsLossless2, whatever it was before.

The dock tab art is flat: two-stop gradients, hairline borders and eight-pixel
text. That is the worst case for JPEG - every edge is a hard one and the DC
blocks around them cost more than the panels they sit on - and the best case
for the deflate stream a DefineBitsLossless2 carries, because a vertical
gradient is a run of identical rows. The four tabs together encode about 2.9KB
smaller lossless than they do at the JPEG quality their byte budgets bought,
and they come out exact rather than approximate.

The characters being replaced ship as DefineBitsJPEG3, so the tag code changes
as well as the body. Nothing references a bitmap by tag type - the shapes that
paint them carry a character id - so the swap is safe as long as the id and the
dimensions stay put.

Body of a DefineBitsLossless2, format 5:

    UI16  character id
    UI8   format (5 = 32-bit ARGB)
    UI16  width
    UI16  height
    ...   zlib-compressed ARGB, one row after another, alpha *premultiplied*

Premultiplication is not optional: the player composites these directly, and
art with a soft edge over a light fill shows a bright halo without it.
"""
from __future__ import annotations

import struct
import zlib
from pathlib import Path

from PIL import Image

from replace_jpeg3 import iter_tags, pack_tag

DEFINE_BITS_LOSSLESS2 = 36
# Every tag that can define a bitmap character, so the old one can be found
# whichever form it shipped in.
BITMAP_TAGS = {6, 20, 21, 35, 36, 90}
FORMAT_ARGB = 5


def build_body(character: int, image: Image.Image) -> bytes:
    image = image.convert("RGBA")
    pixels = bytearray()
    source = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = source[x, y]
            pixels += bytes((a, r * a // 255, g * a // 255, b * a // 255))
    return (struct.pack("<HBHH", character, FORMAT_ARGB, image.width, image.height)
            + zlib.compress(bytes(pixels), 9))


def replace(path: Path, character: int, source: Path) -> int:
    """Rewrite `character` as a DefineBitsLossless2. Returns the new tag length."""
    body = build_body(character, Image.open(source))
    data = path.read_bytes()
    for pos, header, code, length in iter_tags(data):
        if code not in BITMAP_TAGS:
            continue
        (found,) = struct.unpack_from("<H", data, pos + header)
        if found != character:
            continue
        rebuilt = bytearray(data[:pos])
        rebuilt += pack_tag(DEFINE_BITS_LOSSLESS2, body)
        rebuilt += data[pos + header + length:]
        struct.pack_into("<I", rebuilt, 4, len(rebuilt))
        path.write_bytes(bytes(rebuilt))
        return len(body)
    raise RuntimeError(f"bitmap character {character} not found in {path}")
