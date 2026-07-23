"""NIM buddy-list sizing: shrink the oversized avatar thumbnails.

The buddy rows read as heavy because the avatar is drawn at 58% of a portrait
that is already large, so each thumbnail comes out ~52px in a list only a few
rows tall. The reference design wants a noticeably smaller thumbnail and a
tighter row.

Only the avatar scale needs to move. `drawBuddyList.reorderBuddyList` lays rows
out with

    _loc4_ = _loc2_ * listItem._height

i.e. the row pitch is *measured from the item's content*, not a constant, so
shrinking the thumbnail pulls the whole list tighter on its own.

Deliberately NOT touched:
  * `buddyHeaderH` (52) -- that is the header strip above the list, feeding
    `insetBoxBuddies` and the scroller `_y`/mask height. Changing it slides the
    whole list, which is not the complaint.
  * the other four `52` pushes in Console -- unrelated `lineTo`/draw coordinates.

Both operands are ActionPush type-7 int32, so 58 -> 44 is exactly byte-neutral.
Offsets are from the P-code dump of the deployed build (dialog+loader theme).
"""

AVATAR = 44   # buddy list was 58, request lists were 50

CONSOLE = [
    (28299757, "i", 58, AVATAR, "buddy list avatar _xscale"),
    (28299777, "i", 58, AVATAR, "buddy list avatar _yscale"),
    # Requests tab. These were already a step smaller (50) than the buddy list,
    # so leaving them would make the two tabs disagree once the buddy rows shrink.
    (28316733, "i", 50, AVATAR, "incoming request avatar _xscale"),
    (28316753, "i", 50, AVATAR, "incoming request avatar _yscale"),
    (28319876, "i", 50, AVATAR, "outgoing request avatar _xscale"),
    (28319896, "i", 50, AVATAR, "outgoing request avatar _yscale"),
]

# The other `50` pushes in Console are `_alpha` fades and `_x`/`_y` offsets, and
# the four other `52` pushes are lineTo/draw coordinates -- all left alone.

# Class tag markers, used to assert each offset lands inside the right class.
OWNERS = [
    (b"buddyHeaderH", CONSOLE, "Console"),
]
