"""Extract reusable UI elements from the approved telemetry login concept."""
from __future__ import annotations

import json
from pathlib import Path

import cv2
import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "login" / "login_telemetry_exact_cars_v2.png"
LOGO = ROOT / "1320-legends-logo-smaller.png"
OUTPUT = ROOT / "assets" / "telemetry_ui_v2" / "elements"

# Pixel coordinates in the 1600x976 approved source concept.
CROPS: dict[str, tuple[int, int, int, int]] = {
    "01_header_complete": (8, 33, 1599, 238),
    "02_header_logo_from_concept": (145, 48, 735, 221),
    "03_support_control": (1345, 105, 1535, 165),
    "04_car_hero_complete": (0, 238, 1600, 660),
    "05_login_console_complete": (27, 659, 1583, 931),
    "06_console_left_section": (28, 660, 520, 930),
    "07_console_center_section": (520, 660, 846, 930),
    "08_console_right_section": (846, 660, 1582, 930),
    "09_button_discord": (63, 775, 476, 864),
    "10_button_create_account": (546, 775, 815, 864),
    "11_button_login": (881, 789, 1537, 869),
    "12_field_racer_name": (1067, 677, 1538, 724),
    "13_field_password": (1067, 732, 1538, 779),
    "14_console_divider_left": (510, 665, 530, 923),
    "15_console_divider_right": (835, 665, 855, 923),
    "16_red_edge_trim": (31, 652, 1579, 674),
    "17_panel_texture_sample": (1218, 180, 1314, 220),
}


def _blank_panel(source: Image.Image, inset: tuple[int, int, int, int]) -> Image.Image:
    """Keep the approved perimeter while clearing embedded labels and controls."""
    panel = source.copy().convert("RGBA")
    left, top, right, bottom = inset
    pixels = panel.load()
    height = max(1, bottom - top)
    for y in range(top, bottom):
        # Very subtle vertical smoked-glass lift; no baked-in content.
        lift = round(8 * (1.0 - abs(((y - top) / height) - 0.35)))
        value = max(7, 12 + lift)
        for x in range(left, right):
            pixels[x, y] = (value, value + 1, value + 2, 255)
    return panel


def _extract_car(
    hero: Image.Image,
    name: str,
    probable_polygon: list[tuple[int, int]],
    definite_polygon: list[tuple[int, int]],
    crop_box: tuple[int, int, int, int],
) -> tuple[Image.Image, Image.Image]:
    """Separate the visible silhouette while retaining exact approved pixels."""
    rgba = np.array(hero.convert("RGBA"))
    alpha = np.zeros(rgba.shape[:2], dtype=np.uint8)
    cv2.fillPoly(alpha, [np.array(probable_polygon, dtype=np.int32)], 255)
    alpha = cv2.GaussianBlur(alpha, (3, 3), 0)
    isolated = rgba.copy()
    isolated[:, :, 3] = alpha
    car = Image.fromarray(isolated, "RGBA").crop(crop_box)
    car_mask = Image.fromarray(alpha, "L").crop(crop_box)
    car.save(OUTPUT / f"{name}.png", "PNG", optimize=True)
    car_mask.save(OUTPUT / f"{name}_mask.png", "PNG", optimize=True)
    return car, car_mask


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    image = Image.open(SOURCE).convert("RGBA")
    manifest: dict[str, object] = {
        "source": str(SOURCE.relative_to(ROOT)),
        "source_size": list(image.size),
        "elements": {},
    }

    for name, box in CROPS.items():
        element = image.crop(box)
        path = OUTPUT / f"{name}.png"
        element.save(path, "PNG", optimize=True)
        manifest["elements"][name] = {
            "file": path.name,
            "source_box": list(box),
            "size": list(element.size),
        }

    header = image.crop(CROPS["01_header_complete"])
    header_blank = _blank_panel(header, (30, 18, header.width - 30, header.height - 18))
    header_blank_path = OUTPUT / "18_header_shell_blank.png"
    header_blank.save(header_blank_path, "PNG", optimize=True)
    manifest["elements"]["18_header_shell_blank"] = {
        "file": header_blank_path.name,
        "size": list(header_blank.size),
        "notes": "Approved perimeter with an empty smoked-glass content area.",
    }

    console = image.crop(CROPS["05_login_console_complete"])
    console_blank = _blank_panel(console, (18, 14, console.width - 18, console.height - 16))
    console_blank_path = OUTPUT / "19_console_shell_blank.png"
    console_blank.save(console_blank_path, "PNG", optimize=True)
    manifest["elements"]["19_console_shell_blank"] = {
        "file": console_blank_path.name,
        "size": list(console_blank.size),
        "notes": "Approved perimeter with empty content area for other screens.",
    }

    hero = image.crop(CROPS["04_car_hero_complete"])
    car_specs = {
        "20_car_left_alpha": (
            [(40, 208), (48, 164), (65, 116), (174, 73), (192, 63), (194, 48), (223, 46), (265, 39), (294, 39), (320, 25), (355, 20), (462, 20), (499, 31), (532, 49), (564, 74), (579, 96), (566, 117), (532, 144), (505, 183), (499, 224), (478, 256), (430, 282), (350, 286), (277, 277), (205, 260), (132, 246), (72, 225)],
            [],
            (20, 12, 625, 330),
        ),
        "21_car_center_alpha": (
            [(492, 245), (500, 183), (523, 124), (590, 89), (650, 57), (690, 38), (775, 28), (856, 25), (905, 30), (1012, 24), (1061, 31), (1083, 42), (1092, 30), (1103, 32), (1104, 70), (1122, 76), (1111, 118), (1086, 148), (1050, 186), (1014, 224), (984, 272), (934, 303), (862, 324), (766, 329), (684, 316), (603, 292), (536, 274)],
            [],
            (465, 10, 1145, 360),
        ),
        "22_car_right_alpha": (
            [(876, 319), (887, 254), (911, 190), (941, 145), (1022, 119), (1096, 103), (1176, 72), (1239, 62), (1442, 64), (1502, 76), (1534, 97), (1570, 105), (1599, 124), (1599, 326), (1572, 343), (1502, 366), (1450, 394), (1371, 415), (1190, 419), (1089, 405), (1005, 377), (936, 352)],
            [],
            (850, 45, 1600, 422),
        ),
    }
    for car_name, (probable, definite, box) in car_specs.items():
        car, car_mask = _extract_car(hero, car_name, probable, definite, box)
        manifest["elements"][car_name] = {
            "file": f"{car_name}.png",
            "mask": f"{car_name}_mask.png",
            "size": list(car.size),
            "notes": "Exact approved pixels; alpha separated with a reusable mask.",
        }

    logo = Image.open(LOGO).convert("RGBA")
    logo_path = OUTPUT / "00_logo_repository_original.png"
    logo.save(logo_path, "PNG", optimize=True)
    manifest["elements"]["00_logo_repository_original"] = {
        "file": logo_path.name,
        "source": str(LOGO.relative_to(ROOT)),
        "size": list(logo.size),
    }

    # A half-size set is convenient when placing assets onto the 800 px game stage.
    stage_dir = OUTPUT / "stage_800"
    stage_dir.mkdir(exist_ok=True)
    for path in OUTPUT.glob("*.png"):
        element = Image.open(path).convert("RGBA")
        size = (max(1, round(element.width / 2)), max(1, round(element.height / 2)))
        element.resize(size, Image.Resampling.LANCZOS).save(
            stage_dir / path.name, "PNG", optimize=True
        )

    manifest_path = OUTPUT / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Extracted {len(manifest['elements'])} elements to {OUTPUT}")


if __name__ == "__main__":
    main()
