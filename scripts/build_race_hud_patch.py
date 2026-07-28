"""Apply the dark-theme pass to the race HUD (rc.swf).

rc.swf loads from `cache/car/rc.swf` at race start via a plain MovieClipLoader
with no version check, so it carries no fixed byte allocation.

**Never run the decompiler over this file.** Button 141 registers six keyPress
conditions covering both cases of each shift key (`119 'w'` / `87 'W'`,
`115 's'` / `83 'S'`, plus both arrows). Re-serialisation is exactly what
flipped `'s'` to `'S'` in the main client and killed shifting twice; here it
would be worse, because there is no previously-patched copy to byte-restore
from. Everything below is raw tag surgery through `dialog_swf`, which copies
untouched tags through byte for byte, and the build asserts the six codes are
unchanged before it writes.

Scope is set by `map_placements.py`, not by eye - see `prepare_race_hud` for
why the sub-gauges and everything under sprite 138 are excluded.
"""
from __future__ import annotations

import shutil
import struct
import sys
from pathlib import Path

import dialog_swf
from prepare_race_hud import POINTER_RAMP, add_face, cyan_to_red
from swf_utils import ROOT, game_root

PATCH_DIR = ROOT / "patches" / "race_hud"
TARGET = PATCH_DIR / "rc.swf"
SNAPSHOT = PATCH_DIR / "rc.pre-dark-hud.swf"

# The game loads cache/car; cache/misc holds an identical copy. Both are kept
# in step so nothing falls back to the untouched one.
DEPLOY = ("cache/car/rc.swf", "cache/misc/rc.swf")

# Frame-1 stock instruments only. 35 is the tach face (sprite 43), 37 its
# needle, and 22 / 16 the boost and NOS pointers - none of them reachable from
# sprite 138, the purchasable cluster.
TACH = 35
# The tach needle is big enough to carry the full glow ramp; the two ~30px
# sub-gauge pointers wash out on it and need the held-back one.
NEEDLES = {37: None, 22: POINTER_RAMP, 16: POINTER_RAMP}

SHIFT_BUTTON = 141
DEFINE_BUTTON2 = 34


def button_conditions(data: bytes, character: int) -> list[int]:
    """Every keyPress code registered on one button, for before/after proof."""
    for pos, header, code, length in dialog_swf.iter_tags(data):
        if code != DEFINE_BUTTON2:
            continue
        body = data[pos + header: pos + header + length]
        if struct.unpack_from("<H", body, 0)[0] != character:
            continue
        (offset,) = struct.unpack_from("<H", body, 3)
        if offset == 0:
            return []
        found, cursor = [], 3 + offset
        while cursor < len(body) - 3:
            (size,) = struct.unpack_from("<H", body, cursor)
            (condition,) = struct.unpack_from("<H", body, cursor + 2)
            found.append((condition >> 9) & 0x7F)
            if size == 0:
                break
            cursor += size
        return found
    raise RuntimeError(f"button {character} not found")


def main() -> None:
    if not SNAPSHOT.exists():
        raise SystemExit(f"missing pristine snapshot: {SNAPSHOT}")

    data = dialog_swf.read(SNAPSHOT)
    before = button_conditions(data, SHIFT_BUTTON)
    print(f"  shift keys before: {before}")

    original, _code = dialog_swf.extract(data, TACH)
    data, length = dialog_swf.replace(
        data, TACH, cyan_to_red(add_face(original)))
    print(f"  {TACH:>4}  tach face: smoked face + red glow, {length:,} B")

    for character, stops in NEEDLES.items():
        art, _code = dialog_swf.extract(data, character)
        # full: these bitmaps are nothing but glow, so every pixel converts
        recoloured = (cyan_to_red(art, full=True, stops=stops) if stops
                      else cyan_to_red(art, full=True))
        data, length = dialog_swf.replace(data, character, recoloured)
        print(f"  {character:>4}  needle -> red, {length:,} B")

    after = button_conditions(data, SHIFT_BUTTON)
    if after != before:
        raise SystemExit(f"ABORT: shift keys changed {before} -> {after}")
    print(f"  shift keys after:  {after}  (unchanged)")

    size = dialog_swf.write(TARGET, data)
    print(f"  {TARGET.name}: {SNAPSHOT.stat().st_size:,} -> {size:,} B "
          f"({size - SNAPSHOT.stat().st_size:+,})")

    if "--deploy" in sys.argv:
        root = game_root()
        for relative in DEPLOY:
            destination = root / relative
            shutil.copy2(TARGET, destination)
            print(f"  deployed -> {destination}")


if __name__ == "__main__":
    main()
