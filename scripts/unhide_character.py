"""Drop the blanking colour transform from a placement inside a sprite.

`ui_editor.py` hides a character by stamping a CXFORMWITHALPHA whose multiply
terms are all zero onto its PlaceObject2 tag. That is how the header logo
(character 2040, depth 35 of sprite 2093) came to be invisible, which is why
the logo had to be baked into the login background instead - where it could
only ever appear on the login screen.

Removing the transform is the inverse edit: clear the HasColorTransform flag,
drop the transform bytes, and shrink the enclosing DefineSprite's length to
match. The SWF gets shorter, which is safe because the build pads back up to
the embedded allocation afterwards.
"""
from __future__ import annotations

import struct
from pathlib import Path

DEFINE_SPRITE = 39
PLACE_OBJECT2 = 26
HAS_MOVE = 0x01
HAS_CHARACTER = 0x02
HAS_MATRIX = 0x04
HAS_COLOR_TRANSFORM = 0x08
HAS_RATIO = 0x10
HAS_NAME = 0x20


class _Bits:
    def __init__(self, data, byte: int) -> None:
        self.data, self.byte, self.bit = data, byte, 0

    def read(self, count: int) -> int:
        value = 0
        for _ in range(count):
            value = (value << 1) | ((self.data[self.byte] >> (7 - self.bit)) & 1)
            self.bit += 1
            if self.bit == 8:
                self.bit, self.byte = 0, self.byte + 1
        return value

    def align(self) -> int:
        if self.bit:
            self.bit, self.byte = 0, self.byte + 1
        return self.byte


def _skip_matrix(body, pos: int) -> int:
    reader = _Bits(body, pos)
    if reader.read(1):
        bits = reader.read(5)
        reader.read(bits * 2)
    if reader.read(1):
        bits = reader.read(5)
        reader.read(bits * 2)
    bits = reader.read(5)
    reader.read(bits * 2)
    return reader.align()


def _skip_cxform(body, pos: int) -> int:
    reader = _Bits(body, pos)
    has_add = reader.read(1)
    has_mult = reader.read(1)
    bits = reader.read(4)
    if has_mult:
        reader.read(bits * 4)
    if has_add:
        reader.read(bits * 4)
    return reader.align()


def _iter_tags(data: bytes, start: int, end: int):
    pos = start
    while pos < end:
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


def _swf_body_start(data: bytes) -> int:
    pos = 8
    pos += (5 + 4 * (data[pos] >> 3) + 7) // 8
    return pos + 4


def _matrix_bytes(dx: float, dy: float) -> bytes:
    """Smallest MATRIX record carrying just a translation, in stage pixels."""
    x, y = round(dx * 20), round(dy * 20)
    bits = 1
    while any(v < -(1 << (bits - 1)) or v >= (1 << (bits - 1)) for v in (x, y)):
        bits += 1
    stream = [0, 0]                                   # no scale, no rotate
    stream += [(bits >> (4 - i)) & 1 for i in range(5)]
    for value in (x, y):
        if value < 0:
            value += 1 << bits
        stream += [(value >> (bits - 1 - i)) & 1 for i in range(bits)]
    stream += [0] * (-len(stream) % 8)
    return bytes(
        sum(bit << (7 - i) for i, bit in enumerate(stream[byte:byte + 8]))
        for byte in range(0, len(stream), 8)
    )


def unhide(path: Path, sprite_id: int, depth: int,
           dx: float = 0.0, dy: float = 0.0) -> int:
    """Strip the colour transform, optionally re-placing the object.

    The blanked placement carries an identity matrix with a zero-width
    translate field, so a shift cannot be written in place: the matrix is
    rebuilt here instead, while the tag is already being rewritten anyway.

    Returns the number of bytes removed (negative if the tag grew)."""
    data = path.read_bytes()
    for pos, header, code, length in _iter_tags(data, _swf_body_start(data), len(data)):
        if code != DEFINE_SPRITE:
            continue
        (found,) = struct.unpack_from("<H", data, pos + header)
        if found != sprite_id:
            continue
        body_start, body_end = pos + header + 4, pos + header + length
        for tpos, theader, tcode, tlength in _iter_tags(data, body_start, body_end):
            if tcode != PLACE_OBJECT2:
                continue
            p = tpos + theader
            flags = data[p]
            (place_depth,) = struct.unpack_from("<H", data, p + 1)
            if place_depth != depth or not flags & HAS_COLOR_TRANSFORM:
                continue
            cursor = p + 3
            if flags & HAS_CHARACTER:
                cursor += 2
            matrix_start = cursor
            if flags & HAS_MATRIX:
                cursor = _skip_matrix(data, cursor)
            cxform_start = cursor
            cxform_end = _skip_cxform(data, cursor)

            matrix = data[matrix_start:cxform_start]
            if dx or dy:
                if not flags & HAS_MATRIX:
                    raise RuntimeError(
                        f"sprite {sprite_id} depth {depth} has no matrix to replace"
                    )
                matrix = _matrix_bytes(dx, dy)
            place_body = (bytes([flags & ~HAS_COLOR_TRANSFORM])
                          + data[p + 1:matrix_start]
                          + matrix
                          + data[cxform_end:tpos + theader + tlength])
            removed = (tpos + theader + tlength) - tpos - 2 - len(place_body)
            new_place = (struct.pack("<H", (PLACE_OBJECT2 << 6) | len(place_body))
                         + place_body)
            sprite_body = (data[pos + header:tpos]
                           + new_place
                           + data[tpos + theader + tlength:body_end])
            if len(sprite_body) < 0x3F:
                new_sprite = (struct.pack("<H", (DEFINE_SPRITE << 6) | len(sprite_body))
                              + sprite_body)
            else:
                new_sprite = (struct.pack("<HI", (DEFINE_SPRITE << 6) | 0x3F,
                                          len(sprite_body)) + sprite_body)
            rebuilt = bytearray(data[:pos] + new_sprite + data[pos + header + length:])
            struct.pack_into("<I", rebuilt, 4, len(rebuilt))
            path.write_bytes(bytes(rebuilt))
            return removed
        raise RuntimeError(
            f"sprite {sprite_id} has no colour-transformed placement at depth {depth}"
        )
    raise RuntimeError(f"sprite {sprite_id} not found in {path}")
