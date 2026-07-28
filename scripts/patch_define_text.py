"""Recolour DefineText / DefineText2 glyph records in place.

Button captions in this client are static glyph runs, not edit fields, so
`patch_edit_text` cannot touch them. A caption's colour lives in the
StyleChangeRecord that opens each text record: three bytes (DefineText) or
four (DefineText2), at an offset that depends only on which optional fields
precede it. Rewriting it in place keeps the tag length identical, so the file
never has to be repacked.

A record that carries no colour flag inherits black from the player. There is
no room to add the field without resizing the tag, so those are reported
rather than silently skipped.
"""
from __future__ import annotations

import struct
from pathlib import Path

DEFINE_TEXT = 11
DEFINE_TEXT2 = 33

HAS_FONT = 0x08
HAS_COLOR = 0x04
HAS_Y_OFFSET = 0x02
HAS_X_OFFSET = 0x01


def _iter_tags(data: bytes):
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
        yield pos + header, code, length
        pos += header + length
        if code == 0:
            break


def _skip_rect(data, pos: int) -> int:
    return pos + (5 + 4 * (data[pos] >> 3) + 7) // 8


def _skip_matrix(data, pos: int) -> int:
    """MATRIX is bit-packed, so it has to be walked a field at a time."""
    bit = pos * 8

    def take(n: int) -> int:
        nonlocal bit
        value = 0
        for _ in range(n):
            value = (value << 1) | ((data[bit >> 3] >> (7 - (bit & 7))) & 1)
            bit += 1
        return value

    if take(1):                      # HasScale
        take(2 * take(5))
    if take(1):                      # HasRotate
        take(2 * take(5))
    take(2 * take(5))                # translate
    return (bit + 7) // 8


def colour_offsets(data, body: int, alpha: bool) -> list[int]:
    """Byte offsets of every glyph-run colour in one text character."""
    pos = _skip_matrix(data, _skip_rect(data, body + 2))
    glyph_bits, advance_bits = data[pos], data[pos + 1]
    pos += 2
    found = []
    while True:
        flags = data[pos]
        pos += 1
        if flags == 0:
            return found
        if flags & 0x80:                                  # StyleChangeRecord
            if flags & HAS_FONT:
                pos += 2
            if flags & HAS_COLOR:
                found.append(pos)
                pos += 4 if alpha else 3
            if flags & HAS_X_OFFSET:
                pos += 2
            if flags & HAS_Y_OFFSET:
                pos += 2
            if flags & HAS_FONT:
                pos += 2
        else:                                             # GlyphEntry run
            bits = flags * (glyph_bits + advance_bits)
            pos += (bits + 7) // 8


def read_colours(path: Path) -> dict[int, list[tuple]]:
    """Every text character in the file, mapped to the colours it uses."""
    data = path.read_bytes()
    out = {}
    for body, code, _length in _iter_tags(data):
        if code not in (DEFINE_TEXT, DEFINE_TEXT2):
            continue
        (character,) = struct.unpack_from("<H", data, body)
        width = 4 if code == DEFINE_TEXT2 else 3
        try:
            offsets = colour_offsets(data, body, code == DEFINE_TEXT2)
        except (IndexError, struct.error):
            continue
        out[character] = [tuple(data[o:o + width]) for o in offsets]
    return out


def set_colour(path: Path, character: int,
               rgb: tuple[int, int, int]) -> list[tuple]:
    """Recolour every glyph run in one character. Returns what was replaced."""
    data = bytearray(path.read_bytes())
    original_length = len(data)
    for body, code, _length in _iter_tags(bytes(data)):
        if code not in (DEFINE_TEXT, DEFINE_TEXT2):
            continue
        (found,) = struct.unpack_from("<H", data, body)
        if found != character:
            continue
        alpha = code == DEFINE_TEXT2
        offsets = colour_offsets(data, body, alpha)
        if not offsets:
            raise RuntimeError(
                f"text {character} has no colour record to patch - its runs "
                f"inherit the player default"
            )
        previous = []
        for offset in offsets:
            width = 4 if alpha else 3
            previous.append(tuple(data[offset:offset + width]))
            data[offset:offset + 3] = bytes(rgb)
        if len(data) != original_length:
            raise RuntimeError("text recolour changed the file length")
        path.write_bytes(bytes(data))
        return previous
    raise RuntimeError(f"text character {character} not found in {path}")
