"""Sanity checks for the client patch/deploy loop.

    python scripts/client_guard.py report  <NittoLegendsBeta.exe>
    python scripts/client_guard.py inspect <main.swf>
    python scripts/client_guard.py verify  <exe> --baseline <exe|swf> --expect <swf>

Two failure modes on 2026-07-27 motivated this, both of which looked like
success at the time.

**Laundered padding.** `extract_main.py` pulls the whole SWF slot, so extracting
from a *grown* executable yields a SWF with the growth padding baked in.
Deploying that grows the exe again and each round-trip compounds it. Worse, the
extract silently overwrote `patches/main_client/main.swf` -- the promoted build
-- with a padded copy of the *original* art, so later deploys produced a client
that looked patched but had the old bitmaps. `inspect` flags a SWF carrying a
large zero tail; `deploy_patches.py` refuses to embed one without --force.

**Tautological verification.** A deploy was "verified" by checking the embedded
SWF equalled `main.swf` -- while `main.swf` was itself the un-promoted original.
The check passed on a client containing none of the intended changes. `verify`
requires the embedded SWF to equal what you expect *and* to differ from the
baseline, so an accidental no-op cannot pass.

Rule of thumb: a check that cannot fail is not a check.
"""
from __future__ import annotations

import hashlib
import struct
import sys
from pathlib import Path

# A SWF built for this client carries a few KB of legitimate slack after its
# End tag. Growth padding is orders of magnitude larger.
PADDING_ALARM = 64 * 1024
BASE_CAPACITY = 29_832_751   # slot size in an un-grown projector


def md5(data: bytes) -> str:
    return hashlib.md5(data).hexdigest()


def swf_tags_end(swf: bytes) -> int:
    """Offset just past the End tag, i.e. where real content stops."""
    p = 8
    p += (5 + 4 * (swf[p] >> 3) + 7) // 8 + 4
    while p + 2 <= len(swf):
        value = struct.unpack_from("<H", swf, p)[0]
        code, length = value >> 6, value & 0x3F
        p += 2
        if length == 0x3F:
            length = struct.unpack_from("<I", swf, p)[0]
            p += 4
        p += length
        if code == 0:
            return p
    return len(swf)


def zero_tail(data: bytes) -> int:
    return len(data) - len(data.rstrip(b"\x00"))


def inspect_swf(swf: bytes) -> dict:
    end = swf_tags_end(swf)
    return {
        "size": len(swf),
        "signature": swf[:3].decode("latin-1"),
        "header_length": struct.unpack_from("<I", swf, 4)[0],
        "content_end": end,
        "slack": len(swf) - end,
        "zero_tail": zero_tail(swf),
        "md5": md5(swf),
    }


def problems_with_patch(swf: bytes) -> list[str]:
    info = inspect_swf(swf)
    out = []
    if info["signature"] != "FWS":
        out.append(f"SWF is {info['signature']}, not FWS -- CWS silently breaks avatar upload")
    if info["header_length"] != info["size"]:
        out.append(
            f"header fileLength {info['header_length']:,} != actual size {info['size']:,}")
    if info["zero_tail"] > PADDING_ALARM:
        out.append(
            f"{info['zero_tail']:,} trailing zero bytes -- this looks extracted from a grown "
            f"build. Deploying it bakes the padding in and grows the exe again. Rebuild from a "
            f"named artifact instead of an extract.")
    if info["size"] > BASE_CAPACITY and info["zero_tail"] > PADDING_ALARM:
        out.append(
            f"size {info['size']:,} exceeds the base slot ({BASE_CAPACITY:,}) purely on padding")
    return out


def find_swf(exe: bytes) -> tuple[int, int]:
    """-> (offset, declared length) of the embedded SWF."""
    hits = []
    off = exe.find(b"FWS")
    while off != -1:
        if 1 <= exe[off + 3] <= 40:
            length = struct.unpack_from("<I", exe, off + 4)[0]
            if 1_000_000 < length <= len(exe) - off:
                hits.append((off, length))
        off = exe.find(b"FWS", off + 1)
    if not hits:
        raise SystemExit("no embedded SWF found")
    return max(hits, key=lambda h: h[1])


def load_swf_from(path: Path) -> bytes:
    data = path.read_bytes()
    if data[:3] == b"FWS":
        return data
    off, length = find_swf(data)
    return data[off:off + length]


def cmd_report(path: Path) -> int:
    exe = path.read_bytes()
    off, length = find_swf(exe)
    info = inspect_swf(exe[off:off + length])
    capacity = struct.unpack_from(">I", exe, off - 4)[0]
    print(f"{path.name}")
    print(f"  exe size        {len(exe):,}")
    print(f"  SWF at          {off:,}")
    print(f"  SWF size        {info['size']:,}   md5 {info['md5'][:12]}")
    print(f"  slot capacity   {capacity:,}"
          + ("   [GROWN]" if capacity > BASE_CAPACITY else ""))
    print(f"  content ends    {info['content_end']:,}  (slack {info['slack']:,},"
          f" zero tail {info['zero_tail']:,})")
    issues = problems_with_patch(exe[off:off + length])
    for i in issues:
        print(f"  WARNING: {i}")
    return 1 if issues else 0


def cmd_inspect(path: Path) -> int:
    swf = load_swf_from(path)
    info = inspect_swf(swf)
    print(f"{path.name}")
    for key in ("size", "signature", "header_length", "content_end", "slack", "zero_tail", "md5"):
        value = info[key]
        print(f"  {key:<14} {value:,}" if isinstance(value, int) else f"  {key:<14} {value}")
    issues = problems_with_patch(swf)
    for i in issues:
        print(f"  WARNING: {i}")
    print("  OK" if not issues else "  NOT SAFE TO DEPLOY")
    return 1 if issues else 0


def cmd_verify(exe_path: Path, baseline: Path, expect: Path) -> int:
    embedded = load_swf_from(exe_path)
    want = load_swf_from(expect)
    base = load_swf_from(baseline)

    matches = embedded[:len(want)] == want
    changed = embedded[:len(base)] != base or len(embedded) != len(base)

    print(f"embedded  {len(embedded):,}  md5 {md5(embedded)[:12]}")
    print(f"expected  {len(want):,}  md5 {md5(want)[:12]}")
    print(f"baseline  {len(base):,}  md5 {md5(base)[:12]}")
    print(f"  matches expected build : {matches}")
    print(f"  differs from baseline  : {changed}   <- guards against a no-op deploy")

    if want == base:
        print("\nFAIL: expected build is identical to the baseline, so this check "
              "cannot fail. Point --expect at the build you actually intended to ship.")
        return 1
    ok = matches and changed
    print("\nVERIFIED" if ok else "\nFAIL")
    return 0 if ok else 1


def main(argv: list[str]) -> int:
    if not argv:
        print(__doc__)
        return 2
    cmd, rest = argv[0], argv[1:]
    if cmd == "report":
        return cmd_report(Path(rest[0]).resolve())
    if cmd == "inspect":
        return cmd_inspect(Path(rest[0]).resolve())
    if cmd == "verify":
        exe = Path(rest[0]).resolve()
        baseline = Path(rest[rest.index("--baseline") + 1]).resolve()
        expect = Path(rest[rest.index("--expect") + 1]).resolve()
        return cmd_verify(exe, baseline, expect)
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
