"""Fix issue #891: KOTH "New King" screen shows "undefined" for the winner.

Root cause: DefineSprite_2630 (raceRoomMC) and DefineSprite_1532
(raceWinnerKOTH) both read/write the shared, mutable `kingObj` on the room
clip. DefineSprite_1513 (raceKingStepsDown), which runs in between, always
resets `_parent.kingObj = new Object()` once it has read what it needs -- that
reset is intentional and is left untouched here. raceWinnerKOTH's
showWinnerInfo() only runs 2-5s later via a scheduled doShowFinish timeout, by
which time kingObj has already been wiped, so kingObj.username is undefined.

Fix: onRaceResults() (DefineSprite_2630 frame 1, DoAction) snapshots the
finalized winner fields into a new `this.kingResultSnapshot` object right
after kingObj.carXML is set -- a property raceKingStepsDown's reset never
touches. showWinnerInfo() (DefineSprite_1532 frame 1, DoAction) is changed to
read from `_parent.kingResultSnapshot` instead of `_parent.kingObj`.

This uses FFDec's `-importScript` (see scripts/swf_utils.py:import_scripts),
which imports every .as file found under a scripts/ export-shaped directory
tree and matches it back to its owning tag by path
(scripts/<SpriteName>/frame_<n>/<DoAction tag>.as). Plain `-replace <charId>
<scriptName>` does not accept these path-style names on this FFDec build --
only -importScript does. These are logic edits, not colour swaps, so
recompiling just these two DoAction tags is required. Recompiled AS2 tags can
change length, so this patch is NOT byte-neutral; use
scripts/grow_embedded_swf.py at deploy time same as any other content patch.

Usage: python scripts/patch_koth_king_undefined.py <in.swf> <out.swf>
"""
from __future__ import annotations

import shutil
import sys
from pathlib import Path

from swf_utils import import_scripts

SCRIPT_TREE = Path(__file__).resolve().parent / "_koth_king_fix_tree"


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit(f"Usage: python {Path(__file__).name} <in.swf> <out.swf>")
    src, dst = Path(sys.argv[1]), Path(sys.argv[2])
    scripts_dir = SCRIPT_TREE / "scripts"
    if not scripts_dir.exists():
        raise FileNotFoundError(f"Edited script tree not found: {scripts_dir}")

    shutil.copy2(src, dst)
    # import_scripts patches swf_path in place, matching each .as file under
    # scripts_dir to the tag at the same relative path in the target SWF.
    import_scripts(dst, scripts_dir)

    print(f"\n{src.name}: {src.stat().st_size:,} -> {dst.name}: {dst.stat().st_size:,} bytes")


if __name__ == "__main__":
    main()
