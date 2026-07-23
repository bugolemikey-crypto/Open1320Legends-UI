"""Manifest-driven FFDec SWF UI editor for Open1320Legends.

The editor uses FFDec's XML round-trip for layout changes and FFDec's image
replacement command for bitmap changes. Coordinates in the layout manifest are
stage pixels; SWF XML matrices are written in twips (20 twips per pixel).
"""
from __future__ import annotations

import argparse
import json
import shutil
import struct
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Iterable

from PIL import Image

from swf_utils import ROOT, load_config, resolve_ffdec_path

STAGE = (800, 600)
TWIPS = 20
LOGIN_SPRITE_ID = 2002
LOGIN_BACKGROUND_IMAGE_ID = 1925
LOGIN_BACKGROUND_SHAPE_ID = 1926

DEFAULT_LAYOUT = {
    "stage": {"width": 800, "height": 600},
    "background": {
        "image_id": 1925,
        "shape_id": 1926,
        "fit": "cover",
        "anchor": "center",
    },
    "sprites": [{
        "sprite_id": 2002,
        "hide_characters": [1930, 1931, 1932, 1933, 1934, 1952, 1957, 1961],
        "instances": {
            "fldUsername": {"x": 570, "y": 330, "width": 205, "height": 30},
            "fldPass": {"x": 570, "y": 365, "width": 205, "height": 30},
            "btnStart": {"x": 570, "y": 410, "width": 205, "height": 40},
            "btnCreateAccount": {"x": 175, "y": 410, "width": 145, "height": 40},
            "btnFBConnect": {"x": 35, "y": 410, "width": 205, "height": 40},
        },
    }],
}


def die(message: str) -> "NoReturn":
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def run_ffdec(*args: str, timeout: int = 600) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        [resolve_ffdec_path(), *args],
        capture_output=True,
        text=True,
        timeout=timeout,
        creationflags=0x08000000,
    )
    if result.returncode not in (0, 255):
        detail = result.stderr.strip() or result.stdout.strip()
        raise RuntimeError(detail or f"FFDec failed with exit code {result.returncode}")
    return result


def swf_size(path: Path) -> int:
    return path.stat().st_size


def pad_swf(path: Path, target: int) -> None:
    data = bytearray(path.read_bytes())
    if len(data) > target:
        raise RuntimeError(f"Generated SWF is {len(data):,} bytes, target is {target:,}; it cannot be embedded safely.")
    data.extend(b"\0" * (target - len(data)))
    struct.pack_into("<I", data, 4, len(data))
    path.write_bytes(data)


def png_size(path: Path) -> tuple[int, int]:
    with Image.open(path) as image:
        return image.size


def prepare_image(source: Path, output: Path, size: tuple[int, int], fit: str) -> Path:
    """Make a stage-sized RGB JPEG, using cover/contain/stretch semantics."""
    with Image.open(source) as original:
        image = original.convert("RGB")
    target_w, target_h = size
    if fit == "stretch":
        image = image.resize(size, Image.Resampling.LANCZOS)
    else:
        scale = max(target_w / image.width, target_h / image.height) if fit == "cover" else min(target_w / image.width, target_h / image.height)
        new_size = (max(1, round(image.width * scale)), max(1, round(image.height * scale)))
        image = image.resize(new_size, Image.Resampling.LANCZOS)
        canvas = Image.new("RGB", size, (0, 0, 0))
        left = (target_w - image.width) // 2
        top = (target_h - image.height) // 2
        canvas.paste(image, (left, top))
        image = canvas
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, format="JPEG", quality=92, optimize=True)
    return output


def export_xml(swf: Path, xml_path: Path) -> None:
    xml_path.parent.mkdir(parents=True, exist_ok=True)
    run_ffdec("-swf2xml", "-external", "image", str(swf), str(xml_path), timeout=900)


def import_xml(xml_path: Path, swf_path: Path) -> None:
    run_ffdec("-xml2swf", str(xml_path), str(swf_path), timeout=900)


def compress_swf(source: Path, output: Path) -> None:
    run_ffdec("-compress", "zlib", str(source), str(output), timeout=900)


