"""Import edited ActionScript back into patch SWFs."""
from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

from export_targets import resolve_target_source
from swf_utils import ROOT, import_scripts, load_config, replace_script


DISCORD_SCRIPT_PATCHES: dict[str, list[tuple[str, str]]] = {
    "main_client": [
         (r"\__Packages\classes\Frame", "__Packages/classes/Frame"),
         (r"\__Packages\classes\Control", "__Packages/classes/Control"),
         (r"\__Packages\classes\Console", "__Packages/classes/Console"),
        (r"\__Packages\classes\Viewer", "__Packages/classes/Viewer"),
        (r"\__Packages\classes\Drawing", "__Packages/classes/Drawing"),
        (r"\__Packages\classes\BaseBox", "__Packages/classes/BaseBox"),
        (r"\__Packages\classes\DialogBox", "__Packages/classes/DialogBox"),
        (r"\DefineSprite_2242\frame_1\DoAction", "DefineSprite_2242/frame_1/DoAction"),
        (r"\DefineSprite_1012_dialogActivateAccountContent\frame_1\DoAction", "DefineSprite_1012_dialogActivateAccountContent/frame_1/DoAction_2"),
        (r"\DefineSprite_1001_dialogActivateAccountContentNew\frame_1\DoAction", "DefineSprite_1001_dialogActivateAccountContentNew/frame_1/DoAction_2"),
        (r"\__Packages\classes\GaragePartMenu", "__Packages/classes/GaragePartMenu"),
        (r"\__Packages\classes\ShopMenu", "__Packages/classes/ShopMenu"),
        (r"\__Packages\classes\ShopMenu2", "__Packages/classes/ShopMenu2"),
    ],
    "loading_screen": [
        (r"\__Packages\classes\Frame", "__Packages/classes/Frame"),
        (r"\__Packages\classes\Console", "__Packages/classes/Console"),
    ],
}


def import_changed_scripts(
    patch_swf: Path,
    scripts_root: Path,
    script_entries: list[tuple[str, str]],
) -> None:
    working = patch_swf
    temp = patch_swf.with_suffix(".tmp.swf")
    for index, (script_name, script_rel) in enumerate(script_entries):
        script_path = scripts_root / "scripts" / f"{script_rel}.as"
        if not script_path.exists():
            raise FileNotFoundError(f"Script not found: {script_path}")
        out = temp if index < len(script_entries) - 1 else patch_swf
        replace_script(working, out, script_name, script_path)
        working = out
    if temp.exists():
        temp.unlink()


def build_patch(target: dict, exports_root: Path, patches_root: Path, config: dict) -> Path:
    swf_path = resolve_target_source(target, config)
    scripts_dir = exports_root / target["id"] / "scripts"
    if not scripts_dir.exists():
        raise FileNotFoundError(f"Scripts export not found: {scripts_dir}")

    patch_dir = patches_root / target["id"]
    patch_dir.mkdir(parents=True, exist_ok=True)
    patch_swf = patch_dir / swf_path.name
    if not patch_swf.exists() or patch_swf.stat().st_mtime < swf_path.stat().st_mtime:
        shutil.copy2(swf_path, patch_swf)

    script_entries = DISCORD_SCRIPT_PATCHES.get(target["id"])
    if script_entries:
        import_changed_scripts(patch_swf, scripts_dir, script_entries)
    else:
        import_scripts(patch_swf, scripts_dir)
    return patch_swf


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--target",
        help="Import only one manifest target id (loading_screen, login_form, main_client)",
    )
    parser.add_argument(
        "--exports-dir",
        type=Path,
        default=ROOT / "exports",
        help="Root export directory",
    )
    parser.add_argument(
        "--patches-dir",
        type=Path,
        default=ROOT / "patches",
        help="Root patches directory",
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
        patch = build_patch(target, args.exports_dir, args.patches_dir, config)
        print(f"Built patch {target['id']} -> {patch}")


if __name__ == "__main__":
    main()
