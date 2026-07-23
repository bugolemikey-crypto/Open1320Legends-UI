"""Byte-exact bitmap recolouring inside a SWF.

Every replaced image tag keeps its original tag length: the re-encoded JPEG is
produced at a quality that fits inside the original payload and then padded
after the EOI marker (decoders ignore trailing bytes). Lossless tags are
re-deflated and zero-padded the same way. The output SWF is therefore the exact
same size as the input, which is what the Director projector requires.
"""
from __future__ import annotations

import io
import struct
import zlib
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image

DEFINEBITS = 6
JPEGTABLES = 8
JPEG3 = 35
JPEG4 = 90
JPEG2 = 21
LOSSLESS = 20
LOSSLESS2 = 36


def join_jpeg_tables(tables: bytes, data: bytes) -> bytes:
    """DefineBits carries a tableless JPEG; splice the shared JPEGTables in."""
    if tables.endswith(b"\xff\xd9"):
        tables = tables[:-2]
    if data.startswith(b"\xff\xd8"):
        data = data[2:]
    return tables + data


@dataclass
class Tag:
    code: int
    start: int          # offset of the tag header inside body
    payload_start: int
    payload_end: int


def read_swf(path: Path):
    data = path.read_bytes()
    sig = data[:3]
    if sig == b"FWS":
        body = bytearray(data[8:])
    elif sig == b"CWS":
        body = bytearray(zlib.decompress(data[8:]))
    else:
        raise RuntimeError(f"unsupported signature {sig!r}")
    nbits = body[0] >> 3
    rect_len = (5 + 4 * nbits + 7) // 8
    return sig, data[3], body, rect_len + 4


def write_swf(path: Path, version: int, body: bytes):
    header = b"FWS" + bytes([version]) + struct.pack("<I", len(body) + 8)
    path.write_bytes(header + body)


def parse_tags(body, start, end=None):
    end = len(body) if end is None else end
    off = start
    out = []
    while off + 2 <= end:
        hstart = off
        value = struct.unpack_from("<H", body, off)[0]
        off += 2
        code = value >> 6
        length = value & 0x3F
        if length == 0x3F:
            length = struct.unpack_from("<I", body, off)[0]
            off += 4
        pstart = off
        pend = pstart + length
        if pend > end:
            break
        out.append(Tag(code, hstart, pstart, pend))
        off = pend
        if code == 0:
            break
    return out


# ---------------------------------------------------------------- image codec

JPEG_QUIRK = b"\xff\xd9\xff\xd8"


def split_jpeg3(payload: bytes):
    """-> (charId, prefix, jpeg_bytes, jpeg_field_len, alpha_bytes)"""
    cid = struct.unpack_from("<H", payload, 0)[0]
    alpha_off = struct.unpack_from("<I", payload, 2)[0]
    jpeg_field = payload[6:6 + alpha_off]
    alpha = payload[6 + alpha_off:]
    prefix = b""
    if jpeg_field.startswith(JPEG_QUIRK):
        prefix = JPEG_QUIRK
        jpeg_field = jpeg_field[4:]
    return cid, prefix, jpeg_field, alpha_off, alpha


def decode_jpeg(jpeg: bytes) -> Image.Image:
    return Image.open(io.BytesIO(jpeg)).convert("RGB")


def encode_to_budget(im: Image.Image, budget: int) -> bytes:
    """Encode im as JPEG in <= budget bytes; returns padded-to-budget data."""
    for quality in (95, 92, 90, 87, 84, 80, 76, 72, 68, 64, 60, 55, 50, 45, 40, 35, 30):
        for subsampling in (0, 1, 2):
            buf = io.BytesIO()
            im.save(buf, "JPEG", quality=quality, subsampling=subsampling,
                    optimize=True, progressive=False)
            raw = buf.getvalue()
            if len(raw) <= budget:
                return raw + b"\x00" * (budget - len(raw)), quality, subsampling
    raise RuntimeError(f"cannot fit image into {budget} bytes")


def split_lossless(payload: bytes, code: int):
    cid, fmt, w, h = struct.unpack_from("<HBHH", payload, 0)
    off = 7
    table = 0
    if fmt == 3:
        table = payload[off] + 1
        off += 1
    return cid, fmt, w, h, table, off, payload[off:]


def decode_lossless(payload: bytes, code: int) -> tuple[Image.Image, dict]:
    cid, fmt, w, h, table, off, data = split_lossless(payload, code)
    raw = zlib.decompress(data)
    meta = dict(cid=cid, fmt=fmt, w=w, h=h, table=table, header=payload[:off])
    if fmt == 5:  # 32-bit ARGB (lossless2) / XRGB (lossless)
        arr = np.frombuffer(raw, dtype=np.uint8)[: w * h * 4].reshape(h, w, 4)
        if code == LOSSLESS2:
            im = Image.fromarray(arr[:, :, [1, 2, 3, 0]], "RGBA")
        else:
            im = Image.fromarray(arr[:, :, [1, 2, 3]], "RGB")
        return im, meta
    raise NotImplementedError(f"lossless format {fmt} not handled")


