<#
.SYNOPSIS
    Wheel Studio v2 - Open-source rim editor for 1320 Legends
.DESCRIPTION
    Full photoshop-style wheel editor with live cache editing.
    - Browse all 156 wheels from the game cache
    - Paint tools: Brush, Eraser, Fill, Eyedropper
    - Effects: Rainbow, Carbon Fiber, Glow, Chrome, Tint, Brushed Metal, Gold, Burnt Titanium
    - Layer system with opacity
    - Live push: edit and instantly replace in cache (no restart needed for cached assets)
    - Export to PNG or SWF
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

$script:CACHE_DIR = "C:\Users\hunte\Downloads\Open1320Legends\cache\car\wheel"
$script:FFDEC_PATH = "C:\Program Files (x86)\FFDec\ffdec-cli.exe"
$script:BACKUP_DIR = Join-Path $script:CACHE_DIR "_backups"

# ---------------------------------------------------------------------------
# Bitmap format helper — converts indexed/read-only bitmaps to 32bppArgb
# ---------------------------------------------------------------------------

function Convert-To32bppArgb {
    param([System.Drawing.Bitmap]$Bmp)
    # Always create a fresh 32bppArgb copy to avoid GDI+ errors from indexed
    # formats, premultiplied alpha, or bitmaps still attached to a stream.
    $newBmp = New-Object System.Drawing.Bitmap($Bmp.Width, $Bmp.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $gfx = [System.Drawing.Graphics]::FromImage($newBmp)
    $gfx.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $gfx.DrawImage($Bmp, 0, 0, $Bmp.Width, $Bmp.Height)
    $gfx.Dispose()
    $Bmp.Dispose()
    return $newBmp
}

# ---------------------------------------------------------------------------
# Color helpers
# ---------------------------------------------------------------------------

function Convert-HslToRgb {
    param([double]$H, [double]$S, [double]$L)
    if ($S -eq 0.0) {
        $v = [int][Math]::Round($L * 255)
        return @($v, $v, $v)
    }
    $q = if ($L -lt 0.5) { $L * (1.0 + $S) } else { $L + $S - ($L * $S) }
    $p = 2.0 * $L - $q
    function HueToChannel($pp, $qq, $t) {
        if ($t -lt 0) { $t += 1.0 }
        if ($t -gt 1) { $t -= 1.0 }
        if ($t -lt 1.0/6.0) { return $pp + ($qq - $pp) * 6.0 * $t }
        if ($t -lt 0.5)     { return $qq }
        if ($t -lt 2.0/3.0) { return $pp + ($qq - $pp) * (2.0/3.0 - $t) * 6.0 }
        return $pp
    }
    $r = [int][Math]::Round((HueToChannel $p $q ($H + 1.0/3.0)) * 255)
    $g = [int][Math]::Round((HueToChannel $p $q $H) * 255)
    $b = [int][Math]::Round((HueToChannel $p $q ($H - 1.0/3.0)) * 255)
    return @([Math]::Max(0,[Math]::Min(255,$r)), [Math]::Max(0,[Math]::Min(255,$g)), [Math]::Max(0,[Math]::Min(255,$b)))
}

# ---------------------------------------------------------------------------
# Effects library
# ---------------------------------------------------------------------------

function Apply-RainbowAnodize {
    param([System.Drawing.Bitmap]$Bmp, [double]$Sat = 0.85, [double]$HueOffset = 0.0)
    $w = $Bmp.Width; $h = $Bmp.Height; $cx = $w/2.0; $cy = $h/2.0
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $px = $Bmp.GetPixel($x, $y)
            if ($px.A -eq 0) { continue }
            $lum = (0.299*$px.R + 0.587*$px.G + 0.114*$px.B)/255.0
            $hue = (([Math]::Atan2(($y-$cy),($x-$cx)) + [Math]::PI)/(2.0*[Math]::PI) + $HueOffset) % 1.0
            $rgb = Convert-HslToRgb -H $hue -S $Sat -L $lum
            $Bmp.SetPixel($x,$y,[System.Drawing.Color]::FromArgb($px.A,$rgb[0],$rgb[1],$rgb[2]))
        }
    }
}

function Apply-CarbonFiber {
    param([System.Drawing.Bitmap]$Bmp, [double]$Intensity = 0.6)
    $w = $Bmp.Width; $h = $Bmp.Height
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $px = $Bmp.GetPixel($x, $y)
            if ($px.A -eq 0) { continue }
            $cellX = [Math]::Floor($x / 2) % 2; $cellY = [Math]::Floor($y / 2) % 2
            $weave = if (($cellX -bxor $cellY) -eq 0) { 0.7 } else { 1.0 }
            $diag = if (($x + $y) % 4 -eq 0) { 0.85 } else { 1.0 }
            $f = (1.0 - $Intensity) + $Intensity * $weave * $diag
            $Bmp.SetPixel($x,$y,[System.Drawing.Color]::FromArgb($px.A, [Math]::Max(0,[Math]::Min(255,[int]($px.R*$f))), [Math]::Max(0,[Math]::Min(255,[int]($px.G*$f))), [Math]::Max(0,[Math]::Min(255,[int]($px.B*$f)))))
        }
    }
}

function Apply-GlowNeon {
    param([System.Drawing.Bitmap]$Bmp, [System.Drawing.Color]$GlowColor, [double]$Intensity = 0.8)
    $w = $Bmp.Width; $h = $Bmp.Height; $cx = $w/2.0; $cy = $h/2.0
    $maxD = [Math]::Sqrt($cx*$cx + $cy*$cy)
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $px = $Bmp.GetPixel($x, $y)
            if ($px.A -eq 0) { continue }
            $lum = (0.299*$px.R + 0.587*$px.G + 0.114*$px.B)/255.0
            $dist = [Math]::Sqrt(($x-$cx)*($x-$cx)+($y-$cy)*($y-$cy))
            $gf = $Intensity * [Math]::Min(1.0, $dist/$maxD*1.5) * (1.0 - $lum*0.5)
            $r = [Math]::Max(0,[Math]::Min(255,[int]($px.R*(1-$gf)+$GlowColor.R*$gf)))
            $g = [Math]::Max(0,[Math]::Min(255,[int]($px.G*(1-$gf)+$GlowColor.G*$gf)))
            $b = [Math]::Max(0,[Math]::Min(255,[int]($px.B*(1-$gf)+$GlowColor.B*$gf)))
            $Bmp.SetPixel($x,$y,[System.Drawing.Color]::FromArgb($px.A,$r,$g,$b))
        }
    }
}

function Apply-Chrome {
    param([System.Drawing.Bitmap]$Bmp, [double]$Intensity = 0.9)
    $w = $Bmp.Width; $h = $Bmp.Height; $cx = $w/2.0; $cy = $h/2.0
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $px = $Bmp.GetPixel($x, $y)
            if ($px.A -eq 0) { continue }
            $lum = (0.299*$px.R + 0.587*$px.G + 0.114*$px.B)/255.0
            $chrome = [Math]::Pow($lum, 0.6)
            $env = (([Math]::Sin([Math]::Atan2(($y-$cy),($x-$cx))*3)+1)/2)*0.15
            $v = [Math]::Max(0,[Math]::Min(255,[int](([Math]::Min(1.0,$chrome+$env))*255)))
            $r = [Math]::Min(255,[int]($px.R*(1-$Intensity)+$v*$Intensity))
            $g = [Math]::Min(255,[int]($px.G*(1-$Intensity)+$v*$Intensity))
            $b = [Math]::Min(255,[int]($px.B*(1-$Intensity)+$v*0.95*$Intensity))
            $Bmp.SetPixel($x,$y,[System.Drawing.Color]::FromArgb($px.A,$r,$g,$b))
        }
    }
}

