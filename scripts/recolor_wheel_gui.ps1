<#
.SYNOPSIS
    GUI tool for rainbow-anodizing (neochrome) wheel SWFs in Open 1320 Legends.
.DESCRIPTION
    WinForms interface with before/after wheel preview. Lets you pick source/output
    folders, set wheel ID and saturation, preview the effect, then run the full
    export -> recolor -> re-inject cycle.
    Requires JPEXS Free Flash Decompiler (ffdec-cli.exe) installed.
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# HSL <-> RGB conversion
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
    $r = [Math]::Max(0, [Math]::Min(255, $r))
    $g = [Math]::Max(0, [Math]::Min(255, $g))
    $b = [Math]::Max(0, [Math]::Min(255, $b))
    return @($r, $g, $b)
}

# ---------------------------------------------------------------------------
# Core recolor function — loads via MemoryStream to avoid GDI+ file lock
# ---------------------------------------------------------------------------

function Invoke-RainbowRecolor {
    param(
        [string]$PngPath,
        [int]$FrameIndex,
        [int]$TotalFrames,
        [double]$Sat
    )

    # Load into memory so the file isn't locked during save
    $bytes = [System.IO.File]::ReadAllBytes($PngPath)
    $ms = New-Object System.IO.MemoryStream(,$bytes)
    $bmp = [System.Drawing.Bitmap]::new($ms)

    # Convert indexed pixel formats to 32bppArgb so SetPixel works
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
    $frameOffset = $FrameIndex / [Math]::Max(1, $TotalFrames)

    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $pixel = $bmp.GetPixel($x, $y)
            if ($pixel.A -eq 0) { continue }
            $lum = (0.299 * $pixel.R + 0.587 * $pixel.G + 0.114 * $pixel.B) / 255.0
            $dx = $x - $cx
            $dy = $y - $cy
            $angle = [Math]::Atan2($dy, $dx)
            $hue = ($angle + [Math]::PI) / (2.0 * [Math]::PI)
            $hue = ($hue + $frameOffset) % 1.0
            $rgb = Convert-HslToRgb -H $hue -S $Sat -L $lum
            $newColor = [System.Drawing.Color]::FromArgb($pixel.A, $rgb[0], $rgb[1], $rgb[2])
            $bmp.SetPixel($x, $y, $newColor)
        }
    }

    $bmp.Save($PngPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $ms.Dispose()
}

# ---------------------------------------------------------------------------
# Returns a recolored bitmap in memory (for preview, does not save to disk)
# ---------------------------------------------------------------------------

function Get-RainbowPreviewBitmap {
    param(
        [string]$PngPath,
        [int]$FrameIndex,
        [int]$TotalFrames,
        [double]$Sat
    )

    $bytes = [System.IO.File]::ReadAllBytes($PngPath)
    $ms = New-Object System.IO.MemoryStream(,$bytes)
    $bmp = [System.Drawing.Bitmap]::new($ms)

    # Convert indexed pixel formats to 32bppArgb so SetPixel works
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
    $frameOffset = $FrameIndex / [Math]::Max(1, $TotalFrames)

    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $pixel = $bmp.GetPixel($x, $y)
            if ($pixel.A -eq 0) { continue }
            $lum = (0.299 * $pixel.R + 0.587 * $pixel.G + 0.114 * $pixel.B) / 255.0
            $dx = $x - $cx
            $dy = $y - $cy
            $angle = [Math]::Atan2($dy, $dx)
            $hue = ($angle + [Math]::PI) / (2.0 * [Math]::PI)
            $hue = ($hue + $frameOffset) % 1.0
            $rgb = Convert-HslToRgb -H $hue -S $Sat -L $lum
            $newColor = [System.Drawing.Color]::FromArgb($pixel.A, $rgb[0], $rgb[1], $rgb[2])
            $bmp.SetPixel($x, $y, $newColor)
        }
    }

    $ms.Dispose()
    return $bmp  # caller must dispose
}

# ---------------------------------------------------------------------------
# Build the GUI
# ---------------------------------------------------------------------------

