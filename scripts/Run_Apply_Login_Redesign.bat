@echo off
setlocal
pushd "%~dp0.."
set "PYTHON=python"
set "BACKGROUND=assets\login\login_screen_bg.png"
if not exist "%BACKGROUND%" (
  echo Missing %BACKGROUND%
  echo Copy your full-screen PNG there first.
  popd
  exit /b 1
)
%PYTHON% scripts\ui_editor.py apply ^
  --swf source\main.swf ^
  --output patches\main_client\main.swf ^
  --layout ui_layout.json ^
  --background "%BACKGROUND%" ^
  --pad
if errorlevel 1 (
  echo.
  echo Login redesign was not written. If the rebuilt SWF is too large,
  echo use lower-quality assets or deploy it as a cache SWF instead.
  popd
  exit /b 1
)
echo.
echo Login redesign ready: patches\main_client\main.swf
popd
endlocal