function Apply-Tint {
    param([System.Drawing.Bitmap]$Bmp, [System.Drawing.Color]$Color, [double]$Intensity = 0.5)
    $w = $Bmp.Width; $h = $Bmp.Height
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $px = $Bmp.GetPixel($x, $y)
            if ($px.A -eq 0) { continue }
            $r = [Math]::Min(255,[int]($px.R*(1-$Intensity)+$Color.R*$Intensity))
            $g = [Math]::Min(255,[int]($px.G*(1-$Intensity)+$Color.G*$Intensity))
            $b = [Math]::Min(255,[int]($px.B*(1-$Intensity)+$Color.B*$Intensity))
            $Bmp.SetPixel($x,$y,[System.Drawing.Color]::FromArgb($px.A,$r,$g,$b))
        }
    }
}

function Apply-BrushedMetal {
    param([System.Drawing.Bitmap]$Bmp, [double]$Intensity = 0.7)
    $w = $Bmp.Width; $h = $Bmp.Height
    $rng = New-Object System.Random(42)
    for ($y = 0; $y -lt $h; $y++) {
        # Horizontal streak noise per scanline
        $streak = ($rng.NextDouble() - 0.5) * 40 * $Intensity
        for ($x = 0; $x -lt $w; $x++) {
            $px = $Bmp.GetPixel($x, $y)
            if ($px.A -eq 0) { continue }
            $lum = (0.299*$px.R + 0.587*$px.G + 0.114*$px.B)/255.0
            # Desaturate towards gray + add streak
            $gray = [int]($lum * 255)
            $r = [Math]::Max(0,[Math]::Min(255,[int]($px.R*(1-$Intensity) + ($gray+$streak)*$Intensity)))
            $g = [Math]::Max(0,[Math]::Min(255,[int]($px.G*(1-$Intensity) + ($gray+$streak)*$Intensity)))
            $b = [Math]::Max(0,[Math]::Min(255,[int]($px.B*(1-$Intensity) + ($gray+$streak*0.9)*$Intensity)))
            $Bmp.SetPixel($x,$y,[System.Drawing.Color]::FromArgb($px.A,$r,$g,$b))
        }
    }
}

function Apply-BurntTitanium {
    param([System.Drawing.Bitmap]$Bmp, [double]$Intensity = 0.8)
    $w = $Bmp.Width; $h = $Bmp.Height; $cx = $w/2.0; $cy = $h/2.0
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $px = $Bmp.GetPixel($x, $y)
            if ($px.A -eq 0) { continue }
            $lum = (0.299*$px.R + 0.587*$px.G + 0.114*$px.B)/255.0
            # Burnt titanium: purple -> blue -> gold gradient based on distance from center
            $dist = [Math]::Sqrt(($x-$cx)*($x-$cx)+($y-$cy)*($y-$cy)) / [Math]::Sqrt($cx*$cx+$cy*$cy)
            $hue = (0.7 + $dist * 0.4) % 1.0  # purple to gold sweep
            $rgb = Convert-HslToRgb -H $hue -S 0.6 -L $lum
            $r = [Math]::Min(255,[int]($px.R*(1-$Intensity)+$rgb[0]*$Intensity))
            $g = [Math]::Min(255,[int]($px.G*(1-$Intensity)+$rgb[1]*$Intensity))
            $b = [Math]::Min(255,[int]($px.B*(1-$Intensity)+$rgb[2]*$Intensity))
            $Bmp.SetPixel($x,$y,[System.Drawing.Color]::FromArgb($px.A,$r,$g,$b))
        }
    }
}

function Apply-GoldPlate {
    param([System.Drawing.Bitmap]$Bmp, [double]$Intensity = 0.8)
    $w = $Bmp.Width; $h = $Bmp.Height; $cx = $w/2.0; $cy = $h/2.0
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $px = $Bmp.GetPixel($x, $y)
            if ($px.A -eq 0) { continue }
            $lum = (0.299*$px.R + 0.587*$px.G + 0.114*$px.B)/255.0
            # Gold: warm highlight with specular
            $spec = [Math]::Pow($lum, 0.5)
            $r = [Math]::Min(255,[int]($px.R*(1-$Intensity) + (255*$spec)*$Intensity))
            $g = [Math]::Min(255,[int]($px.G*(1-$Intensity) + (200*$spec)*$Intensity))
            $b = [Math]::Min(255,[int]($px.B*(1-$Intensity) + (50*$spec)*$Intensity))
            $Bmp.SetPixel($x,$y,[System.Drawing.Color]::FromArgb($px.A,$r,$g,$b))
        }
    }
}

function Apply-InvertColors {
    param([System.Drawing.Bitmap]$Bmp)
    $w = $Bmp.Width; $h = $Bmp.Height
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $px = $Bmp.GetPixel($x, $y)
            if ($px.A -eq 0) { continue }
            $Bmp.SetPixel($x,$y,[System.Drawing.Color]::FromArgb($px.A, (255-$px.R), (255-$px.G), (255-$px.B)))
        }
    }
}

# ---------------------------------------------------------------------------
# Layer system
# ---------------------------------------------------------------------------

$script:layers = [System.Collections.ArrayList]::new()
$script:activeLayerIndex = 0
$script:canvasWidth = 200
$script:canvasHeight = 200
$script:currentTool = "Brush"
$script:brushSize = 8
$script:brushColor = [System.Drawing.Color]::White
$script:isDrawing = $false
$script:lastPoint = $null
$script:undoStack = [System.Collections.ArrayList]::new()
$script:loadedWheelId = $null
$script:loadedFramePngs = @()

