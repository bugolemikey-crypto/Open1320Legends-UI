# Noob Guide: Replacing the Header Logo with FFDec CLI

This walks through swapping the game's header logo (Character ID **2039**) using
`ffdec-cli.exe` directly, no browser tool needed. Everything here is copy/paste
into a terminal (PowerShell or Command Prompt).

## Why this is fiddly

The game's Flash content isn't a standalone `.swf` file — it's embedded *inside*
`NittoLegendsBeta.exe` at a fixed byte position. FFDec can't edit an exe
directly, so every edit is really three steps:

1. Cut the SWF out of the exe
2. Edit it with FFDec
3. Paste it back into a copy of the exe at the exact same spot

The exe has a fixed amount of room for the SWF. If the edited SWF comes out
**larger** than the original, splicing it back in breaks the game (you'll see
a "Director Player Error — Script Error" dialog on launch). So the golden rule
is: **the new logo file must be small enough that the rebuilt SWF is the same
size or smaller than the original.**

## One-time setup check

Confirm FFDec is where the project expects it:

```
"C:\Program Files (x86)\FFDec\ffdec-cli.exe" -help
```

If that doesn't run, FFDec isn't installed at that path — check
`Open1320Legends-UI\config.json` for the real path.

## Step 1 — Back up the exe

Never skip this.

```powershell
cd "C:\Users\hunte\Downloads\Open1320Legends"
copy NittoLegendsBeta.exe NittoLegendsBeta.exe.bak-before-logo
```

## Step 2 — Extract the embedded SWF

The embed offset for this project is **4794808** (from `config.json`). Run this
PowerShell snippet to cut the SWF out:

```powershell
$offset = 4794808
$exePath = "C:\Users\hunte\Downloads\Open1320Legends\NittoLegendsBeta.exe"
$outPath = "C:\Users\hunte\Downloads\Open1320Legends-UI\cache\working.swf"

$bytes = [System.IO.File]::ReadAllBytes($exePath)
$headerLen = [BitConverter]::ToUInt32($bytes, $offset + 4)
$swfBytes = New-Object byte[] $headerLen
[Array]::Copy($bytes, $offset, $swfBytes, 0, $headerLen)
[System.IO.File]::WriteAllBytes($outPath, $swfBytes)
Write-Host "Extracted $($swfBytes.Length) bytes to $outPath"
```

