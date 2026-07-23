# Discord login button (`btnFBConnect`)

The connect button artwork is **character 1953** (`DefineBitsJPEG3`) inside `main.swf`.

| Item | Value |
|------|-------|
| On-stage instance | `btnFBConnect` (button char **1955**, sprite **2002** frame 1) |
| Bitmap to replace | **1953** |
| Required size | **174 x 30** px |

## Automated replace

After `Run_Patch_Discord.bat`, run:

```bat
scripts\Run_Replace_Discord_Button.bat
```

Source art: `assets/login/btn_discord_connect.png` (auto-resized from `assets/discord_connect_button.png`).

## FFDec GUI (manual)

1. Open `patches/main_client/main.swf` in FFDec.
2. Go to **character 1953** (or sprite **2002** → frame 1 → `btnFBConnect` → edit the bitmap fill).
3. Replace the image with your Discord art at **174x30**.
4. Save. If embedded deploy complains about size, re-run `Run_Replace_Discord_Button.bat` (pads to match `source/main.swf`).

Legacy symbol names (`btnFBConnect`, `fbGetToken`) are unchanged so the Director `fbgettoken` bridge keeps working.