function New-Layer {
    param([string]$Name = "Layer", [System.Drawing.Bitmap]$FromBitmap = $null)
    if ($FromBitmap) {
        # Create a fresh 32bppArgb copy that is fully independent of any stream
        $bmp = New-Object System.Drawing.Bitmap($FromBitmap.Width, $FromBitmap.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $gfx = [System.Drawing.Graphics]::FromImage($bmp)
        $gfx.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $gfx.DrawImage($FromBitmap, 0, 0, $FromBitmap.Width, $FromBitmap.Height)
        $gfx.Dispose()
    } else {
        $bmp = New-Object System.Drawing.Bitmap($script:canvasWidth, $script:canvasHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $gfx = [System.Drawing.Graphics]::FromImage($bmp)
        $gfx.Clear([System.Drawing.Color]::Transparent)
        $gfx.Dispose()
    }
    $layer = @{ Name = $Name; Bitmap = $bmp; Visible = $true; Opacity = 1.0 }
    [void]$script:layers.Add($layer)
    return $layer
}

function Get-FlattenedCanvas {
    $result = New-Object System.Drawing.Bitmap($script:canvasWidth, $script:canvasHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $gfx = [System.Drawing.Graphics]::FromImage($result)
    $gfx.Clear([System.Drawing.Color]::FromArgb(40, 40, 40))
    foreach ($layer in $script:layers) {
        if (-not $layer.Visible) { continue }
        if ($layer.Opacity -lt 1.0) {
            $cm = New-Object System.Drawing.Imaging.ColorMatrix
            $cm.Matrix33 = [float]$layer.Opacity
            $ia = New-Object System.Drawing.Imaging.ImageAttributes
            $ia.SetColorMatrix($cm)
            $gfx.DrawImage($layer.Bitmap,
                (New-Object System.Drawing.Rectangle(0, 0, $script:canvasWidth, $script:canvasHeight)),
                0, 0, $script:canvasWidth, $script:canvasHeight,
                [System.Drawing.GraphicsUnit]::Pixel, $ia)
            $ia.Dispose()
        } else {
            $gfx.DrawImage($layer.Bitmap, 0, 0)
        }
    }
    $gfx.Dispose()
    return $result
}

function Save-UndoState {
    if ($script:layers.Count -eq 0) { return }
    $src = $script:layers[$script:activeLayerIndex].Bitmap
    # Create an independent 32bppArgb copy (avoid GDI+ errors from Clone on stream-backed bitmaps)
    $snapshot = New-Object System.Drawing.Bitmap($src.Width, $src.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $gfx = [System.Drawing.Graphics]::FromImage($snapshot)
    $gfx.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $gfx.DrawImage($src, 0, 0, $src.Width, $src.Height)
    $gfx.Dispose()
    if ($script:undoStack.Count -gt 30) { $script:undoStack[0].Bitmap.Dispose(); $script:undoStack.RemoveAt(0) }
    [void]$script:undoStack.Add(@{ Index = $script:activeLayerIndex; Bitmap = $snapshot })
}

function Invoke-Undo {
    if ($script:undoStack.Count -eq 0) { return }
    $last = $script:undoStack[$script:undoStack.Count - 1]
    $script:undoStack.RemoveAt($script:undoStack.Count - 1)
    $layer = $script:layers[$last.Index]
    if ($layer.Bitmap) { $layer.Bitmap.Dispose() }
    $layer.Bitmap = $last.Bitmap
}

# ---------------------------------------------------------------------------
# Build GUI
# ---------------------------------------------------------------------------

$form = New-Object System.Windows.Forms.Form
$form.Text = "1320 Legends - Wheel Studio v2"
$form.Size = New-Object System.Drawing.Size(1100, 750)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "Sizable"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor = [System.Drawing.Color]::White
$form.KeyPreview = $true

# ---------------------------------------------------------------------------
# Top: Wheel selector bar
# ---------------------------------------------------------------------------

$topBar = New-Object System.Windows.Forms.Panel
$topBar.Dock = "Top"
$topBar.Height = 40
$topBar.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$form.Controls.Add($topBar)

$lblWheel = New-Object System.Windows.Forms.Label
$lblWheel.Text = "Wheel:"
$lblWheel.Location = New-Object System.Drawing.Point(10, 10)
$lblWheel.AutoSize = $true
$lblWheel.ForeColor = [System.Drawing.Color]::FromArgb(200,200,200)
$topBar.Controls.Add($lblWheel)

$cmbWheel = New-Object System.Windows.Forms.ComboBox
$cmbWheel.Location = New-Object System.Drawing.Point(60, 7)
$cmbWheel.Size = New-Object System.Drawing.Size(100, 24)
$cmbWheel.DropDownStyle = "DropDownList"
$cmbWheel.BackColor = [System.Drawing.Color]::FromArgb(50,50,50)
$cmbWheel.ForeColor = [System.Drawing.Color]::White
$cmbWheel.FlatStyle = "Flat"
$topBar.Controls.Add($cmbWheel)

# Populate wheel IDs from cache
$wheelIds = Get-ChildItem -Path $script:CACHE_DIR -Filter "wheelR_*.swf" -ErrorAction SilentlyContinue |
    ForEach-Object { [int]($_.BaseName -replace 'wheelR_', '') } | Sort-Object
foreach ($id in $wheelIds) { [void]$cmbWheel.Items.Add("$id") }
if ($cmbWheel.Items.Count -gt 0) { $cmbWheel.SelectedIndex = 0 }

$btnLoad = New-Object System.Windows.Forms.Button
$btnLoad.Text = "Load Wheel"
$btnLoad.Location = New-Object System.Drawing.Point(170, 6)
$btnLoad.Size = New-Object System.Drawing.Size(90, 26)
$btnLoad.FlatStyle = "Flat"
$btnLoad.BackColor = [System.Drawing.Color]::FromArgb(50, 100, 180)
$btnLoad.ForeColor = [System.Drawing.Color]::White
$topBar.Controls.Add($btnLoad)

$btnPushLive = New-Object System.Windows.Forms.Button
$btnPushLive.Text = "Push to Cache"
$btnPushLive.Location = New-Object System.Drawing.Point(270, 6)
$btnPushLive.Size = New-Object System.Drawing.Size(110, 26)
$btnPushLive.FlatStyle = "Flat"
$btnPushLive.BackColor = [System.Drawing.Color]::FromArgb(180, 60, 60)
$btnPushLive.ForeColor = [System.Drawing.Color]::White
$btnPushLive.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$topBar.Controls.Add($btnPushLive)

$btnExportPng = New-Object System.Windows.Forms.Button
$btnExportPng.Text = "Save PNG"
$btnExportPng.Location = New-Object System.Drawing.Point(390, 6)
$btnExportPng.Size = New-Object System.Drawing.Size(80, 26)
$btnExportPng.FlatStyle = "Flat"
$btnExportPng.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnExportPng.ForeColor = [System.Drawing.Color]::White
$topBar.Controls.Add($btnExportPng)

$btnImportPng = New-Object System.Windows.Forms.Button
$btnImportPng.Text = "Import PNG"
$btnImportPng.Location = New-Object System.Drawing.Point(478, 6)
$btnImportPng.Size = New-Object System.Drawing.Size(90, 26)
$btnImportPng.FlatStyle = "Flat"
$btnImportPng.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnImportPng.ForeColor = [System.Drawing.Color]::White
$topBar.Controls.Add($btnImportPng)

$btnUndo = New-Object System.Windows.Forms.Button
$btnUndo.Text = "Undo"
$btnUndo.Location = New-Object System.Drawing.Point(576, 6)
$btnUndo.Size = New-Object System.Drawing.Size(60, 26)
$btnUndo.FlatStyle = "Flat"
$btnUndo.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnUndo.ForeColor = [System.Drawing.Color]::White
$topBar.Controls.Add($btnUndo)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Ready - select a wheel and click Load"
$lblStatus.Location = New-Object System.Drawing.Point(650, 12)
$lblStatus.AutoSize = $true
$lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(120,200,120)
$lblStatus.Font = New-Object System.Drawing.Font("Consolas", 8)
$topBar.Controls.Add($lblStatus)

# ---------------------------------------------------------------------------
# Left: Tool panel
# ---------------------------------------------------------------------------

$toolPanel = New-Object System.Windows.Forms.Panel
$toolPanel.Location = New-Object System.Drawing.Point(0, 40)
$toolPanel.Size = New-Object System.Drawing.Size(70, 680)
$toolPanel.BackColor = [System.Drawing.Color]::FromArgb(42, 42, 42)
$form.Controls.Add($toolPanel)

$toolDefs = @("Brush", "Eraser", "Fill", "EyeDrp")
$toolY = 8
foreach ($tName in $toolDefs) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $tName
    $btn.Location = New-Object System.Drawing.Point(4, $toolY)
    $btn.Size = New-Object System.Drawing.Size(62, 28)
    $btn.FlatStyle = "Flat"
    $btn.BackColor = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $btn.Tag = $tName
    $btn.Add_Click({
        $script:currentTool = $this.Tag
        foreach ($c in $toolPanel.Controls) {
            if ($c -is [System.Windows.Forms.Button] -and $c.Tag -and $toolDefs -contains $c.Tag) {
                $c.BackColor = if ($c.Tag -eq $script:currentTool) { [System.Drawing.Color]::FromArgb(70,120,200) } else { [System.Drawing.Color]::FromArgb(55,55,55) }
            }
        }
    })
    $toolPanel.Controls.Add($btn)
    $toolY += 32
}

# Brush size
$toolY += 8
$lblBSz = New-Object System.Windows.Forms.Label
$lblBSz.Text = "Size:8"
$lblBSz.Location = New-Object System.Drawing.Point(4, $toolY)
$lblBSz.Size = New-Object System.Drawing.Size(62, 14)
$lblBSz.ForeColor = [System.Drawing.Color]::FromArgb(160,160,160)
$lblBSz.Font = New-Object System.Drawing.Font("Segoe UI", 7)
$toolPanel.Controls.Add($lblBSz)
$toolY += 16

$trackBSz = New-Object System.Windows.Forms.TrackBar
$trackBSz.Location = New-Object System.Drawing.Point(2, $toolY)
$trackBSz.Size = New-Object System.Drawing.Size(65, 28)
$trackBSz.Minimum = 1; $trackBSz.Maximum = 50; $trackBSz.Value = 8
$trackBSz.TickFrequency = 10
$trackBSz.BackColor = [System.Drawing.Color]::FromArgb(42,42,42)
$trackBSz.Add_ValueChanged({ $script:brushSize = $trackBSz.Value; $lblBSz.Text = "Size:$($trackBSz.Value)" })
$toolPanel.Controls.Add($trackBSz)
$toolY += 36

# Color button
$btnClr = New-Object System.Windows.Forms.Button
$btnClr.Text = ""
$btnClr.Location = New-Object System.Drawing.Point(4, $toolY)
$btnClr.Size = New-Object System.Drawing.Size(62, 28)
$btnClr.FlatStyle = "Flat"
$btnClr.BackColor = [System.Drawing.Color]::White
$btnClr.Add_Click({
    $dlg = New-Object System.Windows.Forms.ColorDialog
    $dlg.Color = $script:brushColor; $dlg.FullOpen = $true
    if ($dlg.ShowDialog() -eq "OK") { $script:brushColor = $dlg.Color; $btnClr.BackColor = $dlg.Color }
})
$toolPanel.Controls.Add($btnClr)
$toolY += 32

$lblClr = New-Object System.Windows.Forms.Label
$lblClr.Text = "Color"
$lblClr.Location = New-Object System.Drawing.Point(4, $toolY)
$lblClr.Size = New-Object System.Drawing.Size(62, 14)
$lblClr.ForeColor = [System.Drawing.Color]::FromArgb(140,140,140)
$lblClr.Font = New-Object System.Drawing.Font("Segoe UI", 7)
$toolPanel.Controls.Add($lblClr)

# ---------------------------------------------------------------------------
# Center: Views strip (all 5 angles) + Canvas
# ---------------------------------------------------------------------------

$viewsPanel = New-Object System.Windows.Forms.Panel
$viewsPanel.Location = New-Object System.Drawing.Point(74, 44)
$viewsPanel.Size = New-Object System.Drawing.Size(580, 80)
$viewsPanel.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$viewsPanel.BorderStyle = "FixedSingle"
$form.Controls.Add($viewsPanel)

$viewPrefixes = @("wheelR", "wheelFR", "wheelFF", "wheelBF", "wheelBR")
$viewLabels = @("Rear 3/4", "Front-R", "Front-F", "Back-F", "Back-R")
$script:viewPics = @()

for ($vi = 0; $vi -lt 5; $vi++) {
    $vx = 6 + $vi * 114
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $viewLabels[$vi]
    $lbl.Location = New-Object System.Drawing.Point($vx, 2)
    $lbl.Size = New-Object System.Drawing.Size(108, 14)
    $lbl.ForeColor = [System.Drawing.Color]::FromArgb(140,140,140)
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 7)
    $lbl.TextAlign = "MiddleCenter"
    $viewsPanel.Controls.Add($lbl)

    $pic = New-Object System.Windows.Forms.PictureBox
    $pic.Location = New-Object System.Drawing.Point($vx, 16)
    $pic.Size = New-Object System.Drawing.Size(108, 58)
    $pic.SizeMode = "Zoom"
    $pic.BackColor = [System.Drawing.Color]::FromArgb(15,15,15)
    $pic.BorderStyle = "FixedSingle"
    $viewsPanel.Controls.Add($pic)
    $script:viewPics += $pic
}

$canvas = New-Object System.Windows.Forms.PictureBox
$canvas.Location = New-Object System.Drawing.Point(74, 128)
$canvas.Size = New-Object System.Drawing.Size(580, 496)
$canvas.BackColor = [System.Drawing.Color]::FromArgb(35, 35, 35)
$canvas.BorderStyle = "FixedSingle"
$canvas.SizeMode = "Zoom"
$form.Controls.Add($canvas)

function Refresh-Canvas {
    $flat = Get-FlattenedCanvas
    if ($canvas.Image) { $canvas.Image.Dispose() }
    $canvas.Image = $flat
}

function Get-CanvasCoords([System.Drawing.Point]$mp) {
    $pw = $canvas.ClientSize.Width; $ph = $canvas.ClientSize.Height
    $rX = $pw / $script:canvasWidth; $rY = $ph / $script:canvasHeight
    $r = [Math]::Min($rX, $rY)
    $dw = $script:canvasWidth * $r; $dh = $script:canvasHeight * $r
    $ox = ($pw - $dw)/2; $oy = ($ph - $dh)/2
    $cx = [int](($mp.X - $ox)/$r); $cy = [int](($mp.Y - $oy)/$r)
    if ($cx -lt 0 -or $cx -ge $script:canvasWidth -or $cy -lt 0 -or $cy -ge $script:canvasHeight) { return $null }
    return @{ X = $cx; Y = $cy }
}

# Mouse drawing
$canvas.Add_MouseDown({
    param($s,$e)
    if ($script:layers.Count -eq 0) { return }
    $pt = Get-CanvasCoords $e.Location
    if (-not $pt) { return }
    $script:isDrawing = $true; $script:lastPoint = $pt
    Save-UndoState
    $layer = $script:layers[$script:activeLayerIndex]
    $gfx = [System.Drawing.Graphics]::FromImage($layer.Bitmap)
    switch ($script:currentTool) {
        "Brush" {
            $br = New-Object System.Drawing.SolidBrush($script:brushColor)
            $gfx.FillEllipse($br, ($pt.X - $script:brushSize/2), ($pt.Y - $script:brushSize/2), $script:brushSize, $script:brushSize)
            $br.Dispose()
        }
        "Eraser" {
            $gfx.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
            $br = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Transparent)
            $gfx.FillEllipse($br, ($pt.X - $script:brushSize/2), ($pt.Y - $script:brushSize/2), $script:brushSize, $script:brushSize)
            $br.Dispose()
        }
        "Fill" {
            $target = $layer.Bitmap.GetPixel($pt.X, $pt.Y)
            if ($target.ToArgb() -eq $script:brushColor.ToArgb()) { $gfx.Dispose(); return }
            $visited = New-Object 'bool[,]' $script:canvasWidth,$script:canvasHeight
            $queue = New-Object System.Collections.Queue
            $queue.Enqueue($pt)
            while ($queue.Count -gt 0 -and $queue.Count -lt 80000) {
                $p = $queue.Dequeue(); $px=$p.X; $py=$p.Y
                if ($px -lt 0 -or $px -ge $script:canvasWidth -or $py -lt 0 -or $py -ge $script:canvasHeight) { continue }
                if ($visited[$px,$py]) { continue }
                if ($layer.Bitmap.GetPixel($px,$py).ToArgb() -ne $target.ToArgb()) { continue }
                $visited[$px,$py] = $true
                $layer.Bitmap.SetPixel($px,$py,$script:brushColor)
                $queue.Enqueue(@{X=($px+1);Y=$py}); $queue.Enqueue(@{X=($px-1);Y=$py})
                $queue.Enqueue(@{X=$px;Y=($py+1)}); $queue.Enqueue(@{X=$px;Y=($py-1)})
            }
        }
        "EyeDrp" {
            $c = $layer.Bitmap.GetPixel($pt.X,$pt.Y)
            if ($c.A -gt 0) { $script:brushColor = $c; $btnClr.BackColor = $c }
        }
    }
    $gfx.Dispose()
    Refresh-Canvas
})

$canvas.Add_MouseMove({
    param($s,$e)
    if (-not $script:isDrawing -or $script:layers.Count -eq 0) { return }
    $pt = Get-CanvasCoords $e.Location
    if (-not $pt) { return }
    $layer = $script:layers[$script:activeLayerIndex]
    $gfx = [System.Drawing.Graphics]::FromImage($layer.Bitmap)
    $gfx.SmoothingMode = "AntiAlias"
    switch ($script:currentTool) {
        "Brush" {
            $pen = New-Object System.Drawing.Pen($script:brushColor, $script:brushSize)
            $pen.StartCap = "Round"; $pen.EndCap = "Round"
            $gfx.DrawLine($pen, $script:lastPoint.X, $script:lastPoint.Y, $pt.X, $pt.Y)
            $pen.Dispose()
        }
        "Eraser" {
            $gfx.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::Transparent, $script:brushSize)
            $pen.StartCap = "Round"; $pen.EndCap = "Round"
            $gfx.DrawLine($pen, $script:lastPoint.X, $script:lastPoint.Y, $pt.X, $pt.Y)
            $pen.Dispose()
        }
    }
    $gfx.Dispose()
    $script:lastPoint = $pt
    Refresh-Canvas
})