def load_layout(path: Path | None) -> dict:
    if path is None:
        return DEFAULT_LAYOUT
    with path.open(encoding="utf-8") as handle:
        data = json.load(handle)
    return data


def all_items(root: ET.Element) -> Iterable[ET.Element]:
    yield from root.iter("item")


def find_sprites(root: ET.Element, sprite_id: int | None = None) -> list[ET.Element]:
    result = []
    for item in all_items(root):
        if item.get("type") == "DefineSpriteTag" and (sprite_id is None or item.get("spriteId") == str(sprite_id)):
            result.append(item)
    return result


def matrix_for(item: ET.Element) -> ET.Element:
    matrix = item.find("matrix")
    if matrix is None:
        matrix = ET.Element("matrix")
        item.insert(0, matrix)
    return matrix


def set_matrix(item: ET.Element, spec: dict) -> None:
    matrix = matrix_for(item)
    x = float(spec.get("x", 0)) * TWIPS
    y = float(spec.get("y", 0)) * TWIPS
    matrix.set("translateX", str(round(x)))
    matrix.set("translateY", str(round(y)))
    matrix.set("nTranslateBits", "31")

    width = spec.get("width")
    height = spec.get("height")
    if width is not None or height is not None:
        # The supplied dimensions are the desired stage-space dimensions. The
        # original character bounds are unknown here, so scale is relative to
        # the original placement when explicit scale is supplied. For exact
        # sizing, use scaleX/scaleY in the manifest.
        if "scaleX" in spec:
            sx = float(spec["scaleX"])
        else:
            sx = float(spec.get("scale", 1.0))
        if "scaleY" in spec:
            sy = float(spec["scaleY"])
        else:
            sy = float(spec.get("scale", 1.0))
    else:
        sx = float(spec.get("scaleX", spec.get("scale", 1.0)))
        sy = float(spec.get("scaleY", spec.get("scale", 1.0)))
    if sx != 1.0 or sy != 1.0:
        matrix.set("hasScale", "true")
        matrix.set("nScaleBits", "31")
        matrix.set("scaleX", format(sx, ".7g"))
        matrix.set("scaleY", format(sy, ".7g"))
    else:
        matrix.set("hasScale", "false")
        matrix.set("nScaleBits", "0")
        matrix.attrib.pop("scaleX", None)
        matrix.attrib.pop("scaleY", None)


def set_alpha_zero(item: ET.Element) -> None:
    item.set("placeFlagHasColorTransform", "true")
    transform = item.find("colorTransform")
    if transform is None:
        transform = ET.SubElement(item, "colorTransform")
    transform.set("type", "CXFORMWITHALPHA")
    transform.set("alphaMultTerm", "0")
    transform.set("blueMultTerm", "0")
    transform.set("greenMultTerm", "0")
    transform.set("redMultTerm", "0")
    transform.set("hasAddTerms", "false")
    transform.set("hasMultTerms", "true")
    transform.set("nbits", "1")


def edit_sprite(root: ET.Element, sprite_config: dict) -> tuple[int, int]:
    sprite_id = int(sprite_config["sprite_id"])
    sprites = find_sprites(root, sprite_id)
    if not sprites:
        raise RuntimeError(f"DefineSpriteTag spriteId={sprite_id} was not found")
    changed = hidden = 0
    hide_ids = {str(value) for value in sprite_config.get("hide_characters", [])}
    instances = sprite_config.get("instances", {})
    for sprite in sprites:
        for item in list(sprite.iter("item")):
            if item.get("type") != "PlaceObject2Tag":
                continue
            name = item.get("name")
            if item.get("characterId") in hide_ids and not name:
                set_alpha_zero(item)
                hidden += 1
            if name in instances:
                set_matrix(item, instances[name])
                changed += 1
    return changed, hidden