def encode_lossless(im: Image.Image, meta: dict, code: int, budget: int) -> bytes:
    arr = np.array(im)
    h, w = arr.shape[:2]
    if code == LOSSLESS2:
        # premultiplied ARGB
        rgb = arr[:, :, :3].astype(np.uint16)
        a = arr[:, :, 3].astype(np.uint16)
        pm = (rgb * a[:, :, None] // 255).astype(np.uint8)
        out = np.dstack([arr[:, :, 3], pm]).astype(np.uint8)
    else:
        out = np.dstack([np.zeros((h, w), np.uint8), arr[:, :, :3]]).astype(np.uint8)
    raw = out.tobytes()
    for level in (9, 8, 7, 6):
        packed = zlib.compress(raw, level)
        if len(packed) <= budget:
            return packed + b"\x00" * (budget - len(packed))
    raise RuntimeError(f"lossless image will not fit in {budget} bytes")


# --------------------------------------------------------------- recolour ops

def accent_ramp(im: Image.Image, *, colour, gamma=0.9, floor=0.0) -> Image.Image:
    """Remap an image onto a single-hue ramp from black to `colour`.

    Used for the rollover glow art, where the point of the asset is the glow
    colour itself — desaturating it toward graphite would just delete it.
    """
    has_alpha = im.mode == "RGBA"
    src = np.array(im)
    rgb = src[:, :, :3].astype(np.float32)
    lum = rgb.max(axis=2) / 255.0          # glow art: max is the truest signal
    ramp = np.clip(lum, 0, 1) ** gamma
    ramp = floor + (1.0 - floor) * ramp
    out = np.clip(ramp[..., None] * np.array(colour, dtype=np.float32), 0, 255)
    out = out.astype(np.uint8)
    if has_alpha:
        return Image.fromarray(np.dstack([out, src[:, :, 3]]), "RGBA")
    return Image.fromarray(out, "RGB")


def recolour(im: Image.Image, *, lo=0.03, hi=0.34, gamma=1.0, sat=0.35,
             tint=(0x11, 0x14, 0x18), tint_mix=0.35, preserve=None) -> Image.Image:
    """Map luminance into [lo, hi], desaturate, and mix toward a tint colour.

    preserve: optional (hue_lo, hue_hi, keep) in degrees — pixels whose hue
    falls in the range keep `keep` of their original saturation (used to hold
    on to warning/accent colours).
    """
    has_alpha = im.mode == "RGBA"
    a = None
    if has_alpha:
        a = np.array(im)[:, :, 3]
        rgb = np.array(im)[:, :, :3].astype(np.float32)
    else:
        rgb = np.array(im.convert("RGB")).astype(np.float32)

    lum = rgb @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
    lum_n = np.clip(lum / 255.0, 0, 1) ** gamma
    target = (lo + (hi - lo) * lum_n) * 255.0

    # keep chroma relative to luminance, then scale it down
    with np.errstate(divide="ignore", invalid="ignore"):
        ratio = np.where(lum[..., None] > 1.0, rgb / lum[..., None], 1.0)
    chroma = (ratio - 1.0) * sat + 1.0

    if preserve is not None:
        hlo, hhi, keep = preserve
        mx = rgb.max(axis=2)
        mn = rgb.min(axis=2)
        d = np.maximum(mx - mn, 1e-6)
        r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
        hue = np.select(
            [mx == r, mx == g],
            [(60 * ((g - b) / d)) % 360, 60 * ((b - r) / d) + 120],
            60 * ((r - g) / d) + 240,
        )
        satmask = ((mx - mn) / np.maximum(mx, 1e-6)) > 0.25
        inrange = ((hue >= hlo) & (hue <= hhi)) if hlo <= hhi else ((hue >= hlo) | (hue <= hhi))
        m = (inrange & satmask)[..., None]
        chroma = np.where(m, (ratio - 1.0) * keep + 1.0, chroma)
        target = np.where(m[..., 0], np.clip(lum * 0.85, 0, 255), target)

    out = np.clip(target[..., None] * chroma, 0, 255)
    tint_arr = np.array(tint, dtype=np.float32)
    if tint_mix:
        weight = (1.0 - lum_n[..., None]) * tint_mix
        out = out * (1 - weight) + tint_arr * weight
    out = np.clip(out, 0, 255).astype(np.uint8)

    if has_alpha:
        return Image.fromarray(np.dstack([out, a]), "RGBA")
    return Image.fromarray(out, "RGB")