$canvas.Add_MouseUp({ $script:isDrawing = $false; $script:lastPoint = $null })

# ---------------------------------------------------------------------------
# Right panel: Layers + Effects + Presets
# ---------------------------------------------------------------------------

$rightPanel = New-Object System.Windows.Forms.Panel
$rightPanel.Location = New-Object System.Drawing.Point(660, 44)
$rightPanel.Size = New-Object System.Drawing.Size(420, 660)
$rightPanel.BackColor = [System.Drawing.Color]::FromArgb(38, 38, 38)
$rightPanel.AutoScroll = $true
$form.Controls.Add($rightPanel)

# --- Layers ---
$lblLay = New-Object System.Windows.Forms.Label
$lblLay.Text = "LAYERS"
$lblLay.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$lblLay.Location = New-Object System.Drawing.Point(6, 4)
$lblLay.AutoSize = $true
$lblLay.ForeColor = [System.Drawing.Color]::FromArgb(180,180,180)
$rightPanel.Controls.Add($lblLay)

$lstLay = New-Object System.Windows.Forms.ListBox
$lstLay.Location = New-Object System.Drawing.Point(6, 22)
$lstLay.Size = New-Object System.Drawing.Size(180, 80)
$lstLay.BackColor = [System.Drawing.Color]::FromArgb(25,25,25)
$lstLay.ForeColor = [System.Drawing.Color]::White
$lstLay.BorderStyle = "FixedSingle"
$lstLay.Add_SelectedIndexChanged({ if ($lstLay.SelectedIndex -ge 0) { $script:activeLayerIndex = $lstLay.SelectedIndex } })
$rightPanel.Controls.Add($lstLay)

