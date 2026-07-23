"""Apply dark_ui_consts.py edits to a SWF, byte-for-byte in place.

Usage: python apply_consts.py <in.swf> <out.swf>
"""
from __future__ import annotations

import struct
import sys
from pathlib import Path

import importlib
import os

# DARKUI_CONSTS selects which edit table to apply:
#   dark_ui_consts      -> the stock baseline SWF
#   dark_ui_consts_nim  -> the compact-NIM (FWS) base
cfg = importlib.import_module(os.environ.get("DARKUI_CONSTS", "dark_ui_consts"))
import pcodemap
import swf_theme_lib as swfimg


def main():
    src, dst = Path(sys.argv[1]), Path(sys.argv[2])
    sig, ver, body, tag_start = swfimg.read_swf(src)
    original_len = len(body)
    snapshot = bytes(body)

    total = 0
    for marker, edits, name in cfg.OWNERS:
        tag = pcodemap.find_class_tag(snapshot, tag_start, marker)
        print(f"\n{name}  bytecode {tag.payload_start:,}..{tag.payload_end:,}")
        for off, kind, old, new, note in edits:
            if not (tag.payload_start <= off < tag.payload_end):
                raise SystemExit(f"{name}: offset {off:,} is outside the class tag")
            if kind == "i":
                if body[off] != 7:
                    raise SystemExit(f"{off:,}: not an int32 push (type {body[off]})")
                got = struct.unpack_from("<i", body, off + 1)[0]
                if got != old:
                    raise SystemExit(f"{off:,}: expected #{old:06X}, found #{got:06X}")
                struct.pack_into("<i", body, off + 1, new)
                shown = f"#{old:06X} -> #{new:06X}"
            elif kind == "d":
                if body[off] != 6:
                    raise SystemExit(f"{off:,}: not a double push (type {body[off]})")
                got = pcodemap.unpack_double(bytes(body[off + 1:off + 9]))
                if got != old:
                    raise SystemExit(f"{off:,}: expected {old}, found {got}")
                body[off + 1:off + 9] = pcodemap.pack_double(float(new))
                shown = f"{old:g} -> #{new:06X}"
            else:
                raise SystemExit(f"unknown edit kind {kind!r}")
            total += 1
            print(f"   {off:>12,}  {shown:<22} {note}")

    if len(body) != original_len:
        raise SystemExit("body size drift")
    swfimg.write_swf(dst, ver, bytes(body))
    changed = sum(1 for a, b in zip(snapshot, bytes(body)) if a != b)
    print(f"\n{total} literals patched, {changed} bytes differ")
    print(f"{src.name}: {src.stat().st_size:,} -> {dst.name}: {dst.stat().st_size:,}")
    assert src.stat().st_size == dst.stat().st_size, "SWF SIZE CHANGED"
    print("size identical, signature FWS")


if __name__ == "__main__":
    main()
