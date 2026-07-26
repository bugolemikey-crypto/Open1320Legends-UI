"""One-shot: cut assets/polish/nim/Console.as into per-concern parts.

Run once to produce assets/polish/nim/console/*.as. After that the parts are the
source of truth and this script is only useful for re-cutting from scratch.

The cut is proved safe rather than eyeballed: every line of the original must
appear exactly once across the parts, and the reassembled text must contain the
same multiset of lines as the original. Parts may reorder whole static functions
(AS2 hoists class members, so order is not semantic) but may never lose,
duplicate, or alter a line.
"""
from __future__ import annotations

import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from nim_console_parts import CONSOLE_PARTS_DIR, PART_ORDER, assemble
from swf_utils import ROOT

SRC = ROOT / "assets" / "polish" / "nim" / "Console.as"

# name -> inclusive 1-indexed line ranges taken from the original file.
LAYOUT: dict[str, tuple[tuple[int, int], ...]] = {
    "_head.as": ((1, 33),),
    "Console.as": ((34, 1191), (1687, 1692), (2190, 2200)),
    "BuddyList.as": ((1631, 1671), (1693, 1772), (1876, 1933)),
    "BuddyRequestPanel.as": ((1192, 1630),),
    "BuddyMenu.as": ((1773, 1875),),
    "IndicatorBar.as": ((1672, 1676), (1934, 2077)),
    "Conversation.as": ((1677, 1686), (2078, 2189)),
    "_tail.as": ((2201, 2201),),
}


def main() -> None:
    lines = SRC.read_text(encoding="utf-8", errors="surrogateescape").splitlines(keepends=True)
    total = len(lines)

    covered: Counter[int] = Counter()
    for ranges in LAYOUT.values():
        for start, end in ranges:
            for n in range(start, end + 1):
                covered[n] += 1

    missing = [n for n in range(1, total + 1) if covered[n] == 0]
    doubled = [n for n, c in covered.items() if c > 1]
    stray = [n for n in covered if n < 1 or n > total]
    if missing or doubled or stray:
        raise SystemExit(f"bad layout: missing={missing[:5]} doubled={doubled[:5]} stray={stray[:5]}")

    CONSOLE_PARTS_DIR.mkdir(parents=True, exist_ok=True)
    for name in PART_ORDER:
        chunk = "".join(
            "".join(lines[start - 1:end]) for start, end in LAYOUT[name]
        )
        if chunk and not chunk.endswith("\n"):
            chunk += "\n"
        (CONSOLE_PARTS_DIR / name).write_text(chunk, encoding="utf-8", errors="surrogateescape")
        print(f"{name:24} {chunk.count(chr(10)):>5} lines")

    original = Counter(lines)
    rebuilt = Counter(assemble().splitlines(keepends=True))
    if original != rebuilt:
        lost = original - rebuilt
        gained = rebuilt - original
        raise SystemExit(f"reassembly differs: lost={list(lost)[:3]} gained={list(gained)[:3]}")
    print(f"\nverified: {total} lines reassemble exactly (line multiset identical)")


if __name__ == "__main__":
    main()
