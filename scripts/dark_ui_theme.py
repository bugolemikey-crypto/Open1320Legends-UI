"""Dark-modern theme definition for the Support / Viewer window art.

Palette matches the dark theme already authored in the working classes/ tree:
    surface  #090B0C   panel #151619   raised #202629   accent #FF3823
"""

ACCENT = (0xFF, 0x38, 0x23)

# Neutral graphite tints used to pull the old glossy blues/silvers into line.
GRAPHITE = (0x15, 0x18, 0x1C)
GRAPHITE_COOL = (0x12, 0x17, 0x1E)
GRAPHITE_WARM = (0x1C, 0x18, 0x14)

# id -> recolour kwargs (see swfimg.recolour)
#
# Two treatments. FRAME art carries the window's edges and gloss, so its
# highlights have to survive (high `hi`, gamma <= 1) or the panel stops reading
# as a panel. SURFACE art is large flat fill, so it goes deep charcoal.
FRAME = dict(lo=0.05, hi=0.46, gamma=0.92, sat=0.26, tint=GRAPHITE_COOL, tint_mix=0.28)
SURFACE = dict(lo=0.055, hi=0.25, gamma=1.02, sat=0.20, tint=GRAPHITE, tint_mix=0.32)

SUPPORT = {
    # Bright blue glossy outer window frame -> graphite frame, faint cool cast.
    172: dict(FRAME),
    # Orange glossy frame (moderator variant) -> graphite with a warm ember cast.
    # Saturation stays low or the orange reads as mud rather than as a theme.
    169: dict(FRAME, tint=GRAPHITE_WARM, sat=0.13, tint_mix=0.34),
    # Light grey content well -> charcoal. Deliberately left a step lighter than
    # the body behind it so the well still reads as a distinct surface.
    180: dict(SURFACE),
    # Navy body panel -> deepen behind the well.
    175: dict(SURFACE, lo=0.05, hi=0.20, sat=0.32),
}

VIEWER = {
    # Black/silver diagonal header -> keep the geometry, drop the silver.
    2308: dict(FRAME, lo=0.02, hi=0.38),
    # Light silver -> white content gradients (the bright area in the render).
    2311: dict(SURFACE, hi=0.28),
    2333: dict(SURFACE, hi=0.28),
    # Vertical silver-framed side panel: mostly frame, keep the bezel readable.
    2370: dict(FRAME, hi=0.42),
    # Racers / Teams pills. Their white label text and orange helmet icons are
    # baked into the bitmap, so the curve has to spare the highlights: a steep
    # gamma drops the mid-grey pill body to charcoal while `hi` near 1 leaves
    # anything already near-white alone.
    # `preserve` holds the orange helmet icons at their own brightness so the
    # steep gamma doesn't crush them into the pill body.
    2315: dict(lo=0.04, hi=0.97, gamma=2.6, sat=0.80, tint=GRAPHITE_COOL,
               tint_mix=0.22, preserve=(8, 58, 0.95)),
    2320: dict(lo=0.04, hi=0.97, gamma=2.6, sat=0.80, tint=GRAPHITE_COOL,
               tint_mix=0.22, preserve=(8, 58, 0.95)),
}

# Assets remapped onto the accent hue instead of being desaturated.
ACCENT_RAMP = {
    # Cyan rollover glow rings -> the theme's red accent.
    2317: dict(colour=ACCENT, gamma=1.15),
    2322: dict(colour=ACCENT, gamma=1.15),
}

# 2313 (the white search input bar) is deliberately left alone: its typed text
# comes from a stage-authored DefineEditText whose colour we have not verified,
# and a light field on dark chrome is a legitimate dark-theme pattern.

TARGETS = {**SUPPORT, **VIEWER}