function Refresh-LayerList {
    $lstLay.Items.Clear()
    for ($i = 0; $i -lt $script:layers.Count; $i++) {
        $l = $script:layers[$i]
        $v = if ($l.Visible) { "+" } else { "-" }
        $lstLay.Items.Add("$v $($l.Name)")
    }
    if ($script:activeLayerIndex -lt $lstLay.Items.Count) { $lstLay.SelectedIndex = $script:activeLayerIndex }
}

# Layer buttons row
$layBtnX = 192
$btnAddLay = New-Object System.Windows.Forms.Button
$btnAddLay.Text = "+"; $btnAddLay.Location = New-Object System.Drawing.Point($layBtnX, 22)
$btnAddLay.Size = New-Object System.Drawing.Size(26, 24); $btnAddLay.FlatStyle = "Flat"
$btnAddLay.BackColor = [System.Drawing.Color]::FromArgb(40,110,40); $btnAddLay.ForeColor = [System.Drawing.Color]::White
$btnAddLay.Add_Click({ New-Layer -Name "Layer $($script:layers.Count+1)"; $script:activeLayerIndex=$script:layers.Count-1; Refresh-LayerList; Refresh-Canvas })
$rightPanel.Controls.Add($btnAddLay)

$btnDelLay = New-Object System.Windows.Forms.Button
$btnDelLay.Text = "-"; $btnDelLay.Location = New-Object System.Drawing.Point($layBtnX, 48)
$btnDelLay.Size = New-Object System.Drawing.Size(26, 24); $btnDelLay.FlatStyle = "Flat"
$btnDelLay.BackColor = [System.Drawing.Color]::FromArgb(110,40,40); $btnDelLay.ForeColor = [System.Drawing.Color]::White
$btnDelLay.Add_Click({
    if ($script:layers.Count -le 1) { return }
    $script:layers[$script:activeLayerIndex].Bitmap.Dispose()
    $script:layers.RemoveAt($script:activeLayerIndex)
    $script:activeLayerIndex = [Math]::Max(0,$script:activeLayerIndex-1)
    Refresh-LayerList; Refresh-Canvas
})
$rightPanel.Controls.Add($btnDelLay)

