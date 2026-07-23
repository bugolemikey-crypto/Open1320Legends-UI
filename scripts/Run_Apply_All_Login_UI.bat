@echo off
setlocal
pushd "%~dp0.."
set "GAME_ROOT=C:\Users\hunte\Downloads\Open1320Legends"
set "BACKGROUND=assets\login\login_screen_bg.png"
if not exist "%BACKGROUND%" (
  echo Missing %BACKGROUND%
  popd
  exit /b 1
)
if not exist "%GAME_ROOT%\cache\misc\newuserform.swf" (
  echo Missing %GAME_ROOT%\cache\misc\newuserform.swf
  echo Edit GAME_ROOT in this batch file if the game is installed elsewhere.
  popd
  exit /b 1
)

echo [1/2] Editing embedded main.swf login layer...
python scripts\ui_editor.py apply ^
  --swf source\main.swf ^
  --output patches\main_client\main.swf ^
  --layout ui_layout.json ^
  --background "%BACKGROUND%" ^
  --pad
if errorlevel 1 goto :failed

echo [2/2] Editing cache newuserform.swf overlay...
python scripts\ui_editor.py apply ^
  --swf "%GAME_ROOT%\cache\misc\newuserform.swf" ^
  --output patches\login_form\newuserform.swf ^
  --layout login_form_layout.json
if errorlevel 1 goto :failed

echo.
echo Both login SWFs are ready in patches\.
popd
endlocal
exit /b 0

:failed
echo.
echo Login UI build failed; no deployment was performed.
popd
endlocal
exit /b 1
