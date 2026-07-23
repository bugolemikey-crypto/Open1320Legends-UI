"""Dark theme for the alert / dialog chrome (`alertBox`, char 1785).

This is the box behind every buy / install / trade-in confirmation, every error
and the disconnect notice, so it is the most-seen light surface left in the
client once the Support, Viewer, Email, NIM and loader passes are done.

Why it did not show up as a colour-literal job: the chrome is reached through
*shape fill styles*, not PlaceObject children. `alertBox` resolves to 13 nested
DefineShape leaves whose fills are type 0x41 (clipped bitmap), each carrying a
bitmap character id. Walking only the sprite tree finds no art at all.

    126  Lossless2   19x24    small chrome bit
    925  Lossless    20x16    small chrome bit
    941  DefineBits  428x256  THE CHROME -- dark header + light grey body
    949..966  JPEG3  32-62px  alert ICONS (error X, gear, shop, warning, ...)

Only 941 is retheme material. The 949-966 set are the coloured status icons and
are deliberately left alone -- desaturating them would destroy the one piece of
colour that tells the player what kind of dialog they are looking at.

941 is a plain `DefineBits` sharing the global JPEGTables, the same case as
char 180 in the Support pass: apply_dark_ui.py re-emits it as a self-contained
DefineBitsJPEG2, changing only the tag *code*, so the tag length is preserved.
"""

from dark_ui_theme import GRAPHITE  # noqa: F401

# The body is a large, near-flat light-grey gradient with a dark header band
# above it. A monotonic curve keeps that relationship: the header is already
# near-black and stays there, while the grey body drops to charcoal.
#
# `hi` is held a little above the Support well (0.25) so the dialog still reads
# as a raised surface sitting on top of whatever screen is behind it, rather
# than merging into the page. Saturation is pulled down because the original
# grey carries a faint blue cast that reads as washed-out once darkened.
TARGETS = {
    941: dict(lo=0.045, hi=0.27, gamma=1.0, sat=0.18,
              tint=GRAPHITE, tint_mix=0.30),
}

ACCENT_RAMP = {}