$form = New-Object System.Windows.Forms.Form
$form.Text = "1320 Legends - Rainbow Wheel Recolor"
$form.Size = New-Object System.Drawing.Size(820, 580)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor = [System.Drawing.Color]::White

# --- Title banner ---
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "Rainbow Wheel Recolor"
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 60)
$lblTitle.Location = New-Object System.Drawing.Point(20, 10)
$lblTitle.AutoSize = $true
$form.Controls.Add($lblTitle)

$lblSubtitle = New-Object System.Windows.Forms.Label
$lblSubtitle.Text = "Neochrome anodize any wheel SWF set"
$lblSubtitle.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$lblSubtitle.Location = New-Object System.Drawing.Point(22, 34)
$lblSubtitle.AutoSize = $true
$form.Controls.Add($lblSubtitle)

# --- Wheel ID ---
$lblWheelId = New-Object System.Windows.Forms.Label
$lblWheelId.Text = "Wheel ID:"
$lblWheelId.Location = New-Object System.Drawing.Point(20, 65)
$lblWheelId.AutoSize = $true
$form.Controls.Add($lblWheelId)

$txtWheelId = New-Object System.Windows.Forms.TextBox
$txtWheelId.Location = New-Object System.Drawing.Point(130, 62)
$txtWheelId.Size = New-Object System.Drawing.Size(80, 24)
$txtWheelId.Text = "90"
$txtWheelId.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$txtWheelId.ForeColor = [System.Drawing.Color]::White
$txtWheelId.BorderStyle = "FixedSingle"
$form.Controls.Add($txtWheelId)

# --- Source folder ---
$lblSource = New-Object System.Windows.Forms.Label
$lblSource.Text = "Source Folder:"
$lblSource.Location = New-Object System.Drawing.Point(20, 95)
$lblSource.AutoSize = $true
$form.Controls.Add($lblSource)

$txtSource = New-Object System.Windows.Forms.TextBox
$txtSource.Location = New-Object System.Drawing.Point(130, 92)
$txtSource.Size = New-Object System.Drawing.Size(330, 24)
$txtSource.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$txtSource.ForeColor = [System.Drawing.Color]::White
$txtSource.BorderStyle = "FixedSingle"
$form.Controls.Add($txtSource)

$btnBrowseSource = New-Object System.Windows.Forms.Button
$btnBrowseSource.Text = "..."
$btnBrowseSource.Location = New-Object System.Drawing.Point(468, 91)
$btnBrowseSource.Size = New-Object System.Drawing.Size(40, 24)
$btnBrowseSource.FlatStyle = "Flat"
$btnBrowseSource.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnBrowseSource.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = "Select folder containing wheel SWFs"
    if ($dlg.ShowDialog() -eq "OK") { $txtSource.Text = $dlg.SelectedPath }
})
$form.Controls.Add($btnBrowseSource)

# --- Output folder ---
$lblOutput = New-Object System.Windows.Forms.Label
$lblOutput.Text = "Output Folder:"
$lblOutput.Location = New-Object System.Drawing.Point(20, 125)
$lblOutput.AutoSize = $true
$form.Controls.Add($lblOutput)

$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Location = New-Object System.Drawing.Point(130, 122)
$txtOutput.Size = New-Object System.Drawing.Size(330, 24)
$txtOutput.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$txtOutput.ForeColor = [System.Drawing.Color]::White
$txtOutput.BorderStyle = "FixedSingle"
$txtOutput.Text = "(auto: source\rainbow)"
$form.Controls.Add($txtOutput)

$btnBrowseOutput = New-Object System.Windows.Forms.Button
$btnBrowseOutput.Text = "..."
$btnBrowseOutput.Location = New-Object System.Drawing.Point(468, 121)
$btnBrowseOutput.Size = New-Object System.Drawing.Size(40, 24)
$btnBrowseOutput.FlatStyle = "Flat"
$btnBrowseOutput.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnBrowseOutput.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = "Select output folder for recolored SWFs"
    if ($dlg.ShowDialog() -eq "OK") { $txtOutput.Text = $dlg.SelectedPath }
})
$form.Controls.Add($btnBrowseOutput)

