"""Retune bitmap-fill matrices so higher-resolution art renders at its original size.

Every bitmap this project replaces is painted by a DefineShape whose bitmap
fill matrix is exactly 20 twips per pixel — one bitmap pixel per stage pixel.
The game runs `Stage.scaleMode = "showAll"`, so maximising the window scales the
whole 800x600 stage up (about 1.9x on a 1080p display) and those 1:1 bitmaps
are magnified with nothing in reserve.

Supplying art at N x resolution fixes that, but only if the fill matrix is
divided by N as well — otherwise the shape paints the bigger bitmap at N times
its intended size and the shape bounds crop it.

The matrix scale is a 16.16 fixed-point value in a bit-packed MATRIX record.
20.0 needs 22 signed bits and 10.0 needs 21, so the replacement always fits in
the field width already on disk: the edit is done in place and never changes
the tag length, which matters because the SWF has to keep its exact size.
"""
from __future__ import annotations

import struct
from pathlib import Path

# shape id -> the bitmap character it paints
SHAPE_BITMAPS = {
    1926: 1925,  # login background
    1946: 1945,  # btnStart art
    1949: 1948,  # btnCreateAccount art
    1954: 1953,  # btnFBConnect art
    2004: 2003,  # header strip
    2040: 2039,  # header logo
}

DEFINE_SHAPE_TAGS = {2, 22, 32, 83}
FIXED_ONE = 65536


class BitReader:
    def __init__(self, data: bytes | bytearray, byte: int = 0) -> None:
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

    def align(self) -> None:
        if self.bit:
            self.bit, self.byte = 0, self.byte + 1

    @property
    def offset(self) -> int:
        return self.byte * 8 + self.bit


def write_bits(data: bytearray, offset: int, count: int, value: int) -> None:
    if value < 0:
        value += 1 << count
    for i in range(count):
        bit = (value >> (count - 1 - i)) & 1
        index, shift = divmod(offset + i, 8)
        mask = 1 << (7 - shift)
        data[index] = (data[index] | mask) if bit else (data[index] & ~mask)


def iter_tags(data: bytes):
    pos = 8
    nbits = data[pos] >> 3
    pos += (5 + 4 * nbits + 7) // 8
    pos += 4
    while pos < len(data) - 1:
        (code_len,) = struct.unpack_from("<H", data, pos)
        code, length = code_len >> 6, code_len & 0x3F
        pos += 2
        if length == 0x3F:
            (length,) = struct.unpack_from("<I", data, pos)
            pos += 4
        yield code, pos, length
        pos += length
        if code == 0:
            break


