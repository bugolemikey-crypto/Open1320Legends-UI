"""Reskin the drag-strip christmas tree's bulbs from incandescent to LED.

Usage:
    python scripts/led_tree_lights.py                       # main.swf -> main.led-tree.swf
    python scripts/led_tree_lights.py <in.swf> <out.swf>
    python scripts/led_tree_lights.py --preview <dir>       # also dump the bulbs as PNGs

What the tree is made of
------------------------
Sprite `raceTreeLights` (character 1591) is a housing bitmap with the *unlit*
lens domes and the PRE STAGE / STAGE plates baked in, plus four reusable "lit"
overlay bitmaps that `classes.RaceTreeLights.doLight()` toggles with `_visible`:

    1576  housing, unlit domes baked in   128x187   (not touched)
    1578  lit red                          86x86
    1581  lit green                        86x86
    1584  lit amber (all three reuse it)   86x86
    1587  lit pre/stage pair               54x49

Only the four lit overlays are replaced. The housing, the sprites, every
placement and all ActionScript are left alone, so the .500 sportsman sequence
and its timing are untouched -- this is purely how the bulbs look.

Why the originals looked dated
------------------------------
They are incandescent art: an off-centre white-hot filament core, a lumpy lens,
and a halo whose RGB darkened toward black *at the same time* as its alpha fell
off. That double attenuation is what made the glow read as mud, and the bloom
swallowed the lens rim so a lit bulb lost its shape entirely.

The LED replacements keep the hue right through the lens instead of blowing out
white, hold a crisp rim so the bulb still reads as a lens, and let the *alpha
alone* carry the bloom over a flat, saturated RGB field.

Byte budget
-----------
Each target is a DefineBitsJPEG3 body:

    UI16 character id | UI32 alphaDataOffset | JPEG bytes | zlib alpha bytes

`swf_theme_lib.encode_to_budget` pads the JPEG with zeros after its FFD9 EOI
marker, which decoders ignore, so the alpha stream still ends exactly on the
tag boundary and every tag length is preserved. That is what keeps
`verify_byte_neutral.py` happy and the SWF inside its fixed embedded
allocation -- growing it makes the Director projector fail at startup, and
re-emitting as CWS silently breaks avatar upload.
"""
from __future__ import annotations

import struct
import sys
import zlib
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))

from swf_theme_lib import (  # noqa: E402
    encode_to_budget,
    parse_tags,
    read_swf,
    split_jpeg3,
    write_swf,
)

DEFINE_BITS_JPEG3 = 35
SS = 4  # supersample factor

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_IN = ROOT / "patches" / "main_client" / "main.swf"
DEFAULT_OUT = ROOT / "patches" / "main_client" / "main.led-tree.swf"


# --------------------------------------------------------------------- specs

# Lens centres and radii are measured from the *original* art's own alpha core
# (86x86 core centroid (42.2, 41.0) r~11; the 54x49 pair sits at x 21.8 / 31.2,
# y 22.5, r~4.3) so the new lens lands exactly on the housing dome it covers.
# Lane 2 is placed with scale x = -1, so the art is kept radially symmetric.
BIG = dict(
    size=(86, 86), centres=((42.2, 41.0),), radius=11.0,
    halo_tight=2.6, halo_wide=7.0, halo_near=0.40, halo_far=0.15,
    emitters=6, emitter_radius=0.56, emitter_gain=0.16,
    specular=0.42, rim_gain=0.30, fade_from=0.62, fade_to=0.95,
)
SMALL = dict(
    BIG,
    size=(54, 49), centres=((21.8, 22.5), (31.2, 22.5)), radius=4.3,
    halo_tight=1.9, halo_wide=4.2, halo_near=0.40, halo_far=0.14,
    emitters=0, emitter_gain=0.06,
    specular=0.34, rim_gain=0.22, fade_from=0.45, fade_to=0.92,
)

