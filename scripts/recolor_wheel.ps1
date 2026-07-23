<#
.SYNOPSIS
    Rainbow-anodize (neochrome) wheel SWFs for Open 1320 Legends.

.DESCRIPTION
    Exports every embedded PNG frame from a wheel SWF via JPEXS FFDec,
    applies a radial rainbow HSL recolor with per-frame hue rotation,
    then re-injects the recolored PNGs back into the SWF.

    The result is a local cache replacement that makes a wheel look
    like it has rainbow anodized spokes that visibly rotate with the
    wheel spin animation.

.PARAMETER WheelId
    Numeric wheel ID to recolor (e.g. 90).

.PARAMETER SourceDir
    Folder containing the original wheel SWF files.
    Expected files: wheelR_<id>.swf, wheelFR_<id>.swf, wheelFF_<id>.swf,
                    wheelBF_<id>.swf, wheelBR_<id>.swf

.PARAMETER OutputDir
    Folder where recolored SWFs will be written. Defaults to <SourceDir>\rainbow.

.PARAMETER FfDecPath
    Path to ffdec-cli.exe. Defaults to standard install location.

.PARAMETER Saturation
    HSL saturation for the rainbow overlay (0.0-1.0). Default 0.85.

.EXAMPLE
    .\recolor_wheel.ps1 -WheelId 90 -SourceDir "C:\game\cache\car\wheel"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [int]$WheelId,

    [Parameter(Mandatory = $true)]
    [string]$SourceDir,

    [Parameter(Mandatory = $false)]
    [string]$OutputDir,

    [Parameter(Mandatory = $false)]
    [string]$FfDecPath = "C:\Program Files (x86)\FFDec\ffdec-cli.exe",

    [Parameter(Mandatory = $false)]
    [double]$Saturation = 0.85
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Validate prerequisites
# ---------------------------------------------------------------------------

if (-not (Test-Path $FfDecPath)) {
    Write-Error "FFDec CLI not found at '$FfDecPath'. Install JPEXS Free Flash Decompiler or pass -FfDecPath."
    return
}

if (-not (Test-Path $SourceDir)) {
    Write-Error "Source directory not found: '$SourceDir'"
    return
}

if (-not $OutputDir) {
    $OutputDir = Join-Path $SourceDir "rainbow"
}

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Load System.Drawing for bitmap manipulation
Add-Type -AssemblyName System.Drawing

# ---------------------------------------------------------------------------
# HSL <-> RGB conversion helpers
# ---------------------------------------------------------------------------

function Convert-HslToRgb {
    param([double]$H, [double]$S, [double]$L)

    if ($S -eq 0.0) {
        $v = [int][Math]::Round($L * 255)
        return @($v, $v, $v)
    }

    $q = if ($L -lt 0.5) { $L * (1.0 + $S) } else { $L + $S - ($L * $S) }
    $p = 2.0 * $L - $q

    function HueToChannel($p, $q, $t) {
        if ($t -lt 0) { $t += 1.0 }
        if ($t -gt 1) { $t -= 1.0 }
        if ($t -lt 1.0/6.0) { return $p + ($q - $p) * 6.0 * $t }
        if ($t -lt 0.5)     { return $q }
        if ($t -lt 2.0/3.0) { return $p + ($q - $p) * (2.0/3.0 - $t) * 6.0 }
        return $p
    }

    $r = [int][Math]::Round((HueToChannel $p $q ($H + 1.0/3.0)) * 255)
    $g = [int][Math]::Round((HueToChannel $p $q $H) * 255)
    $b = [int][Math]::Round((HueToChannel $p $q ($H - 1.0/3.0)) * 255)

    # Clamp
    $r = [Math]::Max(0, [Math]::Min(255, $r))
    $g = [Math]::Max(0, [Math]::Min(255, $g))
    $b = [Math]::Max(0, [Math]::Min(255, $b))

    return @($r, $g, $b)
}

# ---------------------------------------------------------------------------
# Core recolor function: radial rainbow with per-frame hue offset
# ---------------------------------------------------------------------------