def edit_background(root: ET.Element, config: dict) -> int:
    bg = config.get("background", {})
    shape_id = str(bg.get("shape_id", LOGIN_BACKGROUND_SHAPE_ID))
    changed = 0
    stage_w = int(config.get("stage", {}).get("width", STAGE[0]))
    stage_h = int(config.get("stage", {}).get("height", STAGE[1]))
    # Shape 1926 is 850x650 in the original SWF. Place it at stage origin and
    # scale it to the stage. This prevents the old 850x650 origin/offset from
    # producing the half-screen result.
    sx = stage_w / 850.0
    sy = stage_h / 650.0
    for item in all_items(root):
        if item.get("type") == "PlaceObject2Tag" and item.get("characterId") == shape_id:
            set_matrix(item, {"x": 0, "y": 0, "scaleX": sx, "scaleY": sy})
            changed += 1
    return changed


def edit_root_instances(root: ET.Element, config: dict) -> int:
    changed = 0
    hide_ids = {str(value) for value in config.get("root_hide_characters", [])}
    hide_names = set(config.get("root_hide_names", []))
    for item in all_items(root):
        if item.get("type") not in ("PlaceObject2Tag", "PlaceObject3Tag"):
            continue
        if item.get("characterId") in hide_ids or item.get("name") in hide_names:
            set_alpha_zero(item)
            changed += 1
        name = item.get("name")
        if name in config.get("root_instances", {}):
            set_matrix(item, config["root_instances"][name])
            changed += 1
    return changed


def edit_text_fields(root: ET.Element, config: dict) -> int:
    changed = 0
    for character_id, spec in config.get("text_fields", {}).items():
        for item in all_items(root):
            if item.get("type") != "DefineEditTextTag" or item.get("characterID") != str(character_id):
                continue
            bounds = item.find("bounds")
            if bounds is not None:
                if "x" in spec:
                    bounds.set("Xmin", str(round(float(spec["x"]) * TWIPS)))
                if "y" in spec:
                    bounds.set("Ymin", str(round(float(spec["y"]) * TWIPS)))
                if "width" in spec:
                    bounds.set("Xmax", str(round((float(spec.get("x", 0)) + float(spec["width"])) * TWIPS)))
                if "height" in spec:
                    bounds.set("Ymax", str(round((float(spec.get("y", 0)) + float(spec["height"])) * TWIPS)))
            color = item.find("textColor")
            if color is not None and "color" in spec:
                red, green, blue = spec["color"]
                color.set("red", str(red)); color.set("green", str(green)); color.set("blue", str(blue))
            if "fontHeight" in spec:
                item.set("fontHeight", str(round(float(spec["fontHeight"]) * TWIPS)))
            changed += 1
    return changed


def set_external_background(xml_path: Path, image_path: Path, image_id: int) -> None:
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for item in all_items(root):
        if item.get("type") == "DefineBitsJPEG3Tag" and item.get("characterID") == str(image_id):
            item.set("_externalFile", image_path.as_posix())
    tree.write(xml_path, encoding="UTF-8", xml_declaration=True)


def make_working_xml(swf: Path, workdir: Path) -> tuple[Path, Path]:
    xml = workdir / "main.xml"
    export_xml(swf, xml)
    return xml, workdir


def command_inspect(args: argparse.Namespace) -> None:
    swf = Path(args.swf)
    with tempfile.TemporaryDirectory(prefix="ui-inspect-") as temp:
        xml, _ = make_working_xml(swf, Path(temp))
        root = ET.parse(xml).getroot()
        for sprite in find_sprites(root):
            sid = sprite.get("spriteId")
            names = []
            for item in sprite.iter("item"):
                if item.get("type") == "PlaceObject2Tag" and item.get("name"):
                    names.append(f"{item.get('name')}=char:{item.get('characterId')} depth:{item.get('depth')}")
            if sid == str(args.sprite_id) or args.sprite_id is None:
                print(f"sprite {sid}: frameCount={sprite.get('frameCount')}")
                for name in names:
                    print(f"  {name}")


def command_prepare(args: argparse.Namespace) -> None:
    output = Path(args.output)
    prepared = prepare_image(Path(args.image), output, (args.width, args.height), args.fit)
    print(f"Prepared {prepared} ({png_size(Path(args.image))[0]}x{png_size(Path(args.image))[1]} -> {args.width}x{args.height}, fit={args.fit})")