BULBS = {
    1578: dict(BIG, role="red", lens="#FF2020", core="#FF8478", bloom="#F00A0A"),
    1581: dict(BIG, role="green", lens="#00D95A", core="#84FFAE", bloom="#00C24E"),
    1584: dict(BIG, role="amber", lens="#FF9E00", core="#FFD95E", bloom="#FF8A00"),
    1587: dict(SMALL, role="pre/stage", lens="#FFC61A", core="#FFF0A8", bloom="#FFB000"),
}


def _rgb(value: str) -> np.ndarray:
    h = value.lstrip("#")
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], dtype=float)


# ------------------------------------------------------------------ renderer

def render_bulb(spec: dict) -> Image.Image:
    """Render one LED bulb plate as RGBA."""
    w, h = spec["size"]
    big_w, big_h = w * SS, h * SS
    radius = spec["radius"] * SS
    lens, core, bloom = _rgb(spec["lens"]), _rgb(spec["core"]), _rgb(spec["bloom"])
    reach = min(big_w, big_h) / 2.0

    # supersample grid expressed in final-pixel index space
    gy, gx = np.mgrid[0:big_h, 0:big_w].astype(float)
    xx = ((gx + 0.5) / SS - 0.5) * SS
    yy = ((gy + 0.5) / SS - 0.5) * SS

    rgb = np.zeros((big_h, big_w, 3), float) + bloom
    alpha = np.zeros((big_h, big_w), float)

    for cx, cy in spec["centres"]:
        cx, cy = cx * SS, cy * SS
        dx, dy = xx - cx, yy - cy
        r = np.hypot(dx, dy)
        t = np.clip(r / radius, 0, 1)

        # lens body: evenly lit and saturated, centre lifted toward `core`
        lift = (1.0 - t ** 2) ** 1.35
        body = lens * (1 - 0.55 * lift)[..., None] + core * (0.55 * lift)[..., None]

        # faint LED emitter array (centre emitter plus a ring)
        if spec["emitters"]:
            er = spec["emitter_radius"] * radius
            emit = np.exp(-(r / (er * 0.85)) ** 2)
            for k in range(spec["emitters"]):
                a = 2 * np.pi * k / spec["emitters"] - np.pi / 2
                ex, ey = cx + np.cos(a) * radius * 0.55, cy + np.sin(a) * radius * 0.55
                emit += np.exp(-(np.hypot(xx - ex, yy - ey) / (er * 0.62)) ** 2)
            body *= (1.0 + spec["emitter_gain"] * np.clip(emit, 0, 1.6))[..., None]

        # rim catch just inside the lens edge
        body *= (1.0 + spec["rim_gain"] * np.exp(-((t - 0.93) / 0.055) ** 2))[..., None]

        # top-lit shading, a touch deeper at the bottom
        body *= (1.0 - 0.13 * np.clip(dy / radius, -1, 1))[..., None]

        # glass specular, upper area, horizontally symmetric
        sp = np.exp(-((dx / (radius * 0.58)) ** 2
                      + ((dy + radius * 0.46) / (radius * 0.26)) ** 2))
        body = body + 255.0 * spec["specular"] * sp[..., None] * 0.55

        inside = np.clip((radius - r) / (0.85 * SS) + 0.5, 0, 1)
        m = inside[..., None]
        rgb = rgb * (1 - m) + np.clip(body, 0, 255) * m

        # chromatic bloom: alpha-only falloff, forced to zero before the plate
        # edge or the rectangular clip shows in game as a box around each bulb
        d_out = np.clip(r - radius, 0, None)
        glow = (spec["halo_near"] * np.exp(-d_out / (spec["halo_tight"] * SS))
                + spec["halo_far"] * np.exp(-d_out / (spec["halo_wide"] * SS)))
        win = np.clip((spec["fade_to"] * reach - r)
                      / ((spec["fade_to"] - spec["fade_from"]) * reach), 0, 1)
        win = win * win * (3 - 2 * win)
        alpha = np.maximum(alpha, np.maximum(np.clip(glow, 0, 1) * win, inside))

    def down(a):
        s = a.reshape(h, SS, w, SS) if a.ndim == 2 else a.reshape(h, SS, w, SS, 3)
        return s.mean(axis=(1, 3))

    out_rgb = np.clip(down(rgb), 0, 255).astype(np.uint8)
    out_a = np.clip(down(alpha) * 255.0, 0, 255)
    out_a[out_a < 2] = 0        # snap the long tail: cleaner edge, compresses better
    im = Image.fromarray(out_rgb, "RGB")
    im.putalpha(Image.fromarray(out_a.astype(np.uint8), "L"))
    return im