# --- FFDec path ---
$lblFfdec = New-Object System.Windows.Forms.Label
$lblFfdec.Text = "FFDec CLI:"
$lblFfdec.Location = New-Object System.Drawing.Point(20, 155)
$lblFfdec.AutoSize = $true
$form.Controls.Add($lblFfdec)

$txtFfdec = New-Object System.Windows.Forms.TextBox
$txtFfdec.Location = New-Object System.Drawing.Point(130, 152)
$txtFfdec.Size = New-Object System.Drawing.Size(330, 24)
$txtFfdec.Text = "C:\Program Files (x86)\FFDec\ffdec-cli.exe"
$txtFfdec.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$txtFfdec.ForeColor = [System.Drawing.Color]::White
$txtFfdec.BorderStyle = "FixedSingle"
$form.Controls.Add($txtFfdec)

$btnBrowseFfdec = New-Object System.Windows.Forms.Button
$btnBrowseFfdec.Text = "..."
$btnBrowseFfdec.Location = New-Object System.Drawing.Point(468, 151)
$btnBrowseFfdec.Size = New-Object System.Drawing.Size(40, 24)
$btnBrowseFfdec.FlatStyle = "Flat"
$btnBrowseFfdec.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnBrowseFfdec.Add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Filter = "ffdec-cli.exe|ffdec-cli.exe|All files|*.*"
    $dlg.Title = "Locate ffdec-cli.exe"
    if ($dlg.ShowDialog() -eq "OK") { $txtFfdec.Text = $dlg.FileName }
})
$form.Controls.Add($btnBrowseFfdec)

# --- Saturation slider ---
$lblSat = New-Object System.Windows.Forms.Label
$lblSat.Text = "Saturation:"
$lblSat.Location = New-Object System.Drawing.Point(20, 188)
$lblSat.AutoSize = $true
$form.Controls.Add($lblSat)

$trackSat = New-Object System.Windows.Forms.TrackBar
$trackSat.Location = New-Object System.Drawing.Point(128, 184)
$trackSat.Size = New-Object System.Drawing.Size(300, 30)
$trackSat.Minimum = 0
$trackSat.Maximum = 100
$trackSat.Value = 85
$trackSat.TickFrequency = 10
$trackSat.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.Controls.Add($trackSat)

$lblSatVal = New-Object System.Windows.Forms.Label
$lblSatVal.Text = "0.85"
$lblSatVal.Location = New-Object System.Drawing.Point(435, 188)
$lblSatVal.AutoSize = $true
$lblSatVal.ForeColor = [System.Drawing.Color]::FromArgb(100, 220, 255)
$form.Controls.Add($lblSatVal)

$trackSat.Add_ValueChanged({
    $lblSatVal.Text = "{0:F2}" -f ($trackSat.Value / 100.0)
})

# ---------------------------------------------------------------------------
# Preview panel (right side) — before / after wheel images
# ---------------------------------------------------------------------------

$previewPanel = New-Object System.Windows.Forms.Panel
$previewPanel.Location = New-Object System.Drawing.Point(530, 10)
$previewPanel.Size = New-Object System.Drawing.Size(260, 520)
$previewPanel.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$previewPanel.BorderStyle = "FixedSingle"
$form.Controls.Add($previewPanel)

$lblBefore = New-Object System.Windows.Forms.Label
$lblBefore.Text = "ORIGINAL"
$lblBefore.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$lblBefore.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
$lblBefore.Location = New-Object System.Drawing.Point(5, 5)
$lblBefore.AutoSize = $true
$previewPanel.Controls.Add($lblBefore)

$picBefore = New-Object System.Windows.Forms.PictureBox
$picBefore.Location = New-Object System.Drawing.Point(5, 25)
$picBefore.Size = New-Object System.Drawing.Size(245, 220)
$picBefore.SizeMode = "Zoom"
$picBefore.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 15)
$picBefore.BorderStyle = "FixedSingle"
$previewPanel.Controls.Add($picBefore)

