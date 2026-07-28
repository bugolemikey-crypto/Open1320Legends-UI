"""Nudge a placed object inside a sprite, without changing the file length.

A PlaceObject2 MATRIX stores its translation as two signed values in a field
whose bit width is written alongside them, so a new translation that fits the
width already on disk can be written straight over the old one. That keeps the
tag - and the whole SWF - exactly the size it was, which matters because the
stream is embedded at a fixed allocation.

Used to right-align the version caption and the Support control in the header's
recessed panel, both of which are live objects placed by sprite 2093.
"""
from __future__ import annotations

import struct
from pathlib import Path

DEFINE_SPRITE = 39
PLACE_OBJECT2 = 26
HAS_CHARACTER = 0x02
HAS_MATRIX = 0x04
TWIPS = 20


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

    def read_signed(self, count: int) -> int:
        value = self.read(count)
        if count and value >> (count - 1):
            value -= 1 << count
        return value

    @property
    def offset(self) -> int:
        return self.byte * 8 + self.bit


def _write_bits(data: bytearray, offset: int, count: int, value: int) -> None:
    if value < 0:
        value += 1 << count
    if value >> count:
        raise RuntimeError(f"value does not fit in {count} bits")
    for i in range(count):
        bit = (value >> (count - 1 - i)) & 1
        index, shift = divmod(offset + i, 8)
        mask = 1 << (7 - shift)
        data[index] = (data[index] | mask) if bit else (data[index] & ~mask)


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


def move(path: Path, sprite_id: int, depth: int,
         dx: float = 0.0, dy: float = 0.0) -> tuple[float, float]:
    """Shift the placement at `depth` by (dx, dy) stage pixels. Returns the new
    translation, also in stage pixels."""
    data = bytearray(path.read_bytes())
    original_length = len(data)
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
            if place_depth != depth:
                continue
            if not flags & HAS_MATRIX:
                raise RuntimeError(
                    f"sprite {sprite_id} depth {depth} has no matrix to move"
                )
            cursor = p + 3 + (2 if flags & HAS_CHARACTER else 0)
            reader = _Bits(data, cursor)
            if reader.read(1):
                bits = reader.read(5)
                reader.read(bits * 2)
            if reader.read(1):
                bits = reader.read(5)
                reader.read(bits * 2)
            bits = reader.read(5)
            translate_offset = reader.offset
            x = reader.read_signed(bits) + round(dx * TWIPS)
            y = reader.read_signed(bits) + round(dy * TWIPS)
            _write_bits(data, translate_offset, bits, x)
            _write_bits(data, translate_offset + bits, bits, y)
            if len(data) != original_length:
                raise RuntimeError("placement move changed the file length")
            path.write_bytes(bytes(data))
            return x / TWIPS, y / TWIPS
        raise RuntimeError(f"sprite {sprite_id} has no placement at depth {depth}")
    raise RuntimeError(f"sprite {sprite_id} not found in {path}")
