"""Crop button art from login.png and replace chars in main.swf."""
from __future__ import annotations

from pathlib import Path
from PIL import Image

from swf_utils import ROOT

LOGIN_PNG = Path(r"C:\Users\hunte\OneDrive\Pictures\login.png")
ASSETS = ROOT / "assets" / "login"

img = Image.open(LOGIN_PNG)
w, h = img.size
print(f"login.png size: {w}x{h}")

# Bottom panel starts at ~y=555 in the 1570x958 image
# From the debug panel image (1570x403, starting at y=555):
# The panel area with buttons is roughly y=600-900 in original coords
#
# "Login with Discord" blue button: 
#   In the panel, it's at roughly x=75-430, y=750-830 in original
#
# "CREATE ACCOUNT" gold button:
#   In the panel, roughly x=545-780, y=750-830 in original
#
# "LOGIN" big red button:
#   In the panel, roughly x=880-1460, y=740-835 in original

crops = {
    "btn_discord": (75, 745, 435, 840),     # Login with Discord (blue)
    "btn_create": (540, 745, 790, 840),      # CREATE ACCOUNT (gold)
    "btn_login": (875, 735, 1465, 840),      # LOGIN (big red)
}

for name, box in crops.items():
    cropped = img.crop(box)
    out = ASSETS / f"{name}.png"
    cropped.save(out)
    print(f"{name}: {cropped.size[0]}x{cropped.size[1]} -> {out}")
