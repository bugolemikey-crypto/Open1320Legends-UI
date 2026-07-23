"""Restyle the original city map without changing any geometry or pixels."""
from __future__ import annotations

import argparse
import colorsys
from pathlib import Path

from PIL import Image, ImageEnhance, ImageFilter


def restyle(source: Path, output: Path, quality: int) -> None:
    with Image.open(source) as opened:
        original = opened.convert("RGB")

    pixels = []
    red_mask = Image.new("L", original.size, 0)
    mask_pixels = []

    for red, green, blue in original.getdata():
        hue, saturation, value = colorsys.rgb_to_hsv(red / 255, green / 255, blue / 255)
        luminance = int(0.2126 * red + 0.7152 * green + 0.0722 * blue)

        # Preserve district label shapes but move them into the new warm-white palette.
        if 0.10 <= hue <= 0.20 and saturation > 0.28 and value > 0.35:
            strength = max(150, min(255, int(value * 275)))
            pixels.append((strength, max(125, strength - 18), max(105, strength - 45)))
            mask_pixels.append(0)
            continue

        # Convert only the legacy cyan coastline bloom to the restrained red accent.
        cyan = 0.47 <= hue <= 0.64 and saturation > 0.70 and value > 0.08
        if cyan:
            glow = max(20, min(255, int(value * 230)))
            pixels.append((glow, int(glow * 0.16), int(glow * 0.12)))
            mask_pixels.append(min(255, int(value * saturation * 400)))
            continue

        # Neutral graphite grade. Luminance is preserved, so roads, coastlines,
        # grid alignment, labels, and every clickable landmark stay pixel-exact.
        graphite = max(0, min(255, int(luminance * 0.82)))
        pixels.append((graphite, graphite, min(255, int(graphite * 1.03))))
        mask_pixels.append(0)

    styled = Image.new("RGB", original.size)
    styled.putdata(pixels)
    red_mask.putdata(mask_pixels)

    # A tiny bloom on the transformed coastline, confined to the existing glow.
    bloom = Image.new("RGB", original.size, (120, 8, 5))
    blurred_mask = red_mask.filter(ImageFilter.GaussianBlur(2.2))
    styled = Image.composite(bloom, styled, blurred_mask.point(lambda px: int(px * 0.22)))
    styled = ImageEnhance.Contrast(styled).enhance(1.08)

    output.parent.mkdir(parents=True, exist_ok=True)
    styled.save(output, "JPEG", quality=quality, optimize=True, progressive=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--quality", type=int, default=76)
    args = parser.parse_args()
    restyle(args.source, args.output, args.quality)


if __name__ == "__main__":
    main()