$btnVisLay = New-Object System.Windows.Forms.Button
$btnVisLay.Text = "V"; $btnVisLay.Location = New-Object System.Drawing.Point($layBtnX, 74)
$btnVisLay.Size = New-Object System.Drawing.Size(26, 24); $btnVisLay.FlatStyle = "Flat"
$btnVisLay.BackColor = [System.Drawing.Color]::FromArgb(55,55,55); $btnVisLay.ForeColor = [System.Drawing.Color]::White
$btnVisLay.Add_Click({ if($script:layers.Count -eq 0){return}; $script:layers[$script:activeLayerIndex].Visible = -not $script:layers[$script:activeLayerIndex].Visible; Refresh-LayerList; Refresh-Canvas })
$rightPanel.Controls.Add($btnVisLay)

# Opacity
$lblOp = New-Object System.Windows.Forms.Label
$lblOp.Text = "Opacity:"; $lblOp.Location = New-Object System.Drawing.Point(6, 106); $lblOp.AutoSize = $true
$lblOp.ForeColor = [System.Drawing.Color]::FromArgb(140,140,140)
$rightPanel.Controls.Add($lblOp)

$trackOp = New-Object System.Windows.Forms.TrackBar
$trackOp.Location = New-Object System.Drawing.Point(60, 102); $trackOp.Size = New-Object System.Drawing.Size(150, 24)
$trackOp.Minimum = 0; $trackOp.Maximum = 100; $trackOp.Value = 100; $trackOp.TickFrequency = 25
$trackOp.BackColor = [System.Drawing.Color]::FromArgb(38,38,38)
$trackOp.Add_ValueChanged({ if($script:layers.Count -eq 0){return}; $script:layers[$script:activeLayerIndex].Opacity = $trackOp.Value/100.0; Refresh-Canvas })
$rightPanel.Controls.Add($trackOp)

# --- Effects ---
$rpY = 132
$lblFx = New-Object System.Windows.Forms.Label
$lblFx.Text = "EFFECTS"; $lblFx.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$lblFx.Location = New-Object System.Drawing.Point(6, $rpY); $lblFx.AutoSize = $true
$lblFx.ForeColor = [System.Drawing.Color]::FromArgb(180,180,180)
$rightPanel.Controls.Add($lblFx)
$rpY += 18

$lblInt = New-Object System.Windows.Forms.Label
$lblInt.Text = "Strength: 0.80"; $lblInt.Location = New-Object System.Drawing.Point(6, $rpY); $lblInt.AutoSize = $true
$lblInt.ForeColor = [System.Drawing.Color]::FromArgb(140,140,140); $lblInt.Font = New-Object System.Drawing.Font("Segoe UI", 7.5)
$rightPanel.Controls.Add($lblInt)

$trackInt = New-Object System.Windows.Forms.TrackBar
$trackInt.Location = New-Object System.Drawing.Point(100, ($rpY - 3)); $trackInt.Size = New-Object System.Drawing.Size(120, 24)
$trackInt.Minimum = 0; $trackInt.Maximum = 100; $trackInt.Value = 80; $trackInt.TickFrequency = 20
$trackInt.BackColor = [System.Drawing.Color]::FromArgb(38,38,38)
$trackInt.Add_ValueChanged({ $lblInt.Text = "Strength: {0:F2}" -f ($trackInt.Value/100.0) })
$rightPanel.Controls.Add($trackInt)
$rpY += 30

# Effect buttons
$fxList = @(
    @{ Name="Rainbow Anodize"; BG=@(140,40,180) },
    @{ Name="Carbon Fiber"; BG=@(50,50,50) },
    @{ Name="Glow / Neon"; BG=@(0,160,80) },
    @{ Name="Chrome"; BG=@(150,150,170) },
    @{ Name="Gold Plate"; BG=@(180,140,20) },
    @{ Name="Brushed Metal"; BG=@(100,100,110) },
    @{ Name="Burnt Titanium"; BG=@(100,50,130) },
    @{ Name="Tint Color"; BG=@(70,100,160) },
    @{ Name="Invert"; BG=@(60,60,60) }
)

foreach ($fx in $fxList) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $fx.Name
    $btn.Location = New-Object System.Drawing.Point(6, $rpY)
    $btn.Size = New-Object System.Drawing.Size(210, 26)
    $btn.FlatStyle = "Flat"
    $btn.BackColor = [System.Drawing.Color]::FromArgb($fx.BG[0], $fx.BG[1], $fx.BG[2])
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
    $btn.Tag = $fx.Name
    $btn.Add_Click({
        if ($script:layers.Count -eq 0) { return }
        Save-UndoState
        $layer = $script:layers[$script:activeLayerIndex]
        $str = $trackInt.Value / 100.0
        switch ($this.Tag) {
            "Rainbow Anodize" { Apply-RainbowAnodize -Bmp $layer.Bitmap -Sat $str }
            "Carbon Fiber"    { Apply-CarbonFiber -Bmp $layer.Bitmap -Intensity $str }
            "Glow / Neon" {
                $d = New-Object System.Windows.Forms.ColorDialog; $d.Color = [System.Drawing.Color]::Cyan; $d.FullOpen = $true
                if ($d.ShowDialog() -eq "OK") { Apply-GlowNeon -Bmp $layer.Bitmap -GlowColor $d.Color -Intensity $str }
            }
            "Chrome"          { Apply-Chrome -Bmp $layer.Bitmap -Intensity $str }
            "Gold Plate"      { Apply-GoldPlate -Bmp $layer.Bitmap -Intensity $str }
            "Brushed Metal"   { Apply-BrushedMetal -Bmp $layer.Bitmap -Intensity $str }
            "Burnt Titanium"  { Apply-BurntTitanium -Bmp $layer.Bitmap -Intensity $str }
            "Tint Color" {
                $d = New-Object System.Windows.Forms.ColorDialog; $d.Color = $script:brushColor; $d.FullOpen = $true
                if ($d.ShowDialog() -eq "OK") { Apply-Tint -Bmp $layer.Bitmap -Color $d.Color -Intensity $str }
            }
            "Invert"          { Apply-InvertColors -Bmp $layer.Bitmap }
        }
        Refresh-Canvas
    })
    $rightPanel.Controls.Add($btn)
    $rpY += 29
}

# --- Presets ---
$rpY += 12
$lblPre = New-Object System.Windows.Forms.Label
$lblPre.Text = "ONE-CLICK PRESETS"; $lblPre.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$lblPre.Location = New-Object System.Drawing.Point(6, $rpY); $lblPre.AutoSize = $true
$lblPre.ForeColor = [System.Drawing.Color]::FromArgb(255,200,60)
$rightPanel.Controls.Add($lblPre)
$rpY += 20

