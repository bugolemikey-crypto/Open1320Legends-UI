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

from insert_console_layer import insert as insert_console_layer
from patch_bitmap_scale import retune as retune_bitmap_scale
from patch_bitmap_scale import set_shape_scale
from patch_edit_text import set_colour as set_text_colour
from move_placement import move as move_placement
from prepare_deployable_login_assets import BACKGROUND_SUPERSAMPLE, SUPERSAMPLE
from prepare_deployable_login_assets import main as prepare_login_assets
from prepare_header_assets import LOGO_BUDGET
from prepare_header_assets import main as prepare_header_assets
from prepare_home_map import main as prepare_home_map
from prepare_polish_assets import main as prepare_polish_assets
from prepare_toolbar_assets import main as prepare_toolbar_assets
from prepare_nim_bezel import main as prepare_nim_bezel
from nim_console_parts import write_assembled as assemble_nim_console
import struct

from replace_jpeg3 import iter_tags as iter_swf_tags
from replace_jpeg3 import replace as replace_jpeg3
from replace_lossless2 import replace as replace_lossless2
import header_layout
from swf_utils import ROOT, game_root, load_config, resolve_ffdec_path
from ui_editor import pad_swf
from unhide_character import unhide

BASE = ROOT / "patches" / "main_client" / "main.dark-ui.current.swf"
OUTPUT = ROOT / "patches" / "main_client" / "main.polish.swf"
# deploy_patches.py embeds patches/<target-id>/main.swf, NOT our OUTPUT name, so
# the build has to publish itself there or a deploy silently ships a stale exe
# while still printing "Deployed embedded main.swf". That has now happened twice.
DEPLOY_SOURCE = ROOT / "patches" / "main_client" / "main.swf"
LOGIN_PREPARED = ROOT / "assets" / "login" / "prepared"
LOGIN_CONSOLE_OVERLAY = LOGIN_PREPARED / "login_console_overlay.png"
HEADER_PREPARED = ROOT / "assets" / "header" / "prepared"
POLISH_PREPARED = ROOT / "assets" / "polish" / "prepared"
HOME_PREPARED = ROOT / "assets" / "home" / "prepared"
LOGIN_ACTION = ROOT / "assets" / "polish" / "DefineSprite_2002_frame_1_DoAction.as"
PAINT_SHOP_ACTION = (ROOT / "assets" / "polish"
                     / "DefineSprite_3719_frame_1_DoAction.as")
# The home screen's purchase-activation panel (sprite 2242). Its code entry was
# styled exactly like the label beside it, so nothing marked it as typeable -
# and with 2231 blanked it has no panel art behind it either. That sprite has a
# single DoAction, so unlike the paint shop it is addressable by -replace.
ACTIVATE_ACTION = (ROOT / "assets" / "polish"
                   / "DefineSprite_2242_frame_1_DoAction.as")
STARTUP_SCRIPTS = ROOT / "assets" / "polish" / "startup"
# classes.Console is edited as separate files under assets/polish/nim/console/
# (see nim_console_parts) and concatenated into one class at build time, because
# FFDec can neither add new classes to the SWF nor honour #include.
NIM_FRAME = ROOT / "assets" / "polish" / "nim" / "Frame.as"
# RaceControls with the launch-control lc.swf loader removed. The repo base
# carries that loader (loadClip "cache/misc/lc.swf" into launchControl); the
# stock client the user was running does not, and loading it breaks the race
# gauge/HUD after staging or a reset. Matching the stock behaviour restores it.
RACE_CONTROLS = ROOT / "assets" / "polish" / "nim" / "RaceControls.as"
# Stock one-shot AvatarUploadBox (from the working client). The base's two-step
# variant never sends the upload POST on this projector - see the -replace note.
AVATAR_UPLOAD = ROOT / "assets" / "polish" / "nim" / "AvatarUploadBox.as"
# Paint finishes. classes.CarConstruction gains setPartFinish/setFinishes, which
# reuse the existing per-part paint/shad/hi layer stack (initPart) the same way
# the stock setPartPrimer already does - no new layers, no per-frame cost, since
# Drawing.snapshotCar flattens the car to a BitmapData afterwards. The finish id
# is read from the high byte of globalClr, which is 0 on every stock car, so a
# server that truncates `cc` to six hex digits leaves every car on gloss. When it
# does, the finish falls back to CarConstruction.finishMap, keyed by account car
# id - which is why CarSpecs is recompiled too, purely to carry that id through.
CAR_CONSTRUCTION = ROOT / "assets" / "polish" / "nim" / "CarConstruction.as"
CAR_SPECS = ROOT / "assets" / "polish" / "nim" / "CarSpecs.as"

