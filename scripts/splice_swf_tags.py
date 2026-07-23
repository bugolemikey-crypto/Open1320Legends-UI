"""Transplant selected top-level character tags between SWFs.

This keeps all untouched tags byte-for-byte identical, avoiding the size growth
caused by a complete FFDec XML round-trip. Supports uncompressed FWS and zlib
CWS files. ZWS/LZMA is intentionally rejected.
"""
from __future__ import annotations

import argparse
import struct
import zlib
from dataclasses import dataclass
from pathlib import Path


@dataclass
class Swf:
    signature: bytes
    version: int
    body: bytes
    tag_offset: int


def rect_byte_length(first_byte: int) -> int:
    nbits = first_byte >> 3
    return (5 + 4 * nbits + 7) // 8


def read_swf(path: Path) -> Swf:
    data = path.read_bytes()
    signature = data[:3]
    if signature == b"FWS":
        body = data[8:]
    elif signature == b"CWS":
        body = zlib.decompress(data[8:])
    else:
        raise RuntimeError(f"Unsupported SWF compression {signature!r}: {path}")
    rect_len = rect_byte_length(body[0])
    return Swf(signature, data[3], body, rect_len + 4)


def write_swf(swf: Swf, path: Path, body: bytes, force_fws: bool = True) -> None:
    signature = b"FWS" if force_fws else swf.signature
    total_length = len(body) + 8
    header = signature + bytes([swf.version]) + struct.pack("<I", total_length)
    payload = body if signature == b"FWS" else zlib.compress(body, 9)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(header + payload)


def parse_records(body: bytes, start: int) -> list[tuple[int, int, int, bytes]]:
    records = []
    offset = start
    while offset + 2 <= len(body):
        record_start = offset
        value = struct.unpack_from("<H", body, offset)[0]
        offset += 2
        code = value >> 6
        length = value & 0x3F
        if length == 0x3F:
            if offset + 4 > len(body):
                raise RuntimeError("Truncated long SWF tag header")
            length = struct.unpack_from("<I", body, offset)[0]
            offset += 4
        payload_start = offset
        record_end = payload_start + length
        if record_end > len(body):
            raise RuntimeError(f"Truncated SWF tag code {code}")
        records.append((code, record_start, record_end, body[payload_start:record_end]))
        offset = record_end
        if code == 0:
            break
    return records


def character_id(code: int, payload: bytes) -> int | None:
    # Character definitions used by this project begin with UI16 character ID.
    if code in {2, 6, 11, 20, 21, 22, 32, 33, 34, 35, 36, 37, 39, 46, 48, 75, 83, 84, 87, 90, 91} and len(payload) >= 2:
        return struct.unpack_from("<H", payload, 0)[0]
    return None


def record_map(swf: Swf) -> dict[int, bytes]:
    result = {}
    for code, start, end, payload in parse_records(swf.body, swf.tag_offset):
        cid = character_id(code, payload)
        if cid is not None:
            result[cid] = swf.body[start:end]
    return result


def splice(source: Path, donor: Path, output: Path, ids: set[int]) -> None:
    src = read_swf(source)
    replacement = record_map(read_swf(donor))
    missing = sorted(ids - replacement.keys())
    if missing:
        raise RuntimeError(f"Donor is missing character tags: {missing}")

    chunks = [src.body[:src.tag_offset]]
    replaced = set()
    cursor = src.tag_offset
    for code, start, end, payload in parse_records(src.body, src.tag_offset):
        if start > cursor:
            chunks.append(src.body[cursor:start])
        cid = character_id(code, payload)
        if cid in ids:
            chunks.append(replacement[cid])
            replaced.add(cid)
        else:
            chunks.append(src.body[start:end])
        cursor = end
    chunks.append(src.body[cursor:])

    missing = sorted(ids - replaced)
    if missing:
        raise RuntimeError(f"Source is missing character tags: {missing}")
    new_body = b"".join(chunks)
    write_swf(src, output, new_body, force_fws=True)
    print(f"Spliced {sorted(replaced)}: {source.stat().st_size:,} -> {output.stat().st_size:,} bytes")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("donor", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("character_ids", nargs="+", type=int)
    args = parser.parse_args()
    splice(args.source, args.donor, args.output, set(args.character_ids))


if __name__ == "__main__":
    main()
