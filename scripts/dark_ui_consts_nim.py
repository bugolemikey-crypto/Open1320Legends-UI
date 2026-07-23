"""Dark-theme literal edits for the compact-NIM (FWS) base.

Same theme as dark_ui_consts.py, retargeted at
main.nim-compact-fws-candidate.swf. That build already carries the dark
NIM redesign, so the Console edits here cover only what the compact
rewrite left behind: the two buddy-request info popups, still a white tab
over a light gradient with dark text.

Drawing/Email offsets are the baseline ones shifted by +3649, verified
against a fresh P-code dump of this base.
"""

from dark_ui_consts import DEEP, BODY, HEADER, RAISED, RULE, TEXT, TEXT2, ACCENT  # noqa: F401


DRAWING = [
    (28186861, "i", 0xFFFFFF, HEADER, "insetBox headClr fallback"),
    (28186942, "i", 0xFFFFFF, BODY, "insetBox winClr fallback"),
    (28188533, "i", 0xFFFFFF, HEADER, "insetBoxBuddies headClr fallback"),
    (28188614, "i", 0xFFFFFF, BODY, "insetBoxBuddies winClr fallback"),
]

EMAIL = [
    (28262081, "i", 0xFFFFFF, BODY, "ctWhite: unselected row bg / selected row text"),
    (28262128, "d", 0.0, TEXT, "ctBlack: unselected row text"),
    (28262179, "i", 0x7FCCFF, ACCENT, "ctHi: selected row bg"),
    (28249830, "i", 0x8291A9, HEADER, "inbox insetBox header"),
    (28249991, "i", 0xA9BAD5, RAISED, "inbox tab column block"),
    (28250221, "i", 0xFFFFFF, HEADER, "inbox tab strip"),
    (28250934, "i", 0xD0D8E6, RULE, "sort header top rule"),
    (28251123, "i", 0xA2B1CC, RAISED, "sort header band"),
    (28251330, "i", 0x9FA1A4, RULE, "sort header bottom rule"),
    (28251667, "i", 0xFFFFFF, DEEP, "list/view separator outer"),
    (28251852, "i", 0xADBDD9, RULE, "list/view separator inner"),
    (28260123, "i", 0xFFFFFF, BODY, "row hilite fill"),
    (28260375, "i", 0xADBDD9, RULE, "row separator line"),
    (28261429, "d", 0.0, TEXT, "fld_from"),
    (28255353, "i", 0xA9BAD5, HEADER, "compose insetBox header"),
    (28255606, "i", 0xFFFFFF, RAISED, "compose To field bg"),
    (28256227, "d", 0.0, TEXT, "compose To text"),
    (28256320, "i", 0xFFFFFF, RAISED, "compose Subject field bg"),
    (28256968, "d", 0.0, TEXT, "compose Subject text"),
    (28257334, "d", 0.0, TEXT, "compose Message text"),
    (28264800, "d", 0.0, TEXT, "msgArea body text"),
]

CONSOLE = [
    (28320597, "i", 0xFFFFFF, RAISED, "incoming-request infoClip tab"),
    (28320799, "i", 0xAEBBCF, RAISED, "incoming-request infoClip body top"),
    (28320807, "i", 0xAEBBCF, BODY, "incoming-request infoClip body bottom"),
    (28321912, "i", 0x5B6675, TEXT, "incoming-request name_txt"),
    (28323660, "i", 0xFFFFFF, RAISED, "outgoing-request infoClip tab"),
    (28323862, "i", 0xAEBBCF, RAISED, "outgoing-request infoClip body top"),
    (28323870, "i", 0xAEBBCF, BODY, "outgoing-request infoClip body bottom"),
    (28324975, "i", 0x5B6675, TEXT, "outgoing-request name_txt"),
]

# The alpha-0 hit-area fills at 28,319,850 and 28,323,107 are deliberately not
# listed: they are beginFill(0xFFFFFF, 0) invisible click targets, not surfaces.

OWNERS = [
    (b"newConsoleWindow", DRAWING, "Drawing"),
    (b"buddyHeaderH",     CONSOLE, "Console"),
    (b"convertTimestamp", EMAIL,   "Email"),
]
