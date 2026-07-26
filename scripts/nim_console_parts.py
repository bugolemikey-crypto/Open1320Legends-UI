"""The NIM Console class, kept as separate source files by concern.

FFDec cannot add new classes to the client SWF - `-importScript` silently drops
script paths that do not already exist, and its AS2 compiler rejects `#include`
outright ("CURLY_CLOSE expected but DIRECTIVE found"). So classes.Console has to
stay one class in the SWF no matter how the source is organised.

What we can do is stop editing it as one 2,200-line file. The source lives in
assets/polish/nim/console/ split by concern, and the build concatenates the
parts back into a single class before handing it to FFDec. Editing is per-file;
the SWF sees exactly what it saw before, at zero byte cost.

PART_ORDER is the concatenation order. Every part is a fragment, not a valid
file on its own: `_head.as` opens `class classes.Console {` and `_tail.as`
closes it. Keep each function whole inside one part.
"""
from __future__ import annotations

from pathlib import Path

from swf_utils import ROOT

CONSOLE_PARTS_DIR = ROOT / "assets" / "polish" / "nim" / "console"

PART_ORDER = (
    "_head.as",              # class declaration + static members
    "Console.as",            # window management: constructor, refreshMe, chrome
    "BuddyList.as",          # the buddy list: rows, drag, status, targeted refresh
    "BuddyRequestPanel.as",  # the REQUESTS tab: incoming/outgoing request items
    "BuddyMenu.as",          # the per-row menu popup
    "IndicatorBar.as",       # the PM indicator strip along the top of the chat
    "Conversation.as",       # chat windows: find/focus/update/new/remove
    "_tail.as",              # closing brace
)


def assemble() -> str:
    """Concatenate the parts into the single class source FFDec compiles."""
    chunks = []
    for name in PART_ORDER:
        part = CONSOLE_PARTS_DIR / name
        if not part.exists():
            raise RuntimeError(f"Missing Console part: {part}")
        text = part.read_text(encoding="utf-8", errors="surrogateescape")
        if text and not text.endswith("\n"):
            text += "\n"
        chunks.append(text)
    return "".join(chunks)


def write_assembled(dest: Path) -> Path:
    dest.write_text(assemble(), encoding="utf-8", errors="surrogateescape")
    return dest
