"""Delete a PlaceObject2 outright, so the object is never instantiated.

`hide_placement` stamps a zero-alpha colour transform, which is the right tool
when something has to keep its place in the display list. It is the wrong tool
for removing a control: in AS2 an alpha-zero button still receives mouse
events, so a "hidden" button is an invisible button the player can still click.

This removes the placement tag instead. The character definition is left alone -
other timelines may share it - but nothing places it, so the clip, its children
and its frame script never come into being. The enclosing DefineSprite's length
and the SWF FileLength are fixed up; the file gets *smaller*, so this must run
before the SWF is padded to its embedded allocation.

Used to take the "Activate your Purchase" panel off the home screen.
"""
from __future__ import annotations

import struct
from pathlib import Path

DEFINE_SPRITE = 39
PLACE_OBJECT2 = 26
HAS_CHARACTER = 0x02


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


def remove(path: Path, sprite_id: int, depth: int,
           expect_character: int | None = None) -> int:
    """Delete sprite_id's placement at `depth`. Returns bytes removed.

    `expect_character` guards against depth drift: if the placement at that
    depth is not the character expected, nothing is written.
    """
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
            character = (struct.unpack_from("<H", data, p + 3)[0]
                         if flags & HAS_CHARACTER else None)
            if expect_character is not None and character != expect_character:
                raise RuntimeError(
                    f"sprite {sprite_id} depth {depth} places character "
                    f"{character}, expected {expect_character}"
                )
            if length < 0x3F:
                raise RuntimeError("sprite tag is short-form; length edit unsupported")
            delta = theader + tlength
            del data[tpos:tpos + delta]
            struct.pack_into("<I", data, pos + 2, length - delta)
            struct.pack_into("<I", data, 4, len(data))
            path.write_bytes(bytes(data))
            return delta
        raise RuntimeError(f"sprite {sprite_id} has no placement at depth {depth}")
    raise RuntimeError(f"sprite {sprite_id} not found in {path}")
