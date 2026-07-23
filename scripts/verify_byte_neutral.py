"""Prove a themed SWF differs from its baseline in visual tags only.

Usage: python verify_byte_neutral.py <baseline.swf> <candidate.swf>

Exits non-zero on the first violation. The rules encode what actually broke
avatar upload before: a build is only safe if the *code* the Flash player runs
is untouched, and the SWF still fits its fixed allocation as FWS.

  1. total file size identical
  2. signature still FWS (never CWS -- compression breaks FileReference.upload)
  3. tag count identical (no tag added or removed)
  4. every tag length identical
  5. tag codes identical, except the documented DefineBits -> DefineBitsJPEG2
     re-emit, which changes the code but preserves the length
  6. code-bearing tags (DoAction / DoInitAction / DoABC) may differ ONLY in the
     operand bytes of ActionPush int32 (type 7) and double (type 6) literals.
     Any other byte difference is a recompile and is rejected.

Rule 6 is the load-bearing one. A colour swap rewrites a literal operand in
place; a recompile moves opcodes. Comparing the two bodies with every push
operand masked out makes the difference decidable without a decompiler.
"""
from __future__ import annotations

import hashlib
import struct
import sys
from pathlib import Path

DEFINEBITS, JPEG2 = 6, 21
DOACTION, DOINITACTION, DOABC = 12, 59, 82
CODE_TAGS = (DOACTION, DOINITACTION, DOABC)

ACTION_PUSH = 0x96
PUSH_INT32, PUSH_DOUBLE = 7, 6

# Push operand payload sizes by type code; None = variable/unsupported, which
# forces the scanner to give up and fall back to an exact comparison.
PUSH_SIZES = {0: None, 1: 4, 2: 0, 3: 0, 4: 1, 5: 1, 6: 8, 7: 4, 8: 1, 9: 2}


class Tag:
    __slots__ = ("code", "length", "payload", "index")

    def __init__(self, code, length, payload, index):
        self.code, self.length, self.payload, self.index = code, length, payload, index


def parse(path: Path):
    data = path.read_bytes()
    sig = data[:3].decode("latin-1")
    version = data[3]
    declared = struct.unpack_from("<I", data, 4)[0]

    i = 8
    nbits = data[i] >> 3
    i += (5 + 4 * nbits + 7) // 8   # RECT
    i += 4                          # frame rate + frame count

    tags = []
    while i < declared - 1:
        header = struct.unpack_from("<H", data, i)[0]
        i += 2
        code, length = header >> 6, header & 0x3F
        if length == 0x3F:
            length = struct.unpack_from("<I", data, i)[0]
            i += 4
        tags.append(Tag(code, length, data[i:i + length], len(tags)))
        i += length
        if code == 0:
            break
    return sig, version, declared, len(data), tags


def mask_push_operands(body: bytes, code: int):
    """Return `body` with int32/double push operands zeroed.

    Returns None if the action stream cannot be walked cleanly, which makes the
    caller reject the tag rather than certify something it could not read.
    """
    if code == DOABC:
        return None  # AVM2, not an AS2 action stream -- never certify a diff
    out = bytearray(body)
    # DoInitAction opens with a UI16 sprite id; DoAction starts at the opcodes.
    i = 2 if code == DOINITACTION else 0
    if len(body) < i:
        return None
    n = len(body)
    while i < n:
        opcode = body[i]
        if opcode == 0:
            i += 1
            continue
        if opcode < 0x80:
            i += 1
            continue
        if i + 3 > n:
            return None
        length = struct.unpack_from("<H", body, i + 1)[0]
        start, end = i + 3, i + 3 + length
        if end > n:
            return None
        if opcode == ACTION_PUSH:
            j = start
            while j < end:
                ptype = body[j]
                size = PUSH_SIZES.get(ptype, None)
                if ptype == 0:  # string, NUL-terminated
                    k = body.find(b"\x00", j + 1, end)
                    if k < 0:
                        return None
                    j = k + 1
                    continue
                if size is None:
                    return None
                if ptype in (PUSH_INT32, PUSH_DOUBLE):
                    out[j + 1:j + 1 + size] = b"\x00" * size
                j += 1 + size
        i = end
    return bytes(out)


def fail(msg):
    print(f"REJECTED: {msg}")
    sys.exit(1)


def main():
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    base_p, cand_p = Path(sys.argv[1]), Path(sys.argv[2])
    b_sig, b_ver, b_decl, b_size, B = parse(base_p)
    c_sig, c_ver, c_decl, c_size, C = parse(cand_p)

    print(f"baseline  {base_p.name}  {b_size:,} bytes  {b_sig}  {len(B):,} tags")
    print(f"candidate {cand_p.name}  {c_size:,} bytes  {c_sig}  {len(C):,} tags")
    print()

    if c_sig != "FWS":
        fail(f"signature is {c_sig}, must be FWS -- CWS breaks FileReference.upload()")
    if c_size != b_size:
        fail(f"file size changed {b_size:,} -> {c_size:,}")
    if len(C) != len(B):
        fail(f"tag count changed {len(B):,} -> {len(C):,}")

    retyped = code_literal = image = 0
    for b, c in zip(B, C):
        if b.length != c.length:
            fail(f"tag #{b.index} (code {b.code}) length changed "
                 f"{b.length:,} -> {c.length:,}")
        if b.code != c.code:
            if (b.code, c.code) == (DEFINEBITS, JPEG2):
                retyped += 1
            else:
                fail(f"tag #{b.index} code changed {b.code} -> {c.code} "
                     f"(only DefineBits->DefineBitsJPEG2 is allowed)")
        if b.payload == c.payload:
            continue

        if b.code in CODE_TAGS:
            mb = mask_push_operands(b.payload, b.code)
            mc = mask_push_operands(c.payload, c.code)
            if mb is None or mc is None:
                fail(f"tag #{b.index} (code {b.code}) could not be walked as an "
                     f"action stream; refusing to certify it")
            if mb != mc:
                fail(f"tag #{b.index} (code {b.code}) differs outside push "
                     f"literals -- this is a RECOMPILE, not a colour patch")
            code_literal += 1
        else:
            image += 1

    print(f"ACCEPTED")
    print(f"  {image} visual tag(s) changed")
    print(f"  {code_literal} code tag(s) changed in push literals only")
    print(f"  {retyped} DefineBits -> DefineBitsJPEG2 re-emit(s)")
    print(f"  all {len(B):,} tag lengths preserved, size {c_size:,}, {c_sig}")
    print(f"  sha256 {hashlib.sha256(cand_p.read_bytes()).hexdigest()[:32]}")


if __name__ == "__main__":
    main()
