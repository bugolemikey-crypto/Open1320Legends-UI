"""Dark-theme colour-literal edits for the Email, NIM and shared window code.

Offsets are byte positions of the ActionPush operand inside the SWF body, taken
from FFDec's P-code hex dump (see pcodemap.py). They stay valid across the image
recolour pass because that pass preserves every tag length. Each edit re-asserts
the operand type and its expected old value before writing, so any drift fails
loudly rather than corrupting bytecode.
"""

# ---------------------------------------------------------------- palette
DEEP   = 0x090B0C   # window floor
BODY   = 0x14171A   # default panel body
HEADER = 0x111415   # panel header bar
RAISED = 0x202629   # fields, strips, raised surfaces
RULE   = 0x2E353D   # dividers and hairlines
TEXT   = 0xC8D0DA   # primary text on dark
TEXT2  = 0x98A2AE   # secondary text on dark
ACCENT = 0xFF3823   # selection / accent

# (offset, kind, old, new, note)
# kind: "i" = ActionPush int32, "d" = ActionPush double
DRAWING = [
    (28183212, "i", 0xFFFFFF, HEADER, "insetBox headClr fallback"),
    (28183293, "i", 0xFFFFFF, BODY,   "insetBox winClr fallback"),
    (28184884, "i", 0xFFFFFF, HEADER, "insetBoxBuddies headClr fallback"),
    (28184965, "i", 0xFFFFFF, BODY,   "insetBoxBuddies winClr fallback"),
]

CONSOLE = [
    # NIM conversation panel
    (28293028, "i", 0x7084A9, HEADER, "converse panel header"),
    (28293023, "i", 0x3D5E99, RAISED, "converse panel body top"),
    (28293018, "i", 0x0C1931, DEEP,   "converse panel body bottom"),
    (28293307, "i", 0xFFFFFF, RAISED, "converse buddy-name strip"),
    (28294488, "i", 0x5B6675, TEXT,   "txt_buddyname (was dark on white strip)"),
    (28296794, "i", 0xADBDD9, RULE,   "inbox divider rule"),
    # buddy hover info popup (three near-identical copies)
    (28300007, "i", 0xFFFFFF, RAISED, "infoClip tab"),
    (28300175, "i", 0xAEBBCF, RAISED, "infoClip body top"),
    (28300180, "i", 0xAEBBCF, BODY,   "infoClip body bottom"),
    (28301162, "i", 0x5B6675, TEXT,   "infoClip name_txt"),
    (28301639, "i", 0x425166, TEXT2,  "infoClip loc_txt (offline)"),
    (28315373, "i", 0xFFFFFF, RAISED, "request infoClip tab"),
    (28315541, "i", 0xAEBBCF, RAISED, "request infoClip body top"),
    (28315546, "i", 0xAEBBCF, BODY,   "request infoClip body bottom"),
    (28316528, "i", 0x5B6675, TEXT,   "request infoClip name_txt"),
    (28318106, "i", 0xFFFFFF, RAISED, "outgoing infoClip tab"),
    (28318274, "i", 0xAEBBCF, RAISED, "outgoing infoClip body top"),
    (28318279, "i", 0xAEBBCF, BODY,   "outgoing infoClip body bottom"),
    (28319261, "i", 0x5B6675, TEXT,   "outgoing infoClip name_txt"),
    # buddy list panel (two callsites: plain and tabbed)
    (28309350, "i", 0x7084A9, HEADER, "buddy list header"),
    (28309345, "i", 0xB3CCF0, RAISED, "buddy list body top"),
    (28309340, "i", 0x93A8C9, DEEP,   "buddy list body bottom"),
    (28310964, "i", 0x7084A9, HEADER, "buddy list header (tabbed)"),
    (28310959, "i", 0xB3CCF0, RAISED, "buddy list body top (tabbed)"),
    (28310954, "i", 0x93A8C9, DEEP,   "buddy list body bottom (tabbed)"),
]

EMAIL = [
    # Inbox rows are painted by ColorTransform.rgb, which overrides the fills
    # and text formats entirely, so these three values are the whole list.
    # ctWhite doubles as the unselected row background AND the selected row's
    # text colour, so it has to be the dark one; the selection inverts to the
    # accent with that same dark tone on top.
    (28258432, "i", 0xFFFFFF, BODY,   "ctWhite: unselected row bg / selected row text"),
    (28258479, "d", 0.0,      TEXT,   "ctBlack: unselected row text"),
    (28258530, "i", 0x7FCCFF, ACCENT, "ctHi: selected row bg"),
    # inbox panel chrome
    (28246181, "i", 0x8291A9, HEADER, "inbox insetBox header"),
    (28246342, "i", 0xA9BAD5, RAISED, "inbox tab column block"),
    (28246572, "i", 0xFFFFFF, HEADER, "inbox tab strip"),
    (28247285, "i", 0xD0D8E6, RULE,   "sort header top rule"),
    (28247474, "i", 0xA2B1CC, RAISED, "sort header band"),
    (28247681, "i", 0x9FA1A4, RULE,   "sort header bottom rule"),
    (28248018, "i", 0xFFFFFF, DEEP,   "list/view separator outer"),
    (28248203, "i", 0xADBDD9, RULE,   "list/view separator inner"),
    (28256474, "i", 0xFFFFFF, BODY,   "row hilite fill"),
    (28256726, "i", 0xADBDD9, RULE,   "row separator line"),
    (28257780, "d", 0.0,      TEXT,   "fld_from"),
    # compose view
    (28251704, "i", 0xA9BAD5, HEADER, "compose insetBox header"),
    (28251957, "i", 0xFFFFFF, RAISED, "compose To field bg"),
    (28252578, "d", 0.0,      TEXT,   "compose To text"),
    (28252671, "i", 0xFFFFFF, RAISED, "compose Subject field bg"),
    (28253319, "d", 0.0,      TEXT,   "compose Subject text"),
    (28253685, "d", 0.0,      TEXT,   "compose Message text"),
    # reading pane
    (28261151, "d", 0.0,      TEXT,   "msgArea body text"),
]

# Class tag markers, used to assert each offset lands inside the right class.
OWNERS = [
    (b"newConsoleWindow", DRAWING, "Drawing"),
    (b"buddyHeaderH",     CONSOLE, "Console"),
    (b"convertTimestamp", EMAIL,   "Email"),
]
