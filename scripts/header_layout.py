"""Where everything in the header strip sits, in one place.

Both `build_polish_patch.py` (which writes the placements into the SWF) and
`preview_header.py` (which draws what the result will look like) read these, so
the preview cannot drift from the build.

Coordinate systems
------------------
Sprite 2093 carries the whole header. Its space is offset from the stage by
(800, 600.6): shape 2004, the chrome strip, has bounds x -799..-1, y -599..-530
and is placed at the sprite origin, landing on stage at x 1..799, y 1.8..70.8.

Placements are quoted below in *stage* pixels, and the deltas the build applies
are derived from them, so the numbers here are the ones that can be read off a
screenshot.

The dock bar
------------
`classes.Control.sortDockTabs` right-anchors the docked tabs against
`tabRight._x` and stacks them leftwards, one pixel apart, so only `_y` comes
from each tab's own placement. That is why the tabs are aligned here by moving
them vertically and by moving the single anchor horizontally - moving an
individual tab's `_x` would be overwritten the next time a panel docks.

The four tabs are three different heights (24, 22 and 19 stage pixels) because
they were cut from three different legacy skins. Rather than fight that, every
tab's art draws the same PANEL_HEIGHT-tall panel inside its own bitmap at the
inset listed in TABS, and the placement is moved so those panels coincide.
"""
from __future__ import annotations

# Sprite 2093 space -> stage.
ORIGIN = (800.0, 600.6)

# --- the dock bar ---------------------------------------------------------
# The band every tab panel is aligned into, in stage pixels. The strip's inner
# floor is at y 70.8 and its bottom bezel eats the last few pixels, so 63 is as
# low as a panel can sit and still read as clear of it.
PANEL_TOP = 44.0
PANEL_HEIGHT = 19

# name -> (bitmap size, where the panel sits inside the bitmap, current stage
# top of the placement). The stage tops are the shipped placements, read from
# sprite 2093: tabNim y -560, tabEmail/tabViewer -554, tabSupport -555.
TABS = {
    "nim": ((67, 24), 2, 40.6),
    "email": ((80, 22), 1, 46.6),
    "viewer": ((86, 22), 1, 46.6),
    "support": ((113, 19), 0, 45.6),
}

# Sprite 2093 depths of each tab's placement. tabSupport is placed twice - as
# the docked tab (depth 9) and as the pre-login Support button (depth 17) - and
# both copies have to move together or the button drifts off the tab.
TAB_DEPTHS = {
    "nim": (2,),
    "email": (7,),
    "viewer": (5,),
    "support": (9, 17),
}

# tabRight, the invisible 37x18 character the dock run is right-anchored to.
# Its placement is the run's right edge. At its shipped x the run overhangs the
# chrome's panel divider (stage x 367) on the left; 733 tucks the full four-tab
# run inside the recessed panel and still leaves twelve pixels before the info
# panel's numbers at x 745.
ANCHOR_DEPTH = 15
ANCHOR_X = 679.8
ANCHOR_TARGET_X = 733.0

# tabRight is *also* a child of the Support sprite (2024, depth 1), left over
# from the legacy skin's plate cap. It is blank now, but it still counts
# towards the sprite's bounds, and sortDockTabs lays the run out by `_width` -
# so the Support tab reserved 131.75px for 113px of art and opened a gap in the
# run. Pulling the cap back to the plate's right edge makes the two agree.
SUPPORT_SPRITE = 2024
SUPPORT_CAP_DEPTH = 1
SUPPORT_CAP_X = 94.75
SUPPORT_CAP_TARGET_X = 113.0 - 37.0

# --- the version caption --------------------------------------------------
# Character 2038, an 8px right-aligned edit text (`txtRelease`, "PUBLIC BETA
# 0.0.1"). Its field box is x +19.1..+193.1, y -2..+11.6 from its placement,
# which sits at stage (425.9, 27.6) as shipped.
VERSION_DEPTH = 34
VERSION_RIGHT = 619.0          # stage x the right-aligned text ends at
VERSION_FIELD_TOP = 25.6       # stage y of the top of the field box
VERSION_FIELD_HEIGHT = 13.6

# The mod-tool sphere (character 2037) fills stage x 625.8..668.8, y 1..41, and
# the caption ran straight through it. 610 leaves sixteen pixels of daylight;
# the chrome's red accent tick ends at x 412, so the caption still has room.
VERSION_TARGET_RIGHT = 610.0
# Centred in the panel's upper row - the tabs start at y 44, so the caption's
# 13.6px field is centred on y 24.
VERSION_TARGET_CENTRE_Y = 24.0

# --- the logo -------------------------------------------------------------
# Character 2039's box inside the chrome bitmap, once the placement's 14px left
# move is applied. Shape 2004 starts at stage (1, 1.8) and shape 2040 at
# (64, 6.8).
LOGO_ORIGIN = (63.0, 5.0)


def version_delta() -> tuple[float, float]:
    """(dx, dy) in stage pixels for the version caption's placement."""
    dy = (VERSION_TARGET_CENTRE_Y - VERSION_FIELD_HEIGHT / 2) - VERSION_FIELD_TOP
    return VERSION_TARGET_RIGHT - VERSION_RIGHT, dy


def tab_delta(name: str) -> float:
    """dy in stage pixels that lands this tab's panel in the shared band."""
    _, inset, top = TABS[name]
    return PANEL_TOP - (top + inset)


def anchor_delta() -> float:
    return ANCHOR_TARGET_X - ANCHOR_X


def support_cap_delta() -> float:
    return SUPPORT_CAP_TARGET_X - SUPPORT_CAP_X