# Character id -> (source art, byte budget). These go through replace_jpeg3
# rather than FFDec because their sizes have to be searched for, not accepted.
BUDGETED = {
    2039: (HEADER_PREPARED / "header_logo_265x74.png", LOGO_BUDGET),
    1942: (POLISH_PREPARED / "help_icon.png", 2_800),
    # NIM conversation bezel, recoloured silver->dark carbon (char 2224, was
    # 11,417B). Flat dark art compresses smaller than the busy silver original.
    2224: (ROOT / "assets" / "nim" / "prepared" / "nim_bezel_2224.png", 11_400),
    # Home 'Activate your Purchase' panel (2231, was 12,214B) + its Activate
    # button (2234, was 1,910B), recoloured orange->dark carbon. See
    # prepare_activate_panel.py. Kept JPEG3 at original dims.
    # Squeezed to the floor at the user's direction (2026-07-26). 900 was asked
    # for and is unreachable: a DefineBitsJPEG3 body is JPEG + a zlib alpha
    # channel, and this panel's alpha is a fixed 3,966 bytes at every quality, so
    # the tag cannot go below ~4,840 however hard the JPEG is crushed. 5,000 lands
    # at the bottom of that range (quality ~1-5, visibly blocky) and frees ~6.6KB
    # against the 11,662 it used to take. 6_000 is the same saving minus ~1KB and
    # looks far better; 12_200 restores the original.
    # The "Activate your Purchase" panel and its button, blanked to a 1x1
    # transparent pixel at the user's direction. Activation was pulled from the
    # client flow (see main-no-activation.swf), so this art is vestigial and was
    # only ever costing payload - it had already been squeezed twice to buy room
    # for other work. A 1x1 with zero alpha is the smallest a DefineBitsJPEG3 can
    # be: the tag is JPEG plus a LOSSLESS zlib alpha channel, and that alpha is
    # sized by pixel count, so shrinking the image is the only real lever.
    # Restore by pointing these back at activate_panel_2231.png / _2234.png.
    2231: (HOME_PREPARED / "blank_1x1.png", 400),
    2234: (HOME_PREPARED / "blank_1x1.png", 400),
    # Home city-map background, regraded to graphite. Budgeted a touch under the
    # original 89,524-byte tag so the swap frees rather than costs bytes.
    2227: (HOME_PREPARED / "map_2227_graphite.png", 70_000),
    # The node badges (2252-2280) and the LEADERBOARD / DAILY CHALLENGE buttons
    # (2285 / 2289) were reverted to their original art at the user's request -
    # they are simply not replaced here, so the base SWF's own bitmaps show.
}

# The header dock tabs, rebuilt as one dark-theme button family (NIM + its alert
# state, Viewer, Email). Their painting shapes (2006/2008/2012/2015) are plain
# DefineShape (v1), NOT the DefineShape2 that red-renders a lossless bitmap - so
# unlike the Support plate these ship as crisp Lossless2. Authored at 2x; the
# shapes are retuned below and the placements nudged onto one baseline.
LOSSLESS_TABS = {
    2005: HEADER_PREPARED / "toolbar_nim_67x24.png",
    2007: HEADER_PREPARED / "toolbar_nim_hilite_67x24.png",
    2011: HEADER_PREPARED / "toolbar_viewer_86x22.png",
    2014: HEADER_PREPARED / "toolbar_email_80x22.png",
}