$lblAfter = New-Object System.Windows.Forms.Label
$lblAfter.Text = "RAINBOW"
$lblAfter.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
$lblAfter.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 60)
$lblAfter.Location = New-Object System.Drawing.Point(5, 255)
$lblAfter.AutoSize = $true
$previewPanel.Controls.Add($lblAfter)

$picAfter = New-Object System.Windows.Forms.PictureBox
$picAfter.Location = New-Object System.Drawing.Point(5, 275)
$picAfter.Size = New-Object System.Drawing.Size(245, 220)
$picAfter.SizeMode = "Zoom"
$picAfter.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 15)
$picAfter.BorderStyle = "FixedSingle"
$previewPanel.Controls.Add($picAfter)

# --- Preview button ---
$btnPreview = New-Object System.Windows.Forms.Button
$btnPreview.Text = "Preview"
$btnPreview.Location = New-Object System.Drawing.Point(530, 536)
$btnPreview.Size = New-Object System.Drawing.Size(130, 30)
$btnPreview.FlatStyle = "Flat"
$btnPreview.BackColor = [System.Drawing.Color]::FromArgb(60, 100, 160)
$btnPreview.ForeColor = [System.Drawing.Color]::White
$btnPreview.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnPreview)

# Store preview temp dir for cleanup
$script:previewTempDir = $null

$btnPreview.Add_Click({
    try {
        $wheelId = 0
        if (-not [int]::TryParse($txtWheelId.Text, [ref]$wheelId)) {
            [System.Windows.Forms.MessageBox]::Show("Wheel ID must be a number.", "Error")
            return
        }
        $ffdecPath = $txtFfdec.Text
        if (-not (Test-Path $ffdecPath)) {
            [System.Windows.Forms.MessageBox]::Show("FFDec CLI not found.", "Error")
            return
        }
        $sourceDir = $txtSource.Text
        if (-not (Test-Path $sourceDir)) {
            [System.Windows.Forms.MessageBox]::Show("Source folder not found.", "Error")
            return
        }

        # Find the main wheelR SWF for preview
        $swfPath = Join-Path $sourceDir "wheelR_${wheelId}.swf"
        if (-not (Test-Path $swfPath)) {
            [System.Windows.Forms.MessageBox]::Show("wheelR_${wheelId}.swf not found in source.", "Error")
            return
        }

        $btnPreview.Enabled = $false
        $btnPreview.Text = "Extracting..."
        [System.Windows.Forms.Application]::DoEvents()

        # Cleanup previous preview temp
        if ($script:previewTempDir -and (Test-Path $script:previewTempDir)) {
            Remove-Item $script:previewTempDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        $script:previewTempDir = Join-Path ([System.IO.Path]::GetTempPath()) "wheelpreview_$(Get-Random)"
        New-Item -ItemType Directory -Path $script:previewTempDir -Force | Out-Null

        # Export one frame from the SWF
        & $ffdecPath -export image $script:previewTempDir $swfPath 2>&1 | Out-Null

        $pngs = @(Get-ChildItem -Path $script:previewTempDir -Filter "*.png" -Recurse |
                 Sort-Object { [int]($_.BaseName -replace '[^\d]', '') })

        if ($pngs.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No images found in SWF.", "Error")
            return
        }

        # Show original (first frame)
        $firstPng = $pngs[0].FullName
        if ($picBefore.Image) { $picBefore.Image.Dispose() }
        $origBytes = [System.IO.File]::ReadAllBytes($firstPng)
        $origMs = New-Object System.IO.MemoryStream(,$origBytes)
        $picBefore.Image = [System.Drawing.Bitmap]::new($origMs)

        # Generate recolored preview
        $btnPreview.Text = "Recoloring..."
        [System.Windows.Forms.Application]::DoEvents()

        $sat = $trackSat.Value / 100.0
        if ($picAfter.Image) { $picAfter.Image.Dispose() }
        $picAfter.Image = Get-RainbowPreviewBitmap -PngPath $firstPng -FrameIndex 0 -TotalFrames $pngs.Count -Sat $sat

        $btnPreview.Text = "Preview"
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Preview error: $($_.Exception.Message)", "Error")
        $btnPreview.Text = "Preview"
    }
    finally {
        $btnPreview.Enabled = $true
    }
})

# --- Progress bar ---
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 220)
$progressBar.Size = New-Object System.Drawing.Size(490, 20)
$progressBar.Style = "Continuous"
$form.Controls.Add($progressBar)

