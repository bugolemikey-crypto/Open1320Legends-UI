"""Read and write the auxiliary SWFs that live outside the embedded slot.

`cache/misc/intro.swf` (post-login dialogs, daily challenge, daily award),
`cache/misc/newuserform.swf` (create-account form) and `cache/car/rc.swf` (the
race HUD) are loaded at runtime from disk, not welded into the projector, so
they carry no fixed allocation. All ship compressed, and every tag helper in
this repo parses raw FWS, so work happens on a decompressed copy and the file
is recompressed on the way out.

Bitmaps are decoded and re-encoded in whatever tag they already use. The
projector red-renders a DefineBitsLossless2 under some shape versions, so a
character that renders correctly today keeps its format rather than being
normalised to one.

This module edits tags in place by byte surgery and never hands a file to the
decompiler - which matters most for rc.swf, whose button 141 carries the
gear-shift keyPress conditions that FFDec re-serialisation corrupts.
"""
from __future__ import annotations

import io
import struct
import zlib
from pathlib import Path

from PIL import Image

DEFINE_BITS_JPEG3 = 35
DEFINE_BITS_LOSSLESS2 = 36


def read(path: Path) -> bytes:
    """Uncompressed FWS bytes, whichever way the file shipped."""
    data = path.read_bytes()
    if data[:3] == b"CWS":
        return b"FWS" + data[3:8] + zlib.decompress(data[8:])
    return data


def write(path: Path, data: bytes, compress: bool = True) -> int:
    """Write back, recompressed by default. Returns the bytes on disk."""
    header = bytearray(data[:8])
    struct.pack_into("<I", header, 4, len(data))
    body = data[8:]
    if compress:
        out = b"CWS" + bytes(header[3:8]) + zlib.compress(body, 9)
    else:
        out = b"FWS" + bytes(header[3:8]) + body
    path.write_bytes(out)
    return len(out)


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


def find_bitmap(data: bytes, character: int) -> tuple[int, int, int, int]:
    """(tag start, header size, tag code, body length) for one bitmap."""
    for pos, header, code, length in iter_tags(data):
        if code not in (DEFINE_BITS_JPEG3, DEFINE_BITS_LOSSLESS2) or length < 2:
            continue
        (found,) = struct.unpack_from("<H", data, pos + header)
        if found == character:
            return pos, header, code, length
    raise RuntimeError(f"bitmap character {character} not found")


def extract(data: bytes, character: int) -> tuple[Image.Image, int]:
    """Decode a bitmap to RGBA. Returns the image and the tag code it used."""
    pos, header, code, length = find_bitmap(data, character)
    body = data[pos + header: pos + header + length]
    if code == DEFINE_BITS_JPEG3:
        (alpha_offset,) = struct.unpack_from("<I", body, 2)
        image = Image.open(io.BytesIO(body[6:6 + alpha_offset])).convert("RGB")
        alpha = zlib.decompress(body[6 + alpha_offset:])
        image.putalpha(Image.frombytes("L", image.size, alpha))
        return image, code

    fmt, width, height = struct.unpack_from("<BHH", body, 2)
    if fmt != 5:
        raise RuntimeError(f"character {character}: lossless format {fmt} "
                           f"is not the 32-bit form this handles")
    raw = zlib.decompress(body[7:])
    out = Image.new("RGBA", (width, height))
    pixels = out.load()
    for y in range(height):
        row = y * width * 4
        for x in range(width):
            a, r, g, b = raw[row + x * 4: row + x * 4 + 4]
            if a:
                pixels[x, y] = (r * 255 // a, g * 255 // a, b * 255 // a, a)
            else:
                pixels[x, y] = (0, 0, 0, 0)
    return out, code


def _jpeg3_body(character: int, image: Image.Image, quality: int) -> bytes:
    buffer = io.BytesIO()
    image.convert("RGB").save(buffer, "JPEG", quality=quality, optimize=True,
                              progressive=False, subsampling=0)
    jpeg = buffer.getvalue()
    alpha = zlib.compress(image.getchannel("A").tobytes(), 9)
    return struct.pack("<HI", character, len(jpeg)) + jpeg + alpha


def _lossless2_body(character: int, image: Image.Image) -> bytes:
    image = image.convert("RGBA")
    pixels = bytearray()
    source = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = source[x, y]
            pixels += bytes((a, r * a // 255, g * a // 255, b * a // 255))
    return (struct.pack("<HBHH", character, 5, image.width, image.height)
            + zlib.compress(bytes(pixels), 9))


def replace(data: bytes, character: int, image: Image.Image,
            quality: int = 94) -> tuple[bytes, int]:
    """Rewrite a bitmap in the tag it already uses. Returns (data, new length)."""
    pos, header, code, length = find_bitmap(data, character)
    if code == DEFINE_BITS_JPEG3:
        body = _jpeg3_body(character, image, quality)
    else:
        body = _lossless2_body(character, image)
    rebuilt = bytearray(data[:pos])
    rebuilt += pack_tag(code, body)
    rebuilt += data[pos + header + length:]
    struct.pack_into("<I", rebuilt, 4, len(rebuilt))
    return bytes(rebuilt), len(body)