# --------------------------------------------------------------------- patch

def apply(src: Path, dst: Path, preview: Path | None = None) -> None:
    sig, version, body, header_len = read_swf(src)
    if sig != b"FWS":
        raise RuntimeError(f"{src.name} is {sig.decode()}, refusing to patch "
                           "(CWS breaks FileReference.upload)")

    tags = parse_tags(body, header_len)
    targets = {}
    for tag in tags:
        if tag.code != DEFINE_BITS_JPEG3:
            continue
        cid = struct.unpack_from("<H", body, tag.payload_start)[0]
        if cid in BULBS:
            targets[cid] = tag

    missing = sorted(set(BULBS) - set(targets))
    if missing:
        raise RuntimeError(f"tree bulb characters not found in {src.name}: {missing}")

    if preview:
        preview.mkdir(parents=True, exist_ok=True)

    print(f"{src.name}: {len(body) + 8:,} bytes, {len(tags)} tags\n")
    print(f"{'char':<6}{'role':<11}{'payload':<9}{'jpeg':<7}{'alpha':<7}{'pad':<7}{'q':<4}sub")

    for cid, spec in BULBS.items():
        tag = targets[cid]
        payload = bytes(body[tag.payload_start:tag.payload_end])
        _, prefix, old_jpeg, _, old_alpha = split_jpeg3(payload)

        art = render_bulb(spec)
        if art.size != spec["size"]:
            raise RuntimeError(f"char {cid}: rendered {art.size}, expected {spec['size']}")

        alpha_z = zlib.compress(art.getchannel("A").tobytes(), 9)
        budget = len(payload) - 6 - len(prefix) - len(alpha_z)
        if budget <= 0:
            raise RuntimeError(f"char {cid}: alpha alone overruns the {len(payload)} byte tag")

        jpeg, quality, subsampling = encode_to_budget(art.convert("RGB"), budget)
        pad = len(jpeg) - len(jpeg.rstrip(b"\x00"))

        field = prefix + jpeg
        new_payload = struct.pack("<HI", cid, len(field)) + field + alpha_z
        if len(new_payload) != len(payload):
            raise RuntimeError(f"char {cid}: {len(new_payload)} != {len(payload)}")
        body[tag.payload_start:tag.payload_end] = new_payload

        if preview:
            art.save(preview / f"bulb-{cid}-{spec['role'].replace('/', '-')}.png")

        print(f"{cid:<6}{spec['role']:<11}{len(payload):<9}"
              f"{len(jpeg) - pad:<7}{len(alpha_z):<7}{pad:<7}{quality:<4}{subsampling}")

    write_swf(dst, version, bytes(body))
    print(f"\nwrote {dst}  ({dst.stat().st_size:,} bytes)")
    if dst.stat().st_size != src.stat().st_size:
        raise RuntimeError("output size differs from the baseline -- not byte-neutral")


def main(argv: list[str]) -> None:
    args = [a for a in argv if not a.startswith("--")]
    preview = None
    if "--preview" in argv:
        idx = argv.index("--preview")
        preview = Path(argv[idx + 1]).resolve()
        args = [a for a in args if a != argv[idx + 1]]

    src = Path(args[0]).resolve() if len(args) > 0 else DEFAULT_IN
    dst = Path(args[1]).resolve() if len(args) > 1 else DEFAULT_OUT
    apply(src, dst, preview)
    print(f"\nnow run: python scripts/verify_byte_neutral.py {src} {dst}")


if __name__ == "__main__":
    main(sys.argv[1:])