# --- Log output ---
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Location = New-Object System.Drawing.Point(20, 248)
$txtLog.Size = New-Object System.Drawing.Size(490, 240)
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.ReadOnly = $true
$txtLog.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$txtLog.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 120)
$txtLog.Font = New-Object System.Drawing.Font("Consolas", 8.5)
$txtLog.BorderStyle = "FixedSingle"
$form.Controls.Add($txtLog)

function Log($msg) {
    $txtLog.AppendText("$msg`r`n")
    $txtLog.SelectionStart = $txtLog.TextLength
    $txtLog.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# --- Run button ---
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "Recolor All"
$btnRun.Location = New-Object System.Drawing.Point(20, 498)
$btnRun.Size = New-Object System.Drawing.Size(140, 34)
$btnRun.FlatStyle = "Flat"
$btnRun.BackColor = [System.Drawing.Color]::FromArgb(40, 140, 40)
$btnRun.ForeColor = [System.Drawing.Color]::White
$btnRun.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnRun)

# --- Open output button ---
$btnOpen = New-Object System.Windows.Forms.Button
$btnOpen.Text = "Open Output Folder"
$btnOpen.Location = New-Object System.Drawing.Point(175, 498)
$btnOpen.Size = New-Object System.Drawing.Size(160, 34)
$btnOpen.FlatStyle = "Flat"
$btnOpen.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnOpen.ForeColor = [System.Drawing.Color]::White
$btnOpen.Enabled = $false
$form.Controls.Add($btnOpen)

$script:outputPath = ""

$btnOpen.Add_Click({
    if ($script:outputPath -and (Test-Path $script:outputPath)) {
        Start-Process explorer.exe $script:outputPath
    }
})

# ---------------------------------------------------------------------------
# Run handler — full batch recolor
# ---------------------------------------------------------------------------

