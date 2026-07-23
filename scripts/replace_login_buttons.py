"""Replace login button art (chars 1945, 1948, 1953) with custom PNGs."""
from __future__ import annotations

import struct
import subprocess
from pathlib import Path
from PIL import Image

from swf_utils import ROOT, resolve_ffdec_path


ASSETS = ROOT / "assets" / "login"
SWF = ROOT / "patches" / "main_client" / "main.swf"
SOURCE_SWF = ROOT / "source" / "main.swf"

# Button char IDs and their required pixel sizes
BUTTONS = {
    "btn_login": {"char_id": 1945, "size": (172, 29), "orig_bytes": 2932},
    "btn_create": {"char_id": 1948, "size": (172, 29), "orig_bytes": 3670},
    "btn_discord": {"char_id": 1953, "size": (174, 29), "orig_bytes": 3400},
}


def prepare_button(source: Path, size: tuple[int, int], max_jpeg_bytes: int) -> Path:
    """Resize button to target size and compress to fit byte budget."""
    img = Image.open(source).convert("RGB")
    img = img.resize(size, Image.Resampling.LANCZOS)

    out = source.with_suffix(".import.jpg")

    # Binary search for best quality that fits
    lo, hi = 20, 95
    best_q = lo
    while lo <= hi:
        mid = (lo + hi) // 2
        img.save(out, format="JPEG", quality=mid, optimize=True)
        if out.stat().st_size <= max_jpeg_bytes:
            best_q = mid
            lo = mid + 1
        else:
            hi = mid - 1

    img.save(out, format="JPEG", quality=best_q, optimize=True)
    print(f"  Quality {best_q}, size {out.stat().st_size:,} bytes (budget: {max_jpeg_bytes:,})")
    return out


def pad_swf_to_size(path: Path, size: int) -> None:
    data = bytearray(path.read_bytes())
    if len(data) < size:
        data.extend(b"\x00" * (size - len(data)))
    elif len(data) > size:
        raise RuntimeError(
            f"SWF too large: {len(data):,} > {size:,}"
        )
    struct.pack_into("<I", data, 4, len(data))
    path.write_bytes(data)


def replace_char(swf: Path, char_id: int, image: Path) -> None:
    ffdec = resolve_ffdec_path()
    tmp = swf.with_suffix(".tmp.swf")

    result = subprocess.run(
        [ffdec, "-replace", str(swf), str(tmp), str(char_id), str(image)],
        capture_output=True,
        text=True,
        creationflags=0x08000000,
    )
    if result.returncode not in (0, 255):
        raise RuntimeError(result.stderr or result.stdout or f"FFDec replace failed for char {char_id}")

    tmp.replace(swf)


def main() -> None:
    if not SWF.exists():
        print(f"ERROR: {SWF} not found. Run patches first.")
        raise SystemExit(1)

    target_size = SOURCE_SWF.stat().st_size if SOURCE_SWF.exists() else None
    print(f"Target SWF size: {target_size:,} bytes")

    # Calculate total byte budget available
    # We need the combined new button JPEGs to not exceed combined original sizes
    # Actually, we'll do them one at a time and just pad at the end
    total_orig = sum(b["orig_bytes"] for b in BUTTONS.values())
    print(f"Total original button data: {total_orig:,} bytes")

    for name, info in BUTTONS.items():
        source_png = ASSETS / f"{name}.png"
        if not source_png.exists():
            print(f"SKIP {name}: {source_png} not found")
            continue

        print(f"\nReplacing {name} (char {info['char_id']}, target {info['size'][0]}x{info['size'][1]}):")

        # Give each button its original byte budget
        jpg = prepare_button(source_png, info["size"], info["orig_bytes"])
        replace_char(SWF, info["char_id"], jpg)
        print(f"  Replaced char {info['char_id']}")

    # Pad back to original size
    if target_size:
        pad_swf_to_size(SWF, target_size)
        print(f"\nPadded SWF to {target_size:,} bytes")

    print("\nDone! All buttons replaced.")


if __name__ == "__main__":
    main()
