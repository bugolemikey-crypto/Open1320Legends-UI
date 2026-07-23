"""Replace btnFBConnect artwork (char 1953) with Discord button art."""
from __future__ import annotations

import argparse
import struct
import subprocess
from pathlib import Path

from swf_utils import ROOT, resolve_ffdec_path


BTN_CHAR_ID = 1953
BTN_SIZE = (174, 30)


def ensure_button_image(source: Path, out: Path) -> Path:
    from PIL import Image

    out.parent.mkdir(parents=True, exist_ok=True)
    img = Image.open(source).convert("RGB")
    if img.size != BTN_SIZE:
        img = img.resize(BTN_SIZE, Image.Resampling.LANCZOS)
    # Keep a PNG preview; FFDec import uses a tuned JPEG for size limits.
    img.save(out, format="PNG")
    jpg = out.with_suffix(".jpg")
    img.save(jpg, format="JPEG", quality=90, optimize=True)
    return jpg


def pad_swf_to_size(path: Path, size: int) -> None:
    data = bytearray(path.read_bytes())
    if len(data) < size:
        data.extend(b"\x00" * (size - len(data)))
    elif len(data) > size:
        raise RuntimeError(f"SWF too large after replace: {len(data):,} > {size:,}")
    struct.pack_into("<I", data, 4, len(data))
    path.write_bytes(data)


def replace_button(
    swf_in: Path,
    swf_out: Path,
    image: Path,
    pad_to: int | None = None,
) -> None:
    ffdec = resolve_ffdec_path()
    tmp = swf_out.with_suffix(".tmp.swf")
    result = subprocess.run(
        [ffdec, "-replace", str(swf_in), str(tmp), str(BTN_CHAR_ID), str(image), "jpeg3"],
        capture_output=True,
        text=True,
        creationflags=0x08000000,
    )
    if result.returncode not in (0, 255):
        raise RuntimeError(result.stderr or result.stdout or "FFDec replace failed")

    if pad_to is not None:
        pad_swf_to_size(tmp, pad_to)
    tmp.replace(swf_out)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--image",
        type=Path,
        default=ROOT / "assets" / "login" / "btn_discord_connect.png",
        help="Discord button source art",
    )
    parser.add_argument(
        "--source-image",
        type=Path,
        default=ROOT / "assets" / "discord_connect_button.png",
        help="Raw art to resize when --image does not exist",
    )
    parser.add_argument(
        "--swf",
        type=Path,
        default=ROOT / "patches" / "main_client" / "main.swf",
    )
    parser.add_argument(
        "--pad-to",
        type=int,
        default=(ROOT / "source" / "main.swf").stat().st_size
        if (ROOT / "source" / "main.swf").exists()
        else None,
        help="Pad output SWF to this byte size (for embedded deploy)",
    )
    args = parser.parse_args()

    image = args.image
    if not image.exists():
        import_image = ensure_button_image(args.source_image, image)
    else:
        import_image = ensure_button_image(image, image)

    replace_button(args.swf, args.swf, import_image, pad_to=args.pad_to)
    print(f"Replaced char {BTN_CHAR_ID} in {args.swf} using {import_image} ({BTN_SIZE[0]}x{BTN_SIZE[1]})")


if __name__ == "__main__":
    main()
