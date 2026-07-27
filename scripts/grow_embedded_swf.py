"""Embed a main.swf of *any* size into the Director projector.

Usage:
    python scripts/grow_embedded_swf.py <NittoLegendsBeta.exe> <new.swf> [-o out.exe]
    python scripts/grow_embedded_swf.py <exe> --report        # just show the layout

Why this exists
---------------
Everything else in this repo is built to a fixed byte budget because the
embedded SWF was assumed to live in an immovable slot. It does not. It lives in
a chunk, and the chunk has a declared length -- several of them, nested:

    outer RIFX (XFIR/APPL)            the projector container
      └─ mmap entry 25  eliF          a nested Director movie
           └─ inner RIFX (XFIR/MV93)
                └─ mmap entry N  XMED   the Flash Xtra's media -> main.swf

Each of those is the **last** chunk inside its parent, so growing the SWF needs
no chunk relocation at all -- nothing follows it to shift. Only the declared
lengths have to move, and there are seven of them (each chunk carries its
length twice: once in its own header, once in its parent's memory map).

That is why the naive attempt failed. `deploy_patches.py` has a branch that
appends a larger SWF before the executable's 4-byte trailer, but it leaves
every one of those length fields stale; Director then reads a chunk whose
declared size no longer matches its contents and dies at startup with
"Director Player Error: Script Error".

With the lengths maintained, the byte budget goes away: `main.swf` no longer
has to be padded back to 29,832,751, tags may change size, and recompiled
symbols become viable.

Still true regardless of size: the SWF must stay **uncompressed FWS**. CWS boots
fine and silently breaks FileReference.upload (avatar upload).
"""
from __future__ import annotations

import shutil
import struct
import sys
from pathlib import Path

TRAILER = 4  # bytes of projector trailer after the outer container


def u32(data: bytes, off: int) -> int:
    return struct.unpack_from("<I", data, off)[0]


def parse_mmap(data: bytes, off: int):
    """-> (entries, entry_base) where each entry is (index, tag, length, offset, entry_off)."""
    if data[off:off + 4] != b"pamm":
        raise RuntimeError(f"no mmap at {off} (found {data[off:off + 4]!r})")
    hdr, entry_size, _cmax, used = struct.unpack_from("<HHII", data, off + 8)
    base = off + 8 + hdr
    out = []
    for i in range(used):
        e = base + i * entry_size
        out.append((i, data[e:e + 4], u32(data, e + 4), u32(data, e + 8), e))
    return out, base


def locate(data: bytes):
    """Find every length field guarding the embedded SWF."""
    outer = data.find(b"XFIR", 0x20000)
    while outer != -1 and data[outer + 8:outer + 12] != b"LPPA":
        outer = data.find(b"XFIR", outer + 1)
    if outer == -1:
        raise RuntimeError("outer RIFX (XFIR/APPL) container not found")

    outer_imap = outer + 12
    outer_mmap = u32(data, outer_imap + 12)
    outer_entries, _ = parse_mmap(data, outer_mmap)

    # the nested movie is the last eliF chunk
    nest = max((e for e in outer_entries if e[1] == b"eliF"), key=lambda e: e[3])
    outer_self = next(e for e in outer_entries if e[1] == b"XFIR")

    inner = nest[3]
    if data[inner:inner + 4] != b"XFIR":
        raise RuntimeError(f"nested chunk at {inner} is not XFIR")
    inner_mmap = u32(data, inner + 12 + 12)
    inner_entries, _ = parse_mmap(data, inner_mmap)
    xmed = max((e for e in inner_entries if e[1] == b"DEMX"), key=lambda e: e[3])
    inner_self = next(e for e in inner_entries if e[1] == b"XFIR")

    swf = data.find(b"FWS", xmed[3])
    if swf == -1 or swf - xmed[3] > 64:
        raise RuntimeError("no FWS signature near the XMED chunk")
    preamble = swf - (xmed[3] + 8)      # XMED data bytes before the SWF

    # The XMED media itself opens with three BIG-endian u32s -- total length,
    # a count, then the SWF payload length. These are easy to miss: everything
    # else in a little-endian Director file is LE, and getting the seven LE
    # fields right without these two makes the projector start, load, and then
    # quietly never reach the login screen (no error, just nothing).
    media = xmed[3] + 8
    return {
        "outer_header": outer + 4,          # RIFX length
        "outer_self_entry": outer_self[4] + 4,
        "nest_entry": nest[4] + 4,
        "inner_header": inner + 4,
        "inner_self_entry": inner_self[4] + 4,
        "xmed_header": xmed[3] + 4,
        "xmed_entry": xmed[4] + 4,
        "media_total_be": media,            # big-endian
        "media_payload_be": media + 8,      # big-endian
        "swf_offset": swf,
        "swf_capacity": xmed[2] - preamble,
        "xmed_len": xmed[2],
        "inner_len": inner_self[2],
        "outer_len": outer_self[2],
        "preamble": preamble,
    }


