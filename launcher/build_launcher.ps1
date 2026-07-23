$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$compiler = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$hero = Join-Path $projectRoot 'assets\login\login_background_cars_v2.png'
$output = Join-Path $PSScriptRoot 'nitto-launcher.exe'
& $compiler /nologo /target:winexe /optimize+ /out:$output /resource:$hero,launcher.hero.png /reference:System.dll /reference:System.Drawing.dll /reference:System.Windows.Forms.dll (Join-Path $PSScriptRoot 'NittoLauncher.cs')
if ($LASTEXITCODE -ne 0) { throw "Launcher build failed: $LASTEXITCODE" }
Write-Output $output
