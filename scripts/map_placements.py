"""Report which sprite places which character, for one SWF.

Restyling a shared bitmap is only safe once you know every place it appears.
This walks the tag stream, descends into sprite bodies, and records each
PlaceObject that names a character - so a bitmap can be traced from its shape
up to the sprites that show it.

Used to scope the race-HUD retheme: it is what proved the tach skins all hang
off sprite 138 (purchasable inventory) while the stock face sits alone in
sprite 43 on frame 1.

    python scripts/map_placements.py <file.swf> [character ...]
"""
from __future__ import annotations

import struct
import sys
from collections import defaultdict
from pathlib import Path

import dialog_swf

DEFINE_SPRITE = 39
DEFINE_SHAPES = {2, 22, 32, 83}
PLACE = {4: "PlaceObject", 26: "PlaceObject2", 70: "PlaceObject3"}
EXPORT_ASSETS = 56


def shape_to_bitmap(data: bytes) -> dict[int, set[int]]:
    """Shape id -> bitmap ids it fills with, by scanning the fill styles.

    The fill style array is bit-packed after the bounds, but a bitmap fill is
    identifiable without unpacking it: style type 0x40-0x43 followed by a
    16-bit character id. Scanning for that pattern over-reports rather than
    missing one, which is the safe direction for an audit.
    """
    out = defaultdict(set)
    for pos, header, code, length in dialog_swf.iter_tags(data):
        if code not in DEFINE_SHAPES:
            continue
        body = data[pos + header: pos + header + length]
        (shape,) = struct.unpack_from("<H", body, 0)
        for i in range(len(body) - 3):
            if body[i] in (0x40, 0x41, 0x42, 0x43):
                (candidate,) = struct.unpack_from("<H", body, i + 1)
                if candidate:
                    out[shape].add(candidate)
    return out


def _inner_tags(body: bytes):
    """Tag stream inside a DefineSprite body, past its id and frame count."""
    pos = 4
    while pos < len(body) - 1:
        (code_len,) = struct.unpack_from("<H", body, pos)
        code, length = code_len >> 6, code_len & 0x3F
        header = 2
        if length == 0x3F:
            (length,) = struct.unpack_from("<I", body, pos + 2)
            header = 6
        yield pos + header, code, length
        pos += header + length
        if code == 0:
            break


def _placed(buffer: bytes, body_at: int, code: int):
    if code == 4:
        return struct.unpack_from("<H", buffer, body_at)[0]
    if not buffer[body_at] & 0x02:               # HasCharacter
        return None
    offset = body_at + (4 if code == 70 else 3)
    return struct.unpack_from("<H", buffer, offset)[0]


def placements(data: bytes) -> dict[int, set[int]]:
    """Character id -> the sprite ids that place it (0 = main timeline).

    DefineSprite is a container: its own timeline tags sit inside its body, so
    a top-level walk steps straight over every PlaceObject in the file that is
    not on the root timeline. Sprite bodies have to be descended into.
    """
    out = defaultdict(set)
    for pos, header, code, length in dialog_swf.iter_tags(data):
        body_at = pos + header
        if code == DEFINE_SPRITE:
            body = data[body_at: body_at + length]
            (sprite,) = struct.unpack_from("<H", body, 0)
            for inner_at, inner_code, _inner_len in _inner_tags(body):
                if inner_code not in PLACE:
                    continue
                character = _placed(body, inner_at, inner_code)
                if character:
                    out[character].add(sprite)
            continue
        if code in PLACE:
            character = _placed(data, body_at, code)
            if character:
                out[character].add(0)
    return out


def names(data: bytes) -> dict[int, str]:
    out = {}
    for pos, header, code, length in dialog_swf.iter_tags(data):
        if code != EXPORT_ASSETS:
            continue
        body = data[pos + header: pos + header + length]
        (count,) = struct.unpack_from("<H", body, 0)
        cursor = 2
        for _ in range(count):
            (character,) = struct.unpack_from("<H", body, cursor)
            cursor += 2
            end = body.index(b"\x00", cursor)
            out[character] = body[cursor:end].decode("latin-1")
            cursor = end + 1
    return out


def main() -> None:
    path = Path(sys.argv[1])
    wanted = {int(a) for a in sys.argv[2:]}
    data = dialog_swf.read(path)
    fills = shape_to_bitmap(data)
    places = placements(data)
    label = names(data)

    def describe(character: int) -> str:
        return f"{character}" + (f"({label[character]})" if character in label else "")

    for bitmap in sorted(wanted) or sorted(fills):
        shapes = [s for s, b in fills.items() if bitmap in b]
        sprites = set()
        for shape in shapes:
            sprites |= places.get(shape, set())
        print(f"bitmap {bitmap}: shapes {shapes or '-'} -> sprites "
              f"{sorted(describe(s) for s in sprites) or '-'}")


if __name__ == "__main__":
    main()