# The Support tab completes the dock family. Its plate's shape (2023) is a
# DefineShape2 with a [0xFFFF, bitmap] fill, which the game's old projector
# renders as a solid red block when the bitmap is anything but the exact bytes
# it shipped with - every re-encode reproduced the "Support red block". So the
# three Support bitmaps are spliced in verbatim from the known-good dark-theme
# build (CURATED-v2) rather than re-encoded: byte-identical, guaranteed clean.
CURATED_SUPPORT = {
    2022: POLISH_PREPARED / "support_plate_2022_curated.tag",
    2020: POLISH_PREPARED / "support_text_2020_curated.tag",
    2021: POLISH_PREPARED / "support_icon_2021_curated.tag",
}
BITMAP_TAG_CODES = {6, 20, 21, 35, 36, 90}


def splice_bitmap_tag(path: Path, char_id: int, full_tag: bytes) -> int:
    """Swap whichever bitmap tag currently defines char_id for raw tag bytes."""
    data = path.read_bytes()
    for pos, header, code, length in iter_swf_tags(data):
        if code in BITMAP_TAG_CODES and \
                struct.unpack_from("<H", data, pos + header)[0] == char_id:
            rebuilt = bytearray(data[:pos]) + full_tag + data[pos + header + length:]
            struct.pack_into("<I", rebuilt, 4, len(rebuilt))
            path.write_bytes(bytes(rebuilt))
            return len(full_tag)
    raise RuntimeError(f"no bitmap tag defines character {char_id}")


DEFINE_BUTTON2 = 34
# FFDec re-serialises the WHOLE SWF on every -replace / -importScript, and in
# doing so it rewrites DefineButton2 keyPress handlers with the wrong character
# case - e.g. the base's `on(keyPress "s")` (the actual S key, code 115) becomes
# `on(keyPress "S")` (Shift+S, code 83). That silently breaks the W/S gear-shift
# controls in racing (buttons 66/1086/1122 call runEngineGearUp/Down). These
# button characters are therefore restored byte-for-byte from the base after all
# the FFDec passes, so the controls behave exactly as they shipped.
RACE_CONTROL_BUTTONS = (66, 1086, 1122)


def _extract_full_tag(data: bytes, char_id: int, code: int) -> bytes:
    for pos, header, tcode, length in iter_swf_tags(data):
        if tcode == code and length >= 2 and \
                struct.unpack_from("<H", data, pos + header)[0] == char_id:
            return data[pos:pos + header + length]
    raise RuntimeError(f"code {code} character {char_id} not found in base")


def splice_char_tag(path: Path, char_id: int, code: int, full_tag: bytes) -> int:
    """Overwrite art's tag (of a given code, matched by char id) with raw bytes."""
    data = path.read_bytes()
    for pos, header, tcode, length in iter_swf_tags(data):
        if tcode == code and length >= 2 and \
                struct.unpack_from("<H", data, pos + header)[0] == char_id:
            rebuilt = bytearray(data[:pos]) + full_tag + data[pos + header + length:]
            struct.pack_into("<I", rebuilt, 4, len(rebuilt))
            path.write_bytes(bytes(rebuilt))
            return len(full_tag)
    raise RuntimeError(f"code {code} char {char_id} not found in {path}")

# Shapes whose bitmap fill matrices this pass newly moves to 2x art. The three
# already retuned in the base SWF (1926, 2004, 2040) sit at 10.0 and are left
# alone by the divisor gate.
RETUNE_SHAPES = {
    1943: 1942,  # credential help button
    2023: 2022,  # header Support control
    2006: 2005,  # dock tab: NIM
    2008: 2007,  # dock tab: NIM alert state
    2012: 2011,  # dock tab: Viewer
    2015: 2014,  # dock tab: Email
}

# The header logo's placement, blanked by ui_editor, and how far left it moves
# to sit where the concept puts the lockup in its bay.
LOGO_SPRITE, LOGO_DEPTH = 2093, 35
MOVE_LOGO_X = -14

