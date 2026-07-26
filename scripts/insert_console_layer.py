"""Lift the login console onto its own crisp, lossless layer.

Historically the console's text was baked into the photographic background
(character 1925), so it was encoded as part of a JPEG and could never be
sharper than the photo's byte budget allowed. This adds a separate layer that
carries only the crisp elements - text, dividers, wells, padlock - as a
transparent DefineBitsLossless2, displayed by a clone of the background's own
shape so it lands pixel-for-pixel over the photo with no matrix arithmetic.

Concretely, on an uncompressed (FWS) working SWF it:

1. builds a DefineBitsLossless2 for the new bitmap (default id 4253) from the
   overlay PNG, in the alpha-premultiplied ARGB layout Lossless2 requires;
2. clones the background shape 1926 as a new DefineShape (default id 4254),
   swapping the bitmap its fill points at from 1925 to the new bitmap - so it
   inherits the background's exact bounds and fill matrix, including whatever
   2x scale the build has already applied;
3. inserts both new character tags immediately before DefineSprite 2094 (the
   login-screen container), so they are defined before use;
4. inside sprite 2094, drops the background from depth 6 to depth 5 and inserts
   a PlaceObject2 for the new shape at depth 6 - above the photo, below the
   live controls sprite at depth 7 - reusing the background's identity matrix.

Character ids 4253/4254 sit just above the file's current maximum (4252). The
edit changes the file length, so it must run before the pad/allocation step.
"""
from __future__ import annotations

import struct
import zlib
from pathlib import Path

from PIL import Image

from patch_bitmap_scale import BitReader, iter_tags

DEFINE_SHAPE_TAGS = {2, 22, 32, 83}
DEFINE_SPRITE = 39
PLACE_OBJECT2 = 26
DEFINE_BITS_LOSSLESS2 = 36


def first_tag_offset(data: bytes) -> int:
    """Byte offset of the first tag, past the SWF header and movie RECT."""
    nbits = data[8] >> 3
    pos = 8 + (5 + 4 * nbits + 7) // 8
    return pos + 4  # framerate (UI16) + frame count (UI16)


def top_tags(data: bytes):
    """Yield (code, tag_start, body_start, length) for each top-level tag."""
    pos = first_tag_offset(data)
    while pos < len(data) - 1:
        (value,) = struct.unpack_from("<H", data, pos)
        code, length = value >> 6, value & 0x3F
        body = pos + 2
        if length == 0x3F:
            (length,) = struct.unpack_from("<I", data, pos + 2)
            body = pos + 6
        yield code, pos, body, length
        pos = body + length
        if code == 0:
            break


def build_lossless2(bitmap_id: int, png_path: Path) -> bytes:
    """A DefineBitsLossless2 tag from an RGBA PNG (format 5, premultiplied ARGB)."""
    image = Image.open(png_path).convert("RGBA")
    width, height = image.size
    rgba = image.tobytes("raw", "RGBA")
    argb = bytearray(len(rgba))
    for i in range(0, len(rgba), 4):
        r, g, b, a = rgba[i], rgba[i + 1], rgba[i + 2], rgba[i + 3]
        # Lossless2 stores colour pre-multiplied by alpha; the player divides it
        # back out on display. Transparent pixels collapse to zero, which is why
        # a mostly-empty overlay compresses to almost nothing.
        argb[i] = a
        argb[i + 1] = (r * a) // 255
        argb[i + 2] = (g * a) // 255
        argb[i + 3] = (b * a) // 255
    body = struct.pack("<HBHH", bitmap_id, 5, width, height) + zlib.compress(bytes(argb), 9)
    return struct.pack("<H", (DEFINE_BITS_LOSSLESS2 << 6) | 0x3F) + struct.pack("<I", len(body)) + body


def _bitmap_fill_offsets(body: bytes, code: int) -> list[tuple[int, int]]:
    """Byte offsets (relative to body) of each bitmap-id field, with its value."""
    reader = BitReader(body, 2)
    nbits = reader.read(5)
    for _ in range(4):
        reader.read_signed(nbits)
    reader.align()
    pos = reader.byte
    count = body[pos]
    pos += 1
    if count == 0xFF:
        (count,) = struct.unpack_from("<H", body, pos)
        pos += 2
    found: list[tuple[int, int]] = []
    for _ in range(count):
        fill_type = body[pos]
        pos += 1
        if fill_type == 0x00:
            pos += 4 if code in (32, 83) else 3
            continue
        if fill_type not in (0x40, 0x41, 0x42, 0x43):
            break
        (bitmap_id,) = struct.unpack_from("<H", body, pos)
        found.append((pos, bitmap_id))
        pos += 2
        matrix = BitReader(body, pos)
        if matrix.read(1):
            sb = matrix.read(5)
            matrix.read_signed(sb)
            matrix.read_signed(sb)
        if matrix.read(1):
            kb = matrix.read(5)
            matrix.read_signed(kb)
            matrix.read_signed(kb)
        tb = matrix.read(5)
        matrix.read_signed(tb)
        matrix.read_signed(tb)
        matrix.align()
        pos = matrix.byte
    return found


