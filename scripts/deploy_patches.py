"""Deploy patched SWFs back into the game install."""
from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

from swf_utils import ROOT, game_root, load_config

# Bytes of unrelated trailer this executable keeps after the embedded SWF.
TRAILER_SIZE = 4


def deploy_cache_target(target: dict, patches_root: Path, game: Path) -> Path:
    patch = patches_root / target["id"] / Path(target["source"]).name
    if not patch.exists():
        raise FileNotFoundError(f"Patch not found: {patch}")

    dest = game / target["deploy_to"]
    backup = dest.with_suffix(dest.suffix + ".bak")
    if dest.exists() and not backup.exists():
        shutil.copy2(dest, backup)

    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(patch, dest)
    return dest


def deploy_embedded_main(
    patch: Path,
    game: Path,
    config: dict,
    exe_path: Path | None = None,
) -> None:
    exe = exe_path or (game / config["game_exe"])
    if not patch.exists():
        raise FileNotFoundError(f"Patch not found: {patch}")

    # Flag a SWF that looks extracted out of a grown build. Deploying one bakes
    # the growth padding in, grows the exe again on every round-trip, and -- as
    # happened on 2026-07-27 -- can quietly ship the *original* art while
    # looking like a successful deploy. This warns rather than blocks: the
    # checks are heuristics and there are legitimate reasons to deploy a grown
    # SWF. Use scripts/client_guard.py if you want an exit code to gate on.
    from client_guard import problems_with_patch

    for issue in problems_with_patch(patch.read_bytes()):
        print(f"WARNING: {issue}")

    data = bytearray(exe.read_bytes())
    offset = int(config["main_swf_embed_offset"])
    header_size = int.from_bytes(data[offset + 4 : offset + 8], "little")
    # A few legacy installs store a logical SWF length that runs past the end
    # of the executable. The embedded client is the final payload, so its
    # physical allocation is the remaining bytes from the configured offset.
    # Never write past that allocation.
    patch_bytes = patch.read_bytes()
    available_size = len(data) - offset
    # This particular legacy executable has four bytes of unrelated trailer
    # data after the valid SWF stream, so the physical allocation is everything
    # from the embed offset except those four bytes.
    capacity = available_size - TRAILER_SIZE
    # `header_size` is only the length the *previous* deploy wrote. Installing a
    # smaller patch shrinks it, so it ratchets downwards and is a floor on what
    # the slot holds, never the ceiling: treat the physical capacity as the
    # ceiling and grow back into it when a later patch needs the room.
    size = min(header_size, capacity) if header_size <= capacity else capacity
    if len(patch_bytes) > size and len(patch_bytes) <= capacity:
        size = len(patch_bytes)
    trailer_size = available_size - len(patch_bytes)
    if header_size > available_size and 0 < trailer_size <= 16:
        size = len(patch_bytes)
    if len(patch_bytes) > size and 0 <= available_size - header_size <= 16:
        # The legacy executable has a four-byte trailer after the embedded
        # SWF. Allow the SWF payload to grow by inserting the larger stream
        # before that trailer; the loader uses the SWF header length.
        trailer = bytes(data[-4:])
        data = data[:offset] + patch_bytes + trailer
        size = len(patch_bytes)
    elif len(patch_bytes) > size:
        raise RuntimeError(
            f"main.swf patch size mismatch: patch={len(patch_bytes):,} embedded={size:,}. "
            "Re-extract main.swf and rebuild the patch at the same size, or update config offset."
        )
    elif len(patch_bytes) < size:
        # Patch is smaller than the embedded slot -- pad with null bytes.
        # The SWF header's own length field tells the loader where the stream
        # ends, so trailing nulls are harmless filler.
        patch_bytes = patch_bytes + b"\x00" * (size - len(patch_bytes))

    backup = exe.with_suffix(exe.suffix + ".bak")
    if not backup.exists():
        shutil.copy2(exe, backup)

    if len(data) >= offset + size and data[offset : offset + size] != patch_bytes:
        data[offset : offset + size] = patch_bytes
    exe.write_bytes(data)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--target",
        help="Deploy only one manifest target id",
    )
    parser.add_argument(
        "--patches-dir",
        type=Path,
        default=ROOT / "patches",
        help="Root patches directory",
    )
    parser.add_argument(
        "--exe",
        type=Path,
        default=None,
        help="Optional executable to receive an embedded main.swf patch",
    )
    args = parser.parse_args()

    manifest = json.loads((ROOT / "targets" / "manifest.json").read_text(encoding="utf-8"))
    config = load_config()
    game = game_root(config)
    targets = manifest["targets"]
    if args.target:
        targets = [t for t in targets if t["id"] == args.target]
        if not targets:
            raise SystemExit(f"Unknown target id: {args.target}")

    for target in targets:
        if target.get("kind") == "embedded_swf":
            patch = args.patches_dir / target["id"] / "main.swf"
            deploy_embedded_main(patch, game, config, args.exe)
            target_exe = args.exe or (game / config["game_exe"])
            print(f"Deployed embedded main.swf into {target_exe}")
            continue

        dest = deploy_cache_target(target, args.patches_dir, game)
        print(f"Deployed {target['id']} -> {dest}")


if __name__ == "__main__":
    main()
