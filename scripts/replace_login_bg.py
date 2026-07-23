"""Replace login background (char 1925) with custom PNG art."""
from __future__ import annotations

import argparse
import struct
import subprocess
from pathlib import Path

from swf_utils import ROOT, resolve_ffdec_path


BG_CHAR_ID = 1925
BG_SIZE = (850, 650)


def prepare_image(source: Path, out: Path, max_size: int | None = None) -> Path:
    """Resize source image to exact BG_SIZE and save as JPEG for FFDec import.
    
    If max_size is given, reduce quality until file fits.
    """
    from PIL import Image

    out.parent.mkdir(parents=True, exist_ok=True)
    img = Image.open(source).convert("RGB")
    if img.size != BG_SIZE:
        print(f"Resizing {img.size[0]}x{img.size[1]} -> {BG_SIZE[0]}x{BG_SIZE[1]}")
        img = img.resize(BG_SIZE, Image.Resampling.LANCZOS)

    jpg = out.with_suffix(".jpg")

    if max_size is None:
        img.save(jpg, format="JPEG", quality=92, optimize=True)
    else:
        # Binary search for best quality that fits within max_size
        lo, hi = 10, 95
        best_q = lo
        while lo <= hi:
            mid = (lo + hi) // 2
            img.save(jpg, format="JPEG", quality=mid, optimize=True)
            if jpg.stat().st_size <= max_size:
                best_q = mid
                lo = mid + 1
            else:
                hi = mid - 1
        img.save(jpg, format="JPEG", quality=best_q, optimize=True)
        print(f"Using JPEG quality {best_q} to fit within {max_size:,} byte budget")

    print(f"Prepared: {jpg} ({jpg.stat().st_size:,} bytes)")
    return jpg


def pad_swf_to_size(path: Path, size: int) -> None:
    """Pad SWF with null bytes to match original embedded size."""
    data = bytearray(path.read_bytes())
    if len(data) < size:
        data.extend(b"\x00" * (size - len(data)))
    elif len(data) > size:
        raise RuntimeError(
            f"SWF too large after replace: {len(data):,} > {size:,}. "
            f"Try reducing JPEG quality or image complexity."
        )
    struct.pack_into("<I", data, 4, len(data))
    path.write_bytes(data)


def replace_bg(
    swf_in: Path,
    swf_out: Path,
    image: Path,
    pad_to: int | None = None,
) -> None:
    """Replace char 1925 in the SWF with the given image."""
    ffdec = resolve_ffdec_path()
    tmp = swf_out.with_suffix(".tmp.swf")

    result = subprocess.run(
        [ffdec, "-replace", str(swf_in), str(tmp), str(BG_CHAR_ID), str(image)],
        capture_output=True,
        text=True,
        creationflags=0x08000000,
    )
    if result.returncode not in (0, 255):
        raise RuntimeError(result.stderr or result.stdout or "FFDec replace failed")

    if pad_to is not None:
        pad_swf_to_size(tmp, pad_to)

    tmp.replace(swf_out)
    print(f"Replaced char {BG_CHAR_ID} in {swf_out}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--image",
        type=Path,
        default=ROOT / "assets" / "login" / "login_screen_bg.png",
        help="Source PNG for login background (will be resized to 850x650)",
    )
    parser.add_argument(
        "--swf",
        type=Path,
        default=ROOT / "patches" / "main_client" / "main.swf",
        help="Target SWF to patch",
    )
    parser.add_argument(
        "--pad-to",
        type=int,
        default=None,
        help="Pad output SWF to this byte size (auto-detected from source/main.swf if omitted)",
    )
    args = parser.parse_args()

    if not args.image.exists():
        print(f"ERROR: Source image not found: {args.image}")
        print(f"Place your login screen PNG at: {args.image}")
        raise SystemExit(1)

    if not args.swf.exists():
        print(f"ERROR: Target SWF not found: {args.swf}")
        print(f"Run 'scripts\\Run_Patch_Discord.bat' first to create patches/main_client/main.swf")
        raise SystemExit(1)

    # Auto-detect pad size from source/main.swf
    pad_to = args.pad_to
    if pad_to is None:
        source_swf = ROOT / "source" / "main.swf"
        if source_swf.exists():
            pad_to = source_swf.stat().st_size
            print(f"Will pad to {pad_to:,} bytes (matching source/main.swf)")

    # Calculate byte budget: new JPEG must not make SWF exceed pad_to
    # Original char 1925 JPEG data was ~26035 bytes inside the SWF
    ORIGINAL_CHAR_SIZE = 26035
    if pad_to is not None:
        current_swf_size = args.swf.stat().st_size
        headroom = pad_to - current_swf_size + ORIGINAL_CHAR_SIZE
        # Leave 1KB safety margin
        max_jpeg_size = max(headroom - 1024, ORIGINAL_CHAR_SIZE)
        print(f"JPEG byte budget: {max_jpeg_size:,} bytes")
    else:
        max_jpeg_size = None

    # Prepare the image
    prepared = prepare_image(
        args.image,
        ROOT / "assets" / "login" / "login_bg_prepared",
        max_size=max_jpeg_size,
    )

    # Do the replacement
    replace_bg(args.swf, args.swf, prepared, pad_to=pad_to)
    print("Done! Login background replaced successfully.")


if __name__ == "__main__":
    main()
