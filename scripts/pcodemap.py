"""Map AS2 numeric literals to exact byte offsets using FFDec's P-code hex dump.

FFDec's `script:pcodehex` export prints every action as a `; hh hh ..` comment
followed by its disassembly. Accumulating those byte counts gives each action's
offset inside the class's action block, and the block starts 2 bytes into the
DoInitAction payload (after the UI16 sprite id). That yields an exact,
checkable file offset for every pushed constant -- no pattern guessing.
"""
from __future__ import annotations

import re
import struct
from pathlib import Path

import swf_theme_lib as swfimg

HEX_LINE = re.compile(r"^; ((?:[0-9a-f]{2} ?)+)$")


def parse_pcode(path: Path):
    """-> list of (action_offset, raw_bytes, disasm_text, source_line_no)"""
    out = []
    offset = 0
    pending = None
    pending_line = 0
    for lineno, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
        m = HEX_LINE.match(line.strip())
        if m:
            if pending is not None:          # hex with no disasm following
                out.append((offset, pending, "", pending_line))
                offset += len(pending)
            pending = bytes.fromhex(m.group(1).replace(" ", ""))
            pending_line = lineno
            continue
        if pending is not None:
            out.append((offset, pending, line.strip(), pending_line))
            offset += len(pending)
            pending = None
    if pending is not None:
        out.append((offset, pending, "", pending_line))
    return out


def find_class_tag(body: bytes, tag_start: int, marker: bytes):
    for t in swfimg.parse_tags(body, tag_start):
        if t.code in (12, 59) and marker in body[t.payload_start:t.payload_end]:
            return t
    raise SystemExit(f"class tag not found for marker {marker!r}")


def pack_double(value: float) -> bytes:
    """Flash stores ActionPush doubles with the two 32-bit words swapped."""
    le = struct.pack("<d", float(value))
    return le[4:] + le[:4]


def unpack_double(raw: bytes) -> float:
    return struct.unpack("<d", raw[4:] + raw[:4])[0]


def literal_sites(swf: Path, pcode: Path, marker: bytes, wanted: set[int],
                  wanted_doubles: set[float] | None = None):
    """Locate every ActionPush int32 operand whose value is in `wanted`.

    Returns [(file_body_offset, value, pcode_line, disasm)] and asserts that the
    action block really starts where we think it does.
    """
    sig, ver, body, tag_start = swfimg.read_swf(swf)
    body = bytes(body)
    tag = find_class_tag(body, tag_start, marker)
    actions = tag.payload_start + 2          # skip UI16 sprite id

    ops = parse_pcode(pcode)
    if not ops:
        raise SystemExit("no actions parsed from pcode")
    first_off, first_raw, _, _ = ops[0]
    if body[actions:actions + len(first_raw)] != first_raw:
        raise SystemExit(
            "pcode does not line up with the SWF at the assumed action start "
            f"(expected {first_raw[:8].hex()} at {actions})"
        )

    sites = []
    for off, raw, text, lineno in ops:
        if not raw or raw[0] != 0x96:        # ActionPush
            continue
        i = 3                                 # opcode + UI16 length
        while i < len(raw):
            typ = raw[i]
            if typ == 7:
                val = struct.unpack_from("<i", raw, i + 1)[0]
                if val in wanted:
                    sites.append((actions + off + i, val, lineno, text))
                i += 5
            elif typ in (0, 1):               # string / float
                if typ == 0:
                    j = raw.index(b"\x00", i + 1)
                    i = j + 1
                else:
                    i += 5
            elif typ in (2, 3):
                i += 1
            elif typ == 4 or typ == 5 or typ == 8:
                i += 2
            elif typ == 6:
                if wanted_doubles is not None:
                    dv = unpack_double(raw[i + 1:i + 9])
                    if dv in wanted_doubles:
                        sites.append((actions + off + i, ("dbl", dv), lineno, text))
                i += 9
            elif typ == 9:
                i += 3
            else:
                break
    # cross-check: every site must actually hold the value in the file
    for off, val, lineno, text in sites:
        if isinstance(val, tuple):
            if body[off] != 6 or unpack_double(body[off + 1:off + 9]) != val[1]:
                raise SystemExit(f"offset {off} does not hold push double {val[1]}")
        else:
            got = struct.unpack_from("<i", body, off + 1)[0]
            if got != val or body[off] != 7:
                raise SystemExit(f"offset {off} does not hold push int32 {val}")
    return sites, tag
