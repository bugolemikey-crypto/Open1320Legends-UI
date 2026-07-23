"""Replace a DefineBitsJPEG3 character with RGBA art, to an exact byte budget.

FFDec's `-replace ... jpeg3` re-encodes a PNG at a quality it chooses itself.
That is fine for the handful of tiny overlay bitmaps, but the header logo has
to land inside a few kilobytes of a fixed-size SWF, so its quality has to be
searched for rather than discovered after the fact.

A DefineBitsJPEG3 body is:

    UI16  character id
    UI32  offset from the end of this field to the alpha data
    ...   JPEG (or PNG/GIF) image data
    ...   zlib-compressed 8-bit alpha, one byte per pixel, row major

which is simple enough to write directly. The tag length changes, so this has
to run before the SWF is padded back to its embedded allocation.
"""
from __future__ import annotations

import io
import struct
import zlib
from pathlib import Path

from PIL import Image

DEFINE_BITS_JPEG3 = 35


def encode(image: Image.Image, quality: int) -> bytes:
    rgb = io.BytesIO()
    image.convert("RGB").save(rgb, "JPEG", quality=quality, optimize=True,
                              progressive=False, subsampling=0)
    jpeg = rgb.getvalue()
    alpha = zlib.compress(image.getchannel("A").tobytes(), 9)
    return jpeg, alpha


def build_body(character: int, image: Image.Image, budget: int) -> tuple[bytes, int]:
    """Smallest-loss body that fits `budget`, including the tag body header."""
    low, high, best = 4, 96, None
    while low <= high:
        quality = (low + high) // 2
        jpeg, alpha = encode(image, quality)
        size = 6 + len(jpeg) + len(alpha)
        if size <= budget:
            best = (quality, jpeg, alpha)
            low = quality + 1
        else:
            high = quality - 1
    if best is None:
        raise RuntimeError(
            f"character {character} cannot be encoded within {budget:,} bytes "
            f"at any quality"
        )
    quality, jpeg, alpha = best
    body = struct.pack("<HI", character, len(jpeg)) + jpeg + alpha
    return body, quality


def iter_tags(data: bytes):
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
        yield pos, header, code, length
        pos += header + length
        if code == 0:
            break


def pack_tag(code: int, body: bytes) -> bytes:
    if len(body) < 0x3F:
        return struct.pack("<H", (code << 6) | len(body)) + body
    return struct.pack("<HI", (code << 6) | 0x3F, len(body)) + body


def replace(path: Path, character: int, source: Path, budget: int) -> tuple[int, int]:
    """Returns (new tag length, chosen quality)."""
    image = Image.open(source).convert("RGBA")
    body, quality = build_body(character, image, budget)
    data = path.read_bytes()
    for pos, header, code, length in iter_tags(data):
        if code != DEFINE_BITS_JPEG3:
            continue
        (found,) = struct.unpack_from("<H", data, pos + header)
        if found != character:
            continue
        rebuilt = bytearray(data[:pos])
        rebuilt += pack_tag(DEFINE_BITS_JPEG3, body)
        rebuilt += data[pos + header + length:]
        struct.pack_into("<I", rebuilt, 4, len(rebuilt))
        path.write_bytes(bytes(rebuilt))
        return len(body), quality
    raise RuntimeError(f"DefineBitsJPEG3 {character} not found in {path}")
