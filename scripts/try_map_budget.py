"""Deploy one of the pre-built client variants, for bisecting what breaks.

Every run resets the exe to its pre-growth baseline first, so each variant is
measured from identical starting conditions instead of stacking on whatever the
last test left behind.

    python scripts/try_map_budget.py newmap      # working build + new map only
    python scripts/try_map_budget.py oldmap      # working build, original map
    python scripts/try_map_budget.py known-good  # the last payload known good

A liveness check proves NOTHING here: this is a Director 11.5 projector, and a
Director error dialog leaves the process alive, responding, with the correct
window title. Confirm by eye, in game, on the affected screen.
"""
from __future__ import annotations

import hashlib
import json
import shutil
import struct
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PATCHES = ROOT / "patches" / "main_client"
VARIANTS = {
    # The confirmed-working build with ONLY the regraded map swapped in - and
    # encoded SMALLER than the map it replaces, so payload size cannot be the
    # variable. Loads = the map art is fine and something else broke the
    # earlier builds. Freezes = the regraded art itself is what Director
    # rejects, independent of its size.
    "newmap": "main.newmap.swf",
    "oldmap": "main.oldmap.swf",
    "known-good": "main.KNOWN-GOOD.swf",
    "stock": "main.polish.swf",
}


def main() -> None:
    if len(sys.argv) != 2 or sys.argv[1] not in VARIANTS:
        raise SystemExit(f"usage: try_map_budget.py {{{'|'.join(VARIANTS)}}}")
    source = PATCHES / VARIANTS[sys.argv[1]]
    if not source.exists():
        raise SystemExit(f"missing {source}")

    config = json.loads((ROOT / "config.json").read_text())
    exe = Path(config["game_root"]) / config["game_exe"]
    backup = exe.with_name(exe.name + ".bak-pre-growth-test")
    if not backup.exists():
        raise SystemExit(f"missing baseline backup {backup}")

    try:
        shutil.copy2(backup, exe)
    except PermissionError:
        raise SystemExit("the game is running - close it first (the exe is locked)")
    print(f"exe reset to baseline ({exe.stat().st_size:,} bytes)")

    shutil.copy2(source, PATCHES / "main.swf")
    print(f"deploy source <- {source.name} ({source.stat().st_size:,} bytes)")

    subprocess.run([sys.executable, str(ROOT / "scripts" / "deploy_patches.py"),
                    "--target", "main_client"], check=True, cwd=ROOT)

    data = exe.read_bytes()
    offset = int(config["main_swf_embed_offset"])
    length = struct.unpack_from("<I", data, offset + 4)[0]
    payload = data[offset:offset + length]
    print(f"exe now {len(data):,} bytes "
          f"({len(data) - backup.stat().st_size:+,} vs baseline)")
    print("payload", "MATCHES" if payload == source.read_bytes() else "MISMATCH",
          hashlib.sha256(payload).hexdigest()[:16])
    print("\nLaunch and reach the city map. Alive-and-responding is NOT "
          "confirmation - look at the screen.")


if __name__ == "__main__":
    main()
