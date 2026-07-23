"""Render compact telemetry-styled artwork for the existing live header tabs."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from swf_utils import ROOT

OUT = ROOT / "assets" / "header" / "prepared"


def font(size: int):
    try:
        return ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", size)
    except OSError:
        return ImageFont.load_default()


def tab(size: tuple[int, int], label: str, active: bool = False) -> Image.Image:
    width, height = size
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    fill = (18, 20, 23, 245) if not active else (62, 12, 14, 250)
    draw.rounded_rectangle((0, 1, width - 1, height - 1), radius=3, fill=fill, outline=(84, 87, 93, 235))
    draw.line((3, height - 2, width - 4, height - 2), fill=(191, 24, 29, 255), width=1)
    if active:
        draw.line((3, 2, width - 4, 2), fill=(240, 45, 50, 220), width=1)
    draw.text((height - 3, max(1, (height - 10) // 2)), label, font=font(max(8, height - 12)), fill=(238, 239, 241))
    return image


def save(name: str, image: Image.Image) -> None:
    image.save(OUT / name, "PNG", optimize=True)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    save("toolbar_nim_67x24.png", tab((67, 24), "NIM"))
    save("toolbar_nim_active_67x24.png", tab((67, 24), "NIM", active=True))
    save("toolbar_viewer_86x22.png", tab((86, 22), "VIEWER"))
    save("toolbar_email_80x22.png", tab((80, 22), "EMAIL"))
    save("toolbar_tab_end_37x18.png", tab((37, 18), ""))
    save("toolbar_support_left_46x12.png", tab((46, 12), ""))
    icon = Image.new("RGBA", (18, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(icon)
    draw.polygon([(9, 1), (17, 15), (1, 15)], fill=(202, 31, 36), outline=(246, 226, 228))
    draw.text((7, 3), "!", font=font(9), fill=(255, 255, 255))
    save("toolbar_support_icon_18x16.png", icon)
    save("toolbar_support_113x19.png", tab((113, 19), "SUPPORT"))


if __name__ == "__main__":
    main()
