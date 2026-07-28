"""Hide a placed object by stamping a zero-alpha colour transform on it.

Some things on the map are static PlaceObject2 tags with no scale field to zero
byte-neutrally, so this inserts a CXFORMWITHALPHA (RGB unchanged, alpha x0) after
the matrix and sets the placement's HasColorTransform flag. The tag grows by the
cxform's length, so the enclosing DefineSprite length and the SWF FileLength are
fixed up. Must run before the SWF is padded to its embedded allocation.

Used to remove the NEWS node from the city map.
"""
from __future__ import annotations

import struct
from pathlib import Path

DEFINE_SPRITE = 39
PLACE_OBJECT2 = 26
HAS_CHARACTER = 0x02
HAS_MATRIX = 0x04
HAS_COLOR_TRANSFORM = 0x08


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

    def align_byte(self) -> int:
        if self.bit:
            self.bit, self.byte = 0, self.byte + 1
        return self.byte


def _iter_tags(data, start: int, end: int):
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


def _swf_body_start(data) -> int:
    pos = 8
    pos += (5 + 4 * (data[pos] >> 3) + 7) // 8
    return pos + 4


def _zero_alpha_cxform() -> bytes:
    # HasAdd=0, HasMult=1, Nbits=10, mult R=G=B=256 (1.0 in 8.8), A=0.
    bits = [0, 1]
    nbits = 10
    bits += [(nbits >> (3 - i)) & 1 for i in range(4)]

    def emit(v):
        if v < 0:
            v += 1 << nbits
        return [(v >> (nbits - 1 - i)) & 1 for i in range(nbits)]

    for v in (256, 256, 256, 0):
        bits += emit(v)
    while len(bits) % 8:
        bits.append(0)
    return bytes(sum(b << (7 - i) for i, b in enumerate(bits[j:j + 8]))
                 for j in range(0, len(bits), 8))


def hide(path: Path, sprite_id: int, depth: int) -> int:
    """Insert a zero-alpha cxform on sprite_id's placement at depth. Returns the
    byte delta added to the file."""
    data = bytearray(path.read_bytes())
    for pos, header, code, length in _iter_tags(data, _swf_body_start(data), len(data)):
        if code != DEFINE_SPRITE:
            continue
        if struct.unpack_from("<H", data, pos + header)[0] != sprite_id:
            continue
        body_start, body_end = pos + header + 4, pos + header + length
        for tpos, theader, tcode, tlength in _iter_tags(data, body_start, body_end):
            if tcode != PLACE_OBJECT2:
                continue
            p = tpos + theader
            flags = data[p]
            if struct.unpack_from("<H", data, p + 1)[0] != depth:
                continue
            if flags & HAS_COLOR_TRANSFORM:
                raise RuntimeError(
                    f"sprite {sprite_id} depth {depth} already has a cxform")
            if not flags & HAS_MATRIX:
                raise RuntimeError(
                    f"sprite {sprite_id} depth {depth} has no matrix")
            cursor = p + 3 + (2 if flags & HAS_CHARACTER else 0)
            reader = _Bits(data, cursor)
            if reader.read(1):
                b = reader.read(5)
                reader.read(b * 2)
            if reader.read(1):
                b = reader.read(5)
                reader.read(b * 2)
            b = reader.read(5)
            reader.read(b * 2)
            insert_at = reader.align_byte()

            cxform = _zero_alpha_cxform()
            data[p] = flags | HAS_COLOR_TRANSFORM
            data[insert_at:insert_at] = cxform
            delta = len(cxform)

            # Grow the enclosing DefineSprite's length field (long form assumed).
            if length < 0x3F:
                raise RuntimeError("sprite tag is short-form; length grow unsupported")
            struct.pack_into("<I", data, pos + 2, length + delta)
            struct.pack_into("<I", data, 4, len(data))
            path.write_bytes(bytes(data))
            return delta
        raise RuntimeError(f"sprite {sprite_id} has no placement at depth {depth}")
    raise RuntimeError(f"sprite {sprite_id} not found in {path}")
