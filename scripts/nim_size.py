"""Shrink the NIM console a touch.

classes.Console.defaultWidth / defaultHeight are plain int32 pushes in the
class's static initialiser, so this is byte-neutral. The compact NIM rewrite
set them to 420x560; the original shipped client was 250x461, so there is
plenty of headroom below 420 before any child art starts to clip.

Offsets verified against a P-code dump of the current shipping SWF.
"""

EDITS = [
    (28332647, "i", 420, 370, "Console.defaultWidth"),
    (28332666, "i", 560, 500, "Console.defaultHeight"),
]

OWNERS = [
    (b"buddyHeaderH", EDITS, "Console"),
]
