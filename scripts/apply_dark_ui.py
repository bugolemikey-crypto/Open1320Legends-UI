"""Apply the dark window theme to main.swf without changing its byte size.

Usage: python apply_theme.py <in.swf> <out.swf>
"""
from __future__ import annotations

import struct
import sys
from pathlib import Path

import swf_theme_lib as swfimg
import importlib
import os

# DARKUI_THEME selects the image table:
#   dark_ui_theme   -> Support Center + Viewer window art
#   dark_ui_loader  -> cache-download progress bar
theme = importlib.import_module(os.environ.get("DARKUI_THEME", "dark_ui_theme"))
from swf_theme_lib import DEFINEBITS, JPEG2, JPEG3, JPEG4, JPEGTABLES, LOSSLESS, LOSSLESS2


def main():
    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])
    sig, ver, body, tag_start = swfimg.read_swf(src)
    original_len = len(body)
    tags = swfimg.parse_tags(bytes(body), tag_start)

    jpeg_tables = b""
    by_id = {}
    for t in tags:
        if t.code == JPEGTABLES:
            jpeg_tables = bytes(body[t.payload_start:t.payload_end])
        elif t.code in (DEFINEBITS, JPEG2, JPEG3, JPEG4, LOSSLESS, LOSSLESS2):
            cid = struct.unpack_from("<H", body, t.payload_start)[0]
            by_id[cid] = t

    work = {cid: ("curve", o) for cid, o in theme.TARGETS.items()}
    work.update({cid: ("accent", o) for cid, o in theme.ACCENT_RAMP.items()})

    missing = sorted(set(work) - set(by_id))
    if missing:
        raise SystemExit(f"target ids not found as image tags: {missing}")

    def transform(im, mode, opts):
        return (swfimg.accent_ramp(im, **opts) if mode == "accent"
                else swfimg.recolour(im, **opts))

    changed = 0
    for cid, (mode, opts) in sorted(work.items()):
        t = by_id[cid]
        payload = bytes(body[t.payload_start:t.payload_end])

        if t.code == JPEG3 or t.code == JPEG4:
            _, prefix, jpeg, jpeg_field_len, alpha = swfimg.split_jpeg3(payload)
            im = swfimg.decode_jpeg(jpeg)
            out = transform(im, mode, opts)
            budget = jpeg_field_len - len(prefix)
            data, q, ss = swfimg.encode_to_budget(out, budget)
            new_payload = payload[:6] + prefix + data + alpha
            note = f"jpeg q={q} ss={ss}"
        elif t.code == DEFINEBITS:
            # Tableless JPEG sharing the global JPEGTables. Re-emitted as a
            # self-contained DefineBitsJPEG2 so we don't have to preserve the
            # shared quantisation tables; the tag length is unchanged, only the
            # tag code in the header, so the file size still holds.
            jpeg = swfimg.join_jpeg_tables(jpeg_tables, payload[2:])
            im = swfimg.decode_jpeg(jpeg)
            out = transform(im, mode, opts)
            data, q, ss = swfimg.encode_to_budget(out, len(payload) - 2)
            new_payload = payload[:2] + data
            # rewrite the tag code in place (long-form header assumed)
            hdr = struct.unpack_from("<H", body, t.start)[0]
            if hdr & 0x3F != 0x3F:
                raise SystemExit(f"id {cid}: short tag header, cannot retype")
            struct.pack_into("<H", body, t.start, (JPEG2 << 6) | 0x3F)
            note = f"DefineBits->JPEG2 q={q} ss={ss}"
        elif t.code == LOSSLESS2 or t.code == LOSSLESS:
            im, meta = swfimg.decode_lossless(payload, t.code)
            out = transform(im, mode, opts)
            budget = len(payload) - len(meta["header"])
            data = swfimg.encode_lossless(out, meta, t.code, budget)
            new_payload = meta["header"] + data
            note = "lossless"
        else:
            raise SystemExit(f"unhandled image tag code {t.code} for id {cid}")

        if len(new_payload) != len(payload):
            raise SystemExit(
                f"id {cid}: payload size drift {len(payload)} -> {len(new_payload)}"
            )
        body[t.payload_start:t.payload_end] = new_payload
        changed += 1
        print(f"  recoloured {cid:>5}  {len(payload):>8,} bytes  ({note})")

    if len(body) != original_len:
        raise SystemExit(f"body size drift {original_len} -> {len(body)}")

    swfimg.write_swf(dst, ver, bytes(body))
    print(f"\n{changed} images recoloured")
    print(f"{src.name}: {src.stat().st_size:,} -> {dst.name}: {dst.stat().st_size:,}")
    assert src.stat().st_size == dst.stat().st_size, "SWF SIZE CHANGED"
    print("size identical, signature FWS")


if __name__ == "__main__":
    main()