This should print a size around **29,833,513 bytes** (write this number down —
it's your budget for Step 4).

## Step 3 — Prepare your new logo image

FFDec's `-replace` command needs a plain image file (JPEG or PNG), not an SWF.

The current logo character (2039) is stored as **JPEG3**, which does *not*
support transparency — it'll be an opaque rectangle. If your logo has a
transparent background (most PNGs do), flatten it onto black first so it
blends into the dark header:

```powershell
# Requires Python + Pillow (pip install pillow --break-system-packages)
python -c "
from PIL import Image
im = Image.open('C:/Users/hunte/Downloads/Open1320Legends-UI/1320-legends-logo-smaller.png').convert('RGBA')
bg = Image.new('RGB', im.size, (0,0,0))
bg.paste(im, mask=im.getchannel('A'))
bg.save('C:/Users/hunte/Downloads/Open1320Legends-UI/cache/new_logo.jpg', 'JPEG', quality=48, optimize=True)
"
```

Quality 48 was the value that got this specific logo comfortably under budget
last time (~9KB). If your image is different, adjust quality up/down and check
the resulting file size — smaller number = smaller file.

## Step 4 — Replace character 2039 in the extracted SWF

```powershell
& "C:\Program Files (x86)\FFDec\ffdec-cli.exe" -replace `
  "C:\Users\hunte\Downloads\Open1320Legends-UI\cache\working.swf" `
  "C:\Users\hunte\Downloads\Open1320Legends-UI\cache\working_new.swf" `
  2039 `
  "C:\Users\hunte\Downloads\Open1320Legends-UI\cache\new_logo.jpg" `
  jpeg3
```

Then check the new file's size:

```powershell
(Get-Item "C:\Users\hunte\Downloads\Open1320Legends-UI\cache\working_new.swf").Length
```

**Compare this number to the original size from Step 2.**

- If it's **the same or smaller** → skip to Step 5a.
- If it's **larger** → go to Step 5b (padding won't help here, you need a
  smaller image — lower the JPEG quality and redo Step 3–4).

## Step 5a — Same size or smaller: pad to match exactly

FFDec's output needs to be padded with zero bytes until it's *exactly* the
original size, and the SWF header's declared length needs to match too:

```powershell
$targetSize = 29833513  # <-- use YOUR number from Step 2
$path = "C:\Users\hunte\Downloads\Open1320Legends-UI\cache\working_new.swf"

$bytes = [System.IO.File]::ReadAllBytes($path)
if ($bytes.Length -lt $targetSize) {
    $lenBytes = [BitConverter]::GetBytes([UInt32]$targetSize)
    [Array]::Copy($lenBytes, 0, $bytes, 4, 4)
    $padding = New-Object byte[] ($targetSize - $bytes.Length)
    $newBytes = $bytes + $padding
    [System.IO.File]::WriteAllBytes($path, $newBytes)
    Write-Host "Padded to $($newBytes.Length) bytes"
} else {
    Write-Host "Already exact size, no padding needed"
}
```

## Step 5b — Came out larger: do NOT deploy

Do not try to splice a larger SWF back in — this is what caused the Director
script error earlier. Go back to Step 3, lower the JPEG quality number (try
40, then 30, etc.), and redo Steps 3–5 until the file is at or under budget.

## Step 6 — Splice the SWF back into the exe

Close the game first if it's running (the exe file can't be written to while
it's open).

```powershell
$offset = 4794808
$exePath = "C:\Users\hunte\Downloads\Open1320Legends\NittoLegendsBeta.exe"
$patchPath = "C:\Users\hunte\Downloads\Open1320Legends-UI\cache\working_new.swf"

$exeBytes = [System.IO.File]::ReadAllBytes($exePath)
$patchBytes = [System.IO.File]::ReadAllBytes($patchPath)
$trailer = $exeBytes[($exeBytes.Length - 4)..($exeBytes.Length - 1)]

$newExe = New-Object byte[] ($offset + $patchBytes.Length + 4)
[Array]::Copy($exeBytes, 0, $newExe, 0, $offset)
[Array]::Copy($patchBytes, 0, $newExe, $offset, $patchBytes.Length)
[Array]::Copy($trailer, 0, $newExe, $offset + $patchBytes.Length, 4)

if ($newExe.Length -ne $exeBytes.Length) {
    Write-Warning "Total exe size changed! Original: $($exeBytes.Length), New: $($newExe.Length). This should NOT happen if you padded correctly in Step 5a."
} else {
    [System.IO.File]::WriteAllBytes($exePath, $newExe)
    Write-Host "Deployed. Exe size unchanged: $($newExe.Length) bytes"
}
```

The script warns you instead of writing if the size doesn't match — that's a
safety check, not a bug.

## Step 7 — Test it

Launch `NittoLegendsBeta.exe` and check the login screen. If you see the
"Director Player Error — Script Error" dialog, click **No**, close the game,
and restore your backup:

```powershell
copy NittoLegendsBeta.exe.bak-before-logo NittoLegendsBeta.exe /Y
```

Then go back to Step 3 and use a lower JPEG quality to shrink the file further.

## Quick reference

| Thing | Value |
|---|---|
| Embed offset | 4794808 |
| Logo character ID | 2039 |
| Logo format | jpeg3 |
| Original SWF size (this project, tonight) | 29,833,513 bytes |
| Trailer size | 4 bytes (leave untouched) |
