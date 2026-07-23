"""Make race staging chat bubbles visible with fixed-size SWF patches."""
from __future__ import annotations

import argparse
import shutil
from pathlib import Path


OLD_Y = 190
NEW_Y = 240

# AS2 bytecode inside classes.Race.racerBubbleMoveCB. The signature includes
# the local name and surrounding Push/StoreRegister actions so an unrelated
# integer 190 can never be changed accidentally.
PREFIX = bytes.fromhex("000100062a0002") + b"skipBubble\x00" + bytes.fromhex("df0096050007")
SUFFIX = bytes.fromhex("8701000517")
OLD = PREFIX + OLD_Y.to_bytes(4, "little") + SUFFIX
NEW = PREFIX + NEW_Y.to_bytes(4, "little") + SUFFIX

# In racePlay frame 20, the original ActionScript creates the racerBubbles
# container only inside `if (!_global.chatObj.raceRoomMC.isTeamRivals)`.
# The compiled bytecode evaluates isTeamRivals, coerces it with Not/Not, then
# ActionIf skips 260 bytes over the whole container setup. Making the branch 0
# keeps the rest of the expression intact but never skips container creation.
FRAME_TEAM_RIVALS_GATE = bytes.fromhex(
    "96 02 00 08 03 1c"
    "96 02 00 08 04 4e"
    "96 02 00 08 05 4e"
    "96 02 00 08 06 4e"
    "12 12 9d 02 00 04 01"
)
FRAME_TEAM_RIVALS_PATCHED = FRAME_TEAM_RIVALS_GATE.replace(
    bytes.fromhex("9d 02 00 04 01"), bytes.fromhex("9d 02 00 00 00")
)

# In classes.Race.checkChatMessage, the original bytecode returns before
# matching racer names when isTeamRivals is true. This makes only that early
# return branch fall through, so racerBubble() still decides whether to attach.
CHECK_CHAT_TEAM_RIVALS_GATE = bytes.fromhex(
    "96 04 00 04 01 08 20"
    "4e"
    "96 02 00 08 a3 4e"
    "96 03 00 09 3e 01 4e"
    "12 9d 02 00 05 00"
    "96 01 00 03 3e"
)
CHECK_CHAT_TEAM_RIVALS_PATCHED = CHECK_CHAT_TEAM_RIVALS_GATE.replace(
    bytes.fromhex("9d 02 00 05 00"), bytes.fromhex("9d 02 00 00 00")
)

# Keep the bubble layer above the staging/track overlays. This targets the two
# createEmptyMovieClip calls in racePlay frame 20.
BUBBLE_DEPTHS = bytes.fromhex(
    "96 0e 00 07 17 00 00 00 08 61 07 02 00 00 00 08 0e"
    "1c 96 02 00 08 62 52 17"
    "96 0e 00 07 18 00 00 00 08 63 07 02 00 00 00 08 0e"
)
BUBBLE_DEPTHS_PATCHED = BUBBLE_DEPTHS.replace(
    bytes.fromhex("07 17 00 00 00"), bytes.fromhex("07 1c 00 00 00")
).replace(
    bytes.fromhex("07 18 00 00 00"), bytes.fromhex("07 1d 00 00 00")
)

# Diagnostic/compatibility patch: if the sender name no longer matches
# racer1Obj.uName exactly, still run the lane-1 bubble path instead of skipping
# all bubble rendering. This confirms/fixes the common mismatch caused by room
# chat display names differing from race object names.
RACER1_NAME_MATCH_GATE = bytes.fromhex(
    "96 03 00 09 88 01 4e"
    "49 12 9d 02 00 25 00"
    "96 0e 00 04 03 07 01 00 00 00 07 02 00 00 00 08 01"
)
RACER1_NAME_MATCH_PATCHED = RACER1_NAME_MATCH_GATE.replace(
    bytes.fromhex("9d 02 00 25 00"), bytes.fromhex("9d 02 00 00 00")
)

# Race.onRaceStart hides the whole bubble layer as the lights drop. Server chat
# can arrive during that same transition, so keep the layer visible.
RACE_START_HIDE = bytes.fromhex(
    "96 05 00 04 01 09 23 01"
    "4e"
    "96 04 00 08 4c 05 00"
    "4f 4f"
)
RACE_START_HIDE_PATCHED = RACE_START_HIDE.replace(
    bytes.fromhex("08 4c 05 00"), bytes.fromhex("08 4c 05 01")
)


FIXED_PATCHES = (
    ("race bubble y", OLD, NEW),
    ("racePlay bubble container team-rivals gate", FRAME_TEAM_RIVALS_GATE, FRAME_TEAM_RIVALS_PATCHED),
    ("Race.checkChatMessage team-rivals gate", CHECK_CHAT_TEAM_RIVALS_GATE, CHECK_CHAT_TEAM_RIVALS_PATCHED),
    ("racePlay bubble layer depths", BUBBLE_DEPTHS, BUBBLE_DEPTHS_PATCHED),
    ("Race.checkChatMessage racer1 name-match fallback", RACER1_NAME_MATCH_GATE, RACER1_NAME_MATCH_PATCHED),
    ("Race.onRaceStart keep bubbles visible", RACE_START_HIDE, RACE_START_HIDE_PATCHED),
)


def patch(source: Path, output: Path) -> int:
    data = source.read_bytes()
    patched = data
    first_offset = -1

    for name, old, new in FIXED_PATCHES:
        old_count = patched.count(old)
        new_count = patched.count(new)
        if old_count == 1 and new_count == 0:
            offset = patched.index(old)
            patched = patched[:offset] + new + patched[offset + len(old) :]
            if first_offset < 0:
                first_offset = offset
            print(f"Patched {name} at file offset {offset:,}")
        elif old_count == 0 and new_count == 1:
            offset = patched.index(new)
            if first_offset < 0:
                first_offset = offset
            print(f"Already patched {name} at file offset {offset:,}")
        else:
            raise RuntimeError(
                f"Expected exactly one signature for {name}; "
                f"found old={old_count}, new={new_count}"
            )

    if len(patched) != len(data):
        raise RuntimeError("Fixed-size patch unexpectedly changed the file length")

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(patched)
    return first_offset


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path, nargs="?")
    parser.add_argument("--backup", action="store_true")
    args = parser.parse_args()

    output = args.output or args.source
    if args.backup and output == args.source:
        backup = args.source.with_suffix(args.source.suffix + ".race-chat.bak")
        if not backup.exists():
            shutil.copy2(args.source, backup)

    offset = patch(args.source, output)
    print(f"Race chat bubble patch complete; first touched/verified offset {offset:,}")


if __name__ == "__main__":
    main()