def clone_shape(data: bytes, src_shape: int, new_shape: int,
                old_bitmap: int, new_bitmap: int) -> bytes:
    """Copy the shape tag for `src_shape`, re-ided and pointed at a new bitmap."""
    for code, body_start, length in iter_tags(data):
        if code not in DEFINE_SHAPE_TAGS or length < 2:
            continue
        (found,) = struct.unpack_from("<H", data, body_start)
        if found != src_shape:
            continue
        body = bytearray(data[body_start:body_start + length])
        struct.pack_into("<H", body, 0, new_shape)
        offsets = _bitmap_fill_offsets(bytes(body), code)
        targets = [off for off, bid in offsets if bid == old_bitmap]
        if not targets:
            raise RuntimeError(
                f"shape {src_shape} has no bitmap fill for {old_bitmap}; "
                f"found {offsets}")
        for off in targets:
            struct.pack_into("<H", body, off, new_bitmap)
        return _encode_tag_header(code, len(body)) + bytes(body)
    raise RuntimeError(f"shape {src_shape} not found")


def _encode_tag_header(code: int, length: int) -> bytes:
    if length < 0x3F:
        return struct.pack("<H", (code << 6) | length)
    return struct.pack("<H", (code << 6) | 0x3F) + struct.pack("<I", length)


def _place_object2(depth: int, character: int) -> bytes:
    # flags: hasCharacter (0x02) | hasMatrix (0x04); identity matrix is one zero
    # byte (no scale, no rotate, zero translate bits) - the same matrix the
    # background placement carries.
    body = struct.pack("<BHH", 0x06, depth, character) + b"\x00"
    return _encode_tag_header(PLACE_OBJECT2, len(body)) + body


def _rebuild_sprite(tag: bytes, bg_bitmap_shape: int, new_shape: int,
                    old_depth: int, new_depth: int, place_depth: int) -> bytes:
    """Return the sprite tag with the bg dropped a depth and the overlay added."""
    # tag = header + body; body = spriteId UI16, frameCount UI16, control tags.
    value = struct.unpack_from("<H", tag, 0)[0]
    if (value & 0x3F) == 0x3F:
        header = 6
    else:
        header = 2
    body = tag[header:]
    sprite_id, frame_count = struct.unpack_from("<HH", body, 0)
    pos = 4
    out = bytearray(body[:4])
    inserted = False
    while pos < len(body):
        rh = struct.unpack_from("<H", body, pos)[0]
        c, l = rh >> 6, rh & 0x3F
        hh = 2
        if l == 0x3F:
            (l,) = struct.unpack_from("<I", body, pos + 2)
            hh = 6
        tag_bytes = bytearray(body[pos:pos + hh + l])
        if c == PLACE_OBJECT2:
            flags = tag_bytes[hh]
            depth = struct.unpack_from("<H", tag_bytes, hh + 1)[0]
            chid = struct.unpack_from("<H", tag_bytes, hh + 3)[0] if flags & 0x02 else None
            if depth == old_depth and chid == bg_bitmap_shape:
                struct.pack_into("<H", tag_bytes, hh + 1, new_depth)
                out += tag_bytes
                out += _place_object2(place_depth, new_shape)
                inserted = True
                pos += hh + l
                continue
        out += tag_bytes
        pos += hh + l
    if not inserted:
        raise RuntimeError(
            f"background placement (depth {old_depth}, shape {bg_bitmap_shape}) "
            f"not found in sprite {sprite_id}")
    del frame_count
    return _encode_tag_header(DEFINE_SPRITE, len(out)) + bytes(out)


def insert(path: Path, overlay_png: Path, *, sprite_id: int = 2094,
           bg_shape: int = 1926, bg_bitmap: int = 1925,
           new_bitmap: int = 4253, new_shape: int = 4254,
           bg_depth: int = 6, moved_depth: int = 5, overlay_depth: int = 6) -> dict:
    data = bytes(path.read_bytes())
    if data[:3] != b"FWS":
        raise RuntimeError(f"expected uncompressed FWS working SWF, got {data[:3]!r}")

    loss2_tag = build_lossless2(new_bitmap, overlay_png)
    shape_tag = clone_shape(data, bg_shape, new_shape, bg_bitmap, new_bitmap)

    start = first_tag_offset(data)
    out = bytearray(data[:start])
    handled = False
    for code, tag_start, body_start, length in top_tags(data):
        end = body_start + length
        if code == DEFINE_SPRITE and length >= 2 and \
                struct.unpack_from("<H", data, body_start)[0] == sprite_id:
            out += loss2_tag
            out += shape_tag
            out += _rebuild_sprite(data[tag_start:end], bg_shape, new_shape,
                                   bg_depth, moved_depth, overlay_depth)
            handled = True
        else:
            out += data[tag_start:end]
    if not handled:
        raise RuntimeError(f"sprite {sprite_id} not found")

    struct.pack_into("<I", out, 4, len(out))
    path.write_bytes(bytes(out))
    return {
        "lossless2_bytes": len(loss2_tag),
        "shape_bytes": len(shape_tag),
        "new_total": len(out),
        "delta": len(out) - len(data),
    }


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("swf", type=Path)
    parser.add_argument("overlay_png", type=Path)
    args = parser.parse_args()
    result = insert(args.swf, args.overlay_png)
    print(f"console layer inserted: lossless2={result['lossless2_bytes']:,}B "
          f"shape={result['shape_bytes']:,}B delta={result['delta']:+,}B "
          f"total={result['new_total']:,}B")


if __name__ == "__main__":
    main()
