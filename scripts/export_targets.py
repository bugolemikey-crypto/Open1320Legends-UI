"""Export all UI target SWFs for FFDec editing."""
from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

from extract_main import extract_main
from swf_utils import ROOT, export_images, export_scripts, game_root, load_config


def resolve_target_source(target: dict, config: dict) -> Path:
    source = Path(target["source"])
    if source.exists():
        return source

    if target.get("kind") == "embedded_swf":
        return extract_main()

    game_path = game_root(config) / source
    if game_path.exists():
        return game_path

    raise FileNotFoundError(f"Target source not found: {source}")


def export_target(target: dict, exports_root: Path, config: dict) -> Path:
    swf_path = resolve_target_source(target, config)
    target_dir = exports_root / target["id"]
    if target_dir.exists():
        shutil.rmtree(target_dir)
    target_dir.mkdir(parents=True, exist_ok=True)

    shutil.copy2(swf_path, target_dir / swf_path.name)
    export_images(swf_path, target_dir / "images")
    export_scripts(swf_path, target_dir / "scripts")
    return target_dir


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--target",
        help="Export only one manifest target id (loading_screen, login_form, main_client)",
    )
    parser.add_argument(
        "--exports-dir",
        type=Path,
        default=ROOT / "exports",
        help="Root export directory",
    )
    args = parser.parse_args()

    manifest = json.loads((ROOT / "targets" / "manifest.json").read_text(encoding="utf-8"))
    config = load_config()
    targets = manifest["targets"]
    if args.target:
        targets = [t for t in targets if t["id"] == args.target]
        if not targets:
            raise SystemExit(f"Unknown target id: {args.target}")

    for target in targets:
        out = export_target(target, args.exports_dir, config)
        print(f"Exported {target['id']} -> {out}")


if __name__ == "__main__":
    main()
