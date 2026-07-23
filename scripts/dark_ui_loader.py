"""Dark theme for the cache-download screen (classes.Frame.assetLoader).

The loader lives in sprite 1981 inside sprite 2002 (the login sprite), driven
from Lingo via loadUpdateCB/loadFinishCB:

    1967  JPEG3       426x22  progress TRACK  -- near-white #FBFBFB, the one
                                                 bright element on the screen
    1969  Lossless    1x20    progress FILL   -- already red #FF4043
    1972  Lossless2   9x20    leading shade   -- black w/ alpha ramp, fine
    1975  Lossless2   426x22  bar frame       -- transparent w/ #0D0D0D edge
    1978/1979/1980    DefineEditText          -- already white on dark

So the retheme is two images: drop the track to a dark well, and nudge the fill
from #FF4043 onto the theme accent #FF3823 so it matches the rollover glows.
"""

from dark_ui_theme import ACCENT, GRAPHITE  # noqa: F401

# Progress track: flat near-white -> dark recessed well. Low `hi` keeps it well
# below the fill so the red reads as progress; the existing dark left edge
# stays dark because the curve is monotonic.
TARGETS = {
    1967: dict(lo=0.03, hi=0.15, gamma=1.0, sat=0.15,
               tint=GRAPHITE, tint_mix=0.30),
}

# Fill remapped onto the accent hue, preserving its own shading.
ACCENT_RAMP = {
    1969: dict(colour=ACCENT, gamma=1.0),
}