LE_FIELDS = ("xmed_header", "xmed_entry", "inner_header", "inner_self_entry",
             "nest_entry", "outer_self_entry", "outer_header")
BE_FIELDS = ("media_total_be", "media_payload_be")


def report(data: bytes) -> None:
    m = locate(data)
    print(f"file size            {len(data):,}")
    print(f"SWF at               {m['swf_offset']:,}")
    print(f"SWF capacity         {m['swf_capacity']:,}  (XMED {m['xmed_len']:,} - {m['preamble']} preamble)")
    print("length fields (little-endian):")
    for key in LE_FIELDS:
        print(f"  {key:<18} @{m[key]:<10} = {u32(data, m[key]):,}")
    print("length fields (BIG-endian, inside the XMED media header):")
    for key in BE_FIELDS:
        print(f"  {key:<18} @{m[key]:<10} = {struct.unpack_from('>I', data, m[key])[0]:,}")


def grow(exe: Path, swf_path: Path, out: Path) -> None:
    data = bytearray(exe.read_bytes())
    m = locate(bytes(data))
    swf = swf_path.read_bytes()

    if swf[:3] != b"FWS":
        raise RuntimeError(f"{swf_path.name} is {swf[:3].decode()}; must be uncompressed FWS")
    if u32(swf, 4) != len(swf):
        raise RuntimeError("SWF header fileLength does not match its real size")

    delta = len(swf) - m["swf_capacity"]
    print(f"current capacity {m['swf_capacity']:,} -> new SWF {len(swf):,}  (delta {delta:+,})")

    tail_start = m["swf_offset"] + m["swf_capacity"]
    tail = bytes(data[tail_start:])           # trailing slack + projector trailer
    rebuilt = bytearray(data[:m["swf_offset"]]) + swf + tail

    # every guarding length moves by the same delta
    for key in LE_FIELDS:
        off = m[key]
        struct.pack_into("<I", rebuilt, off, u32(bytes(data), off) + delta)
    for key in BE_FIELDS:
        off = m[key]
        struct.pack_into(">I", rebuilt, off,
                         struct.unpack_from(">I", bytes(data), off)[0] + delta)

    out.write_bytes(bytes(rebuilt))

    # re-parse the result and prove it is self-consistent
    check = locate(bytes(rebuilt))
    print(f"wrote {out}  ({len(rebuilt):,} bytes, was {len(data):,})")
    print(f"new capacity         {check['swf_capacity']:,}")
    ok = (
        bytes(rebuilt[check["swf_offset"]:check["swf_offset"] + len(swf)]) == swf
        and check["swf_capacity"] >= len(swf)
        and len(rebuilt) == len(data) + delta
        and bytes(rebuilt[-TRAILER:]) == bytes(data[-TRAILER:])
    )
    print("re-parsed and self-consistent:", ok)
    if not ok:
        raise RuntimeError("post-write validation failed")


def main(argv: list[str]) -> None:
    if not argv:
        raise SystemExit(__doc__)
    exe = Path(argv[0]).resolve()
    if "--report" in argv:
        report(exe.read_bytes())
        return
    swf = Path(argv[1]).resolve()
    out = Path(argv[argv.index("-o") + 1]).resolve() if "-o" in argv else exe
    if out == exe:
        backup = exe.with_suffix(exe.suffix + ".pre-grow")
        if not backup.exists():
            shutil.copy2(exe, backup)
            print(f"backup {backup}")
    grow(exe, swf, out)


if __name__ == "__main__":
    main(sys.argv[1:])
