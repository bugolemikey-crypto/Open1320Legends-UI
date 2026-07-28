"""Apply the dark-theme pass to intro.swf and newuserform.swf.

These two movies load from `cache/misc` at runtime rather than living in the
projector's slot, so nothing here competes for the embedded allocation.

What changes:

  * every white input well becomes a recessed dark well, and the dark grey
    text that types into it is recoloured so it stays readable;
  * every silver pill button becomes carbon with a red ring, which also fixes
    the white captions that were near invisible on the silver original;
  * the "Hacked By ..." banner the fork's author left in the create-account
    form is emptied.

Each file is built from a pristine snapshot taken the first time this runs
(`*.pre-dialog-theme.swf`), never from its own output - the well detector looks
for bright fields, so a second pass over an already-darkened file would find
nothing and fail. Building from the snapshot makes re-running free.
"""
from __future__ import annotations

import struct
import sys
from pathlib import Path

import dialog_swf
from patch_edit_text import DEFINE_EDIT_TEXT, _iter_tags, colour_offset
from prepare_dialog_chrome import carbon_pill, darken_wells
from swf_utils import ROOT

INTRO = ROOT / "patches" / "loading_screen" / "intro.swf"
FORM = ROOT / "patches" / "login_form" / "newuserform.swf"

# Bright input fields. intro 13 is a single field; newuserform 41 is a sheet
# holding six of them plus the two radio dots, which stay white because they
# fall under the minimum well area.
WELLS = {INTRO: (13,), FORM: (41, 64)}

# The silver pill. intro ships four copies of the same art, one per dialog.
PILLS = {INTRO: (24, 69, 98, 151), FORM: (35,)}

# A "Hacked By ..." banner bound to HackTxt3 and shown on the live dialog.
# Nothing writes to it, so blanking the authored text removes it for good.
DEFACEMENT = {FORM: (34,)}

# What the fields type in. Every one of these ships #4B4B4B, which is legible
# on white and invisible on carbon.
INPUT_INK = (226, 231, 238)
LEGACY_INK = {(75, 75, 75), (51, 51, 51)}


def recolour_inputs(data: bytes) -> tuple[bytes, list[int]]:
    """Repoint every legacy dark edit field at the light ink. Length-neutral."""
    buffer = bytearray(data)
    touched = []
    for body, code, _length in _iter_tags(data):
        if code != DEFINE_EDIT_TEXT:
            continue
        (character,) = struct.unpack_from("<H", buffer, body)
        try:
            offset, _height = colour_offset(buffer, body)
        except RuntimeError:
            continue
        if tuple(buffer[offset:offset + 3]) not in LEGACY_INK:
            continue
        buffer[offset:offset + 3] = bytes(INPUT_INK)
        touched.append(character)
    return bytes(buffer), touched


def blank_initial_text(data: bytes, character: int) -> tuple[bytes, bytes]:
    """Empty one edit field's authored text. Returns (data, what was there)."""
    for pos, header, code, length in dialog_swf.iter_tags(data):
        if code != DEFINE_EDIT_TEXT:
            continue
        body = pos + header
        (found,) = struct.unpack_from("<H", data, body)
        if found != character:
            continue
        cursor = body + 2
        cursor += (5 + 4 * (data[cursor] >> 3) + 7) // 8
        flags = data[cursor]
        cursor += 2
        if not flags & 0x80:
            raise RuntimeError(f"edit text {character} carries no initial text")
        if flags & 0x01:                       # font id + height
            cursor += 4
        if flags & 0x04:                       # text colour
            cursor += 4
        if flags & 0x02:                       # max length
            cursor += 2
        if flags & 0x20:                       # layout
            cursor += 9
        variable_end = data.index(b"\x00", cursor)
        text_end = data.index(b"\x00", variable_end + 1)
        was = data[variable_end + 1:text_end]
        rebuilt = bytearray(data[:pos])
        rebuilt += dialog_swf.pack_tag(
            DEFINE_EDIT_TEXT,
            data[body:variable_end + 1] + data[text_end:pos + header + length])
        rebuilt += data[pos + header + length:]
        struct.pack_into("<I", rebuilt, 4, len(rebuilt))
        return bytes(rebuilt), was
    raise RuntimeError(f"DefineEditText {character} not found")


def snapshot(path: Path) -> Path:
    """The pristine copy this build reads from, taken once."""
    keep = path.with_suffix(".pre-dialog-theme.swf")
    if not keep.exists():
        keep.write_bytes(path.read_bytes())
        print(f"  snapshot -> {keep.name}")
    return keep


def patch(path: Path) -> None:
    source = snapshot(path)
    data = dialog_swf.read(source)
    before = source.stat().st_size

    for character in WELLS.get(path, ()):
        image, _code = dialog_swf.extract(data, character)
        restyled, wells = darken_wells(image)
        if not wells:
            raise RuntimeError(f"{path.name} character {character}: no well "
                               f"found to darken - the art has changed")
        data, length = dialog_swf.replace(data, character, restyled)
        print(f"  {character:>4}  {wells} well(s) darkened, {length:,} B")

    for character in PILLS.get(path, ()):
        image, _code = dialog_swf.extract(data, character)
        data, length = dialog_swf.replace(data, character, carbon_pill(image))
        print(f"  {character:>4}  pill -> carbon, {length:,} B")

    for character in DEFACEMENT.get(path, ()):
        data, was = blank_initial_text(data, character)
        print(f"  {character:>4}  removed authored text {was!r}")

    data, touched = recolour_inputs(data)
    print(f"  input ink -> {INPUT_INK} on {len(touched)} field(s): "
          f"{', '.join(str(c) for c in touched)}")

    after = dialog_swf.write(path, data)
    print(f"  {path.name}: {before:,} -> {after:,} B ({after - before:+,})")


def main() -> None:
    targets = [INTRO, FORM]
    if len(sys.argv) > 1:
        wanted = {a.lower() for a in sys.argv[1:]}
        targets = [t for t in targets if t.stem.lower() in wanted]
    for target in targets:
        print(f"== {target.relative_to(ROOT)}")
        patch(target)


if __name__ == "__main__":
    main()
