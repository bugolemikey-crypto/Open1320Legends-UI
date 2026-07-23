"""Rewrite AS2 colour literals in place, without recompiling the class.

Recompiling a class through FFDec costs bytes (classes.Drawing alone came out
+3,997, which overruns the projector's fixed SWF allocation). These constants
are ActionPush type-7 int32 operands, so swapping one 32-bit colour for another
is exactly byte-neutral and needs no compiler at all.

Each edit asserts the expected original value and the number of matches inside
the owning class tag, so a stale offset fails loudly instead of corrupting the
bytecode.

Usage: python patch_consts.py <in.swf> <out.swf>
"""
from __future__ import annotations

import struct
import sys
from pathlib import Path

import swf_theme_lib as swfimg

# Byte ranges of the DoInitAction tags that carry each class's bytecode,
# located by searching for names that appear only in that class's constant pool.
CLASS_MARKERS = {
    "Drawing": b"newConsoleWindow",
    "Console": b"buddyHeaderH",
}

# (class, old, new, expected occurrences, note)
EDITS = [
    # classes.Drawing.newBaseWindow — the window backdrop behind the Email
    # inbox/compose views and the Chat window. Ratios stay [0, 207, 255]; only
    # the two upper stops move, so the light silver top becomes graphite while
    # the existing black bottom stop is left untouched.
    ("Drawing", 0xA2ABB4, 0x22262A, 1, "newBaseWindow gradient stop 0"),
    ("Drawing", 0x1C2931, 0x0F0F0F, 1, "newBaseWindow gradient stop 1"),
]


def find_class_ranges(body: bytes, tag_start: int):
    ranges = {}
    for t in swfimg.parse_tags(body, tag_start):
        if t.code not in (12, 59):  # DoAction / DoInitAction
            continue
        payload = body[t.payload_start:t.payload_end]
        for name, marker in CLASS_MARKERS.items():
            if marker in payload and name not in ranges:
                ranges[name] = (t.payload_start, t.payload_end)
    missing = sorted(set(CLASS_MARKERS) - set(ranges))
    if missing:
        raise SystemExit(f"could not locate class bytecode for: {missing}")
    return ranges


def main():
    src, dst = Path(sys.argv[1]), Path(sys.argv[2])
    sig, ver, body, tag_start = swfimg.read_swf(src)
    original_len = len(body)
    ranges = find_class_ranges(bytes(body), tag_start)
    for name, (a, b) in ranges.items():
        print(f"  {name} bytecode at {a:,}..{b:,} ({b - a:,} bytes)")

    print()
    for cls, old, new, expect, note in EDITS:
        lo, hi = ranges[cls]
        pat = b"\x07" + struct.pack("<i", old)
        rep = b"\x07" + struct.pack("<i", new)
        assert len(pat) == len(rep) == 5

        segment = bytes(body[lo:hi])
        hits = []
        off = 0
        while (i := segment.find(pat, off)) >= 0:
            hits.append(i)
            off = i + 1
        if len(hits) != expect:
            raise SystemExit(
                f"{cls}: expected {expect} occurrence(s) of #{old:06X}, found {len(hits)}"
            )
        whole_file = bytes(body).count(pat)
        if whole_file != expect:
            print(f"    note: #{old:06X} also occurs {whole_file - expect}x outside {cls}"
                  f" (not touched)")
        for i in hits:
            body[lo + i:lo + i + 5] = rep
        print(f"  {cls}: #{old:06X} -> #{new:06X}  x{len(hits)}   {note}")

    if len(body) != original_len:
        raise SystemExit("body size drift")
    swfimg.write_swf(dst, ver, bytes(body))
    print(f"\n{src.name}: {src.stat().st_size:,} -> {dst.name}: {dst.stat().st_size:,}")
    assert src.stat().st_size == dst.stat().st_size, "SWF SIZE CHANGED"
    print("size identical, signature FWS")


if __name__ == "__main__":
    main()
