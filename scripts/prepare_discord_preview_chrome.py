from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
PREPARED = ROOT / "assets" / "login" / "prepared"
CONCEPT = ROOT / "assets" / "header" / "header_concept_v1.png"

STAGE_SIZE = (800, 600)
BITMAP_SIZE = (850, 650)
STAGE_OFFSET = (18, 14)
CHROME_HEIGHT = 90


def save_jpeg_to_budget(image: Image.Image, output: Path, budget: int = 30500) -> None:
    low, high, best = 4, 95, None
    while low <= high:
        quality = (low + high) // 2
        image.save(output, "JPEG", quality=quality, optimize=True, progressive=False, subsampling=0)
        if output.stat().st_size <= budget:
            best = quality
            low = quality + 1
        else:
            high = quality - 1
    if best is None:
        best = 1
    image.save(output, "JPEG", quality=best, optimize=True, progressive=False, subsampling=0)
    if output.stat().st_size > budget:
        raise RuntimeError(f"Could not fit {output} below {budget} bytes")


def main() -> None:
    stage_path = PREPARED / "login_stage_800x600.png"
    bitmap_preview_path = PREPARED / "login_bitmap_850x650_preview.png"
    bitmap_jpeg_path = PREPARED / "login_bitmap_850x650.jpg"

    stage = Image.open(stage_path).convert("RGB")
    concept = Image.open(CONCEPT).convert("RGB")

    # The concept's chrome is the middle band; compress it into the login stage
    # while leaving the existing login panel and its controls untouched.
    chrome = concept.crop((0, 195, concept.width, 467)).resize(
        (STAGE_SIZE[0], CHROME_HEIGHT), Image.Resampling.LANCZOS
    )
    stage.paste(chrome, (0, 0))
    stage.save(stage_path, "PNG", optimize=True)

    bitmap = Image.new("RGB", BITMAP_SIZE, (0, 0, 0))
    bitmap.paste(stage, STAGE_OFFSET)
    bitmap.save(bitmap_preview_path, "PNG", optimize=True)
    save_jpeg_to_budget(bitmap, bitmap_jpeg_path)

    print(f"updated {stage_path}")
    print(f"updated {bitmap_preview_path}")
    print(f"updated {bitmap_jpeg_path} ({bitmap_jpeg_path.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
