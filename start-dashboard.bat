@echo off
REM Double-click this file to launch the nitto1320-log-sidecar dashboard.
REM Runs via cmd.exe, not PowerShell, so it isn't affected by PowerShell's
REM script execution policy.

cd /d "%~dp0"

if not exist "node_modules" (
  echo Installing dependencies for the first time - this only happens once...
  call npm install
  if errorlevel 1 (
    echo.
    echo npm install failed. See the error above.
    pause
    exit /b 1
  )
)

if not exist ".env" (
  copy ".env.example" ".env" >nul
  echo Created .env from .env.example - edit it and set SIDECAR_SSH_KEY before this will work.
  pause
  exit /b 1
)

node bin\nitto-log-sidecar.mjs dashboard
if errorlevel 1 (
  echo.
  echo nitto-log-sidecar exited with an error. See above.
  pause
)