$presetList = @(
    @{ Name="Neochrome Rainbow"; Action={Apply-RainbowAnodize -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Sat 0.9} },
    @{ Name="Deep Chrome"; Action={Apply-Chrome -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Intensity 0.95} },
    @{ Name="Matte Black + Carbon"; Action={Apply-Tint -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Color ([System.Drawing.Color]::FromArgb(15,15,15)) -Intensity 0.7; Apply-CarbonFiber -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Intensity 0.5} },
    @{ Name="24K Gold"; Action={Apply-GoldPlate -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Intensity 0.85} },
    @{ Name="Rose Gold"; Action={Apply-Tint -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Color ([System.Drawing.Color]::FromArgb(220,150,130)) -Intensity 0.5; Apply-Chrome -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Intensity 0.4} },
    @{ Name="Neon Green Glow"; Action={Apply-GlowNeon -Bmp $script:layers[$script:activeLayerIndex].Bitmap -GlowColor ([System.Drawing.Color]::FromArgb(0,255,80)) -Intensity 0.8} },
    @{ Name="Neon Blue Glow"; Action={Apply-GlowNeon -Bmp $script:layers[$script:activeLayerIndex].Bitmap -GlowColor ([System.Drawing.Color]::FromArgb(0,100,255)) -Intensity 0.8} },
    @{ Name="Neon Red Glow"; Action={Apply-GlowNeon -Bmp $script:layers[$script:activeLayerIndex].Bitmap -GlowColor ([System.Drawing.Color]::FromArgb(255,30,30)) -Intensity 0.8} },
    @{ Name="Burnt Titanium Exhaust"; Action={Apply-BurntTitanium -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Intensity 0.85} },
    @{ Name="Brushed Aluminum"; Action={Apply-BrushedMetal -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Intensity 0.75} },
    @{ Name="Gunmetal Gray"; Action={Apply-Tint -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Color ([System.Drawing.Color]::FromArgb(60,65,70)) -Intensity 0.6; Apply-Chrome -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Intensity 0.3} },
    @{ Name="Candy Red"; Action={Apply-Tint -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Color ([System.Drawing.Color]::FromArgb(200,20,20)) -Intensity 0.55; Apply-Chrome -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Intensity 0.25} },
    @{ Name="Candy Blue"; Action={Apply-Tint -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Color ([System.Drawing.Color]::FromArgb(20,60,200)) -Intensity 0.55; Apply-Chrome -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Intensity 0.25} },
    @{ Name="Candy Purple"; Action={Apply-Tint -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Color ([System.Drawing.Color]::FromArgb(130,20,200)) -Intensity 0.55; Apply-Chrome -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Intensity 0.25} },
    @{ Name="White Out"; Action={Apply-Tint -Bmp $script:layers[$script:activeLayerIndex].Bitmap -Color ([System.Drawing.Color]::White) -Intensity 0.8} }
)

foreach ($preset in $presetList) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $preset.Name
    $btn.Location = New-Object System.Drawing.Point(6, $rpY)
    $btn.Size = New-Object System.Drawing.Size(210, 24)
    $btn.FlatStyle = "Flat"
    $btn.BackColor = [System.Drawing.Color]::FromArgb(48, 48, 48)
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 7.5)
    $btn.Tag = $preset.Action
    $btn.Add_Click({
        if ($script:layers.Count -eq 0) { return }
        Save-UndoState
        & $this.Tag
        Refresh-Canvas
    })
    $rightPanel.Controls.Add($btn)
    $rpY += 27
}

# ---------------------------------------------------------------------------
# Button handlers: Load, Push, Export, Import, Undo
# ---------------------------------------------------------------------------

$btnLoad.Add_Click({
    if (-not (Test-Path $script:FFDEC_PATH)) {
        [System.Windows.Forms.MessageBox]::Show("FFDec not found at:`n$($script:FFDEC_PATH)`n`nInstall JPEXS Free Flash Decompiler.", "Error")
        return
    }
    $wheelId = $cmbWheel.SelectedItem
    if (-not $wheelId) { return }

    $swfPath = Join-Path $script:CACHE_DIR "wheelR_${wheelId}.swf"
    if (-not (Test-Path $swfPath)) {
        [System.Windows.Forms.MessageBox]::Show("wheelR_${wheelId}.swf not found.", "Error")
        return
    }

    $lblStatus.Text = "Loading wheel #$wheelId..."
    $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(255,200,60)
    [System.Windows.Forms.Application]::DoEvents()

    # Load thumbnails for all 5 views
    foreach ($vp in $script:viewPics) { if ($vp.Image) { $vp.Image.Dispose(); $vp.Image = $null } }

    for ($vi = 0; $vi -lt $viewPrefixes.Count; $vi++) {
        $vSwf = Join-Path $script:CACHE_DIR "$($viewPrefixes[$vi])_${wheelId}.swf"
        if (-not (Test-Path $vSwf)) { continue }
        $vTemp = Join-Path ([System.IO.Path]::GetTempPath()) "ws_view_${vi}_$(Get-Random)"
        New-Item -ItemType Directory -Path $vTemp -Force | Out-Null
        try {
            & $script:FFDEC_PATH -export image $vTemp $vSwf 2>&1 | Out-Null
            $vPngs = @(Get-ChildItem -Path $vTemp -Filter "*.png" -Recurse | Sort-Object { [int]($_.BaseName -replace '[^\d]','') })
            if ($vPngs.Count -gt 0) {
                $vBytes = [System.IO.File]::ReadAllBytes($vPngs[0].FullName)
                $vMs = New-Object System.IO.MemoryStream(,$vBytes)
                $script:viewPics[$vi].Image = [System.Drawing.Bitmap]::new($vMs)
            }
        } catch {} finally { Remove-Item $vTemp -Recurse -Force -ErrorAction SilentlyContinue }
        [System.Windows.Forms.Application]::DoEvents()
    }

    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "ws_load_$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    try {
        & $script:FFDEC_PATH -export image $tempDir $swfPath 2>&1 | Out-Null
        $pngs = @(Get-ChildItem -Path $tempDir -Filter "*.png" -Recurse |
                 Sort-Object { [int]($_.BaseName -replace '[^\d]', '') })

        if ($pngs.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No images in SWF.", "Error")
            return
        }

        # Load first frame
        $bytes = [System.IO.File]::ReadAllBytes($pngs[0].FullName)
        $ms = New-Object System.IO.MemoryStream(,$bytes)
        $imported = [System.Drawing.Bitmap]::new($ms)
        $imported = Convert-To32bppArgb $imported

        # Reset canvas
        foreach ($l in $script:layers) { $l.Bitmap.Dispose() }
        $script:layers.Clear()
        $script:undoStack.Clear()
        $script:canvasWidth = $imported.Width
        $script:canvasHeight = $imported.Height
        $script:loadedWheelId = $wheelId

        New-Layer -Name "Wheel #$wheelId" -FromBitmap $imported
        $imported.Dispose(); $ms.Dispose()
        $script:activeLayerIndex = 0

        Refresh-LayerList
        Refresh-Canvas

        $lblStatus.Text = "Loaded wheel #$wheelId ($($pngs.Count) frames)"
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(120,200,120)
    }
    catch {
        $lblStatus.Text = "Error: $($_.Exception.Message)"
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(255,80,80)
    }
    finally {
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
})

