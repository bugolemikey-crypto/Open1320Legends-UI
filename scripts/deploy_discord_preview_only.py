from pathlib import Path
import shutil
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

from swf_utils import replace_image
from ui_editor import pad_swf


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source" / "main.swf"
PATCH = ROOT / "patches" / "main_client" / "main.swf"
ASSET = ROOT / "assets" / "login" / "prepared" / "login_bitmap_850x650.jpg"
TEMP = ROOT / "patches" / "main_client" / "main.preview-only.swf"


def main() -> None:
    replace_image(PATCH, TEMP, 1925, ASSET)
    if TEMP.stat().st_size < SOURCE.stat().st_size:
        pad_swf(TEMP, SOURCE.stat().st_size)
    if TEMP.stat().st_size != SOURCE.stat().st_size:
        raise RuntimeError("preview-only SWF size does not match source allocation")
    shutil.move(TEMP, PATCH)
    print(f"updated {PATCH} ({PATCH.stat().st_size:,} bytes)")


if __name__ == "__main__":
    main()