def command_apply(args: argparse.Namespace) -> None:
    source = Path(args.swf)
    output = Path(args.output)
    layout = load_layout(Path(args.layout) if args.layout else None)
    stage = layout.get("stage", {})
    stage_size = (int(stage.get("width", STAGE[0])), int(stage.get("height", STAGE[1])))
    output.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, output)
    target_size = swf_size(source) if args.pad else None

    with tempfile.TemporaryDirectory(prefix="ui-apply-") as temp_name:
        workdir = Path(temp_name)
        xml, _ = make_working_xml(output, workdir)
        root = ET.parse(xml).getroot()
        background_changed = edit_background(root, layout)
        root_changed = edit_root_instances(root, layout)
        text_changed = edit_text_fields(root, layout)
        changed = hidden = 0
        for sprite_config in layout.get("sprites", []):
            count, hidden_count = edit_sprite(root, sprite_config)
            changed += count
            hidden += hidden_count
        ET.ElementTree(root).write(xml, encoding="UTF-8", xml_declaration=True)

        # Keep the external image beside the XML because FFDec resolves the
        # _externalFile path relative to the XML file.
        image = Path(args.background) if args.background else None
        if image:
            prepared = workdir / "main_assets" / "images" / "1925.jpg"
            prepare_image(image, prepared, stage_size, layout.get("background", {}).get("fit", "cover"))
            set_external_background(xml, Path("main_assets/images/1925.jpg"), int(layout.get("background", {}).get("image_id", LOGIN_BACKGROUND_IMAGE_ID)))
        rebuilt_uncompressed = workdir / "rebuilt-uncompressed.swf"
        import_xml(xml, rebuilt_uncompressed)
        rebuilt = workdir / "rebuilt.swf"
        compress_swf(rebuilt_uncompressed, rebuilt)
        shutil.copy2(rebuilt, output)

    # Optional bitmap replacements happen after XML rebuild, so FFDec can use
    # ordinary PNG/JPEG imports without hand-editing XML dependencies.
    replacements = list(args.replace or []) + list(layout.get("replacements", []))
    for replacement in replacements:
        char_id, image_path = replacement.split("=", 1)
        image_file = Path(image_path)
        if not image_file.is_absolute():
            image_file = ROOT / image_file
        temp_out = output.with_suffix(".replace.swf")
        run_ffdec("-replace", str(output), str(temp_out), char_id, str(image_file))
        temp_out.replace(output)
    if target_size is not None:
        pad_swf(output, target_size)
    print(f"Applied layout: background placements={background_changed}, instance transforms={changed}, hidden decorative placements={hidden}")
    print(f"Output: {output} ({swf_size(output):,} bytes)")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    inspect = sub.add_parser("inspect", help="List named instances in a sprite")
    inspect.add_argument("--swf", default=str(ROOT / "source" / "main.swf"))
    inspect.add_argument("--sprite-id", type=int, default=LOGIN_SPRITE_ID)
    inspect.set_defaults(func=command_inspect)

    prepare = sub.add_parser("prepare", help="Fit an image to a target stage size")
    prepare.add_argument("image")
    prepare.add_argument("output")
    prepare.add_argument("--width", type=int, default=STAGE[0])
    prepare.add_argument("--height", type=int, default=STAGE[1])
    prepare.add_argument("--fit", choices=("cover", "contain", "stretch"), default="cover")
    prepare.set_defaults(func=command_prepare)

    apply = sub.add_parser("apply", help="Round-trip XML, edit layout, and optionally replace bitmap characters")
    apply.add_argument("--swf", default=str(ROOT / "source" / "main.swf"), help="Input SWF")
    apply.add_argument("--output", default=str(ROOT / "patches" / "main_client" / "main.swf"))
    apply.add_argument("--layout", help="JSON layout manifest")
    apply.add_argument("--background", help="Full-screen PNG/JPEG")
    apply.add_argument("--replace", action="append", metavar="CHAR_ID=IMAGE", help="Repeatable FFDec bitmap replacement")
    apply.add_argument("--pad", action="store_true", help="Pad output back to input byte size for embedded deployment")
    apply.set_defaults(func=command_apply)
    return parser


if __name__ == "__main__":
    parser = build_parser()
    args = parser.parse_args()
    try:
        args.func(args)
    except (OSError, ET.ParseError, RuntimeError, ValueError) as exc:
        die(str(exc))