$btnPushLive.Add_Click({
    if ($script:layers.Count -eq 0) { return }
    if (-not (Test-Path $script:FFDEC_PATH)) {
        [System.Windows.Forms.MessageBox]::Show("FFDec not found.", "Error"); return
    }

    $wheelId = if ($script:loadedWheelId) { $script:loadedWheelId } else { $cmbWheel.SelectedItem }
    if (-not $wheelId) { return }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Push your design to wheel #$wheelId in the live cache?`n`nThis will backup originals to _backups/ first.",
        "Push to Cache", "YesNo", "Warning")
    if ($confirm -ne "Yes") { return }

    $lblStatus.Text = "Pushing to cache..."
    $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(255,200,60)
    [System.Windows.Forms.Application]::DoEvents()

    # Ensure backup dir exists
    if (-not (Test-Path $script:BACKUP_DIR)) { New-Item -ItemType Directory -Path $script:BACKUP_DIR -Force | Out-Null }

    $prefixes = @("wheelR", "wheelFR", "wheelFF", "wheelBF", "wheelBR")
    $pushed = 0

    foreach ($prefix in $prefixes) {
        $swfName = "${prefix}_${wheelId}.swf"
        $swfPath = Join-Path $script:CACHE_DIR $swfName
        if (-not (Test-Path $swfPath)) { continue }

        # Backup original
        $backupPath = Join-Path $script:BACKUP_DIR $swfName
        if (-not (Test-Path $backupPath)) {
            Copy-Item $swfPath $backupPath -Force
        }

        # Export frames, replace with our design
        $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "ws_push_${prefix}_$(Get-Random)"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

        try {
            & $script:FFDEC_PATH -export image $tempDir $swfPath 2>&1 | Out-Null
            $pngs = @(Get-ChildItem -Path $tempDir -Filter "*.png" -Recurse |
                     Sort-Object { [int]($_.BaseName -replace '[^\d]', '') })

            if ($pngs.Count -eq 0) { continue }

            # Flatten canvas and save over each frame
            $flat = Get-FlattenedCanvas
            foreach ($png in $pngs) {
                # Scale to match frame dimensions
                $frameBytes = [System.IO.File]::ReadAllBytes($png.FullName)
                $frameMs = New-Object System.IO.MemoryStream(,$frameBytes)
                $frameBmp = [System.Drawing.Bitmap]::new($frameMs)
                $frameW = $frameBmp.Width; $frameH = $frameBmp.Height
                $frameBmp.Dispose(); $frameMs.Dispose()

                $scaled = New-Object System.Drawing.Bitmap($frameW, $frameH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
                $gfx = [System.Drawing.Graphics]::FromImage($scaled)
                $gfx.InterpolationMode = "HighQualityBicubic"
                $gfx.DrawImage($flat, 0, 0, $frameW, $frameH)
                $gfx.Dispose()
                $scaled.Save($png.FullName, [System.Drawing.Imaging.ImageFormat]::Png)
                $scaled.Dispose()
            }
            $flat.Dispose()

            # Inject back into the SWF in-place
            foreach ($png in $pngs) {
                $charId = $png.BaseName -replace '[^\d]', ''
                & $script:FFDEC_PATH -replace $swfPath $swfPath $charId $png.FullName 2>&1 | Out-Null
            }
            $pushed++
            [System.Windows.Forms.Application]::DoEvents()
        }
        finally {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    $lblStatus.Text = "Pushed to $pushed SWF(s)! Wheel #$wheelId updated in cache."
    $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(120,255,120)
})

$btnExportPng.Add_Click({
    if ($script:layers.Count -eq 0) { return }
    $dlg = New-Object System.Windows.Forms.SaveFileDialog
    $dlg.Filter = "PNG|*.png"; $dlg.Title = "Save as PNG"
    $dlg.FileName = "wheel_custom.png"
    if ($dlg.ShowDialog() -eq "OK") {
        $flat = Get-FlattenedCanvas
        $flat.Save($dlg.FileName, [System.Drawing.Imaging.ImageFormat]::Png)
        $flat.Dispose()
        $lblStatus.Text = "Saved: $($dlg.FileName)"
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(120,200,120)
    }
})

$btnImportPng.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter = "Images|*.png;*.jpg;*.bmp;*.gif"
    $dlg.Title = "Import image as layer"
    if ($dlg.ShowDialog() -eq "OK") {
        $bytes = [System.IO.File]::ReadAllBytes($dlg.FileName)
        $ms = New-Object System.IO.MemoryStream(,$bytes)
        $img = [System.Drawing.Bitmap]::new($ms)

        # First import sets canvas size
        if ($script:layers.Count -eq 0 -or ($script:layers.Count -eq 1 -and $script:layers[0].Name -eq "Background")) {
            $script:canvasWidth = $img.Width; $script:canvasHeight = $img.Height
            foreach ($l in $script:layers) { $l.Bitmap.Dispose() }
            $script:layers.Clear()
        }

        # Scale if needed
        if ($img.Width -ne $script:canvasWidth -or $img.Height -ne $script:canvasHeight) {
            $scaled = New-Object System.Drawing.Bitmap($script:canvasWidth, $script:canvasHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            $gfx = [System.Drawing.Graphics]::FromImage($scaled)
            $gfx.InterpolationMode = "HighQualityBicubic"
            $gfx.DrawImage($img, 0, 0, $script:canvasWidth, $script:canvasHeight)
            $gfx.Dispose()
            $img.Dispose(); $ms.Dispose()
            $img = $scaled; $ms = $null
        }

        $name = [System.IO.Path]::GetFileNameWithoutExtension($dlg.FileName)
        New-Layer -Name $name -FromBitmap $img
        $img.Dispose()
        if ($ms) { $ms.Dispose() }
        $script:activeLayerIndex = $script:layers.Count - 1
        Refresh-LayerList; Refresh-Canvas
        $lblStatus.Text = "Imported: $name"
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(120,200,120)
    }
})

$btnUndo.Add_Click({ Invoke-Undo; Refresh-Canvas })

# ---------------------------------------------------------------------------
# Keyboard shortcuts
# ---------------------------------------------------------------------------

$form.Add_KeyDown({
    param($s,$e)
    if ($e.Control -and $e.KeyCode -eq "Z") { Invoke-Undo; Refresh-Canvas; $e.Handled = $true }
    if ($e.KeyCode -eq "B") { $script:currentTool = "Brush" }
    if ($e.KeyCode -eq "E") { $script:currentTool = "Eraser" }
    if ($e.KeyCode -eq "G") { $script:currentTool = "Fill" }
    if ($e.KeyCode -eq "I") { $script:currentTool = "EyeDrp" }
})

# ---------------------------------------------------------------------------
# Init and show
# ---------------------------------------------------------------------------

New-Layer -Name "Background"
$script:activeLayerIndex = 0
Refresh-LayerList
Refresh-Canvas

$form.Add_FormClosing({
    foreach ($l in $script:layers) { if ($l.Bitmap) { $l.Bitmap.Dispose() } }
    if ($canvas.Image) { $canvas.Image.Dispose() }
    foreach ($u in $script:undoStack) { if ($u.Bitmap) { $u.Bitmap.Dispose() } }
})

[System.Windows.Forms.Application]::EnableVisualStyles()
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
