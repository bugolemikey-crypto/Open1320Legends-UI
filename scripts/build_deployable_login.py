"""Build the deployable, exact-size main.swf login redesign.

Unlike a complete FFDec XML rebuild, this workflow transplants only the edited
layout tags into the untouched source SWF, then replaces four JPEG3 characters.
The result must match source/main.swf byte-for-byte in length before deployment.
"""
from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from patch_bitmap_scale import retune as retune_bitmap_scale
from patch_discord_login import patch_main_swf
from prepare_deployable_login_assets import SUPERSAMPLE
from prepare_deployable_login_assets import main as prepare_assets
from prepare_header_assets import main as prepare_header_assets
from splice_swf_tags import splice
from swf_utils import ROOT, game_root, load_config, resolve_ffdec_path
from ui_editor import pad_swf

SOURCE = ROOT / "source" / "main.swf"
LAYOUT = ROOT / "ui_layout.json"
OUTPUT = ROOT / "patches" / "main_client" / "main.swf"
PREPARED = ROOT / "assets" / "login" / "prepared"
HEADER_PREPARED = ROOT / "assets" / "header" / "prepared"
SELECTED_MAP = ROOT / "assets" / "home" / "map_background_graphite_exact-v2.jpg"
TAG_IDS = {1935, 1936, 1962, 1963, 2002, 2093, 2094, 1043}


def embedded_allocation() -> int:
    """Bytes the executable actually reserves for the embedded main.swf.

    `source/main.swf` is a re-extraction and can be a few hundred bytes shorter
    than the stream the exe declares, so padding to the source size produces a
    patch that deploy_patches.py rejects as a size mismatch. Read the real
    allocation from the exe and fall back to the source size if it is absent.
    """
    config = load_config()
    exe = game_root(config) / config["game_exe"]
    if not exe.exists():
        return SOURCE.stat().st_size
    offset = int(config["main_swf_embed_offset"])
    with exe.open("rb") as fh:
        fh.seek(offset + 4)
        declared = int.from_bytes(fh.read(4), "little")
    available = exe.stat().st_size - offset
    return min(declared, available)


def run(command: list[str], timeout: int = 900) -> None:
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, timeout=timeout)
    if result.stdout:
        print(result.stdout, end="")
    if result.returncode not in (0, 255):
        raise RuntimeError(result.stderr or f"Command failed: {command}")


def main() -> None:
    if not SOURCE.exists():
        raise RuntimeError(f"Missing source SWF: {SOURCE}")
    prepare_assets()
    prepare_header_assets()
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="login-build-", dir=ROOT) as temp_name:
        temp = Path(temp_name)
        donor = temp / "layout-donor.swf"
        scripted_donor = temp / "layout-scripted-donor.swf"
        spliced = temp / "layout-spliced.swf"
        startup_scaled = temp / "layout-startup-scaled.swf"
        startup_hidden = temp / "layout-startup-hidden.swf"
        art = temp / "layout-art.swf"
        discord = temp / "layout-discord.swf"

        run([
            sys.executable,
            str(ROOT / "scripts" / "ui_editor.py"),
            "apply",
            "--swf", str(SOURCE),
            "--output", str(donor),
            "--layout", str(LAYOUT),
        ])
        run([
            resolve_ffdec_path(), "-replace", str(donor), str(scripted_donor),
            "\\DefineSprite_2002\\frame_1\\DoAction", str(
                ROOT / "exports" / "main_client" / "scripts" / "scripts"
                / "DefineSprite_2002" / "frame_1" / "DoAction.as"
            ),
            "\\DefineSprite_1043_dialogCreateAccountContent\\frame_9\\DoAction", str(
                ROOT / "exports" / "main_client" / "scripts" / "scripts"
                / "DefineSprite_1043_dialogCreateAccountContent" / "frame_9" / "DoAction.as"
            ),
        ], timeout=300)
        splice(SOURCE, scripted_donor, spliced, TAG_IDS)

        # Frame 1 contains duplicate top-level DoAction tags, so FFDec cannot
        # address DoAction_2 by its exported filename through -replace. Import
        # the one-file export tree instead; this updates only the startup
        # scaling action while preserving the rest of the SWF.
        import_root = temp / "startup-scripts"
        import_frame = import_root / "frame_1"
        import_frame.mkdir(parents=True)
        shutil.copy2(
            ROOT / "exports" / "main_client" / "scripts" / "scripts"
            / "frame_1" / "DoAction_2.as",
            import_frame / "DoAction_2.as",
        )
        run([
            resolve_ffdec_path(), "-importScript", str(spliced),
            str(startup_scaled), str(import_root),
        ], timeout=300)

        # The legacy intro movie takes over the root stage while loading.
        # Replace frame 111 with a direct play() so it is never requested or
        # rendered during startup.
        run([
            resolve_ffdec_path(), "-replace", str(startup_scaled), str(startup_hidden),
            "\\frame_111\\DoAction", str(
                ROOT / "exports" / "main_client" / "scripts" / "scripts"
                / "frame_111" / "DoAction.as"
            ),
        ], timeout=300)

        run([
            resolve_ffdec_path(), "-replace", str(startup_hidden), str(art),
            "1925", str(PREPARED / "login_bitmap_850x650.jpg"), "jpeg3",
            "1945", str(PREPARED / "btn_login_172x29.jpg"), "jpeg3",
            "1948", str(PREPARED / "btn_create_172x29.jpg"), "jpeg3",
            "1953", str(PREPARED / "btn_discord_174x29.jpg"), "jpeg3",
            "1938", str(PREPARED / "forgot_icon_15x15.png"), "lossless2",
            "2003", str(HEADER_PREPARED / "header_base_798x69.jpg"), "jpeg3",
            "2039", str(HEADER_PREPARED / "header_logo_265x74.jpg"), "jpeg3",
            "2227", str(SELECTED_MAP), "jpeg3",
        ], timeout=300)
        # The replaced art is authored at SUPERSAMPLE x its stage size so it
        # survives the "showAll" upscale when the window is maximised. Divide
        # the matching shape fill matrices by the same factor, or each shape
        # would paint its bitmap oversized and crop it to the shape bounds.
        # In-place, byte-length-neutral, so it cannot disturb the exact size.
        if SUPERSAMPLE != 1:
            retuned = retune_bitmap_scale(art, SUPERSAMPLE)
            if len(retuned) != 6:
                raise RuntimeError(
                    f"expected to retune 6 bitmap fill matrices, retuned {len(retuned)}"
                )
            print(f"Retuned {len(retuned)} bitmap fill matrices for {SUPERSAMPLE}x art")

        target_size = embedded_allocation()
        patch_main_swf(art, discord)
        shutil.copy2(discord, OUTPUT)
        if OUTPUT.stat().st_size < target_size:
            pad_swf(OUTPUT, target_size)

    if OUTPUT.stat().st_size != target_size:
        raise RuntimeError(
            f"Final SWF size {OUTPUT.stat().st_size:,} does not match the "
            f"embedded allocation {target_size:,}"
        )
    print(f"Deployable login patch: {OUTPUT} ({OUTPUT.stat().st_size:,} bytes)")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, subprocess.SubprocessError) as exc:
        raise SystemExit(f"ERROR: {exc}")
