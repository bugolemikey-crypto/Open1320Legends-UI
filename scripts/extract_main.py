"""Extract the embedded main.swf from NittoLegendsBeta.exe."""
from __future__ import annotations

import argparse
from pathlib import Path

from swf_utils import ROOT, game_root, load_config


def find_embedded_swf(data: bytes) -> tuple[int, int]:
    for sig in (b"FWS", b"CWS", b"ZWS"):
        offset = 0
        while True:
            offset = data.find(sig, offset)
            if offset < 0:
                break
            if offset + 8 > len(data):
                break
            size = int.from_bytes(data[offset + 4 : offset + 8], "little")
            if 1_000_000 < size < len(data) - offset:
                return offset, size
            offset += 1
    raise RuntimeError("Could not locate embedded main.swf in game exe")


def extract_main(
    out_path: Path | None = None,
    offset: int | None = None,
    exe_path: Path | None = None,
) -> Path:
    config = load_config()
    exe = exe_path or (game_root(config) / config["game_exe"])
    if not exe.exists():
        raise FileNotFoundError(f"Game exe not found: {exe}")

    data = exe.read_bytes()
    if offset is None:
        configured = config.get("main_swf_embed_offset")
        if configured:
            offset = int(configured)
            size = int.from_bytes(data[offset + 4 : offset + 8], "little")
        else:
            offset, size = find_embedded_swf(data)
    else:
        size = int.from_bytes(data[offset + 4 : offset + 8], "little")

    out_path = out_path or (ROOT / "source" / "main.swf")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_bytes(data[offset : offset + size])
    return out_path


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=ROOT / "source" / "main.swf",
        help="Output path for extracted main.swf",
    )
    parser.add_argument(
        "--offset",
        type=int,
        default=None,
        help="Optional byte offset override for embedded SWF",
    )
    parser.add_argument(
        "--exe",
        type=Path,
        default=None,
        help="Optional executable to extract instead of the configured game executable",
    )
    args = parser.parse_args()
    out = extract_main(args.output, args.offset, args.exe)
    print(f"Extracted {out} ({out.stat().st_size:,} bytes)")


if __name__ == "__main__":
    main()
