"""Apply the chrome polish pass on top of the currently deployed main.swf.

This is deliberately NOT a rebuild from `source/main.swf`. The deployed client
is the product of several patch tracks (login redesign, dark UI dialogs, the
NIM screen), so regenerating from source would silently drop everything except
the login work. Instead this takes the live payload as its base and replaces
only the characters this pass changes.

What it changes:

* 2040 - the header logo placement, un-blanked. It carried a zero colour
  transform, which is why the logo had to be baked into the login background
  where it could only ever show on one screen. It now draws inside the chrome,
  at stage x 78..343, on every screen carrying the strip.
* 2039 - that logo's bitmap, at 2x and with a real byte budget instead of the
  3.3KB it had while it was invisible.
* 2003 - the chrome strip, rebuilt from the concept header (which has the
  recessed right-hand panel and red accent tick that the blank shell lacks)
  with the live-drawn elements painted out.
* 1925 - login background, minus the logo it no longer carries and with the
  band behind the opaque strip flattened. Costs less, looks better.
* 2022 / 2020 / 2021 / 2017 - the Support control. The whole thing is drawn
  into the plate (2022) at 2x, because that is the only one of the four whose
  shape carries its bitmap matrix in the outer fill array and can therefore be
  retuned; the other three are blanked.
* 1942 - the credential help button, red circled "?" at 2x.
* DefineSprite_2002 frame 1 - hides the map button while login is up.
"""
from __future__ import annotations

import shutil
import subprocess
import tempfile
from pathlib import Path

from patch_bitmap_scale import retune as retune_bitmap_scale
from prepare_deployable_login_assets import SUPERSAMPLE
from prepare_deployable_login_assets import main as prepare_login_assets
from prepare_header_assets import LOGO_BUDGET
from prepare_header_assets import main as prepare_header_assets
from prepare_polish_assets import main as prepare_polish_assets
from replace_jpeg3 import replace as replace_jpeg3
from swf_utils import ROOT, game_root, load_config, resolve_ffdec_path
from ui_editor import pad_swf
from unhide_character import unhide

BASE = ROOT / "patches" / "main_client" / "main.dark-ui.current.swf"
OUTPUT = ROOT / "patches" / "main_client" / "main.polish.swf"
LOGIN_PREPARED = ROOT / "assets" / "login" / "prepared"
HEADER_PREPARED = ROOT / "assets" / "header" / "prepared"
POLISH_PREPARED = ROOT / "assets" / "polish" / "prepared"
LOGIN_ACTION = ROOT / "assets" / "polish" / "DefineSprite_2002_frame_1_DoAction.as"

# Character id -> (source art, byte budget). These go through replace_jpeg3
# rather than FFDec because their sizes have to be searched for, not accepted.
BUDGETED = {
    2039: (HEADER_PREPARED / "header_logo_265x74.png", LOGO_BUDGET),
    2022: (POLISH_PREPARED / "support_plate.png", 4_800),
    1942: (POLISH_PREPARED / "help_icon.png", 2_800),
    2020: (POLISH_PREPARED / "support_text.png", 500),
    2021: (POLISH_PREPARED / "support_icon.png", 500),
}

# Shapes whose bitmap fill matrices this pass newly moves to 2x art. The three
# already retuned in the base SWF (1926, 2004, 2040) sit at 10.0 and are left
# alone by the divisor gate.
RETUNE_SHAPES = {
    1943: 1942,  # credential help button
    2023: 2022,  # header Support control
}

# The header logo's placement, blanked by ui_editor.
LOGO_SPRITE, LOGO_DEPTH = 2093, 35


def embedded_allocation() -> int:
    """Bytes the executable physically reserves for the embedded stream.

    The declared length in the header shrinks every time a smaller patch is
    deployed, so it is a floor, not the ceiling. The ceiling is the rest of the
    file from the embed offset, less the four-byte trailer this executable
    keeps after the SWF.
    """
    config = load_config()
    exe = game_root(config) / config["game_exe"]
    offset = int(config["main_swf_embed_offset"])
    return exe.stat().st_size - offset - 4


def run(command: list[str], timeout: int = 600) -> None:
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True,
                            timeout=timeout)
    if result.stdout:
        print(result.stdout, end="")
    if result.returncode not in (0, 255):
        raise RuntimeError(result.stderr or f"Command failed: {command}")


def main() -> None:
    if not BASE.exists():
        raise RuntimeError(f"Missing base SWF: {BASE}")
    prepare_login_assets()
    prepare_header_assets()
    prepare_polish_assets()

    ffdec = resolve_ffdec_path()
    with tempfile.TemporaryDirectory(prefix="polish-", dir=ROOT) as temp_name:
        temp = Path(temp_name)
        scripted = temp / "polish-scripted.swf"
        art = temp / "polish-art.swf"

        run([ffdec, "-replace", str(BASE), str(scripted),
             "\\DefineSprite_2002\\frame_1\\DoAction", str(LOGIN_ACTION)])
        run([ffdec, "-replace", str(scripted), str(art),
             "1925", str(LOGIN_PREPARED / "login_bitmap_850x650.jpg"), "jpeg3",
             "2003", str(HEADER_PREPARED / "header_base_798x69.jpg"), "jpeg3",
             "2017", str(POLISH_PREPARED / "tab_plate.png"), "lossless2"])

        for character, (source, budget) in BUDGETED.items():
            size, quality = replace_jpeg3(art, character, source, budget)
            print(f"character {character}: {size:,} bytes at quality {quality}")

        retuned = retune_bitmap_scale(art, SUPERSAMPLE, RETUNE_SHAPES)
        if len(retuned) != len(RETUNE_SHAPES):
            raise RuntimeError(
                f"expected to retune {len(RETUNE_SHAPES)} bitmap fill matrices, "
                f"retuned {len(retuned)}: {retuned}"
            )
        print(f"Retuned {len(retuned)} bitmap fill matrices for {SUPERSAMPLE}x art")

        removed = unhide(art, LOGO_SPRITE, LOGO_DEPTH)
        print(f"Un-blanked sprite {LOGO_SPRITE} depth {LOGO_DEPTH} "
              f"({removed} colour-transform bytes removed)")

        target = embedded_allocation()
        shutil.copy2(art, OUTPUT)
        built = OUTPUT.stat().st_size
        if built > target:
            raise RuntimeError(
                f"Polish patch is {built:,} bytes, {built - target:,} over the "
                f"embedded allocation of {target:,}"
            )
        if built < target:
            pad_swf(OUTPUT, target)

    print(f"Polish patch: {OUTPUT} ({OUTPUT.stat().st_size:,} bytes; "
          f"{target - built:,} bytes spare before padding)")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, subprocess.SubprocessError) as exc:
        raise SystemExit(f"ERROR: {exc}")