# The version caption sits centred in the header's recessed panel; it is right-
# aligned against the panel's inner edge. It is a live object placed by sprite
# 2093, so it moves by matrix. The caption stops short of the panel's inner
# edge: once signed in, the info panel (money / points / SC / unread mail)
# right-aligns into x 745..796, and a full right-align put the caption straight
# through "SC:". 114 leaves it ending at 733, twelve pixels clear. (The Support
# tab's own placement is now aligned with the rest of the dock via
# header_layout, not moved horizontally here.)
MOVE_VERSION = (2093, 34, 114.0)

# Shape painting the login background, which alone ships below SUPERSAMPLE.
BACKGROUND_SHAPE, BACKGROUND_BITMAP = 1926, 1925

# The header's info panel. All four fields ship in the legacy skin's
# desaturated teal-grey (#5C716D); this is the dark-theme reading order -
# money brightest, points secondary, Street Credit and unread mail on the
# accent, so the two numbers that change during play are the ones that catch
# the eye.
INFO_PANEL_COLOURS = {
    2068: (232, 236, 242),   # txtMoney
    2069: (170, 177, 188),   # txtPoints
    2070: (226, 60, 52),     # txtCred - "SC:"
    2071: (226, 60, 52),     # txtEmail - unread count
}


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
    prepare_home_map()
    prepare_toolbar_assets()
    prepare_nim_bezel()
    import prepare_activate_panel; prepare_activate_panel.main()

    ffdec = resolve_ffdec_path()
    with tempfile.TemporaryDirectory(prefix="polish-", dir=ROOT) as temp_name:
        temp = Path(temp_name)
        scripted = temp / "polish-scripted.swf"
        art = temp / "polish-art.swf"

        run([ffdec, "-replace", str(BASE), str(scripted),
             "\\DefineSprite_2002\\frame_1\\DoAction", str(LOGIN_ACTION)])
        # Frame 1 carries duplicate top-level DoAction tags, so FFDec cannot
        # address DoAction_2 by name through -replace; import the one-file tree
        # instead. That script is where the release number is set.
        versioned = temp / "polish-versioned.swf"
        run([ffdec, "-importScript", str(scripted), str(versioned),
             str(STARTUP_SCRIPTS)])
        # The NIM window redesign: classes.Console is recompiled from the edited
        # deployed source (italic buddy names, ONLINE/OFFLINE section headers,
        # red close button). Kept as its own -replace so a compile failure is
        # obvious. The source is the decompiled *deployed* class, not the drifted
        # repo classes/Console.as, so behaviour is preserved except these edits.
        consoled = temp / "polish-consoled.swf"
        nim_console = assemble_nim_console(temp / "Console.assembled.as")
        run([ffdec, "-replace", str(versioned), str(consoled),
             "\\__Packages\\classes\\Console", str(nim_console)])
        # classes.Frame recompiled from the deployed source (NOT repo Frame.as,
        # which has the legacy skinDockTab that dims/hides the dock tabs). The
        # only edit: createMap hides the map's NEWS node (bubblesGroup.court).
        framed = temp / "polish-framed.swf"
        run([ffdec, "-replace", str(consoled), str(framed),
             "\\__Packages\\classes\\Frame", str(NIM_FRAME)])
        raced = temp / "polish-raced.swf"
        run([ffdec, "-replace", str(framed), str(raced),
             "\\__Packages\\classes\\RaceControls", str(RACE_CONTROLS)])
        # Restore the STOCK one-shot AvatarUploadBox from the working client. The
        # repo base ships a two-step "Upload button" variant that never emits the
        # POST on this Director-embedded Flash (upload() called from the button
        # instead of directly in uploadRequestCB). The stock flow uploads on the
        # server other players use today. Same base-divergence fix as RaceControls.
        avatared = temp / "polish-avatared.swf"
        run([ffdec, "-replace", str(raced), str(avatared),
             "\\__Packages\\classes\\AvatarUploadBox", str(AVATAR_UPLOAD)])
        # Paint finishes (see CAR_CONSTRUCTION). Its own -replace so a compile
        # failure is unambiguous. CarConstruction only runs when a car is drawn,
        # i.e. after login - unlike classes.Drawing, whose recompile has hung
        # this client at startup before.
        painted = temp / "polish-painted.swf"
        run([ffdec, "-replace", str(avatared), str(painted),
             "\\__Packages\\classes\\CarConstruction", str(CAR_CONSTRUCTION)])
        # One added line: carry the account car id through as a spec, so the
        # finish can be keyed per car. Same post-login risk class as
        # CarConstruction - CarSpecs is only touched when a car is drawn.
        specced = temp / "polish-specced.swf"
        run([ffdec, "-replace", str(painted), str(specced),
             "\\__Packages\\classes\\CarSpecs", str(CAR_SPECS)])
        # The paint shop's GLOSS/MATTE/SATIN/CANDY picker, which drives the
        # finish through classes.CarConstruction.finishOverride. This is the
        # named DoAction (the function definitions), addressable by -replace;
        # the sibling DoAction_2 holding the init code is not, so the picker is
        # built from drawSwatches() rather than from the init script. The edit
        # also drops a debug for-in loop whose decompiled `each` identifier is
        # FFDec-escaped and would not survive a recompile.
        shopped = temp / "polish-shopped.swf"
        run([ffdec, "-replace", str(specced), str(shopped),
             "\\DefineSprite_3719\\frame_1\\DoAction", str(PAINT_SHOP_ACTION)])
        activated = temp / "polish-activated.swf"
        run([ffdec, "-replace", str(shopped), str(activated),
             "\\DefineSprite_2242\\frame_1\\DoAction", str(ACTIVATE_ACTION)])
        run([ffdec, "-replace", str(activated), str(art),
             "1925", str(LOGIN_PREPARED / "login_bitmap_850x650.jpg"), "jpeg3",
             # The three console buttons. These were only ever replaced by the
             # older build_deployable_login.py, so every regeneration of them in
             # this track was being built and then thrown away - which is why
             # the Discord button stayed maroon after the tint was removed.
             "1945", str(LOGIN_PREPARED / "btn_login_172x29.jpg"), "jpeg3",
             "1948", str(LOGIN_PREPARED / "btn_create_172x29.jpg"), "jpeg3",
             "1953", str(LOGIN_PREPARED / "btn_discord_174x29.jpg"), "jpeg3",
             "2003", str(HEADER_PREPARED / "header_base_798x69.jpg"), "jpeg3",
             "2017", str(POLISH_PREPARED / "tab_plate.png"), "lossless2"])

        # Undo FFDec's re-serialisation damage to the race-control buttons: it
        # flips their keyPress key case (breaking W/S gear shifting), so restore
        # them verbatim from the base now that all FFDec passes are done. The
        # later Python byte-edits never touch these characters.
        base_bytes = BASE.read_bytes()
        for character in RACE_CONTROL_BUTTONS:
            original = _extract_full_tag(base_bytes, character, DEFINE_BUTTON2)
            splice_char_tag(art, character, DEFINE_BUTTON2, original)
            print(f"Restored race-control button {character} "
                  f"({len(original):,} bytes) from base")

        for character, (source, budget) in BUDGETED.items():
            size, quality = replace_jpeg3(art, character, source, budget)
            print(f"character {character}: {size:,} bytes at quality {quality}")

        # The dock tabs, as crisp deflate streams. Safe here because their shapes
        # are DefineShape v1, not the DefineShape2 that red-blocks a lossless fill.
        for character, source in LOSSLESS_TABS.items():
            size = replace_lossless2(art, character, source)
            print(f"character {character}: {size:,} bytes lossless (dock tab)")

        # The Support tab's three bitmaps, spliced in byte-for-byte from the
        # clean dark-theme build (see CURATED_SUPPORT) so its DefineShape2 plate
        # renders without the red block. Its shape 2023 is retuned to 2x below.
        for character, tag_path in CURATED_SUPPORT.items():
            size = splice_bitmap_tag(art, character, tag_path.read_bytes())
            print(f"character {character}: {size:,} bytes spliced (curated Support)")

        retuned = retune_bitmap_scale(art, SUPERSAMPLE, RETUNE_SHAPES)
        if len(retuned) != len(RETUNE_SHAPES):
            raise RuntimeError(
                f"expected to retune {len(RETUNE_SHAPES)} bitmap fill matrices, "
                f"retuned {len(retuned)}: {retuned}"
            )
        print(f"Retuned {len(retuned)} bitmap fill matrices for {SUPERSAMPLE}x art")

        previous = set_shape_scale(art, BACKGROUND_SHAPE, BACKGROUND_BITMAP,
                                   20 / BACKGROUND_SUPERSAMPLE)
        print(f"Shape {BACKGROUND_SHAPE}: bitmap fill {previous} -> "
              f"{20 / BACKGROUND_SUPERSAMPLE:.4f} twips/px "
              f"({BACKGROUND_SUPERSAMPLE}x background)")

        removed = unhide(art, LOGO_SPRITE, LOGO_DEPTH, dx=MOVE_LOGO_X)
        print(f"Un-blanked sprite {LOGO_SPRITE} depth {LOGO_DEPTH}, moved "
              f"{MOVE_LOGO_X:+g}px ({removed:+d} bytes)")

        for character, rgb in INFO_PANEL_COLOURS.items():
            was = set_text_colour(art, character, rgb)
            print(f"character {character}: text colour {was[:3]} -> {rgb}")

        sprite, depth, dx = MOVE_VERSION
        print(f"Version caption -> {move_placement(art, sprite, depth, dx=dx)}")

        # Nudge every dock tab vertically so the panels each now draws land on
        # one baseline. sortDockTabs recomputes the tabs' _x from the dock anchor
        # at runtime, so only _y is taken from these placements. Support is
        # placed twice (docked tab + pre-login button) - both copies move.
        for name in ("nim", "email", "viewer", "support"):
            dy = header_layout.tab_delta(name)
            for depth in header_layout.TAB_DEPTHS[name]:
                move_placement(art, LOGO_SPRITE, depth, dy=dy)
            print(f"Tab {name} {dy:+g}y (depths {header_layout.TAB_DEPTHS[name]})")

        # The dock anchor (tabRight) tucks the whole right-anchored run inside
        # the header's recessed panel; and the blank tabRight cap inside the
        # Support sprite is pulled back to the plate edge so the run has no gap
        # (leaving it forward was itself a red-block trigger). Both horizontal.
        anchor = header_layout.anchor_delta()
        move_placement(art, LOGO_SPRITE, header_layout.ANCHOR_DEPTH, dx=anchor)
        cap = header_layout.support_cap_delta()
        move_placement(art, header_layout.SUPPORT_SPRITE,
                       header_layout.SUPPORT_CAP_DEPTH, dx=cap)
        print(f"Dock anchor {anchor:+g}x, Support cap {cap:+g}x")

        # Lift the console text off the photographic background onto its own
        # crisp lossless layer. Runs after set_shape_scale so the shape it
        # clones (1926) already carries the 2x fill scale, and before padding
        # because it grows the file. See insert_console_layer for the surgery.
        console = insert_console_layer(art, LOGIN_CONSOLE_OVERLAY)
        print(f"Console layer: lossless2={console['lossless2_bytes']:,}B "
              f"shape={console['shape_bytes']:,}B delta={console['delta']:+,}B")

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

    # Publish to the path the deployer actually reads. After padding, so the
    # deployed bytes are the ones measured above.
    shutil.copy2(OUTPUT, DEPLOY_SOURCE)

    print(f"Polish patch: {OUTPUT} ({OUTPUT.stat().st_size:,} bytes; "
          f"{target - built:,} bytes spare before padding)")
    print(f"Deploy source: {DEPLOY_SOURCE} (identical copy for deploy_patches.py)")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, subprocess.SubprocessError) as exc:
        raise SystemExit(f"ERROR: {exc}")