$btnRun.Add_Click({
    $txtLog.Clear()
    $progressBar.Value = 0
    $btnRun.Enabled = $false
    $btnOpen.Enabled = $false

    try {
        $wheelId = 0
        if (-not [int]::TryParse($txtWheelId.Text, [ref]$wheelId)) {
            Log "ERROR: Wheel ID must be a number."
            return
        }

        $ffdecPath = $txtFfdec.Text
        if (-not (Test-Path $ffdecPath)) {
            Log "ERROR: FFDec CLI not found at '$ffdecPath'"
            return
        }

        $sourceDir = $txtSource.Text
        if (-not (Test-Path $sourceDir)) {
            Log "ERROR: Source folder not found: '$sourceDir'"
            return
        }

        $outputDir = $txtOutput.Text
        if ($outputDir -eq "(auto: source\rainbow)" -or [string]::IsNullOrWhiteSpace($outputDir)) {
            $outputDir = Join-Path $sourceDir "rainbow"
        }
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
        $script:outputPath = $outputDir

        $saturation = $trackSat.Value / 100.0

        Log "=== Rainbow Wheel Recolor ==="
        Log "Wheel ID  : $wheelId"
        Log "Source    : $sourceDir"
        Log "Output    : $outputDir"
        Log "Saturation: $saturation"
        Log ""

        $prefixes = @("wheelR", "wheelFR", "wheelFF", "wheelBF", "wheelBR")
        $swfsToProcess = @()

        foreach ($prefix in $prefixes) {
            $swfName = "${prefix}_${wheelId}.swf"
            $swfPath = Join-Path $sourceDir $swfName
            if (Test-Path $swfPath) {
                $swfsToProcess += @{ Name = $swfName; Path = $swfPath }
            } else {
                Log "  Skip: $swfName (not found)"
            }
        }

        if ($swfsToProcess.Count -eq 0) {
            Log ""
            Log "ERROR: No wheel SWFs found for ID $wheelId in source folder."
            return
        }

        $totalSwfs = $swfsToProcess.Count
        $swfIndex = 0

        foreach ($swf in $swfsToProcess) {
            $swfIndex++
            Log ""
            Log "[$swfIndex/$totalSwfs] Processing $($swf.Name)..."

            $swfBaseName = [System.IO.Path]::GetFileNameWithoutExtension($swf.Path)
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "recolor_${swfBaseName}_$(Get-Random)"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

            try {
                Log "  Exporting images..."
                [System.Windows.Forms.Application]::DoEvents()

                & $ffdecPath -export image $tempDir $swf.Path 2>&1 | Out-Null
                if ($LASTEXITCODE -ne 0) {
                    Log "  WARNING: FFDec export failed (exit $LASTEXITCODE)"
                    continue
                }

                $pngs = @(Get-ChildItem -Path $tempDir -Filter "*.png" -Recurse |
                         Sort-Object { [int]($_.BaseName -replace '[^\d]', '') })

                $totalFrames = $pngs.Count
                Log "  Found $totalFrames frame(s), recoloring..."

                for ($i = 0; $i -lt $pngs.Count; $i++) {
                    Invoke-RainbowRecolor -PngPath $pngs[$i].FullName -FrameIndex $i -TotalFrames $totalFrames -Sat $saturation

                    $overallProgress = (($swfIndex - 1) / $totalSwfs + ($i + 1) / ($totalFrames * $totalSwfs)) * 100
                    $progressBar.Value = [Math]::Min(100, [int]$overallProgress)

                    # Update preview with latest recolored frame (show first frame of first SWF)
                    if ($swfIndex -eq 1 -and $i -eq 0) {
                        if ($picAfter.Image) { $picAfter.Image.Dispose() }
                        $afterBytes = [System.IO.File]::ReadAllBytes($pngs[0].FullName)
                        $afterMs = New-Object System.IO.MemoryStream(,$afterBytes)
                        $picAfter.Image = [System.Drawing.Bitmap]::new($afterMs)
                    }

                    [System.Windows.Forms.Application]::DoEvents()
                }

                Log "  Injecting back into SWF..."
                [System.Windows.Forms.Application]::DoEvents()

                $outSwfPath = Join-Path $outputDir $swf.Name
                Copy-Item -Path $swf.Path -Destination $outSwfPath -Force

                foreach ($png in $pngs) {
                    $charId = $png.BaseName -replace '[^\d]', ''
                    & $ffdecPath -replace $outSwfPath $outSwfPath $charId $png.FullName 2>&1 | Out-Null
                    if ($LASTEXITCODE -ne 0) {
                        Log "  WARNING: Replace failed for char $charId"
                    }
                    [System.Windows.Forms.Application]::DoEvents()
                }

                Log "  Done -> $outSwfPath"
            }
            finally {
                Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        $progressBar.Value = 100
        Log ""
        Log "=== COMPLETE! $totalSwfs SWF(s) recolored. ==="
        Log "Output: $outputDir"
        Log "Drop these into cache/car/wheel/ to use in-game."
        $btnOpen.Enabled = $true
    }
    catch {
        Log ""
        Log "EXCEPTION: $($_.Exception.Message)"
    }
    finally {
        $btnRun.Enabled = $true
    }
})

# ---------------------------------------------------------------------------
# Cleanup on close
# ---------------------------------------------------------------------------

$form.Add_FormClosing({
    if ($picBefore.Image) { $picBefore.Image.Dispose() }
    if ($picAfter.Image) { $picAfter.Image.Dispose() }
    if ($script:previewTempDir -and (Test-Path $script:previewTempDir)) {
        Remove-Item $script:previewTempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
})

# ---------------------------------------------------------------------------
# Show the form
# ---------------------------------------------------------------------------

[System.Windows.Forms.Application]::EnableVisualStyles()
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
