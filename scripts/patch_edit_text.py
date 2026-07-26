"""Recolour a DefineEditText in place, without changing the file length.

The header's info panel - virtual money, points, Street Credit and the unread
email count - is four DefineEditText characters that all share one colour,
#5C716D. That desaturated teal-grey is the legacy skin's, and it is the reason
the panel still reads as the old client even on the redesigned chrome.

A DefineEditText's colour is a fixed four-byte RGBA at a position that depends
only on which optional fields precede it, so it can be overwritten where it
sits. Everything before it is re-read and asserted rather than assumed: if the
tag is not shaped the way this expects, it fails instead of writing into the
middle of a font id.
"""
from __future__ import annotations

import struct
from pathlib import Path

DEFINE_EDIT_TEXT = 37
HAS_TEXT = 0x80
HAS_TEXT_COLOR = 0x04
HAS_MAX_LENGTH = 0x02
HAS_FONT = 0x01
HAS_FONT_CLASS = 0x80
HAS_LAYOUT = 0x20


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
    nbits = data[pos] >> 3
    return pos + (5 + 4 * nbits + 7) // 8


def colour_offset(data, body: int) -> tuple[int, int]:
    """Byte offset of the RGBA, and the font height in twips (0 if no font)."""
    pos = _skip_rect(data, body + 2)
    flags, flags2 = data[pos], data[pos + 1]
    pos += 2
    if not flags & HAS_TEXT_COLOR:
        raise RuntimeError("edit text has no colour to patch")
    height = 0
    if flags & HAS_FONT:
        pos += 2                                    # font id
        height = struct.unpack_from("<H", data, pos)[0]
        pos += 2
    elif flags2 & HAS_FONT_CLASS:
        while data[pos]:
            pos += 1
        pos += 1
        height = struct.unpack_from("<H", data, pos)[0]
        pos += 2
    return pos, height


def set_colour(path: Path, character: int, rgb: tuple[int, int, int],
               alpha: int = 255) -> tuple[int, int, int, int]:
    """Overwrite one character's text colour. Returns the colour replaced."""
    data = bytearray(path.read_bytes())
    original_length = len(data)
    for body, code, _length in _iter_tags(bytes(data)):
        if code != DEFINE_EDIT_TEXT:
            continue
        (found,) = struct.unpack_from("<H", data, body)
        if found != character:
            continue
        pos, _height = colour_offset(data, body)
        previous = tuple(data[pos:pos + 4])
        data[pos:pos + 3] = bytes(rgb)
        data[pos + 3] = alpha
        if len(data) != original_length:
            raise RuntimeError("edit-text recolour changed the file length")
        path.write_bytes(bytes(data))
        return previous
    raise RuntimeError(f"DefineEditText {character} not found in {path}")
