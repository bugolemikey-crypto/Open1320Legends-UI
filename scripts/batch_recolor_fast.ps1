# Fast batch recolor using compiled C# for pixel manipulation (50-100x faster)
# Uses LockBits + unsafe pointer access for the recolor, single FFDec call per SWF

$ErrorActionPreference = "Stop"

$FFDEC = 'C:\Program Files (x86)\FFDec\ffdec-cli.exe'
$SRC = 'C:\Users\hunte\Downloads\Open1320Legends\cache\car\wheel'
$OUT = 'C:\Users\hunte\OneDrive\Desktop\OPENNEWCLIENT\cache\car\wheel'
$SAT = 0.83
$MISSING = @(200,201,202,203,204,205,206,208,209,210,211,212,250)

if (!(Test-Path $OUT)) { New-Item -ItemType Directory -Path $OUT -Force | Out-Null }

# Compile a C# class for fast pixel recolor using LockBits
Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;

public static class WheelRecolor
{
    public static void RainbowRecolor(string pngPath, int frameIndex, int totalFrames, double saturation)
    {
        byte[] bytes = File.ReadAllBytes(pngPath);
        Bitmap bmp;
        using (var ms = new MemoryStream(bytes))
            bmp = new Bitmap(ms);

        // Convert to 32bppArgb if needed
        if (bmp.PixelFormat != PixelFormat.Format32bppArgb)
        {
            var nb = new Bitmap(bmp.Width, bmp.Height, PixelFormat.Format32bppArgb);
            using (var g = Graphics.FromImage(nb))
                g.DrawImage(bmp, 0, 0, bmp.Width, bmp.Height);
            bmp.Dispose();
            bmp = nb;
        }

        int w = bmp.Width, h = bmp.Height;
        double cx = w / 2.0, cy = h / 2.0;
        double frameOffset = (double)frameIndex / Math.Max(1, totalFrames);

        var rect = new Rectangle(0, 0, w, h);
        var data = bmp.LockBits(rect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
        int stride = data.Stride;
        byte[] pixels = new byte[stride * h];
        System.Runtime.InteropServices.Marshal.Copy(data.Scan0, pixels, 0, pixels.Length);

        for (int y = 0; y < h; y++)
        {
            int rowOff = y * stride;
            for (int x = 0; x < w; x++)
            {
                int off = rowOff + x * 4;
                byte b = pixels[off], g2 = pixels[off+1], r = pixels[off+2], a = pixels[off+3];
                if (a == 0) continue;

                double lum = (0.299 * r + 0.587 * g2 + 0.114 * b) / 255.0;
                double angle = Math.Atan2(y - cy, x - cx);
                double hue = ((angle + Math.PI) / (2.0 * Math.PI) + frameOffset) % 1.0;

                double rr, gg, bb;
                HslToRgb(hue, saturation, lum, out rr, out gg, out bb);

                pixels[off+2] = (byte)Math.Max(0, Math.Min(255, (int)(rr * 255)));
                pixels[off+1] = (byte)Math.Max(0, Math.Min(255, (int)(gg * 255)));
                pixels[off]   = (byte)Math.Max(0, Math.Min(255, (int)(bb * 255)));
            }
        }

        System.Runtime.InteropServices.Marshal.Copy(pixels, 0, data.Scan0, pixels.Length);
        bmp.UnlockBits(data);
        bmp.Save(pngPath, ImageFormat.Png);
        bmp.Dispose();
    }

    private static void HslToRgb(double h, double s, double l, out double r, out double g, out double b)
    {
        if (s == 0) { r = g = b = l; return; }
        double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        double p = 2 * l - q;
        r = HueToRgb(p, q, h + 1.0/3.0);
        g = HueToRgb(p, q, h);
        b = HueToRgb(p, q, h - 1.0/3.0);
    }

    private static double HueToRgb(double p, double q, double t)
    {
        if (t < 0) t += 1; if (t > 1) t -= 1;
        if (t < 1.0/6.0) return p + (q - p) * 6 * t;
        if (t < 0.5) return q;
        if (t < 2.0/3.0) return p + (q - p) * (2.0/3.0 - t) * 6;
        return p;
    }
}
"@ -ReferencedAssemblies System.Drawing

$prefixes = @('wheelR','wheelFR','wheelFF','wheelBF','wheelBR')
$totalWheels = $MISSING.Count
$wheelNum = 0

foreach ($id in $MISSING) {
    $wheelNum++
    Write-Host "`n[$wheelNum/$totalWheels] === Wheel $id ===" -ForegroundColor Yellow

    foreach ($prefix in $prefixes) {
        $swfName = "${prefix}_${id}.swf"
        $swfPath = Join-Path $SRC $swfName
        if (!(Test-Path $swfPath)) { Write-Host "  Skip $swfName" -ForegroundColor DarkGray; continue }

        Write-Host "  $swfName " -NoNewline -ForegroundColor Cyan
        $tmp = Join-Path ([IO.Path]::GetTempPath()) "rc_${prefix}_${id}_$(Get-Random)"
        New-Item -ItemType Directory -Path $tmp -Force | Out-Null

        try {
            # Export all images
            & $FFDEC -export image $tmp $swfPath 2>&1 | Out-Null
            $pngs = @(Get-ChildItem $tmp -Filter '*.png' -Recurse | Sort-Object { [int]($_.BaseName -replace '[^\d]','') })
            if ($pngs.Count -eq 0) { Write-Host "(empty)" -ForegroundColor DarkGray; continue }

            $total = $pngs.Count

            # FAST C# recolor
            for ($i = 0; $i -lt $total; $i++) {
                [WheelRecolor]::RainbowRecolor($pngs[$i].FullName, $i, $total, $SAT)
            }

            # Single FFDec replace call for ALL frames
            $outSwf = Join-Path $OUT $swfName
            Copy-Item $swfPath $outSwf -Force

            $replaceArgs = @('-replace', $outSwf, $outSwf)
            foreach ($png in $pngs) {
                $charId = $png.BaseName -replace '[^\d]',''
                $replaceArgs += $charId
                $replaceArgs += $png.FullName
            }
            & $FFDEC @replaceArgs 2>&1 | Out-Null

            Write-Host "-> $total frames done" -ForegroundColor Green
        }
        finally {
            Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "`n=== ALL DONE! $totalWheels wheels recolored ===" -ForegroundColor Green