def scale_shape_fills(data: bytearray, body_start: int, length: int,
                      wanted: dict[int, int], divisor: int) -> list[tuple[int, int]]:
    """Rewrite the scale of any bitmap fill in this shape. Returns (shape, bitmap)."""
    body = memoryview(data)[body_start:body_start + length]
    (shape_id,) = struct.unpack_from("<H", body, 0)
    if shape_id not in wanted:
        return []

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

    touched: list[tuple[int, int]] = []
    for _ in range(count):
        fill_type = body[pos]
        pos += 1
        if fill_type == 0x00:
            pos += 3
            continue
        if fill_type not in (0x40, 0x41, 0x42, 0x43):
            break
        (bitmap_id,) = struct.unpack_from("<H", body, pos)
        pos += 2
        matrix = BitReader(body, pos)
        has_scale = matrix.read(1)
        if has_scale:
            scale_bits = matrix.read(5)
            scale_offset = matrix.offset
            scale_x = matrix.read_signed(scale_bits)
            scale_y = matrix.read_signed(scale_bits)
            if wanted.get(shape_id) == bitmap_id and scale_x == 20 * FIXED_ONE:
                absolute = (body_start + scale_offset // 8) * 8 + scale_offset % 8
                new_scale = (20 * FIXED_ONE) // divisor
                write_bits(data, absolute, scale_bits, new_scale)
                write_bits(data, absolute + scale_bits, scale_bits, new_scale)
                touched.append((shape_id, bitmap_id))
        if matrix.read(1):
            skew_bits = matrix.read(5)
            matrix.read_signed(skew_bits)
            matrix.read_signed(skew_bits)
        translate_bits = matrix.read(5)
        matrix.read_signed(translate_bits)
        matrix.read_signed(translate_bits)
        matrix.align()
        pos = matrix.byte
    return touched


def set_shape_scale(path: Path, shape_id: int, bitmap_id: int, pixels_per_bitmap: float) -> float:
    """Force one shape's bitmap fill to a given twips-per-bitmap-pixel scale.

    `retune` only accepts a fill still sitting at the original 20.0, so it can
    be run repeatedly without compounding. This is the unconditional form, for
    art authored at a non-integer multiple: the login background is drawn at
    1.5x, which is 20/1.5 twips per pixel and cannot be reached by halving.

    The value is written into the bit width already on disk, so the tag - and
    the file - keep their length.
    """
    data = bytearray(path.read_bytes())
    original_length = len(data)
    target = round(pixels_per_bitmap * FIXED_ONE)
    for code, body_start, length in iter_tags(bytes(data)):
        if code not in DEFINE_SHAPE_TAGS or length < 2:
            continue
        body = memoryview(data)[body_start:body_start + length]
        (found,) = struct.unpack_from("<H", body, 0)
        if found != shape_id:
            continue
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
        for _ in range(count):
            fill_type = body[pos]
            pos += 1
            if fill_type == 0x00:
                pos += 4 if code in (32, 83) else 3
                continue
            if fill_type not in (0x40, 0x41, 0x42, 0x43):
                break
            (found_bitmap,) = struct.unpack_from("<H", body, pos)
            pos += 2
            matrix = BitReader(body, pos)
            if matrix.read(1):
                scale_bits = matrix.read(5)
                scale_offset = matrix.offset
                previous = matrix.read_signed(scale_bits)
                matrix.read_signed(scale_bits)
                if found_bitmap == bitmap_id:
                    absolute = body_start * 8 + scale_offset
                    write_bits(data, absolute, scale_bits, target)
                    write_bits(data, absolute + scale_bits, scale_bits, target)
                    if len(data) != original_length:
                        raise RuntimeError("scale patch changed the file length")
                    path.write_bytes(bytes(data))
                    return previous / FIXED_ONE
            if matrix.read(1):
                skew_bits = matrix.read(5)
                matrix.read_signed(skew_bits)
                matrix.read_signed(skew_bits)
            translate_bits = matrix.read(5)
            matrix.read_signed(translate_bits)
            matrix.read_signed(translate_bits)
            matrix.align()
            pos = matrix.byte
    raise RuntimeError(f"shape {shape_id} has no bitmap fill for {bitmap_id}")


def set_fill_translate(path: Path, shape_id: int, bitmap_id: int,
                       tx: float, ty: float) -> tuple[float, float]:
    """Force one shape's bitmap-fill translation, in stage pixels.

    A bitmap fill lands its art at the fill matrix's translation, not at the
    shape's origin, so a non-zero translate offsets the art from where the
    placement puts the shape. The header dock's Support plate carried a +1y
    here - compensation for a bitmap one pixel shorter than shape 2023's
    bounds - which pushed the whole tab a pixel below the other three. With the
    art authored to the full bounds this has to go back to zero.

    Written into the bit width already on disk, so the tag keeps its length.
    """
    data = bytearray(path.read_bytes())
    original_length = len(data)
    for code, body_start, length in iter_tags(bytes(data)):
        if code not in DEFINE_SHAPE_TAGS or length < 2:
            continue
        body = memoryview(data)[body_start:body_start + length]
        (found,) = struct.unpack_from("<H", body, 0)
        if found != shape_id:
            continue
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
        for _ in range(count):
            fill_type = body[pos]
            pos += 1
            if fill_type == 0x00:
                pos += 4 if code in (32, 83) else 3
                continue
            if fill_type not in (0x40, 0x41, 0x42, 0x43):
                break
            (found_bitmap,) = struct.unpack_from("<H", body, pos)
            pos += 2
            matrix = BitReader(body, pos)
            if matrix.read(1):
                scale_bits = matrix.read(5)
                matrix.read_signed(scale_bits)
                matrix.read_signed(scale_bits)
            if matrix.read(1):
                skew_bits = matrix.read(5)
                matrix.read_signed(skew_bits)
                matrix.read_signed(skew_bits)
            translate_bits = matrix.read(5)
            translate_offset = matrix.offset
            previous_x = matrix.read_signed(translate_bits)
            previous_y = matrix.read_signed(translate_bits)
            if found_bitmap == bitmap_id:
                absolute = body_start * 8 + translate_offset
                write_bits(data, absolute, translate_bits, round(tx * 20))
                write_bits(data, absolute + translate_bits, translate_bits,
                           round(ty * 20))
                if len(data) != original_length:
                    raise RuntimeError("fill translate changed the file length")
                path.write_bytes(bytes(data))
                return previous_x / 20, previous_y / 20
            matrix.align()
            pos = matrix.byte
    raise RuntimeError(f"shape {shape_id} has no bitmap fill for {bitmap_id}")


def retune(path: Path, divisor: int, shapes: dict[int, int] | None = None) -> list[tuple[int, int]]:
    shapes = shapes or SHAPE_BITMAPS
    data = bytearray(path.read_bytes())
    original_length = len(data)
    touched: list[tuple[int, int]] = []
    for code, body_start, length in iter_tags(bytes(data)):
        if code in DEFINE_SHAPE_TAGS and length >= 2:
            touched.extend(scale_shape_fills(data, body_start, length, shapes, divisor))
    if len(data) != original_length:
        raise RuntimeError("bitmap-scale patch changed the file length")
    path.write_bytes(bytes(data))
    return touched


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("swf", type=Path)
    parser.add_argument("--divisor", type=int, default=2,
                        help="Resolution multiplier the new art was authored at")
    args = parser.parse_args()
    touched = retune(args.swf, args.divisor)
    for shape_id, bitmap_id in touched:
        print(f"shape {shape_id}: bitmap {bitmap_id} now drawn at 1/{args.divisor} scale")
    if not touched:
        raise SystemExit("ERROR: no bitmap fill matrices were retuned")


if __name__ == "__main__":
    main()