function Invoke-RainbowRecolor {
    param(
        [string]$PngPath,
        [int]$FrameIndex,
        [int]$TotalFrames,
        [double]$Sat
    )

    # Load via MemoryStream to avoid file lock, convert indexed formats
    $bytes = [System.IO.File]::ReadAllBytes($PngPath)
    $ms = New-Object System.IO.MemoryStream(,$bytes)
    $bmp = [System.Drawing.Bitmap]::new($ms)
    if ($bmp.PixelFormat -ne [System.Drawing.Imaging.PixelFormat]::Format32bppArgb) {
        $newBmp = New-Object System.Drawing.Bitmap($bmp.Width, $bmp.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $g2 = [System.Drawing.Graphics]::FromImage($newBmp)
        $g2.DrawImage($bmp, 0, 0, $bmp.Width, $bmp.Height)
        $g2.Dispose()
        $bmp.Dispose()
        $bmp = $newBmp
    }
    $width = $bmp.Width
    $height = $bmp.Height
    $cx = $width / 2.0
    $cy = $height / 2.0

    # Per-frame hue offset so the rainbow rotates with the wheel spin
    $frameOffset = $FrameIndex / [Math]::Max(1, $TotalFrames)

    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $pixel = $bmp.GetPixel($x, $y)

            # Skip fully transparent pixels
            if ($pixel.A -eq 0) { continue }

            # Compute luminance from original RGB (preserves shading/highlights)
            $lum = (0.299 * $pixel.R + 0.587 * $pixel.G + 0.114 * $pixel.B) / 255.0

            # Radial hue: angle from center mapped to 0-1
            $dx = $x - $cx
            $dy = $y - $cy
            $angle = [Math]::Atan2($dy, $dx)                # -pi to pi
            $hue = ($angle + [Math]::PI) / (2.0 * [Math]::PI)  # 0 to 1

            # Apply per-frame rotation offset
            $hue = ($hue + $frameOffset) % 1.0

            # Convert HSL back to RGB
            $rgb = Convert-HslToRgb -H $hue -S $Sat -L $lum

            $newColor = [System.Drawing.Color]::FromArgb($pixel.A, $rgb[0], $rgb[1], $rgb[2])
            $bmp.SetPixel($x, $y, $newColor)
        }
    }

    # Overwrite in place
    $bmp.Save($PngPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $ms.Dispose()
}

# ---------------------------------------------------------------------------
# Process a single SWF file
# ---------------------------------------------------------------------------

function Process-WheelSwf {
    param(
        [string]$SwfPath,
        [string]$OutSwfPath,
        [double]$Sat
    )

    $swfName = [System.IO.Path]::GetFileNameWithoutExtension($SwfPath)
    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "recolor_${swfName}_$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    try {
        Write-Host "  Exporting images from $swfName..." -ForegroundColor Cyan

        # Export all images from the SWF
        & $FfDecPath -export image $tempDir $SwfPath 2>&1 | Out-Null

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "FFDec export failed for $SwfPath (exit code $LASTEXITCODE)"
            return
        }

        # Collect exported PNGs sorted by character ID (numeric filename order)
        $pngs = @(Get-ChildItem -Path $tempDir -Filter "*.png" -Recurse |
                 Sort-Object { [int]($_.BaseName -replace '[^\d]', '') })

        $totalFrames = $pngs.Count
        Write-Host "  Found $totalFrames frame(s). Applying rainbow recolor..." -ForegroundColor Cyan

        # Recolor each frame
        for ($i = 0; $i -lt $pngs.Count; $i++) {
            $png = $pngs[$i]
            Invoke-RainbowRecolor -PngPath $png.FullName -FrameIndex $i -TotalFrames $totalFrames -Sat $Sat

            # Progress indicator every 12 frames
            if (($i + 1) % 12 -eq 0 -or $i -eq $pngs.Count - 1) {
                Write-Host "    Recolored $($i + 1)/$totalFrames" -ForegroundColor DarkGray
            }
        }

        # Copy original SWF to output location, then replace images in-place
        Copy-Item -Path $SwfPath -Destination $OutSwfPath -Force

        Write-Host "  Re-injecting images into SWF..." -ForegroundColor Cyan

        foreach ($png in $pngs) {
            # Extract the character ID from the filename (e.g. "42.png" -> 42)
            $charId = $png.BaseName -replace '[^\d]', ''

            & $FfDecPath -replace $OutSwfPath $OutSwfPath $charId $png.FullName 2>&1 | Out-Null

            if ($LASTEXITCODE -ne 0) {
                Write-Warning "FFDec replace failed for char $charId in $swfName"
            }
        }

        Write-Host "  Done: $OutSwfPath" -ForegroundColor Green
    }
    finally {
        # Clean up temp directory
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ---------------------------------------------------------------------------
# Main: process all 5 wheel view SWFs
# ---------------------------------------------------------------------------

$prefixes = @("wheelR", "wheelFR", "wheelFF", "wheelBF", "wheelBR")

Write-Host "`nRainbow Wheel Recolor Tool" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow
Write-Host "Wheel ID  : $WheelId"
Write-Host "Source    : $SourceDir"
Write-Host "Output    : $OutputDir"
Write-Host "Saturation: $Saturation"
Write-Host ""

$processedCount = 0

foreach ($prefix in $prefixes) {
    $swfName = "${prefix}_${WheelId}.swf"
    $swfPath = Join-Path $SourceDir $swfName

    if (-not (Test-Path $swfPath)) {
        Write-Host "  Skipping $swfName (not found)" -ForegroundColor DarkYellow
        continue
    }

    Write-Host "Processing $swfName..." -ForegroundColor White
    $outPath = Join-Path $OutputDir $swfName

    Process-WheelSwf -SwfPath $swfPath -OutSwfPath $outPath -Sat $Saturation
    $processedCount++
}

Write-Host "`nComplete! Processed $processedCount SWF(s)." -ForegroundColor Green
Write-Host "Drop the files from '$OutputDir' into your cache/car/wheel/ folder to use them." -ForegroundColor Gray
